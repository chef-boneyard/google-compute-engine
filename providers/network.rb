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
    Chef::Log.debug("Attempting to insert network #{new_resource.name}")
    gce.insert_network(new_resource.name, new_resource.ip_range)
    Timeout::timeout(new_resource.timeout) do
      while true
        if network_ready?(gce, new_resource.name)
          Chef::Log.info("Completed network #{new_resource.name} insert")
          break
        else
          Chef::Log.info("Waiting for network #{new_resource.name} to be inserted")
          sleep 1
        end  
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for network insert after #{new_resource.timeout} seconds"
  end
end

action :delete do
  begin
    Chef::Log.debug("Attempting to delete network #{new_resource.name}")
    gce.delete_network(new_resource.name)
    Timeout::timeout(new_resource.timeout) do
      while true
        if network_ready?(gce, new_resource.name)
          Chef::Log.info("Waiting for network #{new_resource.name} to be deleted")
          sleep 1
        else
          Chef::Log.info("Completed network #{new_resource.name} delete")
          break
        end  
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for network insert after #{new_resource.timeout} seconds"
  end
end

private

def network_ready?(connection, name)
  connection.get_network(name)
  true
rescue Fog::Errors::NotFound
  false
end
