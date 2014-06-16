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
  begin
    Chef::Log.debug("Attempting to insert firewall #{new_resource.name}")
    allowed = create_allowed(new_resource.allowed_protocol, new_resource.allowed_ports)
    opts = {}
    opts[:source_ranges] = new_resource.source_ranges if new_resource.source_ranges
    opts[:source_tags] = new_resource.source_tags if new_resource.source_tags
    opts[:target_tags] = new_resource.target_tags if new_resource.target_tags

    gce.insert_firewall(
      new_resource.name,
      allowed,
      new_resource.network,
      opts)
    Timeout::timeout(new_resource.timeout) do
      while true
        if firewall_ready?(gce, new_resource.name)
          Chef::Log.info("Completed firewall #{new_resource.name} insert")
          break
        else
          Chef::Log.info("Waiting for firewall #{new_resource.name} to be inserted")
          sleep 1
        end  
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for firewall insert after #{new_resource.timeout} seconds"
  end
end

action :delete do
  begin
    Chef::Log.debug("Attempting to delete firewall #{new_resource.name}")
    begin
      gce.delete_firewall(new_resource.name)
    rescue Fog::Errors::NotFound
    end
    Timeout::timeout(new_resource.timeout) do
      while true
        if firewall_ready?(gce, new_resource.name)
          Chef::Log.info("Waiting for firewall #{new_resource.name} to be deleted")
          sleep 1
        else
          Chef::Log.info("Completed firewall #{new_resource.name} delete")
          break
        end  
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for firewall insert after #{new_resource.timeout} seconds"
  end
end

private

def create_allowed(protocol, ports)
  allowed = [{"IPProtocol" => protocol, "ports" => ports}]
end

def firewall_ready?(connection, name)
  connection.get_firewall(name)
  true
rescue Fog::Errors::NotFound
  false
end
