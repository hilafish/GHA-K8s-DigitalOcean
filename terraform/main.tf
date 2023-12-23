module "vpc" {
  source      = "terraform-do-modules/vpc/digitalocean"
  version     = "1.0.0"
  name        = "sp-vpc"
  environment = "test"
  region      = var.region
  ip_range    = "10.20.0.0/16"
}

module "kubernetes_cluster" {
  source          = "terraform-do-modules/kubernetes/digitalocean"
  name            = var.cluster_name
  environment     = "test"
  region          = var.region
  cluster_version = var.k8s_version
  vpc_uuid        = module.vpc.id

  critical_node_pool = {
    critical_node = {
      node_count = var.node_count
      min_nodes  = var.node_count
      max_nodes  = var.node_count
      size       = var.node_size
      labels     = { "cluster" = "critical"}
      tags       = ["test", "k8s-cluster", "k8s-sp"]
    }
  }
}

resource "digitalocean_container_registry" "go_registry" {
  name                   = "go-registry"
  subscription_tier_slug = "starter"
}

