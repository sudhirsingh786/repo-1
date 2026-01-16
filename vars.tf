variable "project_id" {}
variable "region" {
  description = "GCP region for the reserved IP (e.g. us-central1)"
  type        = string
}
variable "name" {
  description = "Name for the reserved external IP"
  type        = string
}
variable "labels" {
  description = "Labels to attach to the IP"
  type        = map(string)
  default     = {}
}

