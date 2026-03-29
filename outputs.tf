output "disk_id" {
  description = "The unique identifier of the disk"
  value       = google_compute_disk.test_disk.id
}

output "disk_name" {
  description = "The name of the disk"
  value       = google_compute_disk.test_disk.name
}

output "disk_self_link" {
  description = "The URI of the created resource"
  value       = google_compute_disk.test_disk.self_link
}

output "disk_size_gb" {
  description = "The size of the disk in GB"
  value       = google_compute_disk.test_disk.size_gb
}
