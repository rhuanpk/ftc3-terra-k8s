resource "kubernetes_horizontal_pod_autoscaler" "java_app_hpa" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    scale_target_ref {
      kind        = var.target_kind
      name        = var.target_name
      api_version = var.api_version
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    metric {
      type = var.metric_type

      resource {
        name = var.resource_name

        target {
          type                = var.target_type
          average_utilization = var.average_utilization
        }
      }
    }
  }
}
