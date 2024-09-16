variable "storage_class_name" {
  description = "Name of the storage class"
  type        = string
}

variable "provisioner" {
  description = "Storage provisioner"
  type        = string
}

variable "reclaim_policy" {
  description = "Reclaim policy for the storage class"
  type        = string
}

variable "allow_volume_expansion" {
  description = "Allow volume expansion"
  type        = bool
}

variable "volume_binding_mode" {
  description = "Volume binding mode"
  type        = string
}

variable "type" {
  description = "Type of the storage (e.g., gp2)"
  type        = string
}

variable "fs_type" {
  description = "Filesystem type"
  type        = string
}

variable "encrypted" {
  description = "Encryption flag"
  type        = string
}

variable "persistent_volume_name" {
  description = "Name of the persistent volume"
  type        = string
}

variable "persistent_volume_claim_name" {
  description = "Name of the persistent volume claim"
  type        = string
}

variable "namespace" {
  description = "Namespace for the persistent volume claim"
  type        = string
}

variable "app_label" {
  description = "Label for the app"
  type        = string
}

variable "storage_capacity" {
  description = "Storage capacity"
  type        = string
}

variable "access_modes" {
  description = "Access modes for the persistent volume and claim"
  type        = list(string)
}

variable "volume_mode" {
  description = "Volume mode"
  type        = string
}

variable "host_path" {
  description = "Path for host path volume source"
  type        = string
}
