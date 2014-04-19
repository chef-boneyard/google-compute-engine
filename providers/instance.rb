# Copyright 2014 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include Google::Gce

action :create do
  # Before we do anything, make sure we're not going to stomp on the
  # user's 'startup-script' metadata
  if new_resource.metadata and
      new_resource.metadata.has_key?("startup-script") and
      !new_resource.override_startup_script
    raise "Metadata 'startup-script' collision, use attribute 'override_startup_script' to force using your specified script."
  end

  # If no disk source / name specified, assume they want an existing disk
  # matching the instance name
  if !new_resource.boot_disk_name and !new_resource.boot_disk_image and !new_resource.boot_disk_snapshot
    new_resource.boot_disk_name = new_resource.name
  end
  if new_resource.boot_disk_name
    boot_disk = gce.disks.get(new_resource.boot_disk_name)
    if boot_disk.nil?
      raise "Disk #{new_resource.boot_disk_name} not found"
    end
    Chef::Log.info("Using existing boot_disk #{new_resource.boot_disk_name}")
  else
    # user wants to create a new disk, so they need a data source
    if !new_resource.boot_disk_image and !new_resource.boot_disk_snapshot
      raise "Must specify image name or snapshot name"
    end
    opts = {
      :name => new_resource.name,
      :zone_name => new_resource.zone_name,
    }
    opts[:size_gb] = new_resource.boot_disk_size_gb || 10
    if new_resource.boot_disk_image
      opts[:description] = "Created with image #{new_resource.boot_disk_image}"
      opts[:source_image] = new_resource.boot_disk_image
    else
      opts[:description] = "Created with snapshot #{new_resource.boot_disk_snapshot}"
      opts[:source_snapshot] = new_resource.boot_disk_snapshot
    end
    boot_disk = gce.disks.create(opts)
    boot_disk.wait_for { ready? }
    boot_disk.reload
    Chef::Log.info("Using boot_disk #{new_resource.name}")
  end

  # create instance and use boot_disk
  opts = {
    :name => new_resource.name,
    :zone_name => new_resource.zone_name,
    :machine_type => new_resource.machine_type,
    :disks => [boot_disk],
  }
  opts[:tags] = new_resource.tags if new_resource.tags
  opts[:metadata] = new_resource.metadata if new_resource.metadata
  opts[:service_accounts] = new_resource.service_account_scopes if
        new_resource.service_account_scopes
  opts[:external_ip] = new_resource.external_ip if new_resource.external_ip
  opts[:network] = new_resource.network_name if new_resource.network_name
  opts[:auto_restart] = (new_resource.auto_restart.respond_to?("downcase") &&
        ["yes", "y", "true"].include?(new_resource.auto_restart.downcase))
  opts[:on_host_maintenance] = new_resource.on_host_maintenance if
        new_resource.on_host_maintenance

  # Bootstrap attributes
  if new_resource.first_boot_json
    if !opts.has_key?(:metadata)
      opts[:metadata] = Hash.new
    end
    opts[:metadata]["first-boot-json"] = open(new_resource.first_boot_json) {|io| io.read}
  end
  if new_resource.client_rb
    if !opts.has_key?(:metadata)
      opts[:metadata] = Hash.new
    end
    opts[:metadata]["client-rb"] = open(new_resource.client_rb) {|io| io.read}
  end
  if new_resource.validation_pem
    if !opts.has_key?(:metadata)
      opts[:metadata] = Hash.new
    end
    opts[:metadata]["validation-pem"] = open(new_resource.validation_pem) {|io| io.read}
  end
  if new_resource.first_boot_json or new_resource.client_rb or
      new_resource.validation_pem
    if new_resource.bootstrap_script
      opts[:metadata]["startup-script"] = open(new_resource.bootstrap_script) {|io| io.read}
    else
      opts[:metadata]["startup-script"] = "#{$bootstrap_script}"
    end
  end

  instance = gce.servers.create(opts)
  if new_resource.wait_for
    instance.wait_for { ready? }
  end

  Chef::Log.info("Created instance #{new_resource.name} in zone #{new_resource.zone_name}")
end

action :delete do
  if !new_resource.zone_name
    raise "Missing required zone_name"
  end
  begin
    server = gce.servers.get(new_resource.name, new_resource.zone_name)
    server.destroy if !server.nil?
  rescue Fog::Errors::NotFound
  end
  Chef::Log.info("Destroyed instance #{new_resource.name} in zone #{new_resource.zone_name}")
  Chef::Log.warn("Disks attached to instance #{new_resource.name} were *not* destroyed")
  # Mimic config[:purge] from knife google gem lib/chef/knife/google_server_delete.rb
  Chef::Log.info("Attempting to purge instance #{new_resource.name} from Chef server")
  begin
    node = Chef::Node.load(new_resource.name)
    node.destroy
  rescue Net::HTTPServerException
    Chef::Log.info("Possible error purging Chef::Node #{new_resource.name}")
  end
  begin
    apiclient = Chef::ApiClient.load(new_resource.name)
    apiclient.destroy
  rescue Net::HTTPServerException
    Chef::Log.info("Possible error purging Chef::ApiClient #{new_resource.name}")
  end
  Chef::Log.info("Delete instance #{new_resource.name} complete")
end

private

# This script is intended to be executed as a 'startup-script' on a new
# Compute Engine instance to bootstrap it as a Chef node. Assuming the user
# wants the instance bootstrapped as a Chef client, when they set the
# appropriate attributes, custom metadata attributes are set for the instance
# The actual schell script is defined as a ruby heredoc in order to make
# it easily accessible to the :create action above.
$bootstrap_script = <<-END_BOOTSTRAP
#!/bin/bash
# Make sure the Ohai hints are set to properly identify the node as a
# Compute Engine instance
mkdir -p /etc/chef/ohai/hints
echo "{}" > /etc/chef/ohai/hints/gce.json
echo "{}" > /etc/chef/ohai/hints/google.json

# get metadata values and write to disk
firstboot=$(curl -L "http://metadata/computeMetadata/v1/instance/attributes/first-boot-json" -H "X-Google-Metadata-Request: True")
if [ -n "$firstboot" ]; then
  echo "$firstboot" > /etc/chef/first-boot.json
fi

clientrb=$(curl -L "http://metadata/computeMetadata/v1/instance/attributes/client-rb" -H "X-Google-Metadata-Request: True")
me=$(hostname -s)
if [ -n "$clientrb" ]; then
  echo "$clientrb" > /etc/chef/client.rb
  echo "node_name                '$me'" >> /etc/chef/client.rb
fi

validationpem=$(curl -L "http://metadata/computeMetadata/v1/instance/attributes/validation-pem" -H "X-Google-Metadata-Request: True")
if [ -n "$validationpem" ]; then
  echo "$validationpem" > /etc/chef/validation.pem
fi

curl -L "https://www.opscode.com/chef/install.sh" | bash

if [ -f /etc/chef/first-boot.json ]; then
  chef-client -j /etc/chef/first-boot.json
fi

exit 0
END_BOOTSTRAP
