terraform {
  #required_version = "= 0.11.8"
  required_version = ">= 1.5.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<= 2.21"
    }
  }
}
