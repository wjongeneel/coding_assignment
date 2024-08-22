# write output containing credentials for use in the notebook that will be deployed to synapse
output "secrets_for_notebook" {
  value = <<SECRETS
# SECRETS
connection_string = "${nonsensitive(azurerm_storage_account.coding_assignment.primary_connection_string)}"
jdbc_username = "${nonsensitive(var.sql_administrator_login)}"
jdbc_password = "${nonsensitive(var.sql_administrator_login_password)}"
  SECRETS
  sensitive = false
}
