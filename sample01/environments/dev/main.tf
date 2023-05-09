locals {
  env = "dev"
}

provider "google" {
  project = var.project
}

module "dns" {
  source    = "../../modules/dns"
  project   = var.project
  zone_name = var.zone_name
  dns_name  = var.dns_name
}

module "certificate" {
  source                = "../../modules/certificate"
  project               = var.project
  env                   = local.env
  zone_name             = module.dns.main_zone.name
  dns_name              = var.dns_name
  enable_wild_card_cert = true
}

module "frontend" {
  source              = "../../modules/frontend"
  project             = var.project
  env                 = local.env
  location            = "ASIA"
  zone_name           = module.dns.main_zone.name
  dns_name            = var.dns_name
  certificate_map_id  = module.certificate.certificate_map.id
  enable_sub_dns_name = true
  sub_dns_name        = var.site_sub_dns_name
}
