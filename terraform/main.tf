terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "terraform-managed"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "terraform-demo"
    namespace = kubernetes_namespace.demo.metadata[0].name

    labels = {
      app = "terraform-demo"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "terraform-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "terraform-demo"
        }
      }

      spec {
        container {
          name              = "web"
          image             = "terraform-demo:1.0"
          image_pull_policy = "Never"

          port {
            container_port = 5000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }

            initial_delay_seconds = 10
            period_seconds        = 15
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.demo]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "terraform-demo-service"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    selector = {
      app = "terraform-demo"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.app]
}