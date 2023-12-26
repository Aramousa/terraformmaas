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
    api_key = "dZbSp3KJtMBDRuuGPF:q9zFPRvVRNGM39sesd:M9ERFX96kARXyETBERcXGyz5k2sQGRPc"
    api_url = "http://10.10.10.26:5240/MAAS"
}

resource "maas_space" "tf_space" {
  name = "tf-space"
}

resource "maas_fabric" "tf_fabric" {
  name = "tf-fabric"
}

resource "maas_vlan" "tf_vlan" {
  fabric = maas_fabric.tf_fabric.id
  vid = 14
  name = "tf-vlan14"
  space = maas_space.tf_space.name
}
resource "maas_subnet" "tf_subnet" {
  cidr = "10.10.12.0/24"
  fabric = maas_fabric.tf_fabric.id
  vlan = maas_vlan.tf_vlan.vid
  name = "tf_subnet"
  gateway_ip = "10.10.12.1"
  dns_servers = [
    "1.1.1.1","8.8.8.8"
  ]
  ip_ranges {
    type = "reserved"
    start_ip = "10.10.12.1"
    end_ip = "10.10.12.50"
  }
  ip_ranges {
    type = "dynamic"
    start_ip = "10.10.12.200"
    end_ip = "10.10.12.254"
  }
}
