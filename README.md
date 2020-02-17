# Terraform AWS Cognito module

## About:

Creates a basic AWS Cognito setup with a mandatory 8 character long password policy and dynamic schema support.

Please note the variable ```ignore_changes``` in the ```./main.tf``` file is used to prevent re-deployments from occurring. 

## How to use:

```terraform
module "cognito" {
  source = "../../modules/cognito"

  namespace         = var.namespace
  resource_tag_name = var.resource_tag_name
  region            = var.region

  cognito_identity_pool_name     = var.cognito_identity_pool_name
  cognito_identity_pool_provider = var.cognito_identity_pool_provider

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

### v1.0
 - Initial release