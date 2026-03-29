resource "google_compute_disk" "test_disk" {
  name        = var.disk_name
  type        = "zones/${var.zone}/${var.disk_type}"
  zone        = var.zone
  size_gb     = var.disk_size_gb
  labels      = var.labels
}
