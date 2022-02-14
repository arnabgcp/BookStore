
# health check
resource "google_compute_health_check" "default" {
  name     = "l7-ilb-hc"
  provider = google
  
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}