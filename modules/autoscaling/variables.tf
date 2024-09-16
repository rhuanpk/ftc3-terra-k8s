variable "name" {
  description = "Name of the Horizontal Pod Autoscaler"
  type        = string
}

variable "namespace" {
  description = "Namespace for the Horizontal Pod Autoscaler"
  type        = string
}

variable "target_kind" {
  description = "Kind of the resource to scale"
  type        = string
}

variable "target_name" {
  description = "Name of the resource to scale"
  type        = string
}

variable "api_version" {
  description = "API version of the resource to scale"
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
}

variable "metric_type" {
  description = "Type of metric"
  type        = string
}

variable "resource_name" {
  description = "Name of the resource metric"
  type        = string
}

variable "target_type" {
  description = "Type of target for the metric"
  type        = string
}

variable "average_utilization" {
  description = "Average CPU utilization"
  type        = number
}
