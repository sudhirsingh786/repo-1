# GCP Project ID - Update with your actual project ID
project_id = "youtube-pro-461913"

region = "us-central1"
zone   = "us-central1-a"

instance_name = "test-vm-instance"
machine_type  = "e2-small"
attached_disk_name = "test-disk"  # Must match the disk name from disk branch
image_family  = "debian-11"
image_project = "debian-cloud"

labels = {
  environment = "test"
  terraform   = "true"
  purpose     = "migration-testing"
}
