variable "project" {}
variable "env" {}
variable "zone_name" {}
variable "dns_name" {}
variable "enable_apis" {
  default = true
  type    = bool
}
variable "enable_wild_card_cert" {
  default = false
  type    = bool
}
