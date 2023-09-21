variable "project_id" {
  default = "jetstack-paul"
}

variable "region" {
  validation {
    condition     = contains(["us-central1", "europe-west2"], var.region)
    error_message = "The region must be us-central1 or europe-west2."
  }
}

variable "zone" {
}

variable "cluster_name" {
  default = "kcc"
  validation {
    condition     = length(var.cluster_name) < 50
    error_message = "The name must be <50 characters."
  }
}

variable "network_name" {
  default = "gke-kcc"
  validation {
    condition     = length(var.network_name) < 50
    error_message = "The name must be <50 characters."
  }
}

variable "resource_prefix" {
  default = "fleetops"
  validation {
    condition     = length(var.resource_prefix) < 10
    error_message = "The prefix must be <10 characters."
  }
}

variable "master_authorized_range" {
  description = "IP address to add to GKE master authorized networks"
  validation {
    condition     = can(cidrnetmask(var.master_authorized_range))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}
