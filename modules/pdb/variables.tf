variable "name" {
  description = "Name of the Pod Disruption Budget"
  type        = string
}

variable "namespace" {
  description = "Namespace for the Pod Disruption Budget"
  type        = string
}

variable "min_available" {
  description = "Minimum number of available pods"
  type        = string
}

variable "match_labels" {
  description = "Labels to match pods for the Pod Disruption Budget"
  type        = map(string)
}
