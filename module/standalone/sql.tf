resource "google_sql_database_instance" "mtr" {
  provider = google

  name             = var.instance
  region           = var.region
  database_version = "MYSQL_5_7"
 
 depends_on = ["google_service_networking_connection.private_vpc_connection"]
deletion_protection = false
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.ilb_network.id
      
    }
  }
}


resource "random_string" "rs" {
  length = 10
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.mtr.name
  
  password = random_string.rs.id
}

resource "google_sql_database" "database" {
  name     = "Bookstore"
  instance = google_sql_database_instance.mtr.name

provisioner "local-exec" {

command= "gcloud config set project ${var.project};gcloud sql import sql ${var.instance} gs://bucket-vm-images-2022/book.sql --database=Bookstore"

}

}

