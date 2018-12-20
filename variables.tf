variable "subscription_id" {
    description = "Enter Subscription ID for provisioning resources in Azure"
}

variable "client_id" {
    description = "Enter Client ID for Application created in Azure AD"
}

variable "client_secret" {
    description = "Enter Client Secret for Application created in Azure AD"
}

variable "tenant_id" {
    description = "Enter Tenant ID of your Azure AD."
}

variable "cflKey" {
    description = "Enter the API key for CFL API access."
}

variable "azure_tags" {
    type = "map"
    default = {
        "Owner" = "Zach Milleson"
        "Exception" = "no"
        "StopResources" = "yes"
        "Description" = "Milleson-CFB-Data"
    }
    description = "Required Azure tags and values to be added to resources deployed."
}

variable "prefix" {
    default = "milleson"
    description = "A prefix for certain resources."
}

variable "location" {
    default = "centralus"
    description = "Default Azure region"
}