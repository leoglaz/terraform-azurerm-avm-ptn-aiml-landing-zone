# Cross-region private endpoints for AI Foundry
# When AI Foundry is deployed in a different region than the main VNet,
# private endpoints need to be created manually in the VNet's region

locals {
  create_cross_region_pe = var.ai_foundry_definition.deploy && var.ai_foundry_definition.location != null
}

# Private Endpoint for AI Foundry Hub (Cognitive Services)
resource "azurerm_private_endpoint" "ai_foundry_hub_cross_region" {
  count = local.create_cross_region_pe ? 1 : 0

  name                = "pe-${var.name_prefix}-ai-foundry-hub"
  location            = azurerm_resource_group.this.location  # VNet region (Canada Central)
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.ai_lz_vnet.subnets["PrivateEndpointSubnet"].resource_id

  private_service_connection {
    name                           = "psc-ai-foundry-hub"
    private_connection_resource_id = module.foundry_ptn[0].ai_foundry_id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      (var.flag_platform_landing_zone ? module.private_dns_zones.ai_foundry_cognitive_services_zone.resource_id : local.private_dns_zones_existing.ai_foundry_cognitive_services_zone.resource_id)
    ]
  }

  tags = var.tags
}

# Private Endpoints for Storage Accounts (BYOR)
resource "azurerm_private_endpoint" "storage_blob_cross_region" {
  for_each = local.create_cross_region_pe ? var.ai_foundry_definition.storage_account_definition : {}

  name                = "pe-${var.name_prefix}-storage-${each.key}-blob"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.ai_lz_vnet.subnets["PrivateEndpointSubnet"].resource_id

  private_service_connection {
    name                           = "psc-storage-${each.key}-blob"
    private_connection_resource_id = module.foundry_ptn[0].storage_account_id[each.key]
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      (var.flag_platform_landing_zone ? module.private_dns_zones.storage_blob_zone.resource_id : local.private_dns_zones_existing.storage_blob_zone.resource_id)
    ]
  }

  tags = var.tags
}

# Private Endpoints for Key Vaults (BYOR)
resource "azurerm_private_endpoint" "key_vault_cross_region" {
  for_each = local.create_cross_region_pe ? var.ai_foundry_definition.key_vault_definition : {}

  name                = "pe-${var.name_prefix}-kv-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.ai_lz_vnet.subnets["PrivateEndpointSubnet"].resource_id

  private_service_connection {
    name                           = "psc-kv-${each.key}"
    private_connection_resource_id = module.foundry_ptn[0].key_vault_id[each.key]
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      (var.flag_platform_landing_zone ? module.private_dns_zones.key_vault_zone.resource_id : local.private_dns_zones_existing.key_vault_zone.resource_id)
    ]
  }

  tags = var.tags
}

# Private Endpoints for Cosmos DB (BYOR)
resource "azurerm_private_endpoint" "cosmos_cross_region" {
  for_each = local.create_cross_region_pe ? var.ai_foundry_definition.cosmosdb_definition : {}

  name                = "pe-${var.name_prefix}-cosmos-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.ai_lz_vnet.subnets["PrivateEndpointSubnet"].resource_id

  private_service_connection {
    name                           = "psc-cosmos-${each.key}"
    private_connection_resource_id = module.foundry_ptn[0].cosmos_db_id[each.key]
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      (var.flag_platform_landing_zone ? module.private_dns_zones.cosmos_sql_zone.resource_id : local.private_dns_zones_existing.cosmos_sql_zone.resource_id)
    ]
  }

  tags = var.tags
}

# Private Endpoints for AI Search (BYOR)
resource "azurerm_private_endpoint" "ai_search_cross_region" {
  for_each = local.create_cross_region_pe ? var.ai_foundry_definition.ai_search_definition : {}

  name                = "pe-${var.name_prefix}-search-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.ai_lz_vnet.subnets["PrivateEndpointSubnet"].resource_id

  private_service_connection {
    name                           = "psc-search-${each.key}"
    private_connection_resource_id = module.foundry_ptn[0].ai_search_id[each.key]
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      (var.flag_platform_landing_zone ? module.private_dns_zones.ai_search_zone.resource_id : local.private_dns_zones_existing.ai_search_zone.resource_id)
    ]
  }

  tags = var.tags
}
