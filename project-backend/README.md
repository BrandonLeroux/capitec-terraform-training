# project-backend

One-time **bootstrap** of the S3 bucket that stores the remote Terraform state
for `project/`. It runs with **local state** (it can't use the very backend it
creates), so run it once, up front.

It creates `lerouxbap-s3-backend` and hardens it for state storage:

- **Versioning enabled** — every state write is retained, so a bad/corrupt state can be rolled back.
- **AES256 encryption** at rest (state can contain sensitive values).
- **Public access fully blocked.**

All environments share this one bucket, isolated by key
(`dev/`, `int/`, `qa/`, `prod/terraform.tfstate`), with native state locking
(`use_lockfile` in each `values/<env>/<env>.tfbackend`).

## Usage

```bash
cd project-backend
terraform init
terraform apply        # defaults: surname=leroux, initials=bap → lerouxbap-s3-backend
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.15 |
| aws | ~> 6.57 |

## Inputs

| Name | Type | Default | Purpose |
|------|------|---------|---------|
| `surname` | string | `leroux` | First part of the bucket name |
| `initials` | string | `bap` | Second part of the bucket name |
| `environment` | string | `dev` | Environment tag on the bucket |

## Outputs

| Name | Description |
|------|-------------|
| `backend_bucket_name` | Name of the state bucket |
| `backend_bucket_arn` | ARN of the state bucket |
