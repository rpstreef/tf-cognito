# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "AWS resource namespace/prefix"
}

variable "region" {
  description = "AWS region"
}

variable "resource_tag_name" {
  description = "Resource tag name for cost tracking"
}

# -----------------------------------------------------------------------------
# Variables: Cognito & S3
# -----------------------------------------------------------------------------

variable "cognito_identity_pool_name" {
  description = "Cognito identity pool name"
}

variable "cognito_identity_pool_provider" {
  description = "Cognito identity pool provider"
}

variable "alias_attributes" {
  type = list(string)
  default = ["email"]
  description = "(Optional) Attributes supported as an alias for this user pool. Possible values: phone_number, email, or preferred_username. Conflicts with username_attributes. "
}

variable "auto_verified_attributes" {
  type = list
  default = ["email"]
  description = "(Optional) The attributes to be auto-verified. Possible values: email, phone_number. "
}

variable "schema_map" {
  type = list(object({
    name                = string
    attribute_data_type = string
    mutable             = bool
    required            = bool
  }))
  default = []
  description = "Creates 1 or more Schema blocks"
}

variable "default_email_option" {
  type        = string
  default     = "CONFIRM_WITH_CODE"
  description = "The default email option. Must be either CONFIRM_WITH_CODE or CONFIRM_WITH_LINK. Defaults to CONFIRM_WITH_CODE."
}

variable "email_message" {
  type        = string
  default     = null
  description = "The email message template. Must contain the {####} placeholder. Conflicts with email_verification_message argument."
}

variable "email_message_by_link" {
  type        = string
  default     = null
  description = "The email message template for sending a confirmation link to the user, it must contain the {##Click Here##} placeholder."
}

variable "email_subject" {
  type        = string
  default     = null
  description = "The subject line for the email message template. Conflicts with email_verification_subject argument."
}

variable "email_subject_by_link" {
  type        = string
  default     = null
  description = "The subject line for the email message template for sending a confirmation link to the user."
}

variable "supported_login_providers" {
  type        = map(string)
  default     = null
  description = "Adds support for Federated login with Google (accounts.google.com), Facebook (graph.facebook.com) etc."
}

variable "identity_provider_map" {
  type        = map
  default     = {}
  description = "Configure Identity providers (Federation) such as Google and Facebook"
}

# -----------------------------------------------------------------------------
# Variables: Cognito User Pool Client
# -----------------------------------------------------------------------------

variable "allowed_oauth_flows" {
  type        = list(string)
  description = "(Optional) List of allowed OAuth flows (code, implicit, client_credentials)."
  default     = []
}

variable "allowed_oauth_scopes" {
  type        = list(string)
  description = "(Optional) List of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin)."
  default     = []
}

variable "callback_urls" {
  type        = list(string)
  description = "(Optional) List of allowed callback URLs for the identity providers."
  default     = []
}

variable "supported_identity_providers" {
  type        = list(string)
  description = "(Optional) List of provider names for the identity providers that are supported on this client."
  default     = []
}

variable "default_redirect_uri" {
  type        = string
  description = "(Optional) The default redirect URI. Must be in the list of callback URLs."
  default     = null
}

variable "logout_urls" {
  type        = list(string)
  default     = []
  description = "(Optional) List of allowed logout URLs for the identity providers."
}

variable "explicit_auth_flows" {
  type        = list(string)
  description = "(Optional) List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH)."
  default     = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH"
  ]
}

variable "generate_secret" {
  type        = bool
  default     = false
  description = "(Optional) Should an application secret be generated."
}

variable "prevent_user_existence_errors" {
  type        = string
  default     = "LEGACY"
  description = "When set to ENABLED and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to LEGACY, those APIs will return a UserNotFoundException exception if the user does not exist in the user pool."
}

variable "refresh_token_validity" {
  type        = number
  default     = 30
  description = "(Optional) The time limit in days refresh tokens are valid for."
}

variable "read_attributes" {
 type        = list(string)
 default     = []
 description = "(Optional) List of user pool attributes the application client can read from."
}

variable " write_attributes" {
  type        = list(string)
  default     = []
  description = "(Optional) List of user pool attributes the application client can write to."
}

# -----------------------------------------------------------------------------
# Variables: Cognito Lambda triggers
# -----------------------------------------------------------------------------

variable "lambda_create_auth_challenge" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda creating an authentication challenge."
  default     = null
}

variable "lambda_custom_message" {
  type        = string
  description = "(Optional) The ARN of a custom message AWS Lambda trigger."
  default     = null
}

variable "lambda_define_auth_challenge" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that defines the authentication challenge."
  default     = null
}

variable "lambda_post_authentication" {
  type        = string
  description = "(Optional) The ARN of a post-authentication AWS Lambda trigger."
  default     = null
}

variable "lambda_post_confirmation" {
  type        = string
  description = "(Optional) The ARN of a post-confirmation AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_authentication" {
  type        = string
  description = "(Optional) The ARN of a pre-authentication AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_sign_up" {
  type        = string
  description = "(Optional) The ARN of a pre-registration AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_token_generation" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that allows customization of identity token claims before token generation."
  default     = null
}

variable "lambda_user_migration" {
  type        = string
  description = "(Optional) The ARN of the user migration AWS Lambda config type."
  default     = null
}

variable "lambda_verify_auth_challenge_response" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that verifies the authentication challenge response."
  default     = null
}

# -----------------------------------------------------------------------------
# Variables: Email with SES configuration
# -----------------------------------------------------------------------------

variable "email_sending_account" {
  type        = string
  description = "(Optional) The email delivery method to use. 'COGNITO_DEFAULT' for the default email functionality built into Cognito or 'DEVELOPER' to use your Amazon SES configuration."
  default     = "COGNITO_DEFAULT"
}

variable "email_reply_to_address" {
  type        = string
  description = "(Optional) - The REPLY-TO email address."
  default     = null
}

variable "email_source_arn" {
  type        = string
  description = "(Optional) - The ARN of the SES verified email identity to to use. Required if email_sending_account is set to DEVELOPER."
  default     = null
}

variable "email_from_address" {
  type        = string
  description = "(Optional) - Sender’s email address or sender’s name with their email address (e.g. 'john@smith.com' or 'John Smith <john@smith.com>')."
  default     = null
}