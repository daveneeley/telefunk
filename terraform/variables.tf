variable "terraform_backend_storage_account" {
  type        = string
  description = "The storage account where the tf state files are stored"
  sensitive   = true
}

variable "terraform_backend_resource_group" {
  type        = string
  description = "The resource group where the tf state files are stored"
  sensitive   = true
}

variable "deployment_name" {
  type        = string
  description = "The name of the deployment, used as part of the key for many components including resource group name"
  sensitive   = true
}

variable "location" {
  type        = string
  description = "The region of the deployment in Azure"
  sensitive   = true
}

variable "registry_name" {
  type        = string
  description = "The Azure name of the container registry where the image is found"
  sensitive   = true
}

variable "registry_rg" {
  type        = string
  description = "The resource group of the container registry"
  sensitive   = true
}

variable "container_image_url" {
  type        = string
  description = "The full path to the container image"
  sensitive   = true
}

variable "container_image_tag" {
  type        = string
  description = "The tag of the container image"
  sensitive   = true
}