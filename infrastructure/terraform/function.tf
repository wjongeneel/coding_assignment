# create app service plan 
resource "azurerm_service_plan" "coding_assignment_app_service_plan" {
  name                = "coding-assignment-app-service-plan"
  resource_group_name = data.azurerm_resource_group.coding_assignment.name
  location            = data.azurerm_resource_group.coding_assignment.location 
  os_type             = "Linux"
  sku_name            = "Y1"
}

# create linux function app to run the api on 
resource "azurerm_linux_function_app" "coding_assignment_linux_func_app" {
  name                = "coding-assignment-linux-func-app"
  resource_group_name = data.azurerm_resource_group.coding_assignment.name
  location            = data.azurerm_resource_group.coding_assignment.location
  storage_account_name       = azurerm_storage_account.functionappstorage.name
  storage_account_access_key = azurerm_storage_account.functionappstorage.primary_access_key
  service_plan_id            = azurerm_service_plan.coding_assignment_app_service_plan.id
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
  site_config {
    ip_restriction {
      ip_address = "${var.client_ip}/32"
      action     = "Allow"
      priority   = 100
      name       = "Allow-Only-Specific-IP"
    }
    ip_restriction {
      ip_address = "0.0.0.0/0"
      action     = "Deny"
      priority   = 200
      name       = "Block-All-Others"
    }
  application_stack {
    python_version = 3.11
  }
  }
}