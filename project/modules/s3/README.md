# s3 module

> **Teaching demo.** This module is not wired into the root configuration; it
> exists to contrast the two iteration meta-arguments side by side:
> `count` (indexed) vs `for_each` (map/set keyed).

- `aws_s3_bucket.count` — creates `bucket_count` buckets indexed `0..n`.
- `aws_s3_bucket.each` — creates one bucket per entry in `envs` via `for_each`.

## Usage

```hcl
module "s3" {
  source = "./modules/s3"

  prefix       = "lerouxbap"
  environment  = "dev"
  bucket_count = 3
  envs         = ["dev", "int", "qa", "prod"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.15 |
| aws | ~> 6.0 |

## Inputs

| Name | Type | Default | Required |
|------|------|---------|:--------:|
| `prefix` | string | – | yes |
| `environment` | string | `dev` | no |
| `owner` | string | `bap le roux` | no |
| `resource` | string | `s3` | no |
| `bucket_count` | number | `3` | no |
| `envs` | list(string) | dev/int/qa/prod | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_count_names` | Names of the buckets created with `count` |
| `bucket_each_names` | Names of the buckets created with `for_each` |
