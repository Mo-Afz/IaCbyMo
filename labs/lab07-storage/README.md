# Lab 07 -- Azure Storage

## AZ-104 Domain

Implement and Manage Storage (15--20%)

## Objective

Provision and configure an Azure Storage account using Terraform, covering the core storage services and security features tested on the AZ-104 exam.

## What You Will Learn

- **Storage accounts** -- creating a StorageV2 account with globally unique naming (via `random_string`).
- **Blob containers** -- private containers for data and logs, uploading a sample block blob.
- **Azure Files** -- provisioning an SMB file share with a quota.
- **Access tiers** -- Hot, Cool, and Archive tiers and when to use each.
- **Lifecycle management policies** -- automatic tiering (30 days to Cool, 90 days to Archive, 365 days to delete) and snapshot cleanup.
- **SAS tokens** -- generating a time-limited, read-only Shared Access Signature scoped to blob service containers and objects.
- **Network rules** -- controlling access with a default action (Allow/Deny) and IP allowlists.

## Key Concepts

| Concept | Detail |
|---|---|
| Globally unique naming | Storage account names must be unique across all of Azure; this lab appends a random 8-character suffix. |
| Container access levels | All containers use `private`; public access is disabled by default. |
| Lifecycle automation | Blobs in `data/` move Cool after 30 days, Archive after 90, and are deleted after 365. Snapshots are deleted after 30 days. |
| SAS anatomy | The generated SAS is HTTPS-only, read+list, scoped to blob containers/objects, and expires in 24 hours. |
| Blob versioning | Enabled on the storage account to support point-in-time recovery. |
| TLS enforcement | Minimum TLS 1.2 is required for all connections. |

## Usage

```bash
cd labs/lab07-storage
cp terraform.tfvars.example terraform.tfvars   # edit with your values
terraform init
terraform plan
terraform apply
```

To view the sensitive SAS URL output:

```bash
terraform output -raw sas_url_example
```

## Clean Up

```bash
terraform destroy
```

## Estimated Cost and Time

- **Cost:** ~$0.50/day (Standard LRS storage with minimal data)
- **Time:** ~3 minutes to deploy
