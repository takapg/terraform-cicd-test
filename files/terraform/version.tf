terraform {
  required_version = "1.5.7"
  required_providers {
    null = {
      source  = "registry.terraform.io/hashicorp/null"
      version = "3.2.2"
    }
    tls = {
      source  = "registry.terraform.io/hashicorp/tls"
      version = "4.0.5"
    }
  }
}
