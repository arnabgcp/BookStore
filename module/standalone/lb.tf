# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "l7-xlb-forwarding-rule"
  provider              = google
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "l7-xlb-target-http-proxy"
  provider = google
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "l7-xlb-url-map"
  provider        = google
  default_service = google_compute_backend_service.default.id
}

# backend service

resource "google_compute_backend_service" "default" {
  name      = "staging-service"
  port_name = "http"
  protocol  = "HTTP"

  backend {
    group =google_compute_region_instance_group_manager.mig.instance_group
  }

  health_checks = [
    google_compute_health_check.default.id,
  ]
}