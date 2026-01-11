module "gcs_bucket" {
  source = "git::https://github.com/sudhirsingh786/repo-2.git?ref=bucket-test"

  bucket_name = var.bucket_name
  project_id  = var.project_id
  labels      = var.labels
}
