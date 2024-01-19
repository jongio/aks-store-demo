resource "azurecaf_name" "sb_name" {
  count         = var.ai_only ? 0 : 1
  name          = local.resource_token
  resource_type = "azurerm_servicebus_namespace"
  random_length = 0
  clean_input   = true
}

resource "azurerm_servicebus_namespace" "sb" {
  count               = var.ai_only ? 0 : 1
  name                = azurecaf_name.sb_name[0].result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = azurerm_resource_group.rg.tags

}

resource "azurerm_servicebus_namespace_authorization_rule" "sb_rule" {
  count        = try(var.ai_only ? 0 : 1, 0)
  name         = "listener"
  namespace_id = azurerm_servicebus_namespace.sb[0].id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue" "sb_queue" {
  count        = try(var.ai_only ? 0 : 1, 0)
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.sb[0].id
}

resource "azurerm_servicebus_queue_authorization_rule" "sb_queue_rule" {
  count    = try(var.ai_only ? 0 : 1, 0)
  name     = "sender"
  queue_id = azurerm_servicebus_queue.sb_queue[0].id

  listen = false
  send   = true
  manage = false
}

