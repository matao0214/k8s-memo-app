terraform {
  required_version = ">= 1.9.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 6.3.0"
    }
  }
}

provider "google" {
  project = "matao0214-demo"
  region  = "asia-northeast1"
}
