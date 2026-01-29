hi this is for bucket creation
TF_BIN = "E:\\aws\\terraform\\tf-diff-versions\\tf_1-6\\terraform.exe"
Terraform caches modules in .terraform/modules and will NOT re-download them unless it thinks something changed.
Terraform assumes:

Same source

Same ref

Same lock info
→ module is unchanged

So it reuses cached module code.
Force re-download (local & Jenkins)
terraform init -upgrade
