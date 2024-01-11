resource "aws_eks_cluster" "ekslab" {
  name     = var.cluster_name
  role_arn = aws_iam_role.ekslab.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.ekslab-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.ekslab-AmazonEKSVPCResourceController,
  ]
}