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

actions :create, :delete

# set 'wait_for true' to block on request                                       
attribute :wait_for,                :kind_of => [TrueClass, FalseClass], :default => false

# Google Compute Engine Credentials
attribute :client_email,            :kind_of => String, :required => true
attribute :key_location,            :kind_of => String, :required => true
attribute :project_id,              :kind_of => String, :required => true

attribute :name,                    :kind_of => String
attribute :description,             :kind_of => String
attribute :region,                  :kind_of => String
attribute :ip_address,              :kind_of => String
attribute :ip_protocol,             :kind_of => String, :default => "TCP", :equal_to => ["TCP", "UDP"]
attribute :port_range,              :kind_of => String
attribute :target_pool,             :kind_of => String
attribute :target_instance,         :kind_of => String

def initialize(*args)
  super
  @action = :create
end
