terraform {
  required_version = "1.2.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0, < 5.0, !=4.65.0, !=4.65.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.51.0, < 5.0, !=4.65.0, !=4.65.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
