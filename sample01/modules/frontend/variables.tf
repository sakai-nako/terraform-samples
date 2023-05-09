variable "project" {}
variable "env" {}
variable "location" {}
variable "zone_name" {}
variable "dns_name" {}
variable "certificate_map_id" {}
variable "enable_apis" {
  default = true
  type    = bool
}

variable "enable_sub_dns_name" {
  default = false
  type    = bool
}

variable "sub_dns_name" {
  default = ""
  type    = string
}
