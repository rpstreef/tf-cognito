locals {
  user_pool = try(aws_cognito_user_pool._[0], {})

  client = try(aws_cognito_user_pool_client._[0], {})

  o_user_pool_tags = try(local.user_pool.tags, {})

  o_user_pool = var.cognito_module_enabled ? merge(local.user_pool, {
    tags = local.o_user_pool_tags != null ? local.user_pool.tags : {}
  }) : null
}

# -----------------------------------------------------------------------------
# Outputs: Cognito
# -----------------------------------------------------------------------------

output "user_pool" {
  description = "The full `aws_cognito_user_pool` object."
  value       = local.o_user_pool
}

output "domain" {
  description = "The full `aws_cognito_user_pool` object."
  value       = try(aws_cognito_user_pool_domain._[0], null)
}

output "client" {
  description = "All Cognito User Pool Client resources associated with the Cognito User Pool."
  value       = local.client
}