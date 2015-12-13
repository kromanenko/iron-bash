import subprocess
import output_parser as parser


def shell(command):
    output = subprocess.check_output(command, shell=True)
    return output

# neutron net-create demo-net
# neutron subnet-create demo-net --name demo-subnet --gateway 192.168.1.1 192.168.1.0/24

def net_create(net_name, geatway, net_cidr):
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
    net_list = parser.listing(net_list)
    return net_list

def delete_net(net_id):
    deleted_net = shell('neutron net-delete {0}'.format(net_id))
    return deleted_net

def get_floating_ip_list():
    floating_ip_list = shell('nova floating-ip-list')
    return parser.listing(floating_ip_list)

def boot_instance(net_id,
                  key='admin',
                  vm_name='test_st',
                  flavor='m1.micro',
                  image='TestVM'):
    instance = shell('nova boot \
            --key_name {0} \
            --flavor {1} \
            --image {2} \
            --nic net-id={3} {4}'.format(key, flavor, image, net_id, vm_name))
    return parser.details_multiple(instance)


# nn = net_create('serg05', '192.168.18.1', '192.168.18.0/28')
print '==============================================='
# nn = get_floating_ip_list()
# nets = get_net_list()
inst = boot_instance('cd7c13f6-792f-44cc-bb2f-5e28fd1a976e')
print inst
