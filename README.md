# GCP VM Instance with Attached Disk - Terraform to OpenTofu Migration

## Filesystem Configuration

This VM deploys with TWO disks:

### Boot Disk: `/dev/sda1`
- **Size**: 9.7 GB
- **Type**: Boot filesystem
- **Mount Point**: `/` (root)
- **Device Path**: `/dev/sda1`
- Partitions (from `lsblk`):
  - `/dev/sda1` (9.9G) → mounted at `/`
  - `/dev/sda14` (3M) → BIOS boot partition
  - `/dev/sda15` (124M) → mounted at `/boot/efi` (EFI System Partition)

### External Disk: `/dev/sdb`
- **Size**: 10 GB
- **Type**: Persistent data disk
- **Mount Point**: `/mnt/external-disk`
- **Format**: ext4
- **Filesystem Entry**: `/dev/sdb /mnt/external-disk ext4 defaults,nofail 0 2`

## Startup Script - Automatic Setup

The startup script automatically:

1. **Detects External Disk** - Waits for `/dev/sdb` to appear
2. **Formats Disk** - `mkfs.ext4 -F /dev/sdb`
3. **Creates Mount Point** - `mkdir -p /mnt/external-disk`
4. **Adds fstab Entry** - For persistent mounting
5. **Mounts Disk** - `mount /mnt/external-disk`
6. **Sets Permissions** - `chmod 755 /mnt/external-disk`
7. **Creates Test Files** on `/mnt/external-disk`:
   - `disk-verification.txt` - Boot timestamp & config
   - `system-info.json` - JSON system metadata
   - `disk-usage.txt` - df & lsblk output
8. **Installs GeoServer** to `/mnt/external-disk/geoserver`
9. **Creates Symlink** - `/opt/geoserver` → `/mnt/external-disk/geoserver`
10. **Creates Data Directories** - `/mnt/external-disk/geoserver-data` & `/mnt/external-disk/geoserver-logs`

## Directory Structure After Deployment

```
/                                          # Boot disk root
├── /dev/sda1                              # Boot disk partition
├── /boot/efi                              # EFI partition
└── /mnt/external-disk                     # External disk mount
    ├── geoserver/                         # GeoServer installation
    │   └── bin/startup.sh
    ├── geoserver-data/                    # GeoServer data directory
    ├── geoserver-logs/                    # GeoServer log directory
    ├── geoserver-env.sh                   # Environment config
    ├── disk-verification.txt              # Test file with boot info
    ├── system-info.json                   # JSON test file
    └── disk-usage.txt                     # Disk info snapshot
```

## Symlink Configuration

```bash
/opt/geoserver → /mnt/external-disk/geoserver
```

Both paths point to the same GeoServer installation on the external disk.

## Verification Commands

### Check Boot Disk
```bash
# Boot disk usage
df -h /

# Boot disk details
lsblk | grep sda
```

### Check External Disk
```bash
# External disk mounted?
df -h /mnt/external-disk

# External disk device
lsblk | grep sdb

# Mount status
mount | grep /dev/sdb
```

### Check Filesystem Table
```bash
# View fstab entries for both disks
cat /etc/fstab | grep "sda1\|sdb"

# Full fstab
cat /etc/fstab
```

### Check GeoServer on External Disk
```bash
# Symlink verification
ls -lh /opt/geoserver

# Symlink target
readlink -f /opt/geoserver

# GeoServer directory
ls -lah /mnt/external-disk/geoserver

# Data directory
ls -lah /mnt/external-disk/geoserver-data

# Logs directory
ls -lah /mnt/external-disk/geoserver-logs
```

### View Test Files
```bash
# Disk verification file
cat /mnt/external-disk/disk-verification.txt

# System info JSON
cat /mnt/external-disk/system-info.json

# Disk usage snapshot
cat /mnt/external-disk/disk-usage.txt
```

### All Filesystems Summary
```bash
# All mounted filesystems with disk usage
df -h

# All block devices with partitions
lsblk

# All mounted devices
mount | grep /dev/
```

## Backend Configuration

- **Type**: GCS (Google Cloud Storage)
- **Bucket**: bucket-terraform-state-786
- **Prefix**: ecom-vm

## Machine Configuration

- **Instance Name**: test-vm-instance
- **Machine Type**: e2-small
- **Boot Image**: Debian 11
- **Boot Disk Size**: 10 GB (`/dev/sda1`)
- **External Data Disk**: 10 GB (`/dev/sdb`)
- **Zone**: us-central1-a

## Deployment Order

1. **Disk Branch** - Create the persistent disk:
   ```bash
   git checkout disk
   terraform init -reconfigure
   terraform apply
   ```

2. **VM Branch** - Create VM and attach disk:
   ```bash
   git checkout vm
   terraform init -reconfigure
   terraform apply
   ```

## Startup Script Logs

View the complete startup process logs:
```bash
cat /var/log/startup-script.log
```

## Troubleshooting

### External Disk Not Mounted?
```bash
# Check if disk exists
lsblk

# Manually mount
sudo mount /dev/sdb /mnt/external-disk

# Check fstab
cat /etc/fstab
```

### GeoServer Symlink Issues?
```bash
# Verify symlink exists
ls -lh /opt/geoserver

# Recreate symlink if broken
sudo ln -sfn /mnt/external-disk/geoserver /opt/geoserver
```

### Fix Permissions
```bash
# Reset GeoServer directory permissions
sudo chown -R geoserver:geoserver /mnt/external-disk/geoserver*
sudo chmod 755 /mnt/external-disk/geoserver-data
sudo chmod 755 /mnt/external-disk/geoserver-logs
```
