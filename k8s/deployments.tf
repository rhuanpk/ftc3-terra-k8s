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

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "mysql-data"

    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        volume {
          name = "mysql-data"

          persistent_volume_claim {
            claim_name = "mysql-data"
          }
        }

        container {
          name  = "mysql-db"
          image = "mysql:latest"

          port {
            container_port = 3306
            protocol       = "TCP"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "db"
          }

          env {
            name  = "MYSQL_PASSWORD"
            value = "admin"
          }

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "root"
          }

          env {
            name  = "MYSQL_USER"
            value = "admin"
          }

          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

