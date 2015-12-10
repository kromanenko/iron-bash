#! /bin/bash

set -e
source config_set_up_nodes
source /root/openrc

function virt_flavor_create {
	nova flavor-create bm_flavor auto 3072 150 2
}

function bare_flavor_create {
	nova flavor-create metall_bm_flavor auto 16384 1024 8
}

function get_image {
	curl https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64.tar.gz | tar -xzp
}

function bare_img_create {
	glance \
        --os-image-api-version 1 \
		image-create \
			--name baremetal_trusty_ext4 \
			--disk-format raw \
			--container-format bare \
			--file trusty-server-cloudimg-amd64.img \
			--is-public True \
			--progress \
			--property cpu_arch='x86_64' \
			--property hypervisor_type='baremetal' \
			--property mos_disk_info='[{"name": "sda", "extra": [], "free_space": 11000, "type": "disk", "id": "sda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}

function virtual_img_create {
	glance \
        --os-image-api-version 1 \
		image-create \
			--name virtual_trusty_ext4 \
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
	nova keypair-add ironic_key > ironic_key.pem
	chmod 600 ironic_key.pem
}

function get_kernel_image_id {
	kernel_id=$(glance \
		--os-auth-url http://127.0.0.1:35357/v3 \
		--os-username admin \
		--os-password admin \
		--os-project-name admin \
		--os-user-domain-name default \
		--os-project-domain-name default \
		image-list \
		| grep "ironic-deploy-linux" \
		| awk {'print $2'})
}

function get_ramdisk_image_id {
	ramdisk_id=$(glance \
		--os-auth-url http://127.0.0.1:35357/v3 \
		--os-username admin \
		--os-password admin \
		--os-project-name admin \
		--os-user-domain-name default \
		--os-project-domain-name default \
		image-list \
		| grep "ironic-deploy-initramfs" \
		| awk {'print $2'})
}

function get_squashfs_image_id {
	hfs_id=$(glance \
		--os-auth-url http://127.0.0.1:35357/v3 \
		--os-username admin \
		--os-password admin \
		--os-project-name admin \
		--os-user-domain-name default \
		--os-project-domain-name default \
		image-list \
		| grep "ironic-deploy-squashfs" \
		| awk {'print $2'})
}

function virtual_node_create {
	ironic node-create \
		-n virtual \
		-d fuel_ssh \
		-i deploy_kernel=$kernel_id \
		-i deploy_ramdisk=$ramdisk_id \
		-i deploy_squashfs=$hfs_id \
		-i ssh_address=172.16.165.49 \
		-i ssh_password=ironic_password \
		-i ssh_username=ironic \
		-i ssh_virt_type=virsh \
		-p cpus=2 \
		-p memory_mb=3072 \
		-p local_gb=150 \
		-p cpu_arch=x86_64
}

function bare_node_create {
	ironic node-create \
		-n bare \
		-d fuel_ipmitool \
		-i deploy_kernel=$kernel_id \
		-i deploy_ramdisk=$ramdisk_id \
		-i deploy_squashfs=$hfs_id \
		-i ipmi_address=$ipmi_address \
		-i ipmi_password=$ipmi_password \
		-i ipmi_username=$ipmi_username \
		-p cpus=8 \
		-p memory_mb=16384 \
		-p local_gb=1024 \
		-p cpu_arch=x86_64
}

function get_net_id {
	net_id=$(nova net-list \
		| grep baremetal \
		| awk {'print $2'})	
}

function get_virtual_node_id {
	virtual_node_id=$(ironic node-list \
			| grep virtual \
			| awk {'print $2'})
}

function get_bare_node_id {
	bare_node_id=$(ironic node-list \
			| grep bare \
			| awk {'print $2'})
}

function virtual_port_create {
	ironic port-create \
		-n $virtual_node_id \
		-a $virt_node01_mac
}


function bare_port_create {
	ironic port-create \
		-n $bare_node_id \
		-a $bare_node_mac
}

function boot_bare_image {
	nova boot \
		--flavor metall_bm_flavor \
		--image baremetal_trusty_ext4 \
		--key-name ironic_key \
		--nic net-id=$net_id \
		vm_bare
}

get_kernel_image_id
get_ramdisk_image_id
get_squashfs_image_id
get_net_id
get_virtual_node_id
# get_bare_node_id

echo "ramdisk_image_id = $ramdisk_id"
echo "kernel_image_id = $kernel_id"
echo "squashfs_image_id = $hfs_id"
echo "net-id = $net_id"
echo "virtual_node_id = $virtual_node_id"
echo "bare_node_id = $bare_node_id"

virt_flavor_create
# bare_flavor_create
get_image
# bare_img_create
virtual_img_create
key_create

virtual_node_create
# bare_node_create
virtual_port_create
# bare_port_create
# boot_bare_image
