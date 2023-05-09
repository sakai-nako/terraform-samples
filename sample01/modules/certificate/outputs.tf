output "dns_auth" {
  value = google_certificate_manager_dns_authorization.main
}

output "dns_auth_record" {
  value = google_dns_record_set.main
}

output "ssl_certificate" {
  value = google_certificate_manager_certificate.main
}

output "certificate_map" {
  value = google_certificate_manager_certificate_map.main
}

output "certificate_map_entry" {
  value = google_certificate_manager_certificate_map_entry.main
}
