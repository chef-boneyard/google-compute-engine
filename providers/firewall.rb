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

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  begin
    Chef::Log.debug("Attempting to create firewall #{new_resource.name}")
    opts = {
      :name => new_resource.name
    }
    allowed = []
    new_resource.allowed.each do |a|
      a.each do |k,v|
        if v.kind_of?(Array)
          p = v.flatten
        else
          p = ["#{v}"]
        end
        allowed << {"IPProtocol"=>"#{k}", "ports"=>p}
      end
    end
    opts[:allowed] = allowed
    opts[:description] = new_resource.description if new_resource.description
    # network needs to be a self link
    network = gce.networks.get(new_resource.network)
    opts[:network] = network.self_link
    opts[:source_ranges] = new_resource.source_ranges
    opts[:source_tags] = new_resource.source_tags if new_resource.source_tags
    opts[:target_tags] = new_resource.target_tags if new_resource.target_tags
    converge_by("create firewall #{new_resource.name}") do
      firewall = gce.firewalls.new(opts)
      firewall.save
    end
    Chef::Log.debug("Completed creating firewall #{new_resource.name}")
  rescue => e
    Chef::Log.debug(e.message)
    raise if e.message.scan(/already exists$/).join && new_resource.ignore_exists == false
  end
end

action :delete do
  Chef::Log.debug("Attempting to delete firewall #{new_resource.name}")
  begin
    # returns nil if firewall does not exist
    firewall = gce.firewalls.get(new_resource.name)
    if new_resource.wait_for
      Chef::Log.debug("Waiting for firewall #{new_resource.name} to be deleted")
    end
    converge_by("delete firewall #{new_resource.name}") do
      # async is !wait_for
      firewall.destroy(async=!new_resource.wait_for)
    end
    Chef::Log.debug("Completed deleting firewall #{new_resource.name}")
  rescue
    Chef::Log.debug("Firewall #{new_resource.name} not found, nothing to delete")
  end
end
