
resource "kubernetes_persistent_volume" "disk" {
  count = var.replicas

  metadata {
    name = join("-", [var.pv_prefix, count.index])

    annotations = var.kubernetes_annotations
    labels      = var.kubernetes_labels
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    capacity = {
      storage = "${var.disk_size}G"
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.gke.io/zone"
            operator = "In"
            values = var.regional_disks ? (
              google_compute_region_disk.disk[count.index].replica_zones
              ) : (
              [google_compute_disk.disk[count.index].zone]
            )
          }
        }
      }
    }

    persistent_volume_source {
      csi {
        driver        = "pd.csi.storage.gke.io"
        volume_handle = var.regional_disks ? google_compute_region_disk.disk[count.index].id : google_compute_disk.disk[count.index].id
        fs_type       = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "disk" {
  count = var.replicas

  metadata {
    name = join("-", [var.pv_prefix, count.index])

    annotations = var.kubernetes_annotations
    labels      = var.kubernetes_labels

    namespace = var.pvc_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    volume_name  = kubernetes_persistent_volume.disk[count.index].metadata[0].name

    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = "${var.disk_size}G"
      }
    }
  }
}
