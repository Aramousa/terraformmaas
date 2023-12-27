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

