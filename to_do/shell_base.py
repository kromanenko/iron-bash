import subprocess
import time
import output_parser as parser
from random import randint


def shell(command):
    output = subprocess.check_output(command, shell=True)
    return output

# neutron net-create demo-net
# neutron subnet-create
# demo-net --name demo-subnet --gateway 192.168.1.1 192.168.1.0/24


def generate_name(preffix='test'):
    """Genetate random name"""
    return "{0}-{1}".format(preffix, randint(1000, 9999))


def get_key_list():
    key_list = shell('nova keypair-list')
    return parser.listing(key_list)


def tenant_create(name):
    # name = generate_name()
    tenant = shell('openstack project create {0}'.format(name))
    tenant = parser.listing(tenant)
    # return tenant_id
    return [x['Value'] for x in tenant if 'id' in x.values()][0]


def tenant_delete(name):
    shell('openstack project delete {0}'.format(name))


def user_create(name):
    user = shell('openstack user create \
                 --project {0} \
                 --password {0} \
                 --email {0}@example.com \
                 --enable {0}'.format(name))
    user = parser.listing(user)
    return [x['Value'] for x in user if 'id' in x.values()][0]


def get_user_list():
    user = shell('openstack user list')
    return parser.listing(user)


def user_delete(user_id):
    shell('openstack user delete {0}'.format(user_id))


def create_user_rc(name):
    shell('cp /root/openrc /root/{0}rc'.format(name))
    shell('sed -i s/admin/{0}/g /root/{0}rc'.format(name))
    return shell('cat /root/{0}rc'.format(name))


def get_tenant_list():
    tenant_list = shell('openstack project list')
    return parser.listing(tenant_list)


def key_create(key_name):
    key_list = get_key_list()

    if key_name not in [x['Name'] for x in key_list]:
        key = shell('nova keypair-add {0} > {0}.pem'.format(key_name))
        shell('chmod 600 {0}.pem'.format(key_name))
        return shell('cat {0}.pem'.format(key_name))


def key_delete(key_name):
    key_list = get_key_list()

    if key_name in [x['Name'] for x in key_list]:
        shell('nova keypair-delete {0}'.format(key_name))
        shell('rm {0}.pem'.format(key_name))


def get_flavor_list():
    flavor = shell('nova flavor-list')
    return parser.listing(flavor)


def virt_flavor_create(name='bm_flavor'):
    flavor_list = get_flavor_list()
    if name in [x['Name'] for x in flavor_list]:
        return
    flavor = shell('nova flavor-create {0} auto 3072 150 2'.format(name))
    return parser.listing(flavor)


def delete_flavor(flavor_id):
    shell('nova flavor-delete {0}'.format(flavor_id))


def get_ip():
    return shell("ip ro | grep default | awk {'print $3'}")


def net_create(net_name, geatway, net_cidr):
    """Returns dict.

    To get network id use key:
        'network_id'
    """

    shell('neutron net-create {0}'.format(net_name))
    subnet_name = 'sub-{0}'.format(net_name)
    subnet = shell('neutron subnet-create {0} \
                    --name {1} \
                    --gateway {2} {3}'
                   .format(net_name, subnet_name, geatway, net_cidr))
    subnet = parser.listing(subnet)
    subnet_dict = {}
    for _ in subnet:
        subnet_dict[_.values()[0]] = _.values()[-1]
    return subnet_dict


def get_net_list():
    net_list = shell('neutron net-list')
    return parser.listing(net_list)


def get_net_list_names():
    net_list = get_net_list()
    return [x['name'] for x in net_list]


def delete_net(net_id):
    deleted_net = shell('neutron net-delete {0}'.format(net_id))
    return deleted_net


def get_floating_ip_list():
    floating_ip_list = shell('nova floating-ip-list')
    return parser.listing(floating_ip_list)


def get_nova_list():
    nova_list = shell('nova list')
    return parser.listing(nova_list)


def get_instance_status(name):
    instance = shell('nova show {0}'.format(name))
    instance = parser.details_multiple(instance)
    return [x['status'] for x in instance]


def boot_instance(net_id,
                  vm_name,
                  key,
                  flavor='m1.micro',
                  image='TestVM'):

    instance = shell('nova boot \
                     --key_name {0} \
                     --flavor {1} \
                     --image {2} \
                     --nic net-id={3} {4}'
                     .format(key, flavor, image, net_id, vm_name))
    for _ in range(5):
        status = get_instance_status(vm_name)
        print "Instance status:", status
        if status == 'ERROR':
            raise "Booting instance goes to an Error!!!"
        if status == 'ACTIVE':
            return parser.details_multiple(instance)
        time.sleep(5)
    return


def get_instance_list_ids():
    instance_list = shell('nova list')
    instance_list = parser.listing(instance_list)
    return [x['ID'] for x in instance_list]


def delete_instance(instance_id):
    deleted_instance = shell('nova delete {0}'.format(instance_id))
    print deleted_instance
    return deleted_instance
