variable "tenant_id" {
  type        = string
  description = "tenant_id for azure, define in terraform.tfvars"
}

variable "subscription_id" {
  type        = string
  description = "subscription_id for azure, define in terraform.tfvars"
}

variable "resource_group" {
  type        = string
  description = "existing resource group to work in, define in terraform.tfvars"
}

variable "client_ip" {
  type        = string
  description = "client ip from which connections to synapse will be made, define in terraform.tfvars"
}

variable "sql_administrator_login" {
  type        = string
  description = "sql admin username, define in environment vars 'TF_VAR_sql_administrator_login' in env_vars.sh, then run '. ./env_vars.sh'"
  default     = null
}

variable "sql_administrator_login_password" {
  type        = string
  description = "sql admin password, define in environment vars 'TF_VAR_sql_administrator_login_password' in env_vars.sh, then run '. ./env_vars.sh'"
  default     = null
}

variable "storage_account_key" {
  type        = string
  description = "storage account key for adls, retrieve this from the azure portal, put it into env_vars.h, then run '. ./env_vars.sh'"
  default     = null
}