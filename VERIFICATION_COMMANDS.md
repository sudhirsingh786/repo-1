# GCP VM Disk & GeoServer Setup - Verification Commands

## Quick SSH into VM
```bash
gcloud compute ssh test-vm-instance --zone=us-central1-a
```

---

## 1. FILESYSTEM VERIFICATION

### Check all mounted filesystems
```bash
df -h
```

### Check block devices
```bash
lsblk
```

### Check external disk specifically
```bash
df -h /mnt/external-disk
```

### Check disk UUID and type
```bash
sudo blkid
```

### View mount table
```bash
cat /etc/fstab
```

---

## 2. EXTERNAL DISK MOUNT POINT VERIFICATION

### Show mount information
```bash
mount | grep /dev/sdb
```

### Check disk space and usage
```bash
df -h /mnt/external-disk
df -i /mnt/external-disk
```

### Check disk permissions
```bash
ls -ld /mnt/external-disk
stat /mnt/external-disk
```

---

## 3. /MNT DIRECTORY STRUCTURE

### Tree view of /mnt (install tree first: apt-get install tree)
```bash
sudo tree /mnt/external-disk
```

### Alternative: find command
```bash
find /mnt/external-disk -type d | sort
```

### Detailed recursive listing
```bash
ls -lRah /mnt/external-disk
```

### Count all files
```bash
find /mnt/external-disk -type f | wc -l
```

### Show directory sizes
```bash
du -sh /mnt/external-disk/*
```

---

## 4. GEOSERVER SYMLINK VERIFICATION

### Check symlink
```bash
ls -lh /opt/geoserver
```

### Get symlink target
```bash
readlink /opt/geoserver
```

### Get full path
```bash
readlink -f /opt/geoserver
```

### Verify symlink points to correct location
```bash
[ "$(readlink -f /opt/geoserver)" = "/mnt/external-disk/geoserver" ] && echo "✓ Symlink correct" || echo "✗ Symlink incorrect"
```

---

## 5. GEOSERVER INSTALLATION

### Check GeoServer directory
```bash
ls -lah /mnt/external-disk/geoserver
```

### Check startup script
```bash
ls -lah /mnt/external-disk/geoserver/bin/startup.sh
file /mnt/external-disk/geoserver/bin/startup.sh
```

### GeoServer version
```bash
cat /mnt/external-disk/geoserver/web/WEB-INF/version.txt 2>/dev/null || echo "Version file not in expected location"
```

---

## 6. GEOSERVER DATA & LOG DIRECTORIES

### Check data directory
```bash
ls -lah /mnt/external-disk/geoserver-data
```

### Check logs directory
```bash
ls -lah /mnt/external-disk/geoserver-logs
```

### Check permissions
```bash
stat /mnt/external-disk/geoserver-data
stat /mnt/external-disk/geoserver-logs
```

---

## 7. TEST FILES VERIFICATION

### Verify disk-verification.txt
```bash
cat /mnt/external-disk/disk-verification.txt
```

### Verify system-info.json
```bash
cat /mnt/external-disk/system-info.json
```

### Verify disk-usage.txt content
```bash
cat /mnt/external-disk/disk-usage.txt
```

### List all test files
```bash
ls -lah /mnt/external-disk/*.txt /mnt/external-disk/*.json /mnt/external-disk/*.sh 2>/dev/null
```

---

## 8. GEOSERVER ENVIRONMENT

### Source GeoServer environment
```bash
source /mnt/external-disk/geoserver-env.sh
```

### Check environment variables
```bash
echo "GEOSERVER_HOME: $GEOSERVER_HOME"
echo "GEOSERVER_DATA_DIR: $GEOSERVER_DATA_DIR"
echo "GEOSERVER_LOG_DIR: $GEOSERVER_LOG_DIR"
```

### View entire environment script
```bash
cat /mnt/external-disk/geoserver-env.sh
```

---

## 9. JAVA VERIFICATION

### Java version
```bash
java -version
```

### Java location
```bash
which java
update-alternatives --display java
```

### JAVA_HOME
```bash
echo $JAVA_HOME
ls -lah /usr/lib/jvm/default-java
```

---

## 10. USER & PERMISSIONS

### GeoServer user
```bash
id geoserver
getent passwd geoserver
```

### Home directory
```bash
sudo -u geoserver pwd
```

