#! /bin/bash

set -e

# source config_set_up_nodes
source /root/openrc

function boot01 {
	nova boot \
		--flavor m1.small \
		--image 10b843af-29fb-4e1c-84d9-1ff728e2ebea \
		--key-name ironic_demo_key \
		--nic net-id=1411d1f2-db2d-4ce0-8769-baf94a4cc4f4 \
		vm_test_01
}
function boot02 {
	nova boot \
		--flavor m1.small \
		--image 10b843af-29fb-4e1c-84d9-1ff728e2ebea \
		--key-name ironic_demo_key \
		--nic net-id=1411d1f2-db2d-4ce0-8769-baf94a4cc4f4 \
		vm_test_02
}
function boot03 {
	nova boot \
		--flavor m1.small \
		--image 10b843af-29fb-4e1c-84d9-1ff728e2ebea \
		--key-name ironic_demo_key \
		--nic net-id=1411d1f2-db2d-4ce0-8769-baf94a4cc4f4 \
		vm_test_03
}
function boot04 {
	nova boot \
		--flavor m1.small \
		--image 10b843af-29fb-4e1c-84d9-1ff728e2ebea \
		--key-name ironic_demo_key \
		--nic net-id=1411d1f2-db2d-4ce0-8769-baf94a4cc4f4 \
		vm_test_04
}
boot01
boot02
boot03
boot04
