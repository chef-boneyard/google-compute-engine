include Google::Gce

action :create do
  opts = {
    :name => new_resource.name
  }
  opts[:description] = new_resource.description if new_resource.description
  opts[:host] = new_resource.host if new_resource.host
  opts[:port] = new_resource.port if new_resource.port
  opts[:request_path] = new_resource.request_path if new_resource.request_path
  opts[:check_interval_sec] = new_resource.check_interval_sec if new_resource.check_interval_sec
  opts[:timeout_sec] = new_resource.timeout_sec if new_resource.timeout_sec
  opts[:unhealthy_threshold] = new_resource.unhealthy_threshold if new_resource.unhealthy_threshold
  opts[:healthy_threshold] = new_resource.healthy_threshold if new_resource.healthy_threshold
  hc = gce.http_health_checks.create(opts)
  if new_resource.wait_for
    hc.wait_for { ready? }
  end
  Chef::Log.info("Created HTTP health check #{new_resource.name}")
end

action :delete do
  begin
    hc = gce.http_health_checks.get(new_resource.name)
    hc.destroy
  rescue Fog::Errors::NotFound
  end
  Chef::Log.info("Deleted HTTP health check #{new_resource.name}")
end

