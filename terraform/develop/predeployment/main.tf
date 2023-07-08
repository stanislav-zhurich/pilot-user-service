data "azurerm_user_assigned_identity" "aks_user_identity" {
  name                = "${var.environment}_aks_user_identity"
  resource_group_name = "${var.environment}_resource_group"
}
data "azurerm_cosmosdb_account" "cosmosdb_account" {
    name                = "${var.environment}-pilot-account"
    resource_group_name = "${var.environment}_resource_group"
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.environment}-pilot-kv"
  resource_group_name = "${var.environment}_resource_group"
}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "${var.environment}_cluster"
  resource_group_name = "${var.environment}_resource_group"
}

data "azurerm_servicebus_topic_authorization_rule" "user_topic_auth_rule" {
  name                = var.servicebus_user_topic_auth_rule
  resource_group_name = "${var.environment}_resource_group"
  namespace_name      = "${var.environment}pilotappservicebus"
  topic_name          = var.servicebus_user_topic_name
}

provider "kubernetes" {
    host = data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.cluster_ca_certificate)
    experiments {
        manifest_resource = true
    }
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

resource "azurerm_key_vault_secret" "key_vault_user_topic_connection_string" {
  name         = var.kv_user_topic_connection_string
  value        = data.azurerm_servicebus_topic_authorization_rule.user_topic_auth_rule.primary_connection_string
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_role_assignment" "key_vault_service_reader_assignement" {
  scope                = data.azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.aad_service_sp.object_id
}

resource "kubernetes_manifest" "aks_service_account" {
   manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"

    metadata = {
      annotations = {
			"azure.workload.identity/client-id" = data.azurerm_user_assigned_identity.aks_user_identity.client_id
      }
      labels = {
        "azure.workload.identity/use" = true
      }
      name = "pilotserviceaccount"
      namespace = "default"
    }
  }
}

resource "azurerm_federated_identity_credential" "service_account_federated_identity" {
  name                = "pilot_service_account_federated_identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.aks_user_identity.id
  subject             = "system:serviceaccount:default:pilotserviceaccount"
}

