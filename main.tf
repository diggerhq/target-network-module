terraform {
  required_version = ">= 0.12"

  required_providers {
    archive = {
      version = "= 1.3.0"
      source  = "hashicorp/archive"
    }

    local = {
      version = "= 1.4.0"
      source  = "hashicorp/local"
    }

    template = {
      version = "= 2.1.2"
      source  = "hashicorp/template"
    }
  }
}