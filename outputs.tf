output "pd" {
  description = "List of persistent Disk IDs"
  value       = var.regional_disks ? google_compute_region_disk.disk[*].id : google_compute_disk.disk[*].id
}

output "resource_policy" {
  description = "Resource Policy ID, if enabled"
  value       = var.resource_policy_enabled ? google_compute_resource_policy.backup[0].id : null
}

output "pv" {
  description = "List of names of PV/PVC created"
  value       = [for disk in kubernetes_persistent_volume_claim.disk : disk.metadata[0].name]
}
