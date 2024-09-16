resource "kubernetes_namespace" "java_app" {
  metadata {
    name = "java-app"
  }
}

resource "kubernetes_namespace" "mysql_data" {
  metadata {
    name = "mysql-data"
  }
}