terraform {
  backend "gcs" {
    bucket  = "bucket-terraform-state-786"
    prefix  = "ecom-eip"
  }
}