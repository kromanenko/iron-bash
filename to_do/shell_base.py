import logging
import subprocess
import time
import output_parser as parser

from random import randint

import os


class Base(object):

    def __init__(self):
        logging.basicConfig(format='%(asctime)s | %(message)s',
                            datefmt='%m/%d/%Y %I:%M:%S %p',
                            filemode='w', filename="out.log",
                            level=logging.DEBUG)

    def shell(self, command):
        output = subprocess.check_output(command, shell=True)
        logging.info('{0} \n {1}'.format(command, output))
        return output

    def generate_name(self, preffix='test'):
        """Genetate random name"""
        name = "{0}-{1}".format(preffix, randint(1000, 9999))
        logging.info('Name: {0}'.format(name))
        return name

    def export_env(self, name):
        logging.info('Start export environment variables')
        params = ['OS_TENANT_NAME', 'OS_PROJECT_NAME',
                  'OS_USERNAME', 'OS_PASSWORD']
        for param in params:
            os.environ[param] = name
            env_var = os.environ.get(param)
            logging.info(env_var)
        os.environ['OS_AUTH_URL'] = 'http://192.168.0.2:5000/v2.0/'
        logging.info('OS_AUTH_URL')

    def get_key_list(self):
        key_list = self.shell('nova keypair-list')
        return parser.listing(key_list)

    def tenant_create(self, name):
        tenant = self.shell('openstack project create {0}'.format(name))
        tenant = parser.listing(tenant)
        return [x['Value'] for x in tenant if 'id' in x.values()][0]

    def tenant_delete(self, name):
        self.shell('openstack project delete {0}'.format(name))

    def user_create(self, name):
        user = self.shell('openstack user create \
                    --project {0} \
                    --password {0} \
                    --email {0}@example.com \
                    --enable {0}'.format(name))
        user = parser.listing(user)
        return [x['Value'] for x in user if 'id' in x.values()][0]

    def get_user_list(self):
        user = self.shell('openstack user list')
        return parser.listing(user)

    def user_delete(self, user_id):
        self.shell('openstack user delete {0}'.format(user_id))

    def create_user_rc(self, name):
        self.shell('cp /root/openrc /root/{0}rc'.format(name))
        self.shell('sed -i s/admin/{0}/g /root/{0}rc'.format(name))
        return self.shell('cat /root/{0}rc'.format(name))

    def get_tenant_list(self):
        tenant_list = self.shell('openstack project list')
        return parser.listing(tenant_list)

    def key_create(self, key_name):
        key_list = self.get_key_list()

        if key_name not in [x['Name'] for x in key_list]:
            self.shell('nova keypair-add {0} > {0}.pem'.format(key_name))
            self.shell('chmod 600 {0}.pem'.format(key_name))
            return self.shell('cat {0}.pem'.format(key_name))

    def key_delete(self, key_name):
        key_list = self.get_key_list()

        if key_name in [x['Name'] for x in key_list]:
            self.shell('nova keypair-delete {0}'.format(key_name))
            self.shell('rm {0}.pem'.format(key_name))

    def get_flavor_list(self):
        flavor = self.shell('nova flavor-list')
        return parser.listing(flavor)

    def virt_flavor_create(self, name='bm_flavor'):
        flavor_list = self.get_flavor_list()
        if name in [x['Name'] for x in flavor_list]:
            return
        flavor = self.shell('nova flavor-create {0} auto 3072 150 2'
                            .format(name))
        return parser.listing(flavor)

    def delete_flavor(self, flavor_id):
        self.shell('nova flavor-delete {0}'.format(flavor_id))

    def get_ip(self):
        return self.shell("ip ro | grep default | awk {'print $3'}")

    def net_create(self, net_name, geatway, net_cidr):
        """Returns dict.

        To get network id use key:
            'network_id'
        """
        self.shell('neutron net-create {0}'.format(net_name))
        subnet_name = 'sub-{0}'.format(net_name)
        subnet = self.shell('neutron subnet-create {0} \
                            --name {1} \
                            --gateway {2} {3}'
                            .format(net_name, subnet_name, geatway, net_cidr))
        subnet = parser.listing(subnet)
        subnet_dict = {}
        for _ in subnet:
            subnet_dict[_.values()[0]] = _.values()[-1]
        return subnet_dict

    def get_net_list(self):
        net_list = self.shell('neutron net-list')
        return parser.listing(net_list)

    def get_net_list_names(self):
        net_list = self.get_net_list()
        return [x['name'] for x in net_list]

    def delete_net(self, net_id):
        deleted_net = self.shell('neutron net-delete {0}'.format(net_id))
        return deleted_net

    def get_floating_ip_list(self):
        floating_ip_list = self.shell('nova floating-ip-list')
        return parser.listing(floating_ip_list)

    def get_nova_list(self):
        nova_list = self.shell('nova list')
        return parser.listing(nova_list)

    def get_instance_status(self, name):
        instance = self.shell('nova show {0}'.format(name))
        instance = parser.details_multiple(instance)
        return [x['status'] for x in instance]

    def get_image_list(self):
        image_list = self.shell('glance image-list')
        return parser.listing(image_list)

    def get_kernel_image_id(self):
        image_list = self.shell('glance image-list')
        image_list = parser.listing(image_list)
        return [x['ID'] for x in image_list
                if x['Name'] == 'ironic-deploy-linux'][0]

    def get_ramdisk_image_id(self):
        image_list = self.shell('glance image-list')
        image_list = parser.listing(image_list)
        return [x['ID'] for x in image_list
                if x['Name'] == 'ironic-deploy-initramfs'][0]

    def get_quashfs_image_id(self):
        image_list = self.shell('glance image-list')
        image_list = parser.listing(image_list)
        return [x['ID'] for x in image_list
                if x['Name'] == 'ironic-deploy-squashfs'][0]

    def virtual_node_create(self, name='testtest03'):
        kernel_id = self.get_kernel_image_id()
        ramdisk_id = self.get_ramdisk_image_id()
        quashfs_id = self.get_quashfs_image_id()
        ip_addr = self.get_ip()
        virtual_node = self.shell('ironic node-create -n {0} -d fuel_ssh -i deploy_kernel={1} -i deploy_ramdisk={2} -i deploy_squashfs={3} -i ssh_address={4} -i ssh_password=ironic_password -i ssh_username=ironic -i ssh_virt_type=virsh -p cpus=2 -p memory_mb=3072 -p local_gb=150 -p cpu_arch=x86_64'.format(name, kernel_id, ramdisk_id, quashfs_id, ip_addr))
        return parser.listing(virtual_node)

    def boot_testvm_instance(self, net_id, vm_name, key=' ',
                             flavor='m1.micro', image='TestVM'):

        instance = self.shell('nova boot \
                        --key_name {0} \
                        --flavor {1} \
                        --image {2} \
                        --nic net-id={3} {4}'
                        .format(key, flavor, image, net_id, vm_name))
        for _ in range(5):
            status = self.get_instance_status(vm_name)
            print "Instance status:", status
            if status == 'ERROR':
                raise "Booting instance goes to an Error!!!"
            if status == 'ACTIVE':
                return parser.details_multiple(instance)
            time.sleep(5)
        return

    def get_instance_list_ids(self):
        instance_list = self.shell('nova list')
        instance_list = parser.listing(instance_list)
        return [x['ID'] for x in instance_list]

    def delete_instance(self, instance_id):
        deleted_instance = self.shell('nova delete {0}'.format(instance_id))
