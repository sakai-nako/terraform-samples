module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.1"

  project_id  = var.project
  enable_apis = var.enable_apis

  activate_apis = [
    "dns.googleapis.com",
  ]
  disable_services_on_destroy = false
}

resource "google_dns_managed_zone" "main" {
  name        = var.zone_name
  dns_name    = "${var.dns_name}."
  description = "DNS zone"
  labels      = var.labels
}
