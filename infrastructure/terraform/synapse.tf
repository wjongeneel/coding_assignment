# creates synapse workspace
resource "azurerm_synapse_workspace" "coding_assignment_synapse" {
  name                                 = "codingassignmentsynapse"
  resource_group_name                  = data.azurerm_resource_group.coding_assignment.name
  location                             = data.azurerm_resource_group.coding_assignment.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.coding_assignment_adls.id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = var.sql_administrator_login_password

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.synapse_mi.id
    ]
  }
}

# allows network access to the synapse workspace from provided client_ip 
resource "azurerm_synapse_firewall_rule" "client_ip" {
  name                 = "ClientIpAccess"
  synapse_workspace_id = azurerm_synapse_workspace.coding_assignment_synapse.id
  start_ip_address     = var.client_ip
  end_ip_address       = var.client_ip
}

# creates a managed identity for the synapse workspace 
resource "azurerm_user_assigned_identity" "synapse_mi" {
  name                = "synapse-mi"
  resource_group_name = data.azurerm_resource_group.coding_assignment.name
  location            = data.azurerm_resource_group.coding_assignment.location
}

# assign needed roles to system and user assigned identities 
resource "azurerm_role_assignment" "adls-storage-reader" {
  scope                = azurerm_storage_account.coding_assignment.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.synapse_mi.principal_id
}

resource "azurerm_role_assignment" "adls-storage-contributor" {
  scope                = azurerm_storage_account.coding_assignment.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.synapse_mi.principal_id
}

resource "azurerm_role_assignment" "adls-storage-reader2" {
  scope                = azurerm_storage_account.coding_assignment.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_synapse_workspace.coding_assignment_synapse.identity[0].principal_id
}

resource "azurerm_role_assignment" "adls-storage-contributor2" {
  scope                = azurerm_storage_account.coding_assignment.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.coding_assignment_synapse.identity[0].principal_id
}

# creates a sparkpool
resource "azurerm_synapse_spark_pool" "coding_assignment_spark_pool" {
  name = "sparkpool"
  synapse_workspace_id = azurerm_synapse_workspace.coding_assignment_synapse.id
  node_size_family = "MemoryOptimized"
  node_size = "Small"
  session_level_packages_enabled = true
  node_count = 3
  cache_size = 50
  auto_pause {
    delay_in_minutes = 5
  }
  dynamic_executor_allocation_enabled = false
  spark_version = 3.4
}