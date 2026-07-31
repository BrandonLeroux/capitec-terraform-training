######################## Trainee Resources ########################

locals {
  cluster_name      = "${var.prefix}-eks-${var.environment}"
  cluster_role_name = "${var.prefix}-eks-cluster-role-${var.environment}"
  node_role_name    = "${var.prefix}-eks-node-iam-role-${var.environment}"
  node_group_name   = "${var.prefix}-eks-ng-${var.environment}"
  access_entry_name = "${var.prefix}-eks-access-entry-${var.environment}"

  common_tags = {
    Owner       = var.owner
    Environment = var.environment
  }
}

module "subnet" {
  source = "../subnet"

  vpc_id             = var.vpc_id
  rt_id              = var.rt_id
  availability_zones = var.availability_zones
  cidr_blocks        = local.subnet_allocation.brandon_le_roux.subnets
  prefix             = var.prefix
  environment        = var.environment
  owner              = var.owner
}

resource "aws_eks_cluster" "eks-cluster" {
  name = local.cluster_name

  access_config {
    authentication_mode = "API"
    #bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.35"

  vpc_config {
    subnet_ids = module.subnet.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = merge(local.common_tags, { Name = local.cluster_name })
}

resource "aws_iam_role" "eks-cluster-role" {
  name = local.cluster_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags, { Name = local.cluster_role_name })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
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

  tags = merge(local.common_tags, { Name = local.access_entry_name })
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = aws_eks_access_entry.eks-access-entry.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_role" "node-iam-role" {
  name = local.node_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags, { Name = local.node_role_name })
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset(var.node_policy_arns)

  policy_arn = each.value
  role       = aws_iam_role.node-iam-role.name
}

resource "aws_security_group_rule" "nodeport-ingress-sg" {
  type              = "ingress"
  from_port         = 30007
  to_port           = 30007
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
  description       = "Allow inbound access to nginx NodePort service"
}

resource "aws_eks_node_group" "eks-ng" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.node-iam-role.arn
  subnet_ids      = module.subnet.subnet_ids

  capacity_type  = var.capacity_type
  instance_types = ["t3.micro"]

  scaling_config {
    min_size     = 1
    max_size     = 3
    desired_size = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(local.common_tags, { Name = local.node_group_name })

  # Ensure IAM permissions are created before and deleted after the
  # node group, otherwise EKS cannot properly bootstrap/tear down nodes.
  depends_on = [
    aws_iam_role_policy_attachment.node,
  ]
}
