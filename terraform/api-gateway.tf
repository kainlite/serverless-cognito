# https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html

resource "aws_api_gateway_rest_api" "lambda-api" {
  name = replace(var.domain_name, ".", "-")
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  parent_id   = aws_api_gateway_rest_api.lambda-api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-api" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda-api" {
  depends_on = [aws_api_gateway_integration.lambda-api]

  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = replace(var.domain_name, ".", "-")
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda-api.execution_arn}/*/*/*"

  depends_on = [aws_lambda_function.api]
}

###############
# Enable CORS #
###############
# Usually you would enable the OPTIONS method, but I wasn't able
# to make it work with options enabled.
# https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac
# resource "aws_api_gateway_method" "options_method" {
#   rest_api_id   = aws_api_gateway_rest_api.lambda-api.id
#   resource_id   = aws_api_gateway_resource.proxy.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "options_200" {
#   rest_api_id = aws_api_gateway_rest_api.lambda-api.id
#   resource_id = aws_api_gateway_resource.proxy.id
#   http_method = aws_api_gateway_method.options_method.http_method
#   status_code = 200

#   response_models = {
#     "application/json" = "Empty"
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Origin"  = true
#   }
# }

# resource "aws_api_gateway_integration" "options_integration" {
#   rest_api_id = aws_api_gateway_rest_api.lambda-api.id
#   resource_id = aws_api_gateway_resource.proxy.id
#   http_method = aws_api_gateway_method.options_method.http_method
#   type        = "MOCK"

#   # https://stackoverflow.com/questions/43990464/api-gateway-mock-integration-fails-with-500/44013347#44013347
#   request_templates = {
#     "application/json" = <<EOF
# {
#   "statusCode": 200
# }
# EOF

#   }
# }

# resource "aws_api_gateway_integration_response" "options_integration_response" {
#   rest_api_id = aws_api_gateway_rest_api.lambda-api.id
#   resource_id = aws_api_gateway_resource.proxy.id
#   http_method = aws_api_gateway_method.options_method.http_method
#   status_code = aws_api_gateway_method_response.options_200.status_code

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#   }
# }
