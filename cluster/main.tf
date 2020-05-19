provider "google" {
  #  credentials = file("account.json")
  project = var.project_id
  region  = "us-central1"
}

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = "us-central1-a"
  initial_node_count = 3

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      owner = "akentosh"
    }

    tags = ["tfc", "akentosh"]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
