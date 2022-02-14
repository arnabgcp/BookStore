# VPC network
resource "google_compute_network" "ilb_network" {
  name                    = "l7-ilb-network"
  provider                = google
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "l7-ilb-subnet"
  provider      = google
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.ilb_network.id
}

resource "google_compute_global_address" "private_ip_address" {
    provider="google"
    name          = "${google_compute_network.ilb_network.name}"
    purpose       = "VPC_PEERING"
    address_type = "INTERNAL"
    prefix_length = 16
    network       = "${google_compute_network.ilb_network.name}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
    provider="google"
    network       = "${google_compute_network.ilb_network.self_link}"
    service       = "servicenetworking.googleapis.com"
    reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}