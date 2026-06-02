terraform {
  backend "azurerm" {
    resource_group_name  = "rg-rooftop-kms-training"
    storage_account_name = "blobkmsrooftoplamvt"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
