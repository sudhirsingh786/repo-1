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

variable "disk_name" {
  description = "Name of the GCP disk"
  type        = string
  default     = "test-disk"
}

variable "disk_size_gb" {
  description = "Size of the disk in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Type of disk (pd-standard, pd-balanced, pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "labels" {
  description = "Labels to apply to the disk"
  type        = map(string)
  default = {
    environment = "test"
    terraform   = "true"
  }
}
