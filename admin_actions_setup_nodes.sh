#! /bin/bash

# !!!! additional parameters !!!!!!!
# $1 MAC address

set -e

# Colors:
RB="\e[31m\e[1m"
GB="\e[92m\e[1m"
YB="\e[93m\e[1m"
END="\e[0m"

# Patterns:
id_pattern="^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$"
ip_addr_pattern="^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$"

echo "================================================="

if [ $# -ne 2 ]
  then
    echo -e "$RB No arguments supplied $END"
    echo -e "$RB Supply Ironic Node MAC address $END"
    exit 1
fi

mac_address="$1"
mac_address_02="$2"

# source config_set_up_nodes
echo -e "$YB Activate openrc $END"
source /root/openrc

function virt_flavor_create {
    echo -e "$YB Start creating flavor $END"
    nova flavor-create bm_flavor auto 3072 150 2
    echo -e "$GB Flavor has been created successfully $END"
}

function get_ip {
    echo -e "$YB Start geting IP address $END"
    ip_addr=$(ip ro | grep default | awk {'print $3'})
    if [[ $ip_addr =~ $ip_addr_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi

}

function get_kernel_image_id {
    echo -e "$YB Start geting kernel ID $END"
    kernel_id=$(glance \
		image-list \
		| grep "ironic-deploy-linux" \
		| awk {'print $2'})
    if [[ $kernel_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function get_ramdisk_image_id {
    echo -e "$YB Start geting Ramdisk ID $END"
    ramdisk_id=$(glance \
		image-list \
		| grep "ironic-deploy-initramfs" \
		| awk {'print $2'})
    if [[ $ramdisk_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function get_squashfs_image_id {
    echo -e "$YB Start geting hfd ID $END"
    hfs_id=$(glance \
	     image-list \
	     | grep "ironic-deploy-squashfs" \
	     | awk {'print $2'})
    if [[ $hfs_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function virtual_node_create {
    echo -e "$YB Start creating virtual ironic node $END"
	ironic node-create \
		-n virtualone \
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

function virtual_node_02_create {
    echo -e "$YB Start creating virtual ironic node 02 $END"
	ironic node-create \
		-n virtualtwo \
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
    echo -e "$YB Start geting Network ID $END"
    net_id=$(nova net-list \
	     | grep baremetal \
	     | awk {'print $2'})	
    if [[ $net_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function get_virtual_node_id {
    echo -e "$YB Start geting virtual node ID $END"
	virtual_node_id=$(ironic node-list \
			| grep virtualone \
			| awk {'print $2'})
    if [[ $virtual_node_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function get_virtual_node_02_id {
    echo -e "$YB Start geting virtual node 02 ID $END"
	virtual_node_02_id=$(ironic node-list \
			| grep virtualtwo \
			| awk {'print $2'})
    if [[ $virtual_node_02_id =~ $re_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function virtual_port_create {
    echo "MAC is $mac_address"
    echo -e "$YB Start creating virtual port $END"
    ironic port-create \
		-n $virtual_node_id \
		-a $mac_address
}

function virtual_port_02_create {
        echo "MAC is $mac_address_02"
    echo -e "$YB Start creating virtual port 02 $END"
    ironic port-create \
		-n $virtual_node_02_id \
		-a $mac_address_02
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
virt_flavor_create
virtual_node_create
virtual_node_02_create

echo "Start sleeping 3m"
date
sleep 3m
echo "End sleeping"

get_virtual_node_id
echo "virtual_node_id = $virtual_node_id"
get_virtual_node_02_id
echo "virtual_node_02_id = $virtual_node_02_id"
virtual_port_create
virtual_port_02_create
echo -e "$GB [Script has been executed successfully] $END"
