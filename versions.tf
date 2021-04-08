terraform {
  experiments = [module_variable_optional_attrs]

  required_version = ">= 0.14"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.4"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.38"
    }
  }
}
