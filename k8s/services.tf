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
