#! /bin/bash

set -e

# source config_set_up_nodes
source /root/demorc

function get_net_id {
	net_id=$(nova net-list \
		| grep baremetal \
		| awk {'print $2'})	
}

function get_fedora {
    wget https://download.fedoraproject.org/pub/fedora/linux/releases/23/Server/x86_64/iso/Fedora-Server-DVD-x86_64-23.iso
}

function get_ubuntu_12 {
    wget http://releases.ubuntu.com/12.04/ubuntu-12.04.5-desktop-amd64.iso
}

function get_ubuntu_image {
    curl https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64.tar.gz | tar -xzp
}

function virtual_fedora_img_create {
    glance \
	--os-image-api-version 1 \
	image-create \
	    	--name virtual_fedora_demo \
	    	--disk-format raw \
		--container-format bare \
		--file Fedora-Server-DVD-x86_64-23.iso \
		--progress \
		--property cpu_arch='x86_64' \
		--property hypervisor_type='baremetal' \
		--property mos_disk_info='[{"name": "vda", "extra": [], "free_space": 11000, "type": "disk", "id": "vda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}

function virtual_ubuntu_trasty_img_create {
    glance \
       	--os-image-api-version 1 \
	image-create \
		--name virtual_ubuntu_trasty_ext4_demo \
		--disk-format raw \
		--container-format bare \
		--file trusty-server-cloudimg-amd64.img \
		--progress \
		--property cpu_arch='x86_64' \
		--property hypervisor_type='baremetal' \
		--property mos_disk_info='[{"name": "vda", "extra": [], "free_space": 11000, "type": "disk", "id": "vda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}

function virtual_ubuntu_12_img_create {
    glance \
       	--os-image-api-version 1 \
	image-create \
		--name virtual_ubuntu_12_demo \
		--disk-format raw \
		--container-format bare \
		--file ubuntu-12.04.5-desktop-amd64.iso \
		--progress \
		--property cpu_arch='x86_64' \
		--property hypervisor_type='baremetal' \
		--property mos_disk_info='[{"name": "vda", "extra": [], "free_space": 11000, "type": "disk", "id": "vda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}

function virtual_ubuntu_15_img_create {
    glance \
       	--os-image-api-version 1 \
	image-create \
		--name virtual_ubuntu_15_demo \
		--disk-format raw \
		--container-format bare \
		--file ubuntu-15.04-server-amd64.iso \
		--progress \
		--property cpu_arch='x86_64' \
		--property hypervisor_type='baremetal' \
		--property mos_disk_info='[{"name": "vda", "extra": [], "free_space": 11000, "type": "disk", "id": "vda", "size": 11000, "volumes": [{"mount": "/", "type": "partition", "file_system": "ext4", "size": 10000}]}]'
}


function key_create {
    nova keypair-add ironic_demo_key > ironic_demo_key.pem
    chmod 600 ironic_demo_key.pem
}

function user_data {
    touch myfile.txt 
    echo "# Hi there!!!" >> myfile.txt
}

function boot_image {
    nova boot \
        --flavor bm_flavor \
        --image virtual_ubuntu_trasty_ext4_demo \
        --key-name ironic_demo_key \
        --nic net-id=$net_id \
        vm_test_img_01
}
#        --file /home/ubuntu/myfile.txt=myfile.txt \

function boot_fedora {
    nova boot \
        --flavor bm_flavor \
        --image virtual_trusty_ext4_demo \
        --key-name ironic_key \
        --nic net-id=$net_id \
        vm_test_f_img_01
}

# get_fedora
# get_ubuntu_12
# get_ubuntu_image
get_net_id

# virtual_fedora_img_create
# virtual_ubuntu_trasty_img_create
# virtual_ubuntu_12_img_create
# virtual_ubuntu_15_img_create

echo "net-id = $net_id"
# key_create
# user_data
boot_image
