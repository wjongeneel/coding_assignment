# create storage account for synapse
resource "azurerm_storage_account" "coding_assignment" {
  name                     = "codingassignmentstorage"
  resource_group_name      = data.azurerm_resource_group.coding_assignment.name
  location                 = data.azurerm_resource_group.coding_assignment.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

# create filesystem on top of the storage account for synapse, set appropriate acl records
resource "azurerm_storage_data_lake_gen2_filesystem" "coding_assignment_adls" {
  name               = "codingassignmentfilesystem"
  storage_account_id = azurerm_storage_account.coding_assignment.id
  ace {
    id          = null
    permissions = "--x"
    scope       = "access"
    type        = "other"
  }
  ace {
    id          = null
    permissions = "r-x"
    scope       = "access"
    type        = "group"
  }
  ace {
    id          = null
    permissions = "rwx"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "default"
    type        = "user"
  }
}

# create directory arriving_data on adls filesystem, set appropriate acl records
resource "azurerm_storage_data_lake_gen2_path" "arriving_data" {
  path               = "arriving_data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.coding_assignment_adls.name
  storage_account_id = azurerm_storage_account.coding_assignment.id
  resource           = "directory"
   ace {
    id          = null
    permissions = "--x"
    scope       = "access"
    type        = "other"
  }
  ace {
    id          = null
    permissions = "r-x"
    scope       = "access"
    type        = "group"
  }
  ace {
    id          = null
    permissions = "rwx"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "default"
    type        = "user"
  }
}

# create directory reports on adls filesystem, set appropriate acl records
resource "azurerm_storage_data_lake_gen2_path" "reports" {
  path               = "reports"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.coding_assignment_adls.name
  storage_account_id = azurerm_storage_account.coding_assignment.id
  resource           = "directory"
   ace {
    id          = null
    permissions = "--x"
    scope       = "access"
    type        = "other"
  }
  ace {
    id          = null
    permissions = "r-x"
    scope       = "access"
    type        = "group"
  }
  ace {
    id          = null
    permissions = "rwx"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "access"
    type        = "user"
  }
  ace {
    id          = azurerm_user_assigned_identity.synapse_mi.principal_id
    permissions = "r-x"
    scope       = "default"
    type        = "user"
  }
}

# create storage account for the function app
resource "azurerm_storage_account" "functionappstorage" {
  name                     = "functionappstorage1234"
  resource_group_name      = data.azurerm_resource_group.coding_assignment.name
  location                 = data.azurerm_resource_group.coding_assignment.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

