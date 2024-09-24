resource "kubernetes_deployment" "java_app" {
  metadata {
    name      = "java-app"
    namespace = "java-app"

    labels = {
      app = "java-app"
    }
  }

  spec {
    replicas = 4

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
          image = "filipeborba/fast-food-app:v7"

          port {
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "admin"
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://mysql.mysql-data.svc.cluster.local:3306/db"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "admin"
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }

            requests = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_replica_set" "java_app_replicaset" {
  metadata {
    name      = "java-app-replicaset"
    namespace = "java-app"
  }

  spec {
    replicas = 2

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
          image = "filipeborba/fast-food-app:v7"

          env {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "admin"
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://mysql.mysql-data.svc.cluster.local:3306/db"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "admin"
          }

          port {
            container_port = 8080
            protocol      = "TCP"
          }

          resources {
            requests {
              memory = "256Mi"
              cpu    = "500m"
            }

            limits {
              memory = "1Gi"
              cpu    = "1000m"
            }
          }
        }
      }
    }
  }
}
