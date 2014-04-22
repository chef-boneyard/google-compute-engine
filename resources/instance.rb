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
attribute :zone_name,               :kind_of => String, :default => "us-central1-a"
attribute :machine_type,            :kind_of => String, :default => "n1-standard-1"
attribute :tags,                    :kind_of => Array
attribute :external_ip,             :kind_of => String
attribute :network_name,            :kind_of => String, :default => "default"
attribute :metadata,                :kind_of => Hash
attribute :service_account_scopes,  :kind_of => Array
attribute :auto_restart,            :kind_of => [TrueClass, FalseClass]
attribute :on_host_maintenance,     :kind_of => String, :default => "MIGRATE", :equal_to => ["MIGRATE", "TERMINATE"]
# if user sets boot_disk_name, they intend to use existing disk as boot device
attribute :boot_disk_name,          :kind_of => String
# attributes needed if user wants to create a disk and instance in one shot
attribute :boot_disk_image,         :kind_of => String, :default => "debian-7-wheezy-v20140318"
attribute :boot_disk_snapshot,      :kind_of => String
attribute :boot_disk_size_gb,       :kind_of => Integer, :default => 10
# unattended bootstrap attributes (required client.rb parameters)
attribute :first_boot_json,         :kind_of => String # e.g. "/etc/chef-server/first-boot.json"
attribute :client_rb,               :kind_of => String # e.g. "/etc/chef-server/client.rb"
attribute :validation_pem,          :kind_of => String # e.g. "/etc/chef-server/chef-validator.pem"
attribute :bootstrap_script,        :kind_of => String
attribute :override_startup_script, :kind_of => String

def initialize(*args)
  super
  @action = :create
end
