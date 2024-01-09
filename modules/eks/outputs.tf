output "endpoint" {
  value = aws_eks_cluster.ekslab.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.ekslab.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.ekslab.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.ekslab.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.ekslab.name
}
