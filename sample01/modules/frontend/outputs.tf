output "static_site_bucket" {
  value = google_storage_bucket.main
}

output "site_allow_read" {
  value = google_storage_bucket_iam_binding.main
}

output "site_lb_ip" {
  value = google_compute_global_address.main
}

output "site_record" {
  value = google_dns_record_set.main
}

output "site_record_www_redirect" {
  value = var.enable_sub_dns_name ? google_dns_record_set.sub_cname : null
}

output "site_lb_backend_bucket" {
  value = google_compute_backend_bucket.main
}

output "site_lb_url_map" {
  value = google_compute_url_map.main
}

output "site_lb_target_proxy" {
  value = google_compute_target_https_proxy.main
}

output "site_lb_forwarding_rule" {
  value = google_compute_global_forwarding_rule.main
}
