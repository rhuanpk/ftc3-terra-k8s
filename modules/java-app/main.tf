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

          resources {
            limits = {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }

            requests = {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
          }
        }

        restart_policy = var.restart_policy
      }
    }
  }
}

resource "kubernetes_service" "java_app_service_load_balancer" {
  metadata {
    name      = "java-app-service-load-balancer"
    namespace = "java-app"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }

    selector = {
      app = "java-app"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "java_app" {
  metadata {
    name      = "java-app"
    namespace = "java-app"
  }

  spec {
    port {
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "java-app"
    }
  }
}