### File ownership on external disk
```bash
find /mnt/external-disk -exec ls -ld {} \; | awk '{print $3":"$4}' | sort | uniq
```

---

## 11. STARTUP SCRIPT LOGS

### View startup logs
```bash
cat /var/log/startup-script.log | head -100
```

### Tail logs (last 50 lines)
```bash
tail -50 /var/log/startup-script.log
```

### Errors in logs
```bash
grep -i "error\|failed" /var/log/startup-script.log
```

### Warnings in logs
```bash
grep -i "warning" /var/log/startup-script.log
```

---

## 12. COMPREHENSIVE STATUS CHECK (All-in-One)

```bash
#!/bin/bash
echo "========== COMPREHENSIVE VM STATUS =========="
echo ""
echo "1. Filesystem Status:"
df -h /mnt/external-disk
echo ""
echo "2. External Disk Device:"
lsblk | grep sdb
echo ""
echo "3. GeoServer Symlink:"
ls -lh /opt/geoserver
echo ""
echo "4. GeoServer Installation Path:"
readlink -f /opt/geoserver
echo ""
echo "5. GeoServer Data:"
du -sh /mnt/external-disk/geoserver-data
echo ""
echo "6. GeoServer Logs:"
du -sh /mnt/external-disk/geoserver-logs
echo ""
echo "7. Test Files:"
ls -lah /mnt/external-disk/{disk-verification.txt,system-info.json,disk-usage.txt} 2>/dev/null | awk '{print $9, "(" $5 ")"}'
echo ""
echo "8. Java Version:"
java -version 2>&1 | head -3
echo ""
echo "9. GeoServer User:"
id geoserver
echo ""
echo "10. Total Files on External Disk:"
find /mnt/external-disk -type f | wc -l
echo ""
echo "========== END OF STATUS CHECK =========="
```

---

## 13. DISK-SPECIFIC HEALTH CHECKS

### Check for filesystem errors
```bash
sudo fsck -n /dev/sdb
```

### Monitor disk I/O
```bash
iostat -dx 1 5
```

### Check disk SMART status (if available)
```bash
sudo smartctl -H /dev/sdb
```

### View disk partition info
```bash
sudo fdisk -l /dev/sdb
```

---

## 14. SYMLINK VALIDATION SCRIPT

```bash
#!/bin/bash
echo "GeoServer Symlink Validation"
echo ""

SYMLINK="/opt/geoserver"
TARGET="/mnt/external-disk/geoserver"

if [ -L "$SYMLINK" ]; then
    echo "✓ Symlink exists: $SYMLINK"
    ACTUAL_TARGET=$(readlink -f "$SYMLINK")
    echo "  Target: $ACTUAL_TARGET"
    
    if [ "$ACTUAL_TARGET" = "$TARGET" ]; then
        echo "✓ Symlink points to correct location"
    else
        echo "✗ ERROR: Symlink points to $ACTUAL_TARGET instead of $TARGET"
    fi
    
    if [ -d "$ACTUAL_TARGET" ]; then
        echo "✓ Target directory exists"
        echo "  Files in target: $(find $ACTUAL_TARGET -type f | wc -l)"
    else
        echo "✗ ERROR: Target directory does not exist"
    fi
else
    echo "✗ ERROR: Symlink does not exist at $SYMLINK"
fi

echo ""
echo "External Disk Summary:"
echo "  Mount Point: /mnt/external-disk"
echo "  Size: $(df -h /mnt/external-disk | tail -1 | awk '{print $2}')"
echo "  Used: $(df -h /mnt/external-disk | tail -1 | awk '{print $3}')"
echo "  Available: $(df -h /mnt/external-disk | tail -1 | awk '{print $4}')"
```

---

## 15. QUICK TROUBLESHOOTING

### If disk not mounted
```bash
sudo mount /dev/sdb /mnt/external-disk
cat /etc/fstab | grep sdb
```

### If symlink broken
```bash
sudo ls -lah /opt/geoserver
sudo rm /opt/geoserver
sudo ln -sfn /mnt/external-disk/geoserver /opt/geoserver
```

### If permissions wrong
```bash
sudo chown -R geoserver:geoserver /mnt/external-disk/geoserver
sudo chmod -R 755 /mnt/external-disk/geoserver
```

### Reset GeoServer ownership
```bash
sudo chown -R geoserver:geoserver /mnt/external-disk/geoserver*
```
