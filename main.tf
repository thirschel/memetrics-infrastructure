locals {
  name       = "memetrics-${lower(terraform.workspace)}"
  short_name = "mm${lower(replace(terraform.workspace, "-", ""))}"
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "resource_group" {
  name     = local.name
  location = var.location

  tags     = var.tags
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                       = "${local.name}-plan"
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  kind                       = "Linux"
  reserved                   = true

  sku {
    tier     = var.app_service_plan_tier
    size     = var.app_service_plan_size
  }

  tags = var.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                    = "${local.name}-insights"
  location                = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  application_type        = "web"

  tags = var.tags
}

resource "azurerm_sql_server" "mm_sql_server" {
  name                         = "${local.name}-sql-server"
  location                     = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  version                      = "12.0"
  administrator_login          = var.secret_db_username
  administrator_login_password = var.secret_db_password

  tags = var.tags
}

resource "azurerm_sql_database" "mm_database" {
  name                              = "${local.name}-db"
  location                          = azurerm_resource_group.resource_group.location
  resource_group_name               = azurerm_resource_group.resource_group.name
  server_name                       = azurerm_sql_server.mm_sql_server.name
  edition                           = var.azurerm_sql_database_edition
  requested_service_objective_name  = var.azurerm_sql_database_requested_service_objective_name

  tags = var.tags
}

resource "azurerm_key_vault" "mm_keyvault" {
  name                        = "${local.short_name}-keyvault"
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.secret_devops_tenant_id
  sku_name                    = var.keyvault_sku

  access_policy {
    tenant_id = var.secret_devops_tenant_id
    object_id = var.service_principal_object_id

    key_permissions = [
      "get",
      "list",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete"
    ]

    storage_permissions = [
      "get",
      "list",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [
      var.agent_ip_address
    ]

  }
  tags = var.tags
}

resource "azurerm_key_vault_secret" "app_insights_intrumentation_key" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.app_insights.instrumentation_key
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "DbConnectionString"
  value        = "Server=tcp:${azurerm_sql_server.mm_sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.mm_database.name};Persist Security Info=False;User ID=${var.secret_db_username};Password=${var.secret_db_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_client_id" {
  name         = "GmailClientId"
  value        = var.secret_gmail_client_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_client_secret" {
  name         = "GmailClientSecret"
  value        = var.secret_gmail_client_secret
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_history_refresh_token" {
  name         = "GmailHistoryRefreshToken"
  value        = var.secret_gmail_history_refresh_token
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_main_refresh_token" {
  name         = "GmailMainRefreshToken"
  value        = var.secret_gmail_main_refresh_token
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_sms_email_address" {
  name         = "GmailSmsEmailAddress"
  value        = var.secret_gmail_sms_email_address
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "gmail_recruiter_email_address" {
  name         = "GmailRecruiterEmailAddress"
  value        = var.secret_gmail_recruiter_email_address
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "groupme_access_token" {
  name         = "GroupMeAccessToken"
  value        = var.secret_groupme_access_token
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "lyft_refresh_token" {
  name         = "LyftRefreshToken"
  value        = var.secret_lyft_refresh_token
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "lyft_basic_auth" {
  name         = "LyftBasicAuth"
  value        = var.secret_lyft_basic_auth
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "uber_client_id" {
  name         = "UberClientId"
  value        = var.secret_uber_client_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "uber_client_secret" {
  name         = "UberClientSecret"
  value        = var.secret_uber_client_secret
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "uber_refresh_token" {
  name         = "UberRefreshToken"
  value        = var.secret_uber_refresh_token
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "uber_cookie" {
  name         = "UberCookie"
  value        = var.secret_uber_cookie
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "uber_user_id" {
  name         = "UberUserId"
  value        = var.secret_uber_user_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "lyft_cookie" {
  name         = "LyftCookie"
  value        = var.secret_lyft_cookie
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "devops_client_id" {
  name         = "DevopsClientId"
  value        = var.secret_devops_client_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "devops_client_secret" {
  name         = "DevopsClientSecret"
  value        = var.secret_devops_client_secret
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "devops_tenant_id" {
  name         = "DevopsTenantId"
  value        = var.secret_devops_tenant_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "devops_subscription_id" {
  name         = "DevopsSubscriptionId"
  value        = var.secret_devops_subscription_id
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "primary_api_key" {
  name         = "PrimaryApiKey"
  value        = var.secret_primary_api_key
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "secondary_api_key" {
  name         = "SecondaryApiKey"
  value        = var.secret_secondary_api_key
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "linkedin_username" {
  name         = "LinkedInUsername"
  value        = var.secret_linkedin_username
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "linkedin_password" {
  name         = "LinkedInPassword"
  value        = var.secret_linkedin_password
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "personal_capital_username" {
  name         = "PersonalCapitalUsername"
  value        = var.secret_personal_capital_username
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "personal_capital_password" {
  name         = "PersonalCapitalPassword"
  value        = var.secret_personal_capital_password
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}

resource "azurerm_key_vault_secret" "personal_capital_pmdata" {
  name         = "PersonalCapitalPMData"
  value        = var.secret_personal_capital_pmdata
  key_vault_id = azurerm_key_vault.mm_keyvault.id
}
