# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

# Azure region where all resources will be deployed
location = "canadacentral"

# Name of the resource group for the AI/ML Landing Zone
resource_group_name = "rg-aiml2-lz-dev-canadcentral3"

# Virtual Network configuration
# Note: address_space must be from 192.168.0.0/16 range for AI Foundry capability host injection
vnet_definition = {
  name          = "vnet-aiml-lz-cc3"
  address_space = "192.168.0.0/20"  # Provides 512 IPs
  dns_servers   = []                 # Empty = use Azure default DNS
}

# ============================================================================
# OPTIONAL BUT RECOMMENDED VARIABLES
# ============================================================================

# Prefix for resource naming (max 10 characters, lowercase alphanumeric only)
name_prefix = "aiml3"

# Tags for all resources
tags = {
  Environment = "Development"
  Project     = "AI-ML-LandingZone"
  ManagedBy   = "Terraform"
  CostCenter  = "IT"
}

# Enable telemetry (default: true)
enable_telemetry = true

# Set to true to create private DNS zones (required for standalone deployment with private endpoints)
flag_platform_landing_zone = true

# ============================================================================
# AI FOUNDRY CONFIGURATION (Optional)
# ============================================================================

ai_foundry_definition = {
  deploy           = true           # Enable AI Foundry deployment
  location         = "canadaeast"   # Deploy AI Foundry in Canada East (other resources use main location)
  create_byor      = true           # Create Bring Your Own Resources
  purge_on_destroy = false          # Set to true in dev/test environments

  ai_foundry = {
    name                     = "aifoundry-hub-ce"
    disable_local_auth       = false
    allow_project_management = true
    create_ai_agent_service  = true
    sku                      = "S0"
  }

  # AI Model Deployments - Disabled
  # Uncomment below to enable AI model deployments
  # ai_model_deployments = {
  #   "gpt-4o" = {
  #     name = "gpt-4-deployment"
  #     model = {
  #       format  = "OpenAI"
  #       name    = "gpt-4"
  #       version = "2024-05-13"
  #     }
  #     scale = {
  #       type     = "Standard"
  #       capacity = 10
  #     }
  #   }
  # }

  # AI Projects
  ai_projects = {
    project_1 = {
      name                       = "ai-project-001-cc3"
      display_name               = "AI Project 001-cc3"
      description                = "First AI project for development"
      create_project_connections = true
      
      cosmos_db_connection = {
        new_resource_map_key = "project1"
      }
      ai_search_connection = {
        new_resource_map_key = "project1"
      }
      storage_account_connection = {
        new_resource_map_key = "project1"
      }
    }
  }

  # Bring Your Own Resources - AI Search
  ai_search_definition = {
    project1 = {
      name                         = "search-project12-cc3"
      sku                          = "standard"
      partition_count              = 1
      replica_count                = 2
      semantic_search_sku          = "standard"  # Note: semantic_search_enabled removed to avoid module bug
      local_authentication_enabled = true
      enable_diagnostic_settings   = false  # Disabled due to law_definition bug in foundry v0.6.0
    }
  }

  # Bring Your Own Resources - Cosmos DB
  cosmosdb_definition = {
    project1 = {
      name                          = "cosmos-project12-cc3"
      public_network_access_enabled = false
      analytical_storage_enabled    = true
      automatic_failover_enabled    = true
      local_authentication_disabled = true
      enable_diagnostic_settings    = false  # Disabled due to law_definition bug in foundry v0.6.0
      consistency_policy = {
        consistency_level = "Session"
      }
    }
  }

  # Bring Your Own Resources - Key Vault
  key_vault_definition = {
    project1 = {
      name                       = "kv-project12-cc3"
      sku                        = "standard"
      enable_diagnostic_settings = false  # Disabled due to law_definition bug in foundry v0.6.0
    }
  }

  # Bring Your Own Resources - Storage Account
  storage_account_definition = {
    project1 = {
      name                       = "stproject1aiml0cc3"  # Must be globally unique
      account_tier               = "Standard"
      account_replication_type   = "LRS"
      shared_access_key_enabled  = true  # Required for Terraform management
      enable_diagnostic_settings = false  # Disabled due to law_definition bug in foundry v0.6.0
      endpoints = {
        blob = {
          type = "blob"
        }
      }
    }
  }

  # Note: law_definition is omitted due to a bug in foundry module v0.6.0
  # The module will automatically create a Log Analytics Workspace
}

# ============================================================================
# NETWORKING COMPONENTS (Optional)
# ============================================================================

