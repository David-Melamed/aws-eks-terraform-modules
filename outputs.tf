output "cluster_iam_role_arn" {
    value = module.eks.cluster_iam_role_arn
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.webapp.arn
}

output "cert_validation" {
  value = [for record in aws_route53_record.cert_validation : record.fqdn]
}