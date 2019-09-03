data "aws_route53_zone" "zone" {
  # When doing this like this, it's often useful to test it with
  # `terraform console` for example for xxx.skynetng.pw or anything.skynetng.pw
  # it will return just skynetng.pw, it's a simple way to remove the subdomain
  name = join(".", slice(split(".", var.domain_name), 1, 3))
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
