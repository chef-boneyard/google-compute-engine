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

apt_package 'build-essential' do
end.run_action(:install)

apt_package 'patch' do
end.run_action(:install)

apt_package 'ruby-dev' do
end.run_action(:install)

apt_package 'zlib1g-dev' do
end.run_action(:install)

apt_package 'liblzma-dev' do
end.run_action(:install)

chef_gem 'fog' do
  version node['gce']['fog_version']
  compile_time true
end

chef_gem 'google-api-client' do
  version node['gce']['google-api-client_version']
  compile_time true
end

chef_gem 'fog-google' do
  compile_time true
end

chef_gem 'uuidtools'
chef_gem 'multi_json'

require 'fog'