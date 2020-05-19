#Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {}

data "google_container_cluster" "cluster" {
  name     = "chadevops"
  location = "us-central1"
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.chadevops.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.chadevops.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_deployment" "hashi-demo" {
  metadata {
    name = "demo-app"
    labels {
      App = "container-paas"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels {
        App = "container-paas"
      }
    }
    template {
      metadata {
        labels {
          App = "container-paas"
        }
      }
      spec {
        container {
          image = var.container_image
          name  = "container-paas"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hashi-demo" {
  metadata {
    name = "container-paas-service"
  }
  spec {
    selector {
      App = "${kubernetes_deployment.hashi-demo.metadata.0.labels.App}"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = "${kubernetes_service.hashi-demo.load_balancer_ingress.0.ip}"
}
