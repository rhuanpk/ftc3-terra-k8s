output "pdb_name" {
  value = kubernetes_pod_disruption_budget.java_app_pdb.metadata[0].name
}
