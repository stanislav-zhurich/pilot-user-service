variable "environment" {
  type = string
  default = "develop"
}

variable "client_id" {
   type = string
}

variable "client_secret" {
   type = string
}

variable "tenant_id" {
   type = string
}

variable "subscription_id" {
   type = string
}

variable "cosmosdb_database_name" {
  type = string
  default = "user-container"
}

variable "container_name" {
  type = string
  default = "user-primary-data"
}

variable "aad_service_app_name" {
   type = string
   default = "azuread_pilot_user_application"
}

variable "kv_user_service_sp_id" {
  type = string
  default = "user-service-sp-id"
}

variable "kv_user_service_sp_pswd" {
  type = string
  default = "user-service-sp-password"
}

variable "kv_user_service_sp_tenant" {
  type = string
  default = "user-service-sp-tenant"
}