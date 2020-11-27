# Terraform AWS Cognito module

## About:

Creates a basic AWS Cognito setup with a mandatory 8 character long password policy and dynamic schema support.

Please note the variable ```ignore_changes``` in the ```./main.tf``` file is used to prevent re-deployments from occurring. 

There's no built in support yet for;

- SNS Email sending and template, instead it uses the built in email support with sending limitations.
- SMS sending

## How to use:

To add a Federation, provide the ``identity_provider_map`` with the appropriate configuration for the supported Fedartion, in this case, Google.

To then enable that login provider for your Cognito identity pool, add ``supported_login_providers`` configuration.

```terraform
module "cognito" {
  source = "../../modules/cognito"

  namespace         = var.namespace
  resource_tag_name = var.resource_tag_name
  region            = var.region

  cognito_identity_pool_name     = var.cognito_identity_pool_name
  cognito_identity_pool_provider = var.cognito_identity_pool_provider

  # User Pool Client Configuration
  allowed_oauth_flows          = [ "implicit" ]
  allowed_oauth_scopes         = [ "aws.cognito.signin.user.admin" ]
  callback_urls                = [ "https://google.com" ]
  supported_identity_providers = [ "Google" ]

  supported_login_providers = {
    "accounts.google.com" = "dfsfsf.apps.googleusercontent.com"
  }

  identity_provider_map = {
    google = {
      provider_name    = "Google"
      provider_type    = "Google"
      authorize_scopes = "email"
      client_id        = "dfsfsf.apps.googleusercontent.com"
      client_secret    = "sdfsfasdfafsafsafsfsdf"

      attribute_mapping = {
        email    = "email"
        username = "sub"
      }
    }

  schema_map = [
    {
      name                = "email"
      attribute_data_type = "String"
      mutable             = false
      required            = true
    },
    {
      name                = "phone_number"
      attribute_data_type = "String"
      mutable             = false
      required            = true
    }
  ]
}
```

## Changelog

### v1.4
  - Added email configuration options with default or SES
  - Added user pool client variables to support identity federation configuration.

### v1.3
  - updated new to Terraform standards
  - added Federated login support with an example; Google.
  - added all Lambda triggers, provide the appropriate Lambda ARN to enable.
  - Added lifecycle ignores to prevent continuous changes on resources; 
    - ``provider_details`` for resource; ``aws_cognito_identity_provider``
    - ``lambda_config`` for resource; ``aws_cognito_user_pool``

### v1.2
 - Added mail template variables (cognito based emails)
 - Verify by Link or code variable

### v1.1
 - Added ignore on ``password_policy[0].temporary_password_validity_days``
 
### v1.0
 - Initial release
