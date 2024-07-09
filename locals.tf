locals {
  cluster_name = "ekslab"
  partition = data.aws_partition.current.partition 
  environment = "dev"
  kubernetes_namespace = "development"
  cluster_iam_role_name = module.eks.cluster_iam_role_name
  account_id = data.aws_caller_identity.current.account_id
}
