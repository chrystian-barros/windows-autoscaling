terraform {
  required_version = "~>1.14.6"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "8.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}