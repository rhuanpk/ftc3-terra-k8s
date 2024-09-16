variable "namespace" {
  description = "Namespace for the Deployment"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
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
  type = map(object({
    name  = string
    value = string
  }))
}

variable "resource_limits_cpu" {
  description = "CPU limit for the container"
  type        = string
}

variable "resource_limits_memory" {
  description = "Memory limit for the container"
  type        = string
}

variable "resource_requests_cpu" {
  description = "CPU request for the container"
  type        = string
}

variable "resource_requests_memory" {
  description = "Memory request for the container"
  type        = string
}
