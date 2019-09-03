variable "profile_name" {
  default = "default"
}

variable "region" {
  default = "us-east-1"
}

variable "email_address_arn" {
  default = "arn:aws:ses:us-east-1:894527626897:identity/kainlite@gmail.com"
}

variable "cognito_user_pool_name" {
  default = "api-skynetng-pw"
}

variable "domain_name" {
  default = "api.skynetng.pw"
}

variable "log_retention_in_days" {
  default = 7
}

variable "function_name" {
  description = "Function name"
  default     = "mylambda"
}

variable "stage_name" {
  description = "Api version number"
  default     = "v1"
}

variable "environment_variables" {
  description = "Map with environment variables for the function"

  default = {
    myenvvar = "test"
  }
}

