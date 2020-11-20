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