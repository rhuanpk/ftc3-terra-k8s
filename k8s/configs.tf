resource "kubernetes_horizontal_pod_autoscaler" "java_app_hpa" {
  metadata {
    name      = "java-app-hpa"
    namespace = "java-app"
  }

  spec {
    scale_target_ref {
      kind        = "Deployment"
      name        = "java-app"
      api_version = "apps/v1"
    }

    min_replicas = 2
    max_replicas = 10

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget" "java_app_pdb" {
  metadata {
    name      = "java-app-pdb"
    namespace = "java-app"
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        app = "java-app"
      }
    }
  }
}

