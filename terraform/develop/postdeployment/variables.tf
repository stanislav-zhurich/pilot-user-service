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

variable "servicebus_user_topic_name" {
  type = string
  default = "user_topic"
}

variable "servicebus_user_topic_auth_rule" {
  type = string
  default = "user_topic_send_listen_auth_rule"
}