resource "azurerm_cosmosdb_account" "example" {
  count               = var.ai_only ? 0 : 1
  name                = "db-${local.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "example" {
  count               = try(var.ai_only ? 0 : 1, 0)
  name                = "orderdb"
  resource_group_name = azurerm_cosmosdb_account.example[0].resource_group_name
  account_name        = azurerm_cosmosdb_account.example[0].name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "example" {
  count               = try(var.ai_only ? 0 : 1, 0)
  name                = "orders"
  resource_group_name = azurerm_cosmosdb_account.example[0].resource_group_name
  account_name        = azurerm_cosmosdb_account.example[0].name
  database_name       = azurerm_cosmosdb_mongo_database.example[0].name
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}
