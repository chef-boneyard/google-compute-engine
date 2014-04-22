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

actions :create, :delete,
        :add_instance, :remove_instance,
        :add_healthcheck, :remove_healthcheck

# set 'wait_for true' to block on request                                       
attribute :wait_for,                :kind_of => [TrueClass, FalseClass], :default => false

# Google Compute Engine Credentials
attribute :client_email,            :kind_of => String, :required => true
attribute :key_location,            :kind_of => String, :required => true
attribute :project_id,              :kind_of => String, :required => true

attribute :name,                    :kind_of => String
attribute :description,             :kind_of => String
attribute :region,                  :kind_of => String
attribute :health_checks,           :kind_of => Array
attribute :instances,               :kind_of => Array
attribute :session_affinity,        :kind_of => String
attribute :failover_ratio,          :kind_of => Float
attribute :backup_pool,             :kind_of => String
# Use these attribute for :add/remove resources
attribute :instance_name,           :kind_of => String
attribute :healthcheck_name,        :kind_of => String

def initialize(*args)
  super
  @action = :create
end
