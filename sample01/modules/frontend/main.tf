module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.1"

  project_id  = var.project
  enable_apis = var.enable_apis

  activate_apis = [
    "storage.googleapis.com",
    "dns.googleapis.com",
    "compute.googleapis.com",
    "certificatemanager.googleapis.com",
  ]
  disable_services_on_destroy = false
}

resource "random_id" "main" {
  byte_length = 8
}

resource "google_storage_bucket" "main" {
  name          = "${var.env}-static-website-bucket-${random_id.main.hex}"
  location      = var.location
  storage_class = "STANDARD"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_iam_binding" "main" {
  bucket  = google_storage_bucket.main.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# グローバルIP
resource "google_compute_global_address" "main" {
  name = "${var.env}-site-lb-ip-${random_id.main.hex}"
}

# Record Set
resource "google_dns_record_set" "main" {
  name         = "${var.dns_name}."
  type         = "A"
  ttl          = 300
  managed_zone = var.zone_name
  rrdatas      = [google_compute_global_address.main.address]
}

# Record Set (Sub Domain CNAME)
resource "google_dns_record_set" "sub_cname" {
  count        = var.enable_sub_dns_name ? 1 : 0
  name         = "${var.sub_dns_name}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = var.zone_name
  rrdatas      = ["${var.dns_name}."]
}

# LB Backend
resource "google_compute_backend_bucket" "main" {
  name        = "${var.env}-site-lb-backend-${random_id.main.hex}"
  bucket_name = google_storage_bucket.main.name
  enable_cdn  = true
  cdn_policy {
    # Todo : 直値を変数化
    cache_mode  = "FORCE_CACHE_ALL"
    client_ttl  = 60
    default_ttl = 300
  }
}

# URL Map
resource "google_compute_url_map" "main" {
  name            = "${var.env}-site-lb-url-map-${random_id.main.hex}"
  default_service = google_compute_backend_bucket.main.id
  # host_rule {
  #   hosts = ["*"]
  #   path_matcher = "path-matcher"
  # }
  # path_matcher {
  #   name = "path-mathcer"
  #   default_service = google_compute_backend_bucket.main
  #   path_rule {
  #     paths = ["/test-path/*"]
  #     service = google_compute_backend_bucket.main
  #   }
  # }
}

# Target Proxy
resource "google_compute_target_https_proxy" "main" {
  name            = "${var.env}-site-lb-target-proxy-${random_id.main.hex}"
  url_map         = google_compute_url_map.main.id
  certificate_map = "//certificatemanager.googleapis.com/${var.certificate_map_id}"
}

# Forwarding Rule
resource "google_compute_global_forwarding_rule" "main" {
  name                  = "${var.env}-site-lb-forwarding-rule-${random_id.main.hex}"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.main.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.main.id
}
