#! /bin/bash

# Checks statuses of ironic-api and ironic-conductor
# in case if conductor ranning on controller node 

set -e
# source config_set_up_nodes
source /root/openrc

function api {
	service ironic-api status
}

function conductor {
	service ironic-conductor status
}

api
conductor
