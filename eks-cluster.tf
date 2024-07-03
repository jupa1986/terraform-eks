data "aws_subnets" "private-a" {
  filter {
    name = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region}a"]
  }

  filter {
    name   = "cidr-block"
    values = ["10.25.128.0/19"]
  }
}
data "aws_subnets" "private-b" {
  filter {
    name = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region}b"]
  }

  filter {
    name   = "cidr-block"
    values = ["10.25.160.0/19"]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.private-a.ids
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.5.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = slice(module.vpc.private_subnets, 3, 5)
  # new group of subnets
  # subnet_ids                     = [concat(data.aws_subnets.private-a.ids, data.aws_subnets.private-b.ids)

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }


  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

