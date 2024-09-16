output "deployment_name" {
  description = "The name of the Deployment"
  value       = kubernetes_deployment.this.metadata[0].name
}
