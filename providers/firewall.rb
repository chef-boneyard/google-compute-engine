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
    opts = {
      :name => new_resource.name
    }
    # allowed [{"tcp"=>"1"}, {"tcp"=>["2","3"]}, {"udp"=>"2-3"}, {"icmp"=>["2"]}]
    # allowed = [{"IPProtocol"=>"tcp", "ports"=>["80", "443"]},
    #            {"IPProtocol"=>"tcp", "ports"=>["1-65535"]},
    #            {"IPProtocol"=>"udp", "ports"=>["1-65535"]},
    #            {"IPProtocol"=>"icmp", "ports"=>["100"]}]
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
    # source_ranges = ["0.0.0.0/0"]
    opts[:source_ranges] = new_resource.source_ranges
    opts[:source_tags] = new_resource.source_tags if new_resource.source_tags
    opts[:target_tags] = new_resource.target_tags if new_resource.target_tags
    firewall = gce.firewalls.new(opts)
    firewall.save
  rescue => e
    Chef::Log.info("Error creating #{new_resource.name} firewall")
    Chef::Log.debug(e)
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
