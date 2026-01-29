module "service_account" {
  source = "git::https://github.com/sudhirsingh786/repo-2.git?ref=sa-test"

  project_id = var.project_id
  sa_name    = var.sa_name
  labels     = var.labels
}
output "service_account_email" {
  value = google_service_account.this.email
}
output "state_change_marker" {
  value = timestamp()
}
