data "azurerm_key_vault" "azure-devops-keyvault" {
  name = "azure-devops-keyvault-01"
  resource_group_name = "resource-group-1"
}

data "azurerm_key_vault_secret" "publicKey" {
  name = "jumpboxPublicKey"
  key_vault_id = data.azurerm_key_vault.azure-devops-keyvault.id
}

