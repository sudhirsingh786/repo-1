output "instance_id" {
  description = "The unique identifier of the instance"
  value       = google_compute_instance.test_instance.id
}

output "instance_name" {
  description = "The name of the instance"
  value       = google_compute_instance.test_instance.name
}

output "instance_self_link" {
  description = "The URI of the instance"
  value       = google_compute_instance.test_instance.self_link
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = try(google_compute_instance.test_instance.network_interface[0].access_config[0].nat_ip, "")
}

output "instance_internal_ip" {
  description = "Internal IP address of the instance"
  value       = google_compute_instance.test_instance.network_interface[0].network_ip
}

output "attached_disk_name" {
  description = "Name of the attached disk (referenced via data source)"
  value       = data.google_compute_disk.attached_disk.name
}

output "attached_disk_self_link" {
  description = "Self link of the attached disk"
  value       = data.google_compute_disk.attached_disk.self_link
}

output "attached_disk_size_gb" {
  description = "Size of the attached disk in GB"
  value       = data.google_compute_disk.attached_disk.size
}
