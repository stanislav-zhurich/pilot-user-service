data "azurerm_cosmosdb_account" "cosmosdb_account" {
    name                = "${var.environment}-pilot-account"
    resource_group_name = "${var.environment}_resource_group"
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.environment}-pilot-kv"
  resource_group_name = "${var.environment}_resource_group"
}

data "azuread_client_config" "current" {}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_database" {
  name                = var.cosmosdb_database_name
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
}

resource "azurerm_cosmosdb_sql_container" "comsosdb_container" {
  name                  = var.container_name
  resource_group_name   = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name          = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name         = azurerm_cosmosdb_sql_database.cosmosdb_database.name
  partition_key_path    = "/tenantId"
  partition_key_version = 1

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}


resource "azuread_application" "aad_service_application" {
  display_name = var.aad_service_app_name
  identifier_uris  = ["api://${var.aad_service_app_name}"]
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aad_service_sp" {
  application_id               = azuread_application.aad_service_application.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_cosmosdb_sql_role_assignment" "user_service_contributor_role_assignment" {
  name                = "736180af-7fbc-4c7f-9004-22735173c1c3"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  role_definition_id  = "${data.azurerm_cosmosdb_account.cosmosdb_account.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azuread_service_principal.aad_service_sp.object_id
  scope               = data.azurerm_cosmosdb_account.cosmosdb_account.id
}

resource "azuread_service_principal_password" "service_sp_pswd" {
  service_principal_id = azuread_service_principal.aad_service_sp.object_id
}

resource "azurerm_key_vault_secret" "key_vault_service_principal_id" {
  depends_on = [ azuread_service_principal_password.service_sp_pswd ]
  name         = var.kv_user_service_sp_id
  value        = azuread_service_principal.aad_service_sp.application_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "key_vault_service_principal_password" {
  depends_on = [ azuread_service_principal_password.service_sp_pswd ]
  name         = var.kv_user_service_sp_pswd
  value        = azuread_service_principal_password.service_sp_pswd.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "key_vault_service_principal_tenant" {
  depends_on = [ azuread_service_principal_password.service_sp_pswd ]
  name         = var.kv_user_service_sp_tenant
  value        = data.azuread_client_config.current.tenant_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_role_assignment" "key_vault_service_reader_assignement" {
  scope                = data.azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.aad_service_sp.object_id
}