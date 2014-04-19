include Google::Gce

action :create do
  opts = {
    :name => new_resource.name,
    :region => new_resource.region,
    :target => gce.target_pools.get(new_resource.target_pool).self_link
  }
  opts[:description] = new_resource.description if new_resource.description
  opts[:ip_protocol] = new_resource.ip_protocol.upcase if new_resource.ip_protocol
  opts[:ip_address] = new_resource.ip_address if new_resource.ip_address
  opts[:port_range] = new_resource.port_range if new_resource.port_range
  fwr = gce.forwarding_rules.create(opts)
  if new_resource.wait_for
    fwr.wait_for { ready? }
  end
  Chef::Log.info("Created forwarding rule #{new_resource.name}")
end

action :delete do
  begin
    fwr = gce.forwarding_rules.get(new_resource.name, new_resource.region)
    fwr.destroy
  rescue Fog::Errors::NotFound
  end
  Chef::Log.info("Deleted forwarding rule #{new_resource.name}")
end