# Azure Bastion for secure VM access
bastion_definition = {
  deploy = true
  name   = "bastion-aiml2-cc3"
  sku    = "Standard"
  zones  = ["1", "2", "3"]
}

# Azure Firewall
firewall_definition = {
  deploy = true
  name   = "fw-aiml2-cc3"
  sku    = "AZFW_VNet"
  tier   = "Standard"
  zones  = ["1", "2", "3"]
}

# Application Gateway
# Temporarily disabled - will enable after NSG is fully created
app_gateway_definition = {
  deploy       = true  # Set to true after initial deployment
  name         = "appgw-aiml-cc3"
  http2_enable = true
  
  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  backend_address_pools = {
    default = {
      name = "backend-pool-default"
    }
  }

  backend_http_settings = {
    default = {
      name     = "http-settings-default"
      port     = 80
      protocol = "Http"
    }
  }

  frontend_ports = {
    http = {
      name = "frontend-port-http"
      port = 80
    }
  }

  http_listeners = {
    default = {
      name               = "listener-default"
      frontend_port_name = "frontend-port-http"
    }
  }

  request_routing_rules = {
    default = {
      name                       = "rule-default"
      rule_type                  = "Basic"
      http_listener_name         = "listener-default"
      backend_address_pool_name  = "backend-pool-default"
      backend_http_settings_name = "http-settings-default"
      priority                   = 100
    }
  }
}

# ============================================================================
# GENAI SERVICES (Optional)
# ============================================================================

# Container Registry for GenAI
genai_container_registry_definition = {
  deploy                  = true
  name                    = "craigenaicc3"
  sku                     = "Premium"
  zone_redundancy_enabled = true
}

# Container App Environment
container_app_environment_definition = {
  deploy                         = true
  name                           = "cae-genai-cc3"
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = true
}

# App Configuration
genai_app_configuration_definition = {
  deploy                   = true
  name                     = "appconf-genai-cc3"
  sku                      = "standard"
  local_auth_enabled       = false
  purge_protection_enabled = true
}

# Key Vault for GenAI
genai_key_vault_definition = {
  name                          = "kv-genai-s12-cc3"
  sku                           = "standard"
  public_network_access_enabled = true  # Enabled for deployment access
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"  # Allow all during deployment, change to "Deny" after
  }
}

# Storage Account for GenAI
genai_storage_account_definition = {
  deploy                   = true
  name                     = "stgenaiaiml0022cc3"  # Must be globally unique
  account_tier             = "Standard"
  account_replication_type = "GRS"
  shared_access_key_enabled = true  # Required for Terraform management
  endpoint_types           = ["blob"]
}

# Cosmos DB for GenAI
genai_cosmosdb_definition = {
  deploy                        = true
  name                          = "cosmos-genai2cc3"
  analytical_storage_enabled    = true
  automatic_failover_enabled    = true
  local_authentication_disabled = true
}

# ============================================================================
# KNOWLEDGE SOURCES (Optional)
# ============================================================================

# AI Search for Knowledge Sources
ks_ai_search_definition = {
  deploy                   = true
  name                     = "search-ks2cc3"
  sku                      = "standard"
  partition_count          = 1
  replica_count            = 2
  semantic_search_sku      = "standard"  # Note: semantic_search_enabled removed to avoid module bug
}

# Bing Grounding Service
# Temporarily disabled due to API timeout issues
ks_bing_grounding_definition = {
  deploy = false  # Changed from true - API timeout with preview version
  name   = "bing-grounding"
  sku    = "G1"
}

# ============================================================================
# VIRTUAL MACHINES (Optional)
# ============================================================================

# Jump VM for management
jumpvm_definition = {
  deploy = true
  name   = "vm-jump2cc3"
  sku    = "Standard_B2s"
}

# Build VM for CI/CD
buildvm_definition = {
  deploy = true
  name   = "vm-build2cc3"
  sku    = "Standard_B2s"
}

# ============================================================================
# MONITORING (Optional)
# ============================================================================

# Note: Log Analytics Workspace for AI Foundry is configured within ai_foundry_definition above
# This section is for other monitoring resources if needed

# ============================================================================
# PRIVATE DNS ZONES (Required for Private Endpoints)
# ============================================================================

private_dns_zones = {
  # Specify the resource group where DNS zones will be created/exist
  # This is required even when creating new zones in standalone mode
  existing_zones_resource_group_resource_id = "/subscriptions/1d5b5f8a-d3d1-4a17-b061-00bf1db56490/resourceGroups/rg-aiml2-lz-dev-canadacentral3"
  
  allow_internet_resolution_fallback = false
  
  # Network links will be automatically created for the AI/ML Landing Zone VNet
  network_links = {}
}
