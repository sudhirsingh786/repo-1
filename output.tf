output "reserved_ip_address" {
  value = module.reserve_eip.reserved_ip_address
}

output "reserved_ip_self_link" {
  value = module.reserve_eip.reserved_ip_self_link
}
output "tf_migration_marker" {
  value = "tf-1.6.3"
}

