module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}


module "eks_admin_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"
  for_each = toset(var.cluster_iam_username)

  name                          = each.key
  create_iam_access_key         = true
  create_iam_user_login_profile = false
  force_destroy                 = true
}


module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "eks-admin-policy"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })
}

module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  name                              = "eks-admin"
  attach_iam_self_management_policy = false
  create_group                      = true
  group_users                       = var.cluster_iam_username
  custom_group_policy_arns          = [module.allow_assume_eks_admins_iam_policy.arn]
}

module "aws_lb_controller_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "AWSLoadBalancerControllerIAMPolicy"
  create_policy = true
  policy = file("${path.root}/deployment/lb-controller-policy.json")
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = module.eks.cluster_oidc_issuer_url
  depends_on = [ module.eks ]
}

module "iam_eks_lb_controller_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.3.1"

  role_name = "AmazonEKSLoadBalancerControllerRole"

  role_policy_arns = {
    policy = module.aws_lb_controller_iam_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = data.aws_iam_openid_connect_provider.oidc.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  tags = {
    Role                                          = "AmazonEKSLoadBalancerControllerRole"
    "alpha.eksctl.io/cluster-name"                = module.eks.cluster_name
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/aws-load-balancer-controller"
    "alpha.eksctl.io/eksctl-version"              = "0.167.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = module.eks.cluster_name
  }

  depends_on = [ module.eks ]
}

resource "null_resource" "update_trust_policy" {
  provisioner "local-exec" {
    command = <<EOT
      aws iam update-assume-role-policy --role-name '${module.eks.cluster_iam_role_name}' --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "EKSClusterAssumeRole",
            "Effect": "Allow",
            "Principal": {
              "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
          },
          {
            "Sid": "AllowDavidAssumeRole",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::'${data.aws_caller_identity.current.account_id}':user/david"
            },
            "Action": "sts:AssumeRole"
          }
        ]
      }'
    EOT
  }

  depends_on = [module.eks]
}