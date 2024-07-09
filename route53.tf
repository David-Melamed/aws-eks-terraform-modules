resource "aws_route53_zone" "webapp" {
  name = var.domain_name
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.webapp.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = aws_route53_zone.webapp.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "webapp" {
  certificate_arn         = aws_acm_certificate.webapp.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  depends_on = [aws_route53_record.cert_validation,aws_route53domains_registered_domain.web_name_servers ]
}

resource "aws_route53domains_registered_domain" "web_name_servers" {
  domain_name = aws_route53_zone.webapp.name

  dynamic "name_server" {
    for_each = aws_route53_zone.webapp.name_servers
    content {
      name = name_server.value
    }
  }

  tags = {
    Cluster_name = "${local.cluster_name}"
    Environment = "${local.environment}"
  }
}
