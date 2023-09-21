locals {
  resource_prefix        = var.resource_prefix
  resource_suffix        = module.utils.region_short_name
  region                 = data.google_compute_regions.available.names[index(data.google_compute_regions.available.names, var.region)]
  zone                   = data.google_compute_zones.available.names[index(data.google_compute_zones.available.names, var.zone)]
  cluster_name           = var.cluster_name
  network_name           = "vpc-${local.resource_prefix}-${var.network_name}"
  subnet_name            = var.cluster_name
  gke_subnet_name        = "sb-${local.resource_prefix}-${local.subnet_name}-${local.resource_suffix}"
  master_auth_subnetwork = "master"
  master_subnet_name     = "sb-${local.resource_prefix}-${local.master_auth_subnetwork}-${local.resource_suffix}"
  pods_range_name        = "ip-pod"
  svc_range_name         = "ip-svc"
  subnet_names           = [for subnet_self_link in module.gcp-network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

data "google_project" "project" {
  project_id = var.project_id
}

module "utils" {
  source  = "terraform-google-modules/utils/google"
  version = "~> 0.7"
  region  = local.region
}

data "google_compute_regions" "available" {
  project = data.google_project.project.project_id
}

data "google_compute_zones" "available" {
  project = data.google_project.project.project_id
  region  = local.region
}

resource "google_container_cluster" "cluster" {
  name     = "gke-${local.resource_prefix}-${local.cluster_name}-${local.resource_suffix}"
  project  = data.google_project.project.project_id
  location = local.zone
  addons_config {
    config_connector_config {
      enabled = true
    }
    network_policy_config {
      disabled = false
    }
  }
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 1
      maximum       = 64
    }
    auto_provisioning_defaults {
      management {
        auto_repair  = true
        auto_upgrade = true
      }
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.master_authorized_range
      display_name = "myip"
    }
  }
  node_config {
    spot = true
    metadata = {
      disable-legacy-endpoints = true
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  release_channel {
    channel = "RAPID"
  }
  initial_node_count = 1
  network            = module.gcp-network.network_name
  subnetwork         = local.subnet_names[index(module.gcp-network.subnets_names, local.gke_subnet_name)]
  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.svc_range_name
  }
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
}

module "gcp-network" {
  source = "terraform-google-modules/network/google"
  #required for terraform v1.2.3 used in infrastructure manager
  version = "6.0.1"

  project_id   = data.google_project.project.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name   = local.gke_subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = local.region
    },
    {
      subnet_name   = local.master_subnet_name
      subnet_ip     = "10.60.0.0/17"
      subnet_region = local.region
    },
  ]

  secondary_ranges = {
    (local.gke_subnet_name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}
