resource "aws_ssm_parameter" "nrel_api_key" {
  name        = "/api_keys/nrel"
  description = "NREL api key for https://developer.nrel.gov/"
  type        = "SecureString"
  value       = var.nrel_api_key
}
