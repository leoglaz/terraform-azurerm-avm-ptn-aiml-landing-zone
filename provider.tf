provider "azurerm" {
  subscription_id     = "c43a7559-6052-495e-ac6f-bbadb08d2768"
  storage_use_azuread = true  # Use Azure AD authentication for storage account management
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    
    virtual_machine {
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
}
