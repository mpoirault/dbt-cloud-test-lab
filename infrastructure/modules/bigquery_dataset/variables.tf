variable "dataset_id" {
  description = "BigQuery dataset id."
  type        = string
}

variable "description" {
  description = "Human readable description of what lives in the dataset."
  type        = string
}

variable "location" {
  description = "GCP region for the dataset."
  type        = string
}

variable "project" {
  description = "GCP project the dataset belongs to."
  type        = string
}

variable "labels" {
  description = "Labels to put on the dataset."
  type        = map(string)
  default     = {}
}
