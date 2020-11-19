#!/usr/bin/env bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-nomad script to configure and start
# Nomad in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -euo pipefail

# Avoid Terraform template by either using double dollar signs, or not using curly braces
readonly service_type="nomad_server"
readonly marker_path="/etc/user-data-marker"

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Configure and run Consul
/opt/consul/bin/run-consul \
    --client \
    --cluster-tag-key "${cluster_tag_key}" \
    --cluster-tag-value "${cluster_tag_value}"

# Post startup Configuration
/opt/consul/bin/post-configure \
    --client \
    --initialisation-marker-path "$marker_path" \
    --consul-prefix "${consul_prefix}"

# Configure and run consul-template
/opt/consul-template/bin/run-consul-template \
    --server-type nomad_server \
    --dedup-enable \
    --syslog-enable \
    --consul-prefix "${consul_prefix}"

# Additional Configuration
/opt/nomad/bin/configure \
    --server \
    --consul-prefix "${consul_prefix}"

/opt/nomad/bin/run-nomad --server --num-servers "${num_servers}"

/opt/vault-ssh \
    --consul-prefix "${consul_prefix}" \
    --type "$service_type"

/opt/run-td-agent \
    --consul-prefix "${consul_prefix}" \
    --type "$service_type"

/opt/run-telegraf \
    --consul-prefix "${consul_prefix}" \
    --type "$service_type"

# Touch the marker file to indicate completion
touch "$marker_path"
