include Google::Gce
action :assign do
  begin
    raise "Missing Instance ID attribute" unless new_resource.server
    raise "Missing IP Name attribute" unless new_resource.name
    raise "Missing project attribute" unless new_resource.project_id
    raise "Missing client email attribute" unless new_resource.client_email
    raise "Missing json key attribute" unless new_resource.json_key

    
    # see Fog/Compute/Google/Real
    # http://www.rubydoc.info/github/fog/fog/Fog/Compute/Google/Real#add_server_access_config-instance_method
    # http://www.rubydoc.info/github/fog/fog/Fog/Compute/Google/Real#delete_server_access_config-instance_method
    Chef::Log.info ("Attempting to replace static ip. ")
        
    Timeout::timeout(new_resource.timeout) do
      server = gce.servers.get(new_resource.server)
      address = gce.addresses.get(new_resource.name,new_resource.region)
 
      options={
        :name=>"External NAT", 
        :address=>address.address
      } #options for adding access config
  
      if server.network_interfaces[0].has_key?("accessConfigs")
        Chef::Log.info "Deleting access_config for 'nic0'"
        gce.delete_server_access_config(server.name,server.zone,'nic0')

      end
       
      while (server.network_interfaces[0].has_key?("accessConfigs"))
        Chef::Log.info 'Waiting for access_config to delete'
        sleep 20
        server.reload
      end

      gce.add_server_access_config(server.name,server.zone,'nic0',options)
      sleep 30 # wait for service to update
      server = server.reload

      while (server.network_interfaces[0].has_key?("accessConfigs") and 
            server.network_interfaces[0]["accessConfigs"][0]["natIP"]!= address.address)
        Chef::Log.info "Waiting for  IP '#{static_ip}' to be added"
        sleep 20
        server.reload
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting to assign static IP after #{new_resource.timeout} seconds"
  end
end
