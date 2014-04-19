include Google::Gce

# TODO(paulrossman): fix
action :create do
  servers = []
  healthchecks = []
  new_resource.instances.each do |i|
    servers << gce.servers.get(i).self_link
  end
  new_resource.health_checks.each do |i|
    healthchecks << gce.http_health_checks.get(i).self_link
  end
  opts = {
    :name => new_resource.name,
    :region => new_resource.region,
    :instances => servers
  }
  opts[:description] = new_resource.description if new_resource.description
  opts[:health_checks] = healthchecks if new_resource.health_checks
  opts[:session_affinity] = new_resource.session_affinity if new_resource.session_affinity
  opts[:failover_ratio] = new_resource.failover_ratio if new_resource.failover_ratio
  opts[:backup_pool] = gce.http_health_checks.get(new_resource.backup_pool).self_link if new_resource.backup_pool
  tp = gce.target_pools.create(opts)
  if new_resource.wait_for
    tp.wait_for { ready? }
  end
  Chef::Log.info("Created target pool #{new_resource.name}")
end

action :add_instance do
  tp = gce.target_pools.get(new_resource.name, new_resource.region)
  tp.add_instance(gce.servers.get(new_resource.instance_name))
  Chef::Log.info("Added instance #{new_resource.instance_name} to target pool #{new_resource.name}")
end

action :add_healthcheck do
  tp = gce.target_pools.get(new_resource.name, new_resource.region)
  tp.add_health_check(gce.http_health_checks.get(new_resource.healthcheck_name))
  Chef::Log.info("Added healthcheck #{new_resource.healthcheck_name} to target pool #{new_resource.name}")
end

action :remove_instance do
  tp = gce.target_pools.get(new_resource.name, new_resource.region)
  tp.remove_instance(gce.servers.get(new_resource.instance_name))
  Chef::Log.info("Removed instance #{new_resource.instance_name} to target pool #{new_resource.name}")
end

action :remove_healthcheck do
  tp = gce.target_pools.get(new_resource.name, new_resource.region)
  tp.remove_health_check(gce.http_health_checks.get(new_resource.healthcheck_name))
  Chef::Log.info("Removed healthcheck #{new_resource.healthcheck_name} to target pool #{new_resource.name}")
end

action :delete do
  begin
    tp = gce.target_pools.get(new_resource.name, new_resource.region)
    tp.destroy
  rescue Fog::Errors::NotFound
  end
  Chef::Log.info("Deleted target pool #{new_resource.name}")
end

