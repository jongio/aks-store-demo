resource "azurerm_servicebus_namespace" "example" {
  count               = var.ai_only ? 0 : 1
  name                = "sb-${local.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "example" {
  count        = try(var.ai_only ? 0 : 1, 0)
  name         = "listener"
  namespace_id = azurerm_servicebus_namespace.example[0].id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue" "example" {
  count        = try(var.ai_only ? 0 : 1, 0)
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.example[0].id
}

resource "azurerm_servicebus_queue_authorization_rule" "example" {
  count    = try(var.ai_only ? 0 : 1, 0)
  name     = "sender"
  queue_id = azurerm_servicebus_queue.example[0].id

  listen = false
  send   = true
  manage = false
}

