#! /bin/bash

# !!!! additional parameters !!!!!!!
# $1 MAC address

set -e

mac_address_01="$1"

# source config_set_up_nodes
source /root/openrc

function virt_flavor_create {
	nova flavor-create bm_flavor auto 3072 150 2
}

function get_ip {
    ip_addr=$(ip ro | grep default | awk {'print $3'})
}

function get_kernel_image_id {
	kernel_id=$(glance \
		image-list \
		| grep "ironic-deploy-linux" \
		| awk {'print $2'})
}

function get_ramdisk_image_id {
	ramdisk_id=$(glance \
		image-list \
		| grep "ironic-deploy-initramfs" \
		| awk {'print $2'})
}

function get_squashfs_image_id {
	hfs_id=$(glance \
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
		-i ssh_address=$ip_addr \
		-i ssh_password=ironic_password \
		-i ssh_username=ironic \
		-i ssh_virt_type=virsh \
		-p cpus=2 \
		-p memory_mb=3072 \
		-p local_gb=150 \
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

function virtual_port_create {
        echo "MAC is $mac_address"
	ironic port-create \
		-a $mac_address \
		-n $virtual_node_id
}

get_ip
get_kernel_image_id
get_ramdisk_image_id
get_squashfs_image_id
get_net_id

echo "IP address = $ip_addr"
echo "ramdisk_image_id = $ramdisk_id"
echo "kernel_image_id = $kernel_id"
echo "squashfs_image_id = $hfs_id"
echo "net-id = $net_id"
echo "virtual_node_id = $virtual_node_id"

virt_flavor_create
virtual_node_create

echo "Start sleeping"
sleep 3m
echo "End sleeping"

get_virtual_node_id
virtual_port_create
