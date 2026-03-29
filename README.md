# GCP VM Instance with Attached Disk - Terraform to OpenTofu Migration

This folder contains Terraform configuration for creating a GCP Compute Instance with an attached persistent disk via data source reference.

## Resources

- `google_compute_instance` - Creates a GCP VM instance
- `data.google_compute_disk` - References an existing persistent disk (created in disk branch)

## Prerequisites

The disk must exist in the same project and zone. Deploy the disk branch first:
```bash
git checkout disk
terraform apply
```

## Usage

### Terraform

```bash
terraform init -reconfigure
terraform plan
terraform apply
```

### OpenTofu

After migration:

```bash
tofu init -reconfigure
tofu plan
tofu apply
```

## Variables

- `project_id` - GCP Project ID (required)
- `region` - GCP Region (default: us-central1)
- `zone` - GCP Zone (default: us-central1-a)
- `instance_name` - Name of the VM instance (default: test-vm-instance)
- `machine_type` - Machine type (default: e2-medium)
- `attached_disk_name` - Name of disk to attach (default: test-disk) - must exist in same zone
- `image_family` - Boot image family (default: debian-11)
- `image_project` - Project with boot image (default: debian-cloud)
- `labels` - Labels for the instance

## Outputs

- `instance_id` - Unique identifier of the instance
- `instance_name` - Name of the instance
- `instance_self_link` - URI of the instance
- `instance_public_ip` - Public IP address
- `instance_internal_ip` - Internal IP address
- `attached_disk_name` - Name of the attached disk
- `attached_disk_self_link` - Self link of the attached disk
- `attached_disk_size_gb` - Size of the attached disk

## Backend

- **Type**: GCS (Google Cloud Storage)
- **Bucket**: bucket-terraform-state-786
- **Prefix**: ecom-vm

## CI/CD

Jenkinsfile is set up for automated:
- terraform init (with -reconfigure flag for fresh workspaces)
- terraform plan
- Manual approval before apply
- terraform apply
- Artifact archival of plan file
