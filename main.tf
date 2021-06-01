locals {
  resource_name = "${var.namespace}-${var.resource_tag_name}"
}

# -----------------------------------------------------------------------------
# Resource: Cognito
# Remarks: Set for Schema String and Number attribute constraints to prevent redeployment (!)
# https://github.com/terraform-providers/terraform-provider-aws/issues/7502
# https://www.terraform.io/docs/providers/aws/r/cognito_user_pool.html#schema-attributes
# -----------------------------------------------------------------------------

resource "aws_cognito_user_pool" "_" {
  count = var.cognito_module_enabled ? 1 : 0

  name                     = "${local.resource_name}-${var.cognito_identity_pool_name}"
  alias_attributes         = var.cognito_alias_attributes
  auto_verified_attributes = var.cognito_auto_verified_attributes

  lambda_config {
    create_auth_challenge          = var.cognito_lambda_create_auth_challenge
    custom_message                 = var.cognito_lambda_custom_message
    define_auth_challenge          = var.cognito_lambda_define_auth_challenge
    post_authentication            = var.cognito_lambda_post_authentication
    post_confirmation              = var.cognito_lambda_post_confirmation
    pre_authentication             = var.cognito_lambda_pre_authentication
    pre_sign_up                    = var.cognito_lambda_pre_sign_up
    pre_token_generation           = var.cognito_lambda_pre_token_generation
    user_migration                 = var.cognito_lambda_user_migration
    verify_auth_challenge_response = var.cognito_lambda_verify_auth_challenge_response
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account  = var.cognito_email_sending_account
    reply_to_email_address = var.cognito_email_reply_to_address
    source_arn             = var.cognito_email_source_arn
    from_email_address     = var.cognito_email_from_address
  }

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  dynamic "schema" {
    for_each = var.cognito_schema_map

    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
      required            = schema.value.required
    }
  }

  verification_message_template {
    default_email_option  = var.cognito_default_email_option
    email_message         = var.cognito_email_message
    email_message_by_link = var.cognito_email_message_by_link
    email_subject         = var.cognito_email_subject
    email_subject_by_link = var.cognito_email_subject_by_link
  }

  lifecycle {
    ignore_changes = [
      schema,
      lambda_config,
      password_policy[0].temporary_password_validity_days
    ]
  }

  tags = {
    Environment = var.namespace
    Name        = var.resource_tag_name
  }
}

# -----------------------------------------------------------------------------
# Domain is required for email link to function:
# https://forums.aws.amazon.com/thread.jspa?threadID=262811
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "_" {
  count = var.cognito_module_enabled && var.cognito_user_pool_domain_name != null ? 1 : 0

  domain       = var.cognito_user_pool_domain_name
  user_pool_id = one(aws_cognito_user_pool._.*.id)

  certificate_arn = var.cognito_acm_certificate_arn
}

resource "aws_cognito_user_pool_client" "_" {
  count = var.cognito_module_enabled ? 1 : 0

  name = "${local.resource_name}-client"

  user_pool_id    = one(aws_cognito_user_pool._.*.id)
  generate_secret = var.cognito_generate_secret

  allowed_oauth_flows_user_pool_client = var.cognito_allowed_oauth_flows_user_pool_client

  allowed_oauth_flows  = var.cognito_allowed_oauth_flows
  allowed_oauth_scopes = var.cognito_allowed_oauth_scopes

  callback_urls        = var.cognito_callback_urls
  logout_urls          = var.cognito_logout_urls
  default_redirect_uri = var.cognito_default_redirect_uri

  supported_identity_providers = var.cognito_supported_identity_providers

  prevent_user_existence_errors = var.cognito_prevent_user_existence_errors

  refresh_token_validity = var.cognito_refresh_token_validity

  explicit_auth_flows = var.cognito_explicit_auth_flows

  read_attributes  = var.cognito_read_attributes
  write_attributes = var.cognito_write_attributes
}

resource "aws_cognito_identity_pool" "_" {
  count = var.cognito_module_enabled ? 1 : 0
  
  identity_pool_name      = var.cognito_identity_pool_name
  developer_provider_name = var.cognito_identity_pool_provider

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = one(aws_cognito_user_pool_client._.*.id)
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${one(aws_cognito_user_pool._.*.id)}"
  }

  supported_login_providers = var.cognito_supported_login_providers
}


# -----------------------------------------------------------------------------
# Route53 Cognito hosted domain configuration
# -----------------------------------------------------------------------------
data "aws_route53_zone" "_" {
  count = var.cognito_create_route53_record ? 1 : 0
  name  = var.cognito_route53_zone_name
}

resource "aws_route53_record" "auth-cognito-A" {
  count = var.cognito_create_route53_record ? 1 : 0

  name    = one(aws_cognito_user_pool_domain._.*.domain)
  type    = "A"
  zone_id = one(data.aws_route53_zone._.*.zone_id)

  alias {
    evaluate_target_health = false

    name = one(aws_cognito_user_pool_domain._.*.cloudfront_distribution_arn)

    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

module "identity_provider" {
  source = "./module/identity-provider"

  for_each = var.cognito_identity_provider_map

  user_pool_id = one(aws_cognito_user_pool._.*.id)

  provider_name = each.value.provider_name
  provider_type = each.value.provider_type

  authorize_scopes = each.value.authorize_scopes
  client_id        = each.value.client_id
  client_secret    = each.value.client_secret

  attribute_mapping = each.value.attribute_mapping
}
