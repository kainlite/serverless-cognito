data "aws_route53_zone" "zone" {
  name = substr(var.domain_name, 4, -1)
}

resource "aws_route53_record" "api" {
  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.api.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.api.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.zone.id
  records = [aws_acm_certificate.api.domain_validation_options.0.resource_record_value]
  ttl     = 60
}
