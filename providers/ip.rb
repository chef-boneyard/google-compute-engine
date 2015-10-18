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
      raise "Unable to find server #{new_resource.server}" if server.nil?
      raise "Unable to find address #{new_resource.name}" if address.nil?
      
      options={
        :name=>"External NAT", 
        :address=>address.address
      } #options for adding access config
  
      if  server.network_interfaces[0].has_key?("accessConfigs") && 
          server.network_interfaces[0]["accessConfigs"][0]["natIP"] == address.address
        Chef::Log.info "Server #{server.name} already has Static IP #{address.address}"
        
      else
   
      
        if server.network_interfaces[0].has_key?("accessConfigs")
          Chef::Log.info "Deleting access_config for 'nic0'"
          access_config =  server.network_interfaces[0]["accessConfigs"][0]["name"]
          delete_options={
            access_config: access_config
          }
          gce.delete_server_access_config(server.name,server.zone,'nic0',delete_options)

        end
       
        while (server.network_interfaces[0].has_key?("accessConfigs"))
          Chef::Log.info 'Waiting for access_config to delete'
          Chef::Log.debug "server.network_interfaces[0]: #{server.network_interfaces[0]}"
          sleep 20
          server = server.reload
        end

        gce.add_server_access_config(server.name,server.zone,'nic0',options)
        Chef::Log.debug "Added server access_config"
        sleep 30
        server = server.reload
      
  
        while !server.network_interfaces[0].has_key?("accessConfigs")
          Chef::Log.info "Waiting for access_config to be added"
          sleep 10
          server = server.reload
        end
      end
    end
  rescue Timeout::Error
    raise "Timeout waiting to assign static IP after #{new_resource.timeout} seconds"
  end
end
