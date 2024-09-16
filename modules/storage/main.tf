resource "kubernetes_storage_class_v1" "mysql_storageclass" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner    = var.provisioner
  reclaim_policy         = var.reclaim_policy
  allow_volume_expansion = var.allow_volume_expansion
  volume_binding_mode    = var.volume_binding_mode

  parameters = {
    type      = var.type
    fsType    = var.fs_type
    encrypted = var.encrypted
  }
}

resource "kubernetes_persistent_volume" "mysql_data" {
  depends_on = [kubernetes_storage_class_v1.mysql_storageclass]
  metadata {
    name = var.persistent_volume_name
  }

  spec {
    capacity = {
      storage = var.storage_capacity
    }
    access_modes                     = var.access_modes
    storage_class_name               = var.storage_class_name
    volume_mode                      = var.volume_mode
    persistent_volume_reclaim_policy = var.reclaim_policy
    persistent_volume_source {
      host_path {
        path = var.host_path
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_data" {
  depends_on = [kubernetes_storage_class_v1.mysql_storageclass]
  metadata {
    name      = var.persistent_volume_claim_name
    namespace = var.namespace

    labels = {
      app = var.app_label
    }
  }

  spec {
    access_modes = var.access_modes

    resources {
      requests = {
        storage = var.storage_capacity
      }
    }

    storage_class_name = var.storage_class_name
  }
}
