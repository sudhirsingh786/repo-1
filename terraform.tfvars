# GCP Project ID - Update with your actual project ID
project_id = "youtube-pro-461913"

region = "us-central1"
zone   = "us-central1-a"

disk_name   = "test-disk"
disk_size_gb = 10
disk_type   = "pd-standard"

labels = {
  environment = "test"
  terraform   = "true"
  purpose     = "migration-testing"
}
