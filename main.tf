locals {
  resource_name = "${var.environment}-${var.resource_tag_name}"

  jwk_url = "https://cognito-idp.${var.region}.amazonaws.com/${try(one(aws_cognito_user_pool._.*.id), "cognito_module_disabled")}/.well-known/jwks.json"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}

# -----------------------------------------------------------------------------
# Resource: Cognito
# Remarks: Set for Schema String and Number attribute constraints to prevent redeployment (!)
# https://github.com/terraform-providers/terraform-provider-aws/issues/7502
# https://www.terraform.io/docs/providers/aws/r/cognito_user_pool.html#schema-attributes
# -----------------------------------------------------------------------------

resource "aws_cognito_user_pool" "_" {
  count = var.cognito_module_enabled ? 1 : 0

  name                     = "${local.resource_name}-${var.identity_pool_name}"
  alias_attributes         = var.alias_attributes
  auto_verified_attributes = var.auto_verified_attributes

  lambda_config {
    create_auth_challenge          = var.lambda_create_auth_challenge
    custom_message                 = var.lambda_custom_message
    define_auth_challenge          = var.lambda_define_auth_challenge
    post_authentication            = var.lambda_post_authentication
    post_confirmation              = var.lambda_post_confirmation
    pre_authentication             = var.lambda_pre_authentication
    pre_sign_up                    = var.lambda_pre_sign_up
    pre_token_generation           = var.lambda_pre_token_generation
    user_migration                 = var.lambda_user_migration
    verify_auth_challenge_response = var.lambda_verify_auth_challenge_response
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account  = var.email_sending_account
    reply_to_email_address = var.email_reply_to_address
    source_arn             = var.email_source_arn
    from_email_address     = var.email_from_address
  }

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  dynamic "schema" {
    for_each = var.schema_map

    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
      required            = schema.value.required
    }
  }

  verification_message_template {
    default_email_option  = var.default_email_option
    email_message         = var.email_message
    email_message_by_link = var.email_message_by_link
    email_subject         = var.email_subject
    email_subject_by_link = var.email_subject_by_link
  }

  lifecycle {
    ignore_changes = [
      schema,
      lambda_config,
      password_policy[0].temporary_password_validity_days
    ]
  }

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Domain is required for email link to function:
# https://forums.aws.amazon.com/thread.jspa?threadID=262811
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "_" {
  count = var.cognito_module_enabled && var.user_pool_domain_name != null ? 1 : 0

  domain       = var.user_pool_domain_name
  user_pool_id = try(one(aws_cognito_user_pool._.*.id), "")

  certificate_arn = var.acm_certificate_arn
}

resource "aws_cognito_user_pool_client" "_" {
  count = var.cognito_module_enabled ? 1 : 0

  name = "${local.resource_name}-client"

  user_pool_id    = try(one(aws_cognito_user_pool._.*.id), "")
  generate_secret = var.generate_secret

  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client

  allowed_oauth_flows  = var.allowed_oauth_flows
  allowed_oauth_scopes = var.allowed_oauth_scopes

  callback_urls        = var.callback_urls
  logout_urls          = var.logout_urls
  default_redirect_uri = var.default_redirect_uri

  supported_identity_providers = var.supported_identity_providers

  prevent_user_existence_errors = var.prevent_user_existence_errors

  refresh_token_validity = var.refresh_token_validity

  explicit_auth_flows = var.explicit_auth_flows

  read_attributes  = var.read_attributes
  write_attributes = var.write_attributes
}

resource "aws_cognito_identity_pool" "_" {
  count = var.cognito_module_enabled ? 1 : 0
  
  identity_pool_name      = var.identity_pool_name
  developer_provider_name = var.identity_pool_provider

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = try(one(aws_cognito_user_pool_client._.*.id), "")
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${try(one(aws_cognito_user_pool._.*.id), "")}"
  }

  supported_login_providers = var.supported_login_providers
}


# -----------------------------------------------------------------------------
# Route53 Cognito hosted domain configuration
# -----------------------------------------------------------------------------
data "aws_route53_zone" "_" {
  count = var.create_route53_record ? 1 : 0

  name  = var.route53_zone_name
}

resource "aws_route53_record" "auth-cognito-A" {
  count = var.create_route53_record ? 1 : 0

  name    = try(one(aws_cognito_user_pool_domain._.*.domain), "")
  type    = "A"
  zone_id = try(one(data.aws_route53_zone._.*.zone_id), "")

  alias {
    evaluate_target_health = false

    name = try(one(aws_cognito_user_pool_domain._.*.cloudfront_distribution_arn), "")

    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

module "identity_provider" {
  source = "./module/identity-provider"

  for_each = var.identity_provider_map

  user_pool_id = try(one(aws_cognito_user_pool._.*.id), "")

  provider_name = each.value.provider_name
  provider_type = each.value.provider_type

  authorize_scopes = each.value.authorize_scopes
  client_id        = each.value.client_id
  client_secret    = each.value.client_secret

  attribute_mapping = each.value.attribute_mapping
}
