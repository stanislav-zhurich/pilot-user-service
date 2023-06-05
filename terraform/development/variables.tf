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