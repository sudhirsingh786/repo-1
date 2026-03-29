variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "test-vm-instance"
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-small"
}

variable "attached_disk_name" {
  description = "Name of the persistent disk to attach (from disk branch)"
  type        = string
  default     = "test-disk"
}

variable "image_family" {
  description = "Image family for the boot disk"
  type        = string
  default     = "debian-11"
}

variable "image_project" {
  description = "Project containing the image"
  type        = string
  default     = "debian-cloud"
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default = {
    environment = "test"
    terraform   = "true"
  }
}
