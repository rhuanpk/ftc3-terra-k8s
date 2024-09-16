output "storage_class_name" {
  value = kubernetes_storage_class_v1.mysql_storageclass.metadata[0].name
}

output "persistent_volume_name" {
  value = kubernetes_persistent_volume.mysql_data.metadata[0].name
}

output "persistent_volume_claim_name" {
  value = kubernetes_persistent_volume_claim.mysql_data.metadata[0].name
}
