# Copyright 2019 The resource-policy-evaluation-library Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


package gcp.compute.firewalls.policy.logs_enabled

#####
# Resource metadata
#####

labels = input.labels

#####
# Policy evaluation
#####

default valid = false

# Check if Logging is enabled
valid = true {
  input.logConfig.enable = true
}

# Check if firewall is disabled
valid = true {
  input.disabled
}

#####
# Remediation
#####

# Make a copy of the input, omitting the versioning field
remediate[key] = value {
  key != "logConfig"
  input[key]=value
}

# Set the versioning field such that the bucket adheres to the policy
remediate[key] = value {
  key:="logConfig"
  value:={"enable":true}
}
