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


package gcp.sqladmin.instances.policy.acl

#####
# Resource metadata
#####

labels = input.settings.userLabels

#####
# Policy evaluation
#####

default valid=true


valid = false {
  # Check for bad acl
  input.settings.ipConfiguration.authorizedNetworks[_].value == "0.0.0.0/0"

  # Sometimes the sqladmin doesn't include labels (which means no matching labels)
  not labels
} else = false {
  # Check for bad acl
  input.settings.ipConfiguration.authorizedNetworks[_].value == "0.0.0.0/0"

  # Also, this must be false
  not data.exclusions.label_exclude(labels)
}



#####
# Remediation
#####

# Copy the input object, omitting the settings key
remediate[key] = value {
 key != "settings"
 input[key]=value
}

# Add the settings key, as defined below
remediate[key] = value {
 key := "settings"
 value := _settings
}

# Copy the settings key, minus the ipConfiguration key
_settings[key]=value{
  key != "ipConfiguration"
  input.settings[key]=value
}

# Add the ipConfiguration key, as defined below
_settings[key]=value{
  key := "ipConfiguration"
  value := _ipConfiguration
}

# Copy the ipConfiguration key, minus the authorizedNetworks key
_ipConfiguration[key]=value{
  key != "authorizedNetworks"
  input.settings.ipConfiguration[key]=value
}

# Add the authorizedNetworks key, as defined below
_ipConfiguration[key]=value{
  key := "authorizedNetworks"
  value := valid_authorized_networks
}

# Remove any invalid authorized networks
valid_authorized_networks = [net | net := input.settings.ipConfiguration.authorizedNetworks[_]
  net.value != "0.0.0.0/0"
]
