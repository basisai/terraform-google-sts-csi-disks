resource "google_compute_disk" "disk" {
  provider = google-beta
  count    = !var.regional_disks ? var.replicas : 0

  name        = join("-", [var.disks_prefix, count.index])
  description = replace(var.disk_description_template, "<replica>", count.index)

  type      = var.disk_type
  size      = var.disk_size
  interface = var.disk_interface

  # Automatically applied GKE labels: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-managing-labels
  labels  = merge(var.labels, { goog-gke-volume = "" })
  project = var.project_id

  zone = element(coalescelist(var.zonal_disk_zones, data.google_compute_zones.available.names), count.index)

  image = length(var.disk_source_image) > 0 ? element(var.disk_source_image, count.index).image : null
  dynamic "source_image_encryption_key" {
    for_each = length(var.disk_source_image) > 0 ? (
      anytrue([for k, v in element(var.disk_source_image, count.index) : k != "image" && v != null]) ? [element(var.disk_source_image, count.index)] : []
    ) : []

    content {
      raw_key                 = source_image_encryption_key.value.raw_key
      sha256                  = source_image_encryption_key.value.sha256
      kms_key_self_link       = source_image_encryption_key.value.kms_key_self_link
      kms_key_service_account = source_image_encryption_key.value.kms_key_service_account
    }
  }

  snapshot = length(var.disk_source_snapshot) > 0 ? element(var.disk_source_snapshot, count.index).snapshot : null
  dynamic "source_snapshot_encryption_key" {
    for_each = length(var.disk_source_snapshot) > 0 ? (
      anytrue([for k, v in element(var.disk_source_snapshot, count.index) : k != "snapshot" && v != null]) ? [element(var.disk_source_snapshot, count.index)] : []
    ) : []

    content {
      raw_key                 = source_snapshot_encryption_key.value.raw_key
      sha256                  = source_snapshot_encryption_key.value.sha256
      kms_key_self_link       = source_snapshot_encryption_key.value.kms_key_self_link
      kms_key_service_account = source_snapshot_encryption_key.value.kms_key_service_account
    }
  }

  dynamic "disk_encryption_key" {
    for_each = length(var.disk_encryption_key) > 0 ? (
      anytrue([for v in values(element(var.disk_encryption_key, count.index)) : v != null]) ? [element(var.disk_encryption_key, count.index)] : []
    ) : []

    content {
      raw_key                 = disk_encryption_key.value.raw_key
      sha256                  = disk_encryption_key.value.sha256
      kms_key_self_link       = disk_encryption_key.value.kms_key_self_link
      kms_key_service_account = disk_encryption_key.value.kms_key_service_account
    }
  }
}

resource "google_compute_region_disk" "disk" {
  provider = google-beta
  count    = var.regional_disks ? var.replicas : 0

  name        = join("-", [var.disks_prefix, count.index])
  description = replace(var.disk_description_template, "<replica>", count.index)

  type = var.disk_type
  size = var.disk_size

  # Automatically applied GKE labels: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-managing-labels
  labels  = merge(var.labels, { goog-gke-volume = "" })
  project = var.project_id

  replica_zones = coalescelist(
    try(element(var.regional_disk_zones, count.index), []),
    [element(data.google_compute_zones.available.names, count.index), element(data.google_compute_zones.available.names, count.index + 1)]
  )

  snapshot = length(var.disk_source_snapshot) > 0 ? element(var.disk_source_snapshot, count.index).snapshot : null
  dynamic "source_snapshot_encryption_key" {
    for_each = length(var.disk_source_snapshot) > 0 ? (
      anytrue([for k, v in element(var.disk_source_snapshot, count.index) : k != "snapshot" && v != null]) ? [element(var.disk_source_snapshot, count.index)] : []
    ) : []

    content {
      raw_key      = source_snapshot_encryption_key.value.raw_key
      sha256       = source_snapshot_encryption_key.value.sha256
      kms_key_name = source_snapshot_encryption_key.value.kms_key_self_link
    }
  }

  dynamic "disk_encryption_key" {
    for_each = length(var.disk_encryption_key) > 0 ? (
      anytrue([for v in values(element(var.disk_encryption_key, count.index)) : v != null]) ? [element(var.disk_encryption_key, count.index)] : []
    ) : []

    content {
      raw_key      = disk_encryption_key.value.raw_key
      sha256       = disk_encryption_key.value.sha256
      kms_key_name = disk_encryption_key.value.kms_key_self_link
    }
  }
}
