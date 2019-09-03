#####################
# SSL custom domain #
#####################

# Since we're re-creating the certificate each time
# We are going to left this commented for now
# data "aws_acm_certificate" "api" {
#   domain     = var.domain_name
#   depends_on = [aws_acm_certificate.api]
# }

resource "aws_acm_certificate" "api" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name     = var.domain_name
  certificate_arn = aws_acm_certificate.api.arn

  depends_on = ["aws_acm_certificate.api"]
}
