variable "replicas" {
  description = "Number of replicas to create"
  type        = number
}

######################
# GCP Resources
######################
variable "project_id" {
  description = "Project ID for resources. Defaults to provider project ID"
  type        = string
  default     = null
}

variable "region" {
  description = "GCP Region. DEfaults to provider region"
  type        = string
  default     = null
}

variable "regional_disks" {
  description = "Use regional disks. Otherwise, zonal disks will be used"
  type        = bool
  default     = false
}

variable "disks_prefix" {
  description = "Name prefix of GCE disks to creates"
  type        = string
}

variable "disk_description_template" {
  description = "Template for disk description. `<replica>` will be replaced with count index"
  type        = string
  default     = "Data replica <replca>"
}

variable "labels" {
  description = "Labels to add to GCP resources"
  type        = map(string)
  default     = {}
}

variable "disk_size" {
  description = "Size of Disk in GiB to create"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Type of disks to create"
  type        = string
  default     = "pd-balanced"
}

variable "disk_interface" {
  description = "Specifies the disk interface to use for attaching this disk, which is either SCSI or NVME. The default is SCSI. Default value is SCSI. Possible values are SCSI and NVME. Not supported on regional disks"
  type        = string
  default     = "SCSI"
}

variable "disk_source_image" {
  description = "Source image for disk. `element` will be used to index the list. Not supported on regional disks."
  type = list(object({
    image = string, # source image

    # Optional image encryption
    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.
    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.
    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console
    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.
  }))
  default = []
}

variable "disk_source_snapshot" {
  description = "Source snapshot for disk. `element` will be used to index the list"
  type = list(object({
    snapshot = string, # source snapshot

    # Optional image encryption
    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.
    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.
    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console
    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.
  }))
  default = []
}

variable "disk_encryption_key" {
  description = "One or more disk encryption keys for disks.  `element` will be used to index the list"
  type = list(object({
    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.
    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.
    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console
    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.
  }))
  default = []
}

variable "zonal_disk_zones" {
  description = "Zones for disks. `element` will be used to index the list. If not specified, all GCP zones will be used in round robin."
  type        = list(string)
  default     = []
}

variable "regional_disk_zones" {
  description = "Zones for regional disks. `element` will be used to index the list. If not specified, all GCP zones will be used in round robin."
  type        = list(list(string))
  default     = []

  validation {
    condition     = length(var.regional_disk_zones) > 0 ? alltrue([for v in var.regional_disk_zones : length(v) == 2]) : true
    error_message = "The `regional_disk_zones` variable must be list of list of string where each inner list is exactly two elements."
  }
}

######################
# Resource Policy
######################
variable "resource_policy_enabled" {
  description = "Create resource policy to periodically snapshot disks"
  type        = bool
  default     = true
}

variable "resource_policy_name" {
  description = "Name of the resource policy"
  type        = string
  default     = ""
}

variable "snapshot_labels" {
  description = "Labels to be placed on snapshots"
  type        = map(string)
  default     = {}
}

variable "snapshot_daily" {
  description = "Take snapshot of disks daily"
  default     = true
}

variable "snapshot_days_in_cycle" {
  description = "Number of days between snapshots for daily snapshots"
  default     = 1
}

variable "snapshot_start_time" {
  description = "Time in UTC format to start snapshot. Context depends on whether it's daily or hourly"
  default     = "19:00"
}

variable "snapshot_hourly" {
  description = "Take snapshot of disks hourly"
  default     = false
}

variable "snapshot_hours_in_cycle" {
  description = "Number of hours between snapshots for hourly snapshots"
  default     = 1
}

variable "snapshot_weekly" {
  description = "Take snapshot of disks weekly"
  default     = false
}

variable "snapshot_day_of_weeks" {
  description = "Map where the key is the day of the week to take snapshot and the value is the time of the day"
  default = {
    SUNDAY    = "00:00"
    WEDNESDAY = "00:00"
  }
}

variable "snapshot_retention_policy" {
  description = "Retention policy of snapshots. Set to `null` to not have any retention policy"
  type = object({
    max_retention_days    = number           # Maximum age of the snapshot that is allowed to be kept.
    on_source_disk_delete = optional(string) # Specifies the behavior to apply to scheduled snapshots when the source disk is deleted. Default value is KEEP_AUTO_SNAPSHOTS. Possible values are KEEP_AUTO_SNAPSHOTS and APPLY_RETENTION_POLICY.
  })
  default = {
    max_retention_days    = 14
    on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
  }
}

variable "snapshot_storage_locations" {
  description = "Cloud Storage bucket location to store the auto snapshot (regional or multi-regional). Defaults to region in `var.region` or provider region"
  type        = list(string)
  default     = []
}

######################
# GKE Resources
######################
variable "pv_prefix" {
  description = "Prefix of PVC and PV to create. Name will be joined with `-<number>"
  type        = string
}

variable "kubernetes_annotations" {
  description = "Annotations for Kubernetes resources"
  type        = map(string)
  default     = {}
}

variable "kubernetes_labels" {
  description = "Labels for Kubernetes resources"
  type        = map(string)
  default     = {}
}

variable "pvc_namespace" {
  description = "Namespace for PVC"
  type        = string
  default     = "default"
}

variable "storage_class_name" {
  description = "StorageClassName for PV"
  default     = ""
}
