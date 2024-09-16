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

resource "kubernetes_service" "mysql" {
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