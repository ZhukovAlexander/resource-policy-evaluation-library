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


package gcp.dataproc.projects.regions.clusters.policy.is_cluster_too_old

#####
# Resource metadata
#####

labels = input.labels

#####
# Policy evaluation
#####

default valid = false

# Max age for cluster in nanoseconds is configured in policy/config.yaml - dataproc:cluster_max_age_ns
# by default is equel to 60 days (5184000000000000 ns)

# Check if cluster was created earlier than cluster_max_age_ns
valid = true {
    creationTime := [ creationTime | input.statusHistory[i].state == "CREATING"; creationTime := input.statusHistory[i].stateStartTime ]
    time.now_ns() - time.parse_rfc3339_ns(creationTime[0]) < data.config.dataproc.cluster_max_age_ns
}

valid = true {
    #Check creation date if cluster is in CREATING state now (in case of network or other issues it can be hanging for a long time)
    creationTime := [ creationTime | input.status.state == "CREATING"; creationTime := input.status.stateStartTime ]
    time.now_ns() - time.parse_rfc3339_ns(creationTime[0]) < data.config.dataproc.cluster_max_age_ns
}

valid = true {
  # Also, make sure this resource isn't excluded by label
  data.exclusions.label_exclude(labels)
}

#####
# Remediation
#####

# Since we cannot remediate it, if policy fails lets end it with "No possible remediation"
remediate[key] = value {
  false
  input[key]=value
}
