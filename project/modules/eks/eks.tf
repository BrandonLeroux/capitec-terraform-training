######################## Trainee Resources ########################

locals {
  cluster_name      = "${var.prefix}-eks-${var.environment}"
  cluster_role_name = "${var.prefix}-eks-cluster-role-${var.environment}"
  node_role_name    = "${var.prefix}-eks-node-iam-role-${var.environment}"
  node_group_name   = "${var.prefix}-eks-ng-${var.environment}"
  access_entry_name = "${var.prefix}-eks-access-entry-${var.environment}"

  iam_roles = {
    cluster = {
      role_name = local.cluster_role_name
      service   = "eks.amazonaws.com"
      actions   = ["sts:AssumeRole", "sts:TagSession"]
    }
    node = {
      role_name = local.node_role_name
      service   = "ec2.amazonaws.com"
      actions   = ["sts:AssumeRole"]
    }
  }
}

module "subnet" {
  source = "../subnet"

  vpc_id             = var.vpc_id
  rt_id              = var.rt_id
  availability_zones = var.availability_zones
  cidr_blocks        = var.cidr_blocks
  prefix             = var.prefix
  environment        = var.environment
}

resource "aws_eks_cluster" "eks-cluster" {
  name = local.cluster_name

  access_config {
    authentication_mode = var.authentication_mode
    #bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.this["cluster"].arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = module.subnet.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = { Name = local.cluster_name }
}

resource "aws_iam_role" "this" {
  for_each = local.iam_roles

  name = each.value.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = each.value.actions
        Effect = "Allow"
        Principal = {
          Service = each.value.service
        }
      },
    ]
  })

  tags = { Name = each.value.role_name }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this["cluster"].name
}

# authentication_mode = "API" means Kubernetes RBAC access is governed
# entirely by EKS access entries, not IAM policies or aws-auth. Without
# this, the IAM principal that creates/manages the cluster has no way
# to authenticate to the Kubernetes API.
data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "eks-access-entry" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"

  tags = { Name = local.access_entry_name }
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = aws_eks_access_entry.eks-access-entry.principal_arn
  policy_arn    = var.cluster_admin_policy_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset(var.node_policy_arns)

  policy_arn = each.value
  role       = aws_iam_role.this["node"].name
}

resource "aws_security_group_rule" "node_ingress" {
  for_each = var.node_security_group_ingress

  type              = "ingress"
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_eks_node_group" "eks-ng" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.this["node"].arn
  subnet_ids      = module.subnet.subnet_ids

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    min_size     = var.node_scaling.min_size
    max_size     = var.node_scaling.max_size
    desired_size = var.node_scaling.desired_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  tags = { Name = local.node_group_name }

  # Ensure IAM permissions are created before and deleted after the
  # node group, otherwise EKS cannot properly bootstrap/tear down nodes.
  depends_on = [
    aws_iam_role_policy_attachment.node,
  ]
}
