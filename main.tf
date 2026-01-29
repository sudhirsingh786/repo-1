module "service_account" {
  source = "git::https://github.com/sudhirsingh786/repo-2.git?ref=sa-test"

  project_id = var.project_id
  sa_name    = var.sa_name
  labels     = var.labels
}
