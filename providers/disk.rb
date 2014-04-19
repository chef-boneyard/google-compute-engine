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
  opts = {
    :name => new_resource.name,
    :zone_name => new_resource.zone_name
  }
  opts[:device_name] = new_resource.device_name || new_resource.name
  opts[:size_gb] = new_resource.size_gb || 10
  if new_resource.source_snapshot
    opts[:source_snapshot] = new_resource.source_snapshot
    opts[:description] = new_resource.description || "Created with snapshot: #{new_resource.source_snapshot}"
  end
  if new_resource.source_image
    opts[:source_image] = new_resource.source_image
    opts[:description] = new_resource.description || "Created with image: #{new_resource.source_image}"
  end
  opts[:boot] = new_resource.boot if new_resource.boot
  opts[:mode] = new_resource.mode if new_resource.mode
  opts[:type] = new_resource.type if new_resource.type

  disk = gce.disks.create(opts)
  if new_resource.wait_for
    disk.wait_for { disk.ready? }
  end
end

action :delete do
  # if disk is not found, that should be OK since user wants it gone anyway
  begin
    disk = gce.disks.get(new_resource.name)
    disk.destroy
  rescue Fog::Errors::NotFound
    Chef::Log.debug("Disk #{new_resource.name} not found, nothing to delete")
  end
  # TODO unregister from chef node if attached
end

#action :attach do
#  begin
#  rescue Fog::Errors::NotFound
#  end
#end

#action :detach do
#  begin
#  rescue Fog::Errors::NotFound
#  end
#end

