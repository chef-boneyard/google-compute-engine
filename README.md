# Google Compute Engine Cookbook LWRP

## Description

This cookbook provides libraries, resources and providers to configure
and manage Google Compute Engine components. The currently supported
GCE resources are:

 * disks (`disk`)
 * firewalls (`firewall`)
 * instances (`instance`)
 * lb forwarding rules (`lb_forwardingrule`)
 * lb health checks (`lb_healthcheck`)
 * lb target pools (`lb_targetpool`)
 * metadata (`metadata`)
 * networks (`network`)
 * snapshots (`snapshot`)
 * tags (`tags`)

## Requirements

Requires [fog](https://github.com/fog/fog) ruby gem to interact with GCP.

## Authorizing Setup

In order to use the Google Compute Engine cookbook with your servers, you will first 
need to authorize its use of the Google Compute Engine API. Authorization to use
any of Google's Cloud service API's utilizes an OAuth 2.0
[Service account](https://developers.google.com/accounts/docs/OAuth2#serviceaccount).
Once your project has been created, log in to the
[Google Developers Console](https://console.developers.google.com/project) and
select your project. Next select APIs & auth then Credentials. Create a new
"Client ID" and specify "Service account". This will generate a new public/private key
pair.

```ruby
    % knife data bag show gce service_account
    {
      "project_id": "my-gce-project",
      "client_email": "my-gce-project@developer.gserviceaccount.com",
      "key_location": "/home/user/.my-gce-project-private-key.p12"
    }
```

This can be loaded in a recipe with:

```ruby
    gce = data_bag_item("gce", "service_account")
```

And to access the values:

```ruby
    gce['project_id']
    gce['client_email']
    gce['key_location']
```

## Installation

Download and install as you would other cookbooks.

### From the Chef Community Site

knife cookbook site install gce

### Using Librarian-Chef

[Librarian-Chef](https://github.com/applicationsonline/librarian) Librarian is a framework
for writing bundlers, which are tools that resolve, fetch, install, and isolate a project's
dependencies, in Ruby.

To use the Opscode platform version:

```
    echo "cookbook 'gce'" >> Cheffile
    librarian-chef install
```

To use the Git version:

```
    echo "cookbook 'gce', :git => 'git@github.com:chef-partners/google-compute-engine.git'" >> Cheffile
    librarian-chef install
```

## Recipes

### default.rb

The default recipe installs the `fog` ruby gem, which this
cookbook requires in order to work with the GCE API. Make sure that
the `google-compute-engine` recipe is in the node or role `run_list` before any resources
from this cookbook are used.

```ruby
    "run_list": [
      "recipe[google-compute-engine]"
    ]
```

## Libraries

The cookbook has a library module, `Google::Gce`, which can be
included where necessary:

```ruby
  include Google::Gce
```

## Resources and Providers

This cookbook provides a resource and corresponding provider.

### disk.rb

Manage GCE persistent disk with this resource.

Actions:

* `create` - create a new disk.
* `delete` - delete a disk.
* `attach` - attach the specified disk.
* `detach` - detach the specified disk.

Attribute Parameters:

### firewall.rb

* `create` - create a new firewall.
* `delete` - delete a firewall.

### instance.rb

* `create` - create a new instance.
* `delete` - delete a instance.

### lb_forwardingrule.rb

* `create` - create a new forwarding rule.
* `delete` - delete a forwarding rule.

### lb_healthcheck.rb

* `create` - create a new healthcheck.
* `delete` - delete a healthcheck.

### lb_targetpool.rb

* `create` - create a new targetpool.
* `add_instance` - add instance to targetpool.
* `add_healthcheck` - add healthcheck to targetpool.
* `remove_instance` - remove instance from a targetpool.
* `remove_healthcheck` - remove healthcheck from a targetpool.
* `delete` - delete a targetpool.

### metadata.rb

* `set` - set instance metadata.
* `delete` - delete instance metadata.

### network.rb

* `create` - create a new network.
* `delete` - delete a network.

### snapshot.rb

* `create` - create a new snapshot.
* `delete` - delete a snapshot.

### tags.rb

* `set` - set instance tags.
* `delete` - delete instance tags.

## Usage

### instance

This will create a new instance.

```ruby
    gce_instance "my-gce-instance" do
      machine_type "n1-standard-1"
      zone_name "us-central1-a"
      boot_disk_image "debian-7-wheezy-v20140318"
      service_account_scopes ["compute", "userinfo.email", "devstorage.full_control"]
      auto_restart true
      on_host_maintenance "MIGRATE"
      action :create
    end
```

### firewall

This will create a new firewall.

```ruby
    gce_firewall "my-firewall" do
      client_email gce['client_email']
      key_location gce['key_location']
      project_id gce['project_id']
      description "my firewall"
      allowed [{"tcp"=>"1000"}, {"tcp"=>["1001","1002"]}, {"udp"=>"1000-1002"}, {"udp"=>["1010-1012"]}]
      source_tags ["foo", "bar"]
      target_tags ["baz", "qux"]
    end
```

This will delete an existing firewall.

```ruby
    gce_firewall "my-firewall" do
      client_email gce['client_email']
      key_location gce['key_location']
      project_id gce['project_id']
      action :delete
    end
```

License and Authors
===================

* Author:: Eric Johnson (<erjohnso@google.com>)
* Author:: Paul Rossman (<paulrossman@google.com>)

Copyright 2014, Google, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
