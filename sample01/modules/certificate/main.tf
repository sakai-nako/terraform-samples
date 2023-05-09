module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.1"

  project_id  = var.project
  enable_apis = var.enable_apis

  activate_apis = [
    "dns.googleapis.com",
    "certificatemanager.googleapis.com",
  ]
  disable_services_on_destroy = false
}

resource "random_id" "main" {
  byte_length = 8
}

# DNS Authorization for SSL Certificate
resource "google_certificate_manager_dns_authorization" "main" {
  name   = "${var.env}-dns-auth-${random_id.main.hex}"
  domain = var.dns_name
}

# CNAME record for DNS Authorization
resource "google_dns_record_set" "main" {
  name         = google_certificate_manager_dns_authorization.main.dns_resource_record[0].name
  managed_zone = var.zone_name
  type         = google_certificate_manager_dns_authorization.main.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.main.dns_resource_record[0].data]
}

# SSL Certificate
resource "google_certificate_manager_certificate" "main" {
  name = "${var.env}-cert-${random_id.main.hex}"
  managed {
    domains = compact([
      var.dns_name,
      var.enable_wild_card_cert ? "*.${var.dns_name}" : "",
    ])
    dns_authorizations = [
      google_certificate_manager_dns_authorization.main.id
    ]
  }
}

# Certificate Map
resource "google_certificate_manager_certificate_map" "main" {
  name = "${var.env}-cert-map-${random_id.main.hex}"
}

# Certificate Map Entry
resource "google_certificate_manager_certificate_map_entry" "main" {
  name         = "${var.env}-entry-${random_id.main.hex}"
  map          = google_certificate_manager_certificate_map.main.name
  certificates = [google_certificate_manager_certificate.main.id]
  hostname     = var.dns_name
}
