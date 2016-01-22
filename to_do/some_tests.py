from shell_base import *
import logging


class TestF(object):

    def __init__(self):
        logging.basicConfig(format='%(asctime)s | %(message)s',
                            datefmt='%m/%d/%Y %I:%M:%S %p',
                            filemode='w', filename="out.log",
                            level=logging.DEBUG)

    def test_01(self):
        name = generate_name()
        print 'Name:', name
        logging.info('Name: {0}'.format(name))
        tenant_id = tenant_create(name)
        logging.info('Tenant id: {0}'.format(tenant_id))
        user_id = user_create(name)
        logging.info('User id: {0}'.format(user_id))
        logging.info('Creating rc file')
        rc_file = create_user_rc(name)
        logging.info('{0}rc file {1}'.format(name, rc_file))
        logging.info('Creating secret key')
        secret_key = key_create(name)
        logging.info('Secret key: {0}'.format(secret_key))
        flavor = virt_flavor_create(name)
        logging.info('Flavor: {0}'.format(flavor))
        flavor_list = get_flavor_list()
        logging.info('Flavor list: {0}'.format(flavor_list))



        logging.info('DONE!')


    def test_02(self):
        name = generate_name()
        print name
        key_create(name)
        net = net_create(name, '192.168.115.1', '192.168.115.0/28')
        instance = boot_instance(net_id=net['network_id'],
                                 vm_name=name, key=name)
        print instance

    def test_03(self):
        net_create('net_02', '192.168.114.1', '192.168.114.0/28')


if __name__ == "__main__":
    test_a = TestF()
    test_a.test_01()
