resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      app = var.labels_app
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.labels_app
      }
    }

    template {
      metadata {
        labels = {
          app = var.labels_app
        }
      }

      spec {
        volume {
          name = var.volume_name

          persistent_volume_claim {
            claim_name = var.persistent_volume_claim_name
          }
        }

        container {
          name  = var.container_name
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

          volume_mount {
            name       = var.volume_name
            mount_path = var.mount_path
          }
        }

        restart_policy = var.restart_policy
      }
    }

    strategy {
      type = var.strategy_type
    }
  }
}

resource "kubernetes_service" "mysql" {
  depends_on = [ kubernetes_deployment.this ]
  metadata {
    name      = "mysql"
    namespace = "mysql-data"

    labels = {
      app = "mysql"
    }
  }

  spec {
    port {
      name        = "mysql"
      port        = 3306
      target_port = "3306"
    }

    selector = {
      app = "mysql"
    }
  }
}
