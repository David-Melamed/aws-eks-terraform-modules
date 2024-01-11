resource "aws_eks_node_group" "ekslab" {
  cluster_name    = aws_eks_cluster.ekslab.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.ekslab2.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.ekslab-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.ekslab-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ekslab-AmazonEC2ContainerRegistryReadOnly,
  ]
}