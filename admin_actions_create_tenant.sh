#! /bin/bash

set -e
source /root/openrc

# Colors:
RB="\e[31m\e[1m"
GB="\e[92m\e[1m"
YB="\e[93m\e[1m"
END="\e[0m"

if [ $# -ne 1 ]
  then
    echo -e "$RB No arguments supplied $END"
    echo -e "$RB Supply Tenant Name $END"
    exit 1
fi

name="$1"
rc="rc"
rc_name=`echo $name$rc`

function tenant_create {
    echo -e "$YB Start creating tenant $END"
    openstack project create "$name"\
	--description "$name Tenant"

    name_pattern="^[[:xdigit:]]{32}$"
    name_id=$(openstack project list | awk "/$name/{print \$2}")
    if [[ $name_id =~ $name_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function user_create {
    echo -e "$YB Start creating user $END"
    openstack user create \
        --project "$name" \
        --password "$name" \
	--email demo@example.com \
	--enable \
        "$name"

    name_pattern="^[[:xdigit:]]{32}$"
    name_id=$(openstack user list | awk "/$name/{print \$2}")
    if [[ $name_id =~ $name_pattern ]]
        then
            echo -e "$GB [OK] $END"
        else
            echo -e "$RB [FAIL] $END"
	    exit 1
    fi
}

function create_demorc {
    echo -e "$YB Start creating rc file from openrc $END"
    cp /root/openrc /root/"$rc_name"
    sed -i "s/admin/$name/g" /root/"$rc_name"
}

tenant_create
user_create
create_demorc
echo -e "$GB [Script has been executed successfully] $END"
