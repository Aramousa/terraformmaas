#API Linkage Definition
terraform {
  required_providers {
    maas = {
      source  = "maas/maas"
      version = "~>1.0"
    }
  }
}

provider "maas" {
  api_version = "2.0"
  api_key     = "dZbSp3KJtMBDRuuGPF:q9zFPRvVRNGM39sesd:M9ERFX96kARXyETBERcXGyz5k2sQGRPc"
  api_url     = "http://10.10.10.26:5240/MAAS"
}
resource "maas_space" "tf_space" {
  name = "tf-space"
}
resource "maas_fabric" "tf_fabric" {
  name = "tf-fabric"
}
resource "maas_vlan" "tf_vlan2" {
  fabric = maas_fabric.tf_fabric.id
  vid = 2
  name = "tf-vlan2"
  space = maas_space.tf_space.name
}
resource "maas_subnet" "tf_subnet" {
  cidr = "10.10.12.0/24"
  fabric = maas_fabric.tf_fabric.id
  vlan = maas_vlan.tf_vlan2.vid
  name = "tf_subnet"
  gateway_ip = "10.10.12.1"
  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
  ]

  ip_ranges {
    type = "reserved"
    start_ip = "10.10.12.10"
    end_ip = "10.10.12.80"
  }
  ip_ranges {
    type = "dynamic"
    start_ip = "10.10.12.150"
    end_ip = "10.10.12.220"
  }
}
resource "maas_block_device" "vdb" {
  machine = maas_machine.virsh_vm1.id
  name = "vdb"
  id_path = "/dev/vdb"
  size_gigabytes = 12
  tags = [
    "ssd",
  ]

  partitions {
    size_gigabytes = 5
    fs_type = "ext4"
    label = "media"
    mount_point = "/media"
  }

  partitions {
    size_gigabytes = 7
    fs_type = "ext4"
    mount_point = "/storage"
  }
}
resource "maas_dns_domain" "runsensibletest" {
  name = "runsensibletest"
  ttl = 3600
  authoritative = true
}
resource "maas_dns_record" "test_a" {
  type = "A/AAAA"
  data = "10.10.12.33"
  fqdn = "test-a.${maas_dns_domain.runsensibletest.name}"
}
resource "maas_vm_host" "kvm" {
  type = "virsh"
  power_address = "qemu+ssh://ubuntu@10.10.12.33/system"
  tags = [
    "pod-console-logging",
    "virtual",
    "kvm",
  ]
}
#resource "maas_vm_host_machine" "kvm" {
#  count = 2
#  vm_host = maas_vm_host.kvm.id
#  cores = 1
#  memory = 2048
#  storage_disks {
#    size_gigabytes = 12
#  }
#}
#resource "maas_instance" "kvm" {
#  count = 1
#  allocate_params {
#    hostname = maas_vm_host_machine.kvm[count.index].hostname
#    min_cpu_count = 1
#    min_memory = 2048
#    tags = [
#      maas_tag.kvm.name,
#    ]
#  }
#  deploy_params {
#    distro_series = "focal"
#  }
#}
resource "maas_machine" "virsh_vm1" {
  power_type = "virsh"
  power_parameters = jsonencode({
    power_address = "qemu+ssh://ubuntu@10.10.12.33/system"
    power_id = "test-vm1"
  })
  pxe_mac_address = "52:54:00:89:f5:3e"
}
resource "maas_tag" "kvm" {
  name = "kvm"
  machines = [
    maas_machine.virsh_vm1.id,
  ]
}
resource "maas_network_interface_link" "virsh_vm1_nic1" {
  machine = maas_machine.virsh_vm1.id
  network_interface = maas_network_interface_physical.virsh_vm1_nic1.id
  subnet = maas_subnet.tf_subnet.id
  mode = "STATIC"
  ip_address = "10.10.12.37"
  default_gateway = true
}
resource "maas_network_interface_physical" "virsh_vm1_nic1" {
  machine = maas_machine.virsh_vm1.id
  mac_address = "52:54:00:89:f5:3e"
  name = "eth0"
  vlan = maas_vlan.tf_vlan2.vid 
  tags = [
    "nic1-tag1",
    "nic1-tag2",
    "nic1-tag3",
  ]
}
