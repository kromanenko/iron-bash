#! /bin/bash

set -e
# source config_set_up_nodes
source /root/demo_openrc

function get_ubuntu_image {
	curl https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64.tar.gz | tar -xzp
}

function virtual_img_create {
	glance \
        	--os-image-api-version 1 \
		image-create \
			--name virtual_trusty_ext4_demo \
			--disk-format raw \
			--container-format bare \
			--file trusty-server-cloudimg-amd64.img \
			--is-public True \
			--progress \
			--property cpu_arch='x86_64' \
			--property hypervisor_type='baremetal' \
			--property mos_disk_info='[{"name": "vda", "extra": [], "free_space": 11000, "type": "disk", "id": "vda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}

function key_create {
	nova keypair-add ironic_demo_key > ironic_demo_key.pem
	chmod 600 ironic_demo_key.pem
}

function get_net_id {
	net_id=$(nova net-list \
		| grep baremetal \
		| awk {'print $2'})	
}

virtual_img_create
key_create

get_net_id
