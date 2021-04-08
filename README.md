# StatefulSet GCE Disks with CSI Driver

This module provisions multiple GCE disks (zonal or regional) for use with a `StatefulSet` in a
GKE cluster backed by CSI drivers.

This **requires** a GKE cluster with CSI drivers enabled.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| google-beta | >= 3.38 |
| kubernetes | >= 1.11.4 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| google-beta | >= 3.38 |
| kubernetes | >= 1.11.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| disk\_description\_template | Template for disk description. `<replica>` will be replaced with count index | `string` | `"Data replica <replca>"` | no |
| disk\_encryption\_key | One or more disk encryption keys for disks.  `element` will be used to index the list | <pre>list(object({<br>    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.<br>    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.<br>    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console<br>    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.<br>  }))</pre> | `[]` | no |
| disk\_interface | Specifies the disk interface to use for attaching this disk, which is either SCSI or NVME. The default is SCSI. Default value is SCSI. Possible values are SCSI and NVME. Not supported on regional disks | `string` | `"SCSI"` | no |
| disk\_size | Size of Disk in GiB to create | `number` | `10` | no |
| disk\_source\_image | Source image for disk. `element` will be used to index the list. Not supported on regional disks. | <pre>list(object({<br>    image = string, # source image<br><br>    # Optional image encryption<br>    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.<br>    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.<br>    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console<br>    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.<br>  }))</pre> | `[]` | no |
| disk\_source\_snapshot | Source image for disk. `element` will be used to index the list | <pre>list(object({<br>    snapshot = string, # source snapshot<br><br>    # Optional image encryption<br>    raw_key                 = optional(string), # Specifies a 256-bit customer-supplied encryption key, encoded in RFC 4648 base64 to either encrypt or decrypt this resource.<br>    sha256                  = optional(string), # The RFC 4648 base64 encoded SHA-256 hash of the customer-supplied encryption key that protects this resource.<br>    kms_key_self_link       = optional(string), # The self link of the encryption key used to encrypt the disk. Also called KmsKeyName in the cloud console<br>    kms_key_service_account = optional(string), # The service account used for the encryption request for the given KMS key.<br>  }))</pre> | `[]` | no |
| disk\_type | Type of disks to create | `string` | `"pd-balanced"` | no |
| disks\_prefix | Name prefix of GCE disks to creates | `string` | n/a | yes |
| kubernetes\_annotations | Annotations for Kubernetes resources | `map(string)` | `{}` | no |
| kubernetes\_labels | Labels for Kubernetes resources | `map(string)` | `{}` | no |
| labels | Labels to add to GCP resources | `map(string)` | `{}` | no |
| project\_id | Project ID for resources. Defaults to provider project ID | `string` | `null` | no |
| pv\_prefix | Prefix of PVC and PV to create. Name will be joined with `-<number>` | `string` | n/a | yes |
| pvc\_namespace | Namespace for PVC | `string` | `"default"` | no |
| region | GCP Region. DEfaults to provider region | `string` | `null` | no |
| regional\_disk\_zones | Zones for regional disks. `element` will be used to index the list. If not specified, all GCP zones will be used in round robin. | `list(list(string))` | `[]` | no |
| regional\_disks | Use regional disks. Otherwise, zonal disks will be used | `bool` | `false` | no |
| replicas | Number of replicas to create | `number` | n/a | yes |
| resource\_policy\_enabled | Create resource policy to periodically snapshot disks | `bool` | `true` | no |
| resource\_policy\_name | Name of the resource policy | `string` | `""` | no |
| snapshot\_daily | Take snapshot of disks daily | `bool` | `true` | no |
| snapshot\_day\_of\_weeks | Map where the key is the day of the week to take snapshot and the value is the time of the day | `map` | <pre>{<br>  "SUNDAY": "00:00",<br>  "WEDNESDAY": "00:00"<br>}</pre> | no |
| snapshot\_days\_in\_cycle | Number of days between snapshots for daily snapshots | `number` | `1` | no |
| snapshot\_hourly | Take snapshot of disks hourly | `bool` | `false` | no |
| snapshot\_hours\_in\_cycle | Number of hours between snapshots for hourly snapshots | `number` | `1` | no |
| snapshot\_labels | Labels to be placed on snapshots | `map(string)` | `{}` | no |
| snapshot\_retention\_policy | Retention policy of snapshots. Set to `null` to not have any retention policy | <pre>object({<br>    max_retention_days    = number           # Maximum age of the snapshot that is allowed to be kept.<br>    on_source_disk_delete = optional(string) # Specifies the behavior to apply to scheduled snapshots when the source disk is deleted. Default value is KEEP_AUTO_SNAPSHOTS. Possible values are KEEP_AUTO_SNAPSHOTS and APPLY_RETENTION_POLICY.<br>  })</pre> | <pre>{<br>  "max_retention_days": 14,<br>  "on_source_disk_delete": "KEEP_AUTO_SNAPSHOTS"<br>}</pre> | no |
| snapshot\_start\_time | Time in UTC format to start snapshot. Context depends on whether it's daily or hourly | `string` | `"19:00"` | no |
| snapshot\_storage\_locations | Cloud Storage bucket location to store the auto snapshot (regional or multi-regional). Defaults to region in `var.region` or provider region | `list(string)` | `[]` | no |
| snapshot\_weekly | Take snapshot of disks weekly | `bool` | `false` | no |
| storage\_class\_name | StorageClassName for PV | `string` | `""` | no |
| zonal\_disk\_zones | Zones for disks. `element` will be used to index the list. If not specified, all GCP zones will be used in round robin. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| pd | List of persistent Disk IDs |
| pv | List of names of PV/PVC created |
| resource\_policy | Resource Policy ID, if enabled |
