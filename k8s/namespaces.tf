resource "kubernetes_namespace" "java_app" {
  metadata {
    name = "java-app"
  }
}