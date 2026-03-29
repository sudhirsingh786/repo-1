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
    set -e
    
    # Logging
    exec > >(tee /var/log/startup-script.log)
    exec 2>&1
    
    echo "========== VM Startup Script Started =========="
    echo "Timestamp: $(date)"
    
    # Update system packages
    echo "Updating system packages..."
    apt-get update || echo "Warning: apt-get update had issues"
    
    # Install required tools
    echo "Installing required packages..."
    apt-get install -y \
      google-cloud-sdk \
      default-jre \
      default-jdk \
      wget \
      curl \
      git || echo "Warning: Some packages may not have installed"
    
    # Wait and detect attached disk
    echo "Waiting for disk to attach..."
    MAX_RETRIES=30
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
      if [ -b /dev/sdb ]; then
        echo "External disk /dev/sdb detected!"
        break
      fi
      RETRY_COUNT=$((RETRY_COUNT + 1))
      sleep 2
    done
    
    if [ ! -b /dev/sdb ]; then
      echo "ERROR: External disk not found after waiting"
      exit 1
    fi
    
    # Create mount point
    echo "Creating mount point..."
    mkdir -p /mnt/external-disk || echo "Mount point already exists"
    
    # Format disk if not already formatted
    echo "Checking disk format..."
    if ! sudo blkid /dev/sdb 2>/dev/null | grep -q ext4; then
      echo "Formatting disk as ext4..."
      sudo mkfs.ext4 -F /dev/sdb || echo "Warning: Disk may already be formatted"
    else
      echo "Disk already formatted with ext4"
    fi
    
    # Mount the disk
    echo "Mounting external disk..."
    if ! grep -q /dev/sdb /etc/fstab; then
      echo "/dev/sdb /mnt/external-disk ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
    fi
    
    sudo mount /mnt/external-disk || echo "Disk already mounted"
    echo "Disk mounted successfully at /mnt/external-disk"
    
    # Set permissions
    sudo chmod 755 /mnt/external-disk
    
    # Create test files on external disk
    echo "Creating test files on external disk..."
    sudo bash -c 'cat > /mnt/external-disk/disk-verification.txt << "EOL"
Disk Attached On: $(date)
Hostname: $(hostname)
VM Instance: Testing external disk attachment
EOL'
    
    sudo bash -c 'cat > /mnt/external-disk/system-info.json << "EOL"
{
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "disk_path": "/dev/sdb",
  "mount_point": "/mnt/external-disk",
  "purpose": "External storage for GeoServer"
}
EOL'
    
    # Create GeoServer data directory on external disk
    echo "Creating GeoServer data directory..."
    sudo mkdir -p /mnt/external-disk/geoserver-data
    sudo chmod 755 /mnt/external-disk/geoserver-data
    
    # Backup verification output
    sudo bash -c 'df -h > /mnt/external-disk/disk-usage.txt'
    sudo bash -c 'lsblk >> /mnt/external-disk/disk-usage.txt'
    
    # Install GeoServer on external disk
    echo "Installing GeoServer on external disk..."
    GEOSERVER_VERSION="2.23.1"
    GEOSERVER_EXTERNAL="/mnt/external-disk/geoserver"
    GEOSERVER_HOME="/opt/geoserver"
    
    # Create geoserver user
    sudo useradd -m -d /mnt/external-disk/geoserver geoserver 2>/dev/null || echo "geoserver user already exists"
    
    # Download and install GeoServer on external disk
    cd /tmp
    echo "Downloading GeoServer version $GEOSERVER_VERSION..."
    wget -q https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip/download -O geoserver.zip || {
      echo "ERROR: Failed to download GeoServer"
      exit 1
    }
    
    # Extract to external disk
    echo "Extracting GeoServer to external disk..."
    sudo unzip -q geoserver.zip -d $GEOSERVER_EXTERNAL || echo "Warning: GeoServer extraction had issues"
    sudo chown -R geoserver:geoserver $GEOSERVER_EXTERNAL
    sudo chmod +x $GEOSERVER_EXTERNAL/bin/startup.sh
    
    # Create symlink from /opt/geoserver to external disk
    echo "Creating symlink: /opt/geoserver -> /mnt/external-disk/geoserver..."
    sudo ln -sfn $GEOSERVER_EXTERNAL $GEOSERVER_HOME
    
    # Create GeoServer data directory on external disk
    echo "Creating GeoServer data directory..."
    sudo mkdir -p /mnt/external-disk/geoserver-data
    sudo mkdir -p /mnt/external-disk/geoserver-logs
    sudo chmod 755 /mnt/external-disk/geoserver-data
    sudo chmod 755 /mnt/external-disk/geoserver-logs
    
    # Create GeoServer configuration on external disk
    sudo bash -c 'cat > /mnt/external-disk/geoserver-env.sh << "EOL"
#!/bin/bash
export GEOSERVER_HOME=/mnt/external-disk/geoserver
export GEOSERVER_DATA_DIR=/mnt/external-disk/geoserver-data
export GEOSERVER_LOG_DIR=/mnt/external-disk/geoserver-logs
export JAVA_HOME=/usr/lib/jvm/default-java
export JAVA_OPTS="-Xms256m -Xmx512m"
echo "GeoServer environment configured"
echo "GEOSERVER_HOME: $GEOSERVER_HOME"
echo "GEOSERVER_DATA_DIR: $GEOSERVER_DATA_DIR"
echo "GEOSERVER_LOG_DIR: $GEOSERVER_LOG_DIR"
EOL'
    
    sudo chmod +x /mnt/external-disk/geoserver-env.sh
    
    # ========== COMPREHENSIVE VERIFICATION ==========
    echo ""
    echo "========== COMPREHENSIVE VERIFICATION =========="
    echo ""
    
    # 1. Filesystem Information
    echo "========== 1. FILESYSTEM INFORMATION =========="
    echo "Mounted filesystems:"
    df -h
    echo ""
    echo "Block devices:"
    lsblk
    echo ""
    
    # 2. External Disk Details
    echo "========== 2. EXTERNAL DISK DETAILS =========="
    echo "External Disk Mount:"
    mount | grep /dev/sdb
    echo ""
    echo "External Disk Space:"
    df -h /mnt/external-disk
    echo ""
    echo "External Disk Inode Usage:"
    df -i /mnt/external-disk
    echo ""
    
    # 3. /mnt Directory Structure
    echo "========== 3. /MNT DIRECTORY STRUCTURE =========="
    echo "Directory tree of /mnt:"
    tree /mnt/external-disk 2>/dev/null || find /mnt/external-disk -type d
    echo ""
    echo "Detailed file listing:"
    ls -lRah /mnt/external-disk
    echo ""
    
    # 4. GeoServer Installation
    echo "========== 4. GEOSERVER INSTALLATION =========="
    echo "GeoServer Symlink Status:"
    ls -lh /opt/geoserver
    echo ""
    echo "Symlink Target:"
    readlink -f /opt/geoserver
    echo ""
    echo "GeoServer Installation Directory:"
    ls -lah /mnt/external-disk/geoserver | head -20
    echo ""
    echo "GeoServer startup.sh status:"
    ls -lah /mnt/external-disk/geoserver/bin/startup.sh
    echo ""
    
    # 5. Test Files and Folders
    echo "========== 5. TEST FILES AND FOLDERS =========="
    echo "Test file: disk-verification.txt"
    cat /mnt/external-disk/disk-verification.txt
    echo ""
    
    echo "Test file: system-info.json"
    cat /mnt/external-disk/system-info.json
    echo ""
    
    echo "Test file: disk-usage.txt"
    head -20 /mnt/external-disk/disk-usage.txt
    echo ""
    
    # 6. GeoServer Directories
    echo "========== 6. GEOSERVER DATA DIRECTORIES =========="
    echo "GeoServer data directory:"
    ls -lah /mnt/external-disk/geoserver-data
    echo ""
    
    echo "GeoServer logs directory:"
    ls -lah /mnt/external-disk/geoserver-logs
    echo ""
    
    # 7. GeoServer Configuration
    echo "========== 7. GEOSERVER CONFIGURATION =========="
    echo "GeoServer environment script:"
    cat /mnt/external-disk/geoserver-env.sh
    echo ""
    
    # 8. Permissions Summary
    echo "========== 8. PERMISSIONS SUMMARY =========="
    echo "User and group for /mnt/external-disk:"
    stat /mnt/external-disk | grep -E "Uid|Gid"
    echo ""
    
    echo "GeoServer user info:"
    id geoserver 2>/dev/null || echo "geoserver user not found in system"
    echo ""
    
    # 9. Java and Dependencies
    echo "========== 9. JAVA AND DEPENDENCIES =========="
    echo "Java Version:"
    java -version 2>&1
    echo ""
    
    echo "Java Location:"
    which java
    echo ""
    
    # 10. Final Status Summary
    echo "========== 10. FINAL STATUS SUMMARY =========="
    echo "External Disk Status: MOUNTED"
    echo "Mount Point: /mnt/external-disk"
    echo "GeoServer Location: /mnt/external-disk/geoserver"
    echo "GeoServer Symlink: /opt/geoserver -> $(readlink -f /opt/geoserver)"
    echo "GeoServer Data Dir: /mnt/external-disk/geoserver-data"
    echo "GeoServer Log Dir: /mnt/external-disk/geoserver-logs"
    
    echo ""
    echo "Available Disk Space:"
    df -h /mnt/external-disk | tail -1 | awk '{print "Used: "$3" / Total: "$2" / Available: "$4}'
    echo ""
    
    echo "Total Files on External Disk:"
    find /mnt/external-disk -type f | wc -l
    echo ""
    
    echo "All Directories on External Disk:"
    find /mnt/external-disk -type d | sort
    echo ""
  EOF

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  depends_on = [data.google_compute_disk.attached_disk]
}
