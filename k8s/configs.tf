

resource "kubernetes_storage_class_v1" "mysql_storageclass" {
  metadata {
    name = "mysql-storageclass"
  }

  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp2"
    fsType    = "ext4"
    encrypted = "true"
  }
}

resource "kubernetes_persistent_volume" "mysql_data" {
  metadata {
    name = "mysql-data"
  }

  spec {
    capacity = {
      storage = "512Mi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "mysql-storageclass"
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      host_path {
        path = "/mnt/mysql-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_data" {
  metadata {
    name      = "mysql-data"
    namespace = "mysql-data"

    labels = {
      app = "mysql"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "512Mi"
      }
    }

    storage_class_name = "mysql-storageclass"
  }
}

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

