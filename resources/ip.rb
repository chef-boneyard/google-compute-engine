#
# Cookbook Name:: gce

# resources
attribute :name, :kind_of => [String], :default => nil
attribute :server, :kind_of => [String], :default => nil
attribute :region, :kind_of => [String], :default => nil
attribute :project_id, :kind_of => [String], :default => nil
attribute :client_email, :kind_of => [String], :default => nil
attribute :json_key, :kind_of => [String], :default => nil
attribute :timeout, :kind_of => [Integer], :default => 300

actions :assign