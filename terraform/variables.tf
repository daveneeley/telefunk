variable "deployment_name" {
  type        = string
  description = "The name of the deployment, used as part of the key for many components including resource group name"
}

variable "location" {
  type        = string
  description = "The region of the deployment in Azure"
}

variable "registry_name" {
  type        = string
  description = "The Azure name of the container registry where the image is found"
}

variable "registry_rg" {
  type        = string
  description = "The resource group of the container registry"
}

variable "container_image_url" {
  type        = string
  description = "The full path to the container image"
}

variable "container_image_tag" {
  type        = string
  description = "The tag of the container image"
}