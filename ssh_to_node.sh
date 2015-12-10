#! /bin/bash

set -e
# source config_set_up_nodes
source /root/demo_openrc

function get_instance_id {
    inst_id=$(nova list | grep baremetal | awk {'print $2'})
}

function get_instance_ip {
    inst_ip=$(nova show $inst_id | grep baremetal | awk {'print $5'})
}

function ssh_to_node {
    echo "================================"
    ssh -i ironic_demo_key.pem ubuntu@$inst_ip 'df -H'
    echo "======== Exit code $? =========="
}

function assign_floating_ip {
    
}

get_instance_id
get_instance_ip
ssh_to_node

echo $inst_id
echo $inst_ip
