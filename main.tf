module "reserve_eip" {
  source = "git::https://github.com/sudhirsingh786/repo-2.git?ref=bucket-test"

  project_id = var.project_id
  region     = var.region

  name   = var.name
  labels = var.labels
}
