#####################
# SSL custom domain #
#####################

data "aws_acm_certificate" "api" {
  domain     = var.domain_name
  depends_on = [aws_acm_certificate.api]
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.lambda-api.id
  stage_name  = aws_api_gateway_deployment.lambda-api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

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
}
