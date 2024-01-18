resource "azurecaf_name" "aks_name" {
  name          = local.resource_token
  resource_type = "azurerm_kubernetes_cluster"
  random_length = 0
  clean_input   = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.ai_only ? 0 : 1
  name                = azurecaf_name.aks_name.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = azurecaf_name.aks_name.result
  tags                = azurerm_resource_group.rg.tags

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D4s_v4"
    node_count = 3
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  lifecycle {
    ignore_changes = [
      monitor_metrics,
      azure_policy_enabled,
      microsoft_defender
    ]
  }
}
