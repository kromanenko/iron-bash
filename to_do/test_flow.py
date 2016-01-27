from shell_base import Base
import unittest


class TestFlow(unittest.TestCase, Base):
    def setUp(self):
        self.name = self.generate_name()

    def test_tenant_create(self):
        self.export_env('admin')
        tenant = self.tenant_create(self.name)
        tenant_list = self.get_tenant_list()
        self.assertIn(tenant, [x['ID'] for x in tenant_list])

    def test_user_create(self):
        self.export_env('admin')
        user = self.user_create(self.name)
        user_list = self.get_user_list()
        self.assertIn(user, [x['ID'] for x in user_list])

    def test_key_create(self):
        self.export_env('admin')
        self.key_create(self.name)
        key_list = self.get_key_list()
        self.assertIn(self.name, [x['Name'] for x in key_list])

    def test_flavor_create(self):
        self.export_env('admin')
        flavor = self.virt_flavor_create(self.name)
        print '====', flavor
        flavor_list = self.get_flavor_list()
        self.assertIn('bm_flavor', [x['Name'] for x in flavor_list])

    def test_virtual_node_create(self):
        self.export_env('admin')
        # ip = self.get_ip()
        # kernel_id = self.get_kernel_image_id()
        # ramdisk_id = self.get_ramdisk_image_id()
        # quashfs_id = self.get_quashfs_image_id()
        node = self.virtual_node_create()
        print node

        # self.assertIn(ip, [1,2,3])

if __name__ == "__main__":
    unittest.main()
