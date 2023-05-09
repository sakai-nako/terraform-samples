variable "project" {
  type = string
}
variable "zone_name" {
  type = string
}
variable "dns_name" {
  type = string
}
variable "labels" {
  default = {}
  type    = map(string)
}
variable "enable_apis" {
  default = true
  type    = bool
}
