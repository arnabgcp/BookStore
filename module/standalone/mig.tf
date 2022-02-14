# MIG
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "l7-ilb-mig1"
  provider = google
  region   = var.region
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  named_port {
    name = "http"
    port = 8080
  }
 target_size  = 2
 base_instance_name = "vm"
  
}