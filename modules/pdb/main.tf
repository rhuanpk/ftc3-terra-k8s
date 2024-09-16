resource "kubernetes_pod_disruption_budget" "java_app_pdb" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    min_available = var.min_available

    selector {
      match_labels = var.match_labels
    }
  }
}
