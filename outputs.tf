# -----------------------------------------------------------------------------
# Outputs: Cognito
# -----------------------------------------------------------------------------

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool._.id
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool._.arn
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client._.id
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool._.id
}

output "cognito_user_pool_domain" {
  value = aws_cognito_user_pool_domain._.domain
}

output "cognito_user_pool_cloudfront_arn" {
  value = aws_cognito_user_pool_domain._.cloudfront_distribution_arn
}