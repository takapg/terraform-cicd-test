terraform {
  required_version = "1.6.6"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
