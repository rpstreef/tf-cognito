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
  name                     = "${local.resource_name}-${var.cognito_identity_pool_name}"
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
  domain       = local.resource_name
  user_pool_id = aws_cognito_user_pool._.id
}

resource "aws_cognito_user_pool_client" "_" {
  name = "${local.resource_name}-client"

  user_pool_id    = aws_cognito_user_pool._.id
  generate_secret = false

  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH",
  ]
}

resource "aws_cognito_identity_pool" "_" {
  identity_pool_name      = var.cognito_identity_pool_name
  developer_provider_name = var.cognito_identity_pool_provider

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client._.id
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool._.id}"
  }

  supported_login_providers = var.supported_login_providers
}

module "identity_provider" {
  source = "./identity-provider"

  for_each = var.identity_provider_map

  user_pool_id  = aws_cognito_user_pool._.id

  provider_name = each.value.provider_name
  provider_type = each.value.provider_type

  authorize_scopes = each.value.authorize_scopes
  client_id        = each.value.client_id
  client_secret    = each.value.client_secret  

  attribute_mapping = each.value.attribute_mapping
}
