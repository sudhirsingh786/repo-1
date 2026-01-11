variable "project_id" {}

variable "sa_name" {
  description = "Service account name (without domain)"
}

variable "labels" {
  type = map(string)
}
