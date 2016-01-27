#! /bin/bash

set -e

# source config_set_up_nodes
source /root/demorc

function get_net_id {
        net_id=$(nova net-list \
                | grep baremetal \
                | awk {'print $2'})
}

function get_ubuntu_14_image {
    wget http://releases.ubuntu.com/14.04.3/ubuntu-14.04.3-desktop-amd64.iso
}

function get_ubuntu_15_image {
    wget http://releases.ubuntu.com/15.10/ubuntu-15.10-desktop-amd64.iso
}


function ubuntu_14_img_create {
    glance \
        image-create \
                --name ubuntu_14 \
                --disk-format iso \
                --container-format bare \
                --file ubuntu-14.04.3-desktop-amd64.iso \
                --progress
}

function ubuntu_15_img_create {
    glance \
        image-create \
                --name ubuntu_15 \
                --disk-format iso \
                --container-format bare \
                --file ubuntu-15.10-desktop-amd64.iso \
                --progress
}

function boot_ubuntu_14 {
    nova boot \
        --flavor m1.small \
        --image ubuntu_14 \
        --key-name ironic_demo_key \
        --nic net-id=$net_id \
        ubuntu_14
}

function boot_ubuntu_15 {
    nova boot \
        --flavor m1.small \
        --image ubuntu_15 \
        --key-name ironic_demo_key \
        --nic net-id=$net_id \
        ubuntu_15
}

# get_ubuntu_14_image
# get_ubuntu_15_image

get_net_id

ubuntu_14_img_create
ubuntu_15_img_create

boot_ubuntu_14
boot_ubuntu_15
