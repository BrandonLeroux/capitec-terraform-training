# subnet module

Creates one public subnet per availability zone and associates each with a
route table. CIDR blocks are provided by the caller (one per AZ, same order).

## Usage

```hcl
module "subnet" {
  source = "./modules/subnet"

  prefix             = "lerouxbap"
  environment        = "dev"
  vpc_id             = "vpc-0123456789abcdef0"
  rt_id              = "rtb-0123456789abcdef0"
  availability_zones = ["af-south-1a", "af-south-1b", "af-south-1c"]
  cidr_blocks        = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
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
| `vpc_id` | string | – | yes |
| `rt_id` | string | – | yes |
| `cidr_blocks` | list(string) | – | yes |
| `prefix` | string | – | yes |
| `availability_zones` | list(string) | af-south-1a/b/c | no |
| `environment` | string | `dev` | no |

## Outputs

| Name | Description |
|------|-------------|
| `subnet_ids` | IDs of the created subnets |
| `subnets` | Full subnet objects, keyed by availability zone |
