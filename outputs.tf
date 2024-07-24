output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.webapp.arn
}

output "certificate-arn" {
  value = aws_acm_certificate.webapp.arn
}