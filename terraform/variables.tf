variable "digitalocean_token" {
  description = "Digital Ocean API token. will be taken from env var, need to be set as TF_VAR_digitalocean_token"
}

variable "cluster_name" {
  description = "Name for the Kubernetes cluster"
  default = "k8s-sp"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default = "1.28.2-do.0"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  default     = 2
}

variable "node_size" {
  description = "Size of the nodes in the cluster"
  #default     = "s-2vcpu-2gb"
  default     = "s-1vcpu-2gb"
}

variable "region" {
  description = "Digital Ocean region. Verify this is the region you'd like to use, from all relevant aspects"
  default     = "nyc1"
}

