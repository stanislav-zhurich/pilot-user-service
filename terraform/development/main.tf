data "azurerm_cosmosdb_account" "cosmosdb_account" {
    name                = "${var.environment}-pilot-account"
    resource_group_name = "${var.environment}_resource_group"
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_database" {
  name                = var.cosmosdb_database_name
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
}

resource "azurerm_cosmosdb_sql_container" "example" {
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