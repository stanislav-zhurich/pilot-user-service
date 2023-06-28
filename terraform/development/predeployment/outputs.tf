output "service_sp_id" {
  value = azuread_service_principal.aad_service_sp.application_id
  description = "Service SP Client Id"
}

output "service_sp_tenant_id" {
  value = azuread_service_principal.aad_service_sp.application_tenant_id
  description = "Service SP Client Tenant"
}

output "service_sp_pswd" {
  value = nonsensitive(azuread_service_principal_password.service_sp_pswd.value)
  description = "Service SP Client Password"
}

