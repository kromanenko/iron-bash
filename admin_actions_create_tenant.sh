#! /bin/bash

# additional parameters 
# $1 IP address
# $2 MAC address

set -e
# source config_set_up_nodes
source /root/openrc

function tenant_create {
    keystone tenant-create \
	--name demo \
	--description "Demo Tenant"
}

function user_create {
    keystone user-create \
	--name demo \
	--tenant demo \
	--pass demo \
	--email demo@example.com
}

function create_demorc {
    cp /root/openrc /root/demorc
    sed -i 's/admin/demo/g' /root/demorc
}

tenant_create
user_create
create_demorc
