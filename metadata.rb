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

name              "gce"
maintainer        "Google Inc."
maintainer_email  "paulrossman@google.com"
license           "Apache 2.0"
description       "LWRPs for managing GCE resources"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.3.0"
recipe            "gce", "Installs the fog gem and other dependencies"
