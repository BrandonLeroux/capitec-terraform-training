# eks module

Creates an EKS cluster with its IAM roles, an access entry for the deploying
principal, a managed node group, and configurable security-group ingress. It
composes the [`subnet`](../subnet) module to build the cluster networking from
the CIDR blocks you pass in.

## Usage

```hcl
module "eks" {
  source = "./modules/eks"

  prefix             = "lerouxbap"
  environment        = "dev"
  vpc_id             = "vpc-0123456789abcdef0"
  rt_id              = "rtb-0123456789abcdef0"
  availability_zones = ["af-south-1a", "af-south-1b", "af-south-1c"]
  cidr_blocks        = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]

  # optional overrides
  cluster_version = "1.35"
  capacity_type   = "SPOT"
  instance_types  = ["t3.micro"]
  node_scaling    = { min_size = 1, desired_size = 2, max_size = 3 }
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
| `vpc_id` | string | – | yes |
| `rt_id` | string | – | yes |
| `cidr_blocks` | list(string) | – | yes |
| `availability_zones` | list(string) | af-south-1a/b/c | no |
| `environment` | string | `dev` | no |
| `cluster_version` | string | `1.35` | no |
| `authentication_mode` | string | `API` | no |
| `cluster_admin_policy_arn` | string | AmazonEKSClusterAdminPolicy | no |
| `node_policy_arns` | list(string) | WorkerNode + CNI + ECR-ro | no |
| `instance_types` | list(string) | `["t3.micro"]` | no |
| `node_scaling` | object(min/desired/max) | 1/2/3 | no |
| `node_max_unavailable` | number | `1` | no |
| `node_security_group_ingress` | map(object) | NodePort 30007 | no |
| `capacity_type` | string | `SPOT` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | Name of the EKS cluster |
| `cluster_arn` | ARN of the cluster |
| `cluster_endpoint` | Kubernetes API endpoint |
| `cluster_certificate_authority_data` | Base64 CA data |
| `cluster_security_group_id` | EKS-managed cluster security group |
| `cluster_role_arn` / `node_role_arn` | IAM role ARNs |
| `node_group_name` | Managed node group name |
| `subnet_ids` | Subnet IDs created for the cluster |
