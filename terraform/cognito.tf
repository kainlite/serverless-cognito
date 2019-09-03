resource "aws_cognito_user_pool" "pool" {
  name = "api-skynetng-pw"

  username_attributes = ["email"]

  # This setting is what actually makes the confirmation code to be sent
  auto_verified_attributes = ["email"]

  email_configuration {
    source_arn = var.email_address_arn
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.pool.id

  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
}

data "aws_cognito_user_pools" "this" {
  name = var.cognito_user_pool_name

  depends_on = ["aws_cognito_user_pool.pool"]
}
