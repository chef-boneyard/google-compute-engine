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

action :set do
  gce.set_tags(new_resource.name, new_resource.zone_name, new_resource.tags)
  Chef::Log.info ("Applied tags to instance #{new_resource.name}")
end

action :delete do
  gce.set_tags(new_resource.name, new_resource.zone_name)
  Chef::Log.info ("Removed tags from instance #{new_resource.name}")
end
