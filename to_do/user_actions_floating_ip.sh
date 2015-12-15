#! /bin/bash

set -e
# source config_set_up_nodes
source /root/demorc

function floating_ip_pool_list {
    nova floating-ip-pool-list
}

function floating_ip_create {
    nova floating-ip-create
}

function get_kernel_image_id {
	kernel_id=$(glance \
        --os-image-api-version 1 \
		image-list \
		| grep "ironic-deploy-linux" \
		| awk {'print $2'})
}
