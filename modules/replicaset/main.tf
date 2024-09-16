resource "kubernetes_deployment" "this" {
  metadata {
    name      = "java-app-deployment"
    namespace = var.namespace

    labels = {
      app = "java-app"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "java-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "java-app"
        }
      }

      spec {
        container {
          name  = "java-app"
          image = var.image

          port {
            container_port = var.container_port
            protocol       = "TCP"
          }

          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          resources {
            requests = {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
            limits = {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }
          }
        }
      }
    }
  }
}
