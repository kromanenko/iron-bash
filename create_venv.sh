#! /bin/bash

set -e

function installs {
    apt-get install python-pip -y -qq 
    pip install virtualenv
}

function create_venv {
    cd /root
    mkdir venv
    virtualenv /root/venv/ironicclient
    source /root/venv/ironicclient/bin/activate
}

function activate_venv {
    source /root/venv/ironicclient/bin/activate
}

function update {
    apt-get install ipython -y -qq
    apt-get install git -y -qq
    apt-get install python-tox -y -qq
    apt-get install python-dev -y -qq
    apt-get install libxml2-dev -y -qq
    apt-get install libxslt1-dev -y -qq
    apt-get install build-essential dkms -y -qq
    apt-get install dkms -y -qq
    apt-get install zlib1g-dev -y -qq
    apt-get install python-oslo-concurrency -y -qq
}

function pip {
    sudo pip install pip --upgrade
    sudo pip install setuptools --upgrade
    echo "testtools"
    sudo pip install testtools
    echo "oslo"
    sudo pip install oslo.concurrency
    echo "prettytable"
    sudo pip install prettytable
    sudo pip install oslo.serialization
    sudo pip install appdirs
    echo "dogpie"
    sudo pip install dogpile.cache
    sudo pip install httplib2
    sudo pip install python-openstackclient
    sudo pip install oslo.i18n
}

function clone {
    cd /root
    git clone https://github.com/openstack/python-ironicclient.git
    git clone https://github.com/testing-cabal/testtools.git
}

function set_up {
    cd testtools/
     ./setup.py install
    cd /root
}

# installs
# create_venv

echo "Activate venv"
activate_venv
echo "Update"
# update
echo "Pip"
pip
echo "Clone"
clone
echo "SetUp"
set_up
echo "Done"
