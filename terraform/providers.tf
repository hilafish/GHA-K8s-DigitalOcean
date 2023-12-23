terraform {
  required_version = "1.6.6"
  
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.28.1"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}