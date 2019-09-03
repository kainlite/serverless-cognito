locals {
  computed_environment_variables = {
    "COGNITO_CLIENT_ID" = aws_cognito_user_pool_client.client.id
  }
  environment_variables = merge(local.computed_environment_variables, var.environment_variables)
}
