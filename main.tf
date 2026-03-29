# Data source to reference the persistent disk created in disk branch
data "google_compute_disk" "attached_disk" {
  name    = var.attached_disk_name
  zone    = var.zone
  project = var.project_id
}

# Data source to get the latest image from the specified family
data "google_compute_image" "debian_image" {
  family      = var.image_family
  project     = var.image_project
}

# Compute instance with attached persistent disk
resource "google_compute_instance" "test_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
      size  = 10
      type  = "pd-standard"
    }
  }

  # Attach the persistent disk to the instance using data source
  attached_disk {
    source = data.google_compute_disk.attached_disk.self_link
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    
    # Wait for external disk to appear
    echo "Waiting for external disk /dev/sdb..."
    for i in {1..30}; do
      if [ -b /dev/sdb ]; then
        echo "External disk detected"
        break
      fi
      sleep 1
    done
    
    # Format disk
    mkfs.ext4 -F /dev/sdb
    
    # Create mount point
    mkdir -p /mnt/external-disk
    
    # Add to fstab
    echo "/dev/sdb /mnt/external-disk ext4 defaults,nofail 0 2" >> /etc/fstab
    
    # Mount disk
    mount /mnt/external-disk
    
    echo "External disk mounted at /mnt/external-disk"
  EOF

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  depends_on = [data.google_compute_disk.attached_disk]
}
