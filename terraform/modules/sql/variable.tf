variable "db_name" {
  type = string
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_settings_edition" {
  type = string
}

variable "db_settings_tier" {
  type = string
}

variable "db_settings_pricing_plan" {
  type = string
}

variable "db_settings_disk_size" {
  type = number
}

variable "db_settings_disk_type" {
  type = string
}

variable "db_settings_disk_autoresize" {
  type = bool
}
