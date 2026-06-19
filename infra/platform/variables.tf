variable "resource_group_name" {
  description = "Existing resource group used as the deployment boundary."
  type        = string
}

variable "location" {
  description = "Azure region used by the ephemeral resources."
  type        = string
  default     = "francecentral"
}

variable "run_id" {
  description = "GitHub Actions run identifier used for traceability."
  type        = string
}

