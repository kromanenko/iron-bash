from shell_base import *


class Tests(object):

    def test_01(self):
        name = generate_name()
        print name
        key_create(name)
        net = net_create(name, '192.168.115.1', '192.168.115.0/28')
        instance = boot_instance(net_id=net['network_id'],
                                 vm_name=name,key=name)
        print instance

    def test_02(self):
        net = net_create('net_02', '192.168.114.1', '192.168.114.0/28')


if __name__ == "__main__":
    test01 = Tests()
    test01.test_01()
