terraform {
  backend "gcs" {
    bucket  = "bucket-terraform-state-786"
    prefix  = "test-service-account"
  }
}
