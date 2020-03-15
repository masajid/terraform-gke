provider "google" {
  version     = "~> 2.20"
  credentials = file("terraform-service-account.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_container_cluster" "default" {
  name        = var.name
  description = "Masajid cluster"

  remove_default_node_pool = true
  initial_node_count = var.initial_node_count # maybe not needed

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "default" {
  name       = "${var.name}-node-pool"
  cluster    = google_container_cluster.default.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
