variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "The GCP region"
}

variable "zone" {
  type        = string
  default     = "europe-west1-b"
  description = "The GCP zone"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "The machine type for the VM instance"
}

variable "admin_username" {
  type        = string
  default     = "traefikadmin"
  description = "Admin username for the virtual machine"
}