variable "name" {
  description = "Name of the MySQL deployment"
  type        = string
}

variable "namespace" {
  description = "Namespace for the MySQL deployment"
  type        = string
}

variable "labels_app" {
  description = "Label for the app"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image" {
  description = "Image of the container"
  type        = string
}

variable "container_port" {
  description = "Port for the container"
  type        = number
}

variable "env_vars" {
  description = "Environment variables for the container"
  type        = map(object({
    name  = string
    value = string
  }))
}

variable "volume_name" {
  description = "Name of the volume"
  type        = string
}

variable "persistent_volume_claim_name" {
  description = "Name of the persistent volume claim"
  type        = string
}

variable "mount_path" {
  description = "Mount path for the volume"
  type        = string
}

variable "restart_policy" {
  description = "Restart policy for the deployment"
  type        = string
}

variable "strategy_type" {
  description = "Deployment strategy type"
  type        = string
}
