
resource "google_compute_resource_policy" "backup" {
  provider = google-beta
  count    = var.resource_policy_enabled ? 1 : 0

  name    = var.resource_policy_name
  region  = var.region
  project = var.project_id

  snapshot_schedule_policy {
    schedule {
      dynamic "hourly_schedule" {
        for_each = var.snapshot_hourly ? [{}] : []
        content {
          hours_in_cycle = var.snapshot_hours_in_cycle
          start_time     = var.snapshot_start_time
        }
      }

      dynamic "daily_schedule" {
        for_each = var.snapshot_daily ? [{}] : []
        content {
          days_in_cycle = var.snapshot_days_in_cycle
          start_time    = var.snapshot_start_time
        }
      }

      dynamic "weekly_schedule" {
        for_each = var.snapshot_weekly ? [{}] : []
        content {
          dynamic "day_of_weeks" {
            for_each = var.snapshot_day_of_weeks

            content {
              day        = day_of_weeks.key
              start_time = day_of_weeks.value
            }
          }
        }
      }
    }

    dynamic "retention_policy" {
      for_each = var.snapshot_retention_policy != null ? [var.snapshot_retention_policy] : []

      content {
        max_retention_days    = retention_policy.value.max_retention_days
        on_source_disk_delete = retention_policy.value.on_source_disk_delete
      }
    }

    snapshot_properties {
      labels            = var.snapshot_labels
      storage_locations = try(coalescelist(var.snapshot_storage_locations, compact([var.region])), null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_disk_resource_policy_attachment" "backup" {
  provider = google-beta
  count    = var.resource_policy_enabled && !var.regional_disks ? var.replicas : 0

  name = google_compute_resource_policy.backup[0].name
  disk = google_compute_disk.disk[count.index].name
  zone = google_compute_disk.disk[count.index].zone

  project = var.project_id
}

resource "google_compute_region_disk_resource_policy_attachment" "backup" {
  provider = google-beta
  count    = var.resource_policy_enabled && var.regional_disks ? var.replicas : 0

  name   = google_compute_resource_policy.backup[0].name
  disk   = google_compute_region_disk.disk[count.index].name
  region = google_compute_region_disk.disk[count.index].region

  project = var.project_id
}
