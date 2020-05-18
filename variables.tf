# These variables are special for this particular terraform. While they will be stored in key vault the key vault can't be accessed until its first created
# Because of this, these values will need to added as pipeline secrets in Azure Devops pipeline that is created for this repo

variable "secret_devops_client_id" {
  description = "Client id or app id of the service principal used to connect to Azure. See the create_service_principal.ps1 file in scripts to create one"
}

variable "secret_devops_client_secret" {
  description = "Client secret of the service principal used to connect to Azure. See the create_service_principal.ps1 file in scripts to create one"
}

variable "secret_devops_tenant_id" {
  description = "Azure tenant id the resources are being created in"
}

variable "secret_devops_subscription_id" {
  description = "Azure subscription id the resources are being created in"
}

variable "service_principal_object_id" {
  description = "Object id of the service principal used to connect to Azure. See the create_service_principal.ps1 file in scripts to create one"
}

# These variables are used to setup the infrastructure but already have default values

variable "location" {
  description = "The location/region where the search service is created. Changing this forces a new resource to be created."
  default     = "East US"
}

variable "keyvault_sku" {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "standard"
}

variable "app_service_plan_tier" {
  description = "The plan's pricing tier"
  default     = "Standard"
}

variable "app_service_plan_size" {
  description = "The plan's instance size"
  default     = "S1"
}

variable "azurerm_sql_database_edition" {
  description = "The edition of the database to be created. Applies only if create_mode is Default. Valid values are: Basic, Standard, Premium, DataWarehouse, Business, BusinessCritical, Free, GeneralPurpose, Hyperscale, Premium, PremiumRS, Standard, Stretch, System, System2, or Web"
  default     = "Standard"
}

variable "azurerm_sql_database_requested_service_objective_name" {
  description = "The service objective name for the database. Valid values depend on edition and location and may include S0, S1, S2, S3, P1, P2, P4, P6, P11 and ElasticPool."
  default     = "S2"
}

variable "tags" {
  description = "A mapping of tages to assign to the resource. Changing this forces a new resource to be created."
  default = {
    source  = "terraform"
    product = "MeMetrics"
  }
}

# Various secrets that get used between the updater and the application

variable "secret_api_access_key" {}
variable "secret_gmail_client_id" {}
variable "secret_gmail_client_secret" {}
variable "secret_gmail_history_refresh_token" {}
variable "secret_gmail_main_refresh_token" {}
variable "secret_gmail_sms_email_address" {}
variable "secret_gmail_recruiter_email_address" {}
variable "secret_groupme_access_token" {}
variable "secret_lyft_refresh_token" {}
variable "secret_lyft_basic_auth" {}
variable "secret_lyft_cookie" {}
variable "secret_uber_client_id" {}
variable "secret_uber_client_secret" {}
variable "secret_uber_refresh_token" {}
variable "secret_uber_cookie" {}
variable "secret_uber_user_id" {}
variable "secret_primary_api_key" {}
variable "secret_secondary_api_key" {}
variable "secret_personal_capital_username" {}
variable "secret_personal_capital_password" {}
variable "secret_personal_capital_pmdata" {}
variable "secret_linkedin_username" {}
variable "secret_linkedin_password" {}
variable "secret_db_username" {}
variable "secret_db_password" {}