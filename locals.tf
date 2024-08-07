locals {
  cluster_name = "ekslab"
  partition = data.aws_partition.current.partition 
  environment = "dev"
  kubernetes_namespace = "development"
  cluster_iam_role_name = module.eks.cluster_iam_role_name
  account_id = data.aws_caller_identity.current.account_id
  dynamodb_tfstate_table_name = join("-", [local.cluster_name, local.environment, "tf-state-lock"])
  bucket_name = join("-", [local.cluster_name, "tf-state-bucket"])
}