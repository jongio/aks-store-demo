output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_name" {
  value = var.ai_only ? "" : azurerm_kubernetes_cluster.aks[0].name
}

output "ai_model_name" {
  value = var.openai_model_name
}

output "ai_endpoint" {
  value = azurerm_cognitive_account.cog.endpoint
}

output "ai_name" {
  value = azurerm_cognitive_account.cog.endpoint
}

output "ai_key" {
  value     = azurerm_cognitive_account.cog.primary_access_key
  sensitive = true
}

output "ai_managed_identity_client_id" {
  value = azurerm_user_assigned_identity.uai.client_id
}

output "sb_namespace_host" {
  value = var.ai_only ? "" : "${azurerm_servicebus_namespace.sb[0].name}.servicebus.windows.net"
}

output "sb_namespace_uri" {
  value     = var.ai_only ? "" : "amqps://${azurerm_servicebus_namespace.sb[0].name}.servicebus.windows.net"
  sensitive = true
}

output "sb_listener_username" {
  value = var.ai_only ? "" : azurerm_servicebus_namespace_authorization_rule.sb_rule[0].name
}

output "sb_listener_key" {
  value     = var.ai_only ? "" : azurerm_servicebus_namespace_authorization_rule.sb_rule[0].primary_key
  sensitive = true
}

output "sb_sender_username" {
  value = var.ai_only ? "" : azurerm_servicebus_queue_authorization_rule.sb_queue_rule[0].name
}

output "sb_sender_key" {
  value     = var.ai_only ? "" : azurerm_servicebus_queue_authorization_rule.sb_queue_rule[0].primary_key
  sensitive = true
}

output "db_account_name" {
  value = var.ai_only ? "" : azurerm_cosmosdb_account.cosmos[0].name
}

output "db_uri" {
  value = var.ai_only ? "" : "mongodb://${azurerm_cosmosdb_account.cosmos[0].name}.mongo.cosmos.azure.com:10255/?retryWrites=false"
}

output "db_key" {
  value     = var.ai_only ? "" : azurerm_cosmosdb_account.cosmos[0].primary_key
  sensitive = true
}

output "k8s_namespace" {
  value = var.ai_only ? "" : var.k8s_namespace
}

