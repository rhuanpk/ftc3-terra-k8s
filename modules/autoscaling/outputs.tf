output "hpa_name" {
  value = kubernetes_horizontal_pod_autoscaler.java_app_hpa.metadata[0].name
}
