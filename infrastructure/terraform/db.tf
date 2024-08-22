resource "azurerm_mssql_server" "coding_assignment_sql_server" {
  name                         = "codingassignmentsqlserver"
  resource_group_name          = data.azurerm_resource_group.coding_assignment.name
  location                     = data.azurerm_resource_group.coding_assignment.location
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_login_password
}

resource "azurerm_mssql_database" "coding_assignment_db" {
  name      = "codingassignmentdb"
  server_id = azurerm_mssql_server.coding_assignment_sql_server.id
  # nieuw
  geo_backup_enabled = false
  license_type       = "LicenseIncluded"
  max_size_gb        = 1
  sku_name           = "Basic"

  lifecycle {
    prevent_destroy = false # set to false to allow for quick infrastructure cleanup, would set to true in production
  }
}

# The Azure feature Allow access to Azure services can be enabled by setting start_ip_address and end_ip_address to 0.0.0.0
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.coding_assignment_sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# allows network access to the azure sql server from provided client_ip 
resource "azurerm_mssql_firewall_rule" "client_ip" {
  name             = "ClientIpAccess"
  server_id        = azurerm_mssql_server.coding_assignment_sql_server.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}