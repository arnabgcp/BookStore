resource "google_project_service" "svc1" {
  project = var.project
  service = "container.googleapis.com"

  depends_on=[
      google_project_service.svc4
  ]
}
resource "google_project_service" "svc4" {
  project = var.project
  service = "compute.googleapis.com"
}


resource "google_container_cluster" "primary" {
  name     = var.clsname
  location = var.region
depends_on = [
  google_project_service.svc1
]
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode = "VPC_NATIVE"

 
  
ip_allocation_policy {
   
    cluster_ipv4_cidr_block="10.4.0.0/14"
                services_ipv4_cidr_block="10.8.0.0/20"
  }

}

resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
   
    machine_type = "e2-medium"

   oauth_scopes    = [
      "https://www.googleapis.com/auth/devstorage.read_only",
                  "https://www.googleapis.com/auth/logging.write",
                  "https://www.googleapis.com/auth/monitoring",
                  "https://www.googleapis.com/auth/service.management.readonly",
                  "https://www.googleapis.com/auth/servicecontrol",
                  "https://www.googleapis.com/auth/trace.append"
    ]
  }
}

resource "google_project_service" "svc2" {
  project = var.project
  service = "sqladmin.googleapis.com"
}
resource "random_integer" "ri" {

 min=10
 max=500 
}

data "google_compute_network" "my-network" {
  name = "default"
  depends_on=[
      google_project_service.svc4
  ]
}

resource "google_sql_database_instance" "mtr" {
  provider = google

  name             = "sql-inst-${random_integer.ri.id}"
  region           = var.region
  database_version = "MYSQL_5_7"
 
 depends_on = ["google_service_networking_connection.private_vpc_connection"] 


deletion_protection = false
  settings {
    tier = "db-f1-micro"
    availability_type="REGIONAL"
     
         backup_configuration{
             enabled = true
             binary_log_enabled = true
         }

         

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.my-network.id      
    }
  }
}



output "sqlmtr" {

value = google_sql_database_instance.mtr.ip_address.0.ip_address

}
resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.mtr.name
  
  password = "******"
}

resource "google_sql_database" "database" {
  name     = "Bookstore"
  instance = google_sql_database_instance.mtr.name

provisioner "local-exec" {

command= "sleep 30;gcloud config set project ${var.project};gcloud sql import sql ${google_sql_database_instance.mtr.name} gs://bucket-vm-images-2022/book.sql --database=Bookstore;gcloud container clusters get-credentials ${var.clsname} --region ${var.region} --project ${var.project};rm -rf bookstore-springboot;git clone https://github.com/arnabgcp/bookstore-springboot.git; sed -i 's/10.79.192.2/'${google_sql_database_instance.mtr.ip_address.0.ip_address}'/g' bookstore-springboot/yamlfiles/qa/db-secret.yaml; kubectl create ns qa; kubectl apply -f bookstore-springboot/yamlfiles/qa/ -n qa; kubectl get ingress -n qa"

}

}

resource "google_project_service" "svc3" {
  project = var.project
  service = "servicenetworking.googleapis.com"
  depends_on=[
      google_project_service.svc4
  ]
}

resource "google_compute_global_address" "private_ip_address" {
    provider="google"
    name          = "default"
    purpose       = "VPC_PEERING"
    address_type = "INTERNAL"
    prefix_length = 16
    network       = "default"
    depends_on = [
  google_project_service.svc3
]
}

resource "google_service_networking_connection" "private_vpc_connection" {
    provider="google"
    network       = "default"
    service       = "servicenetworking.googleapis.com"
    reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
depends_on = [
  google_project_service.svc2
]
}
