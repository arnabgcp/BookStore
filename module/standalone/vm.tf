resource "google_compute_instance_template" "instance_template" {
  name         = "l7-ilb-mig-template"
  provider     = google
  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }
metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
       apt-get update -y
       apt-get install -y tomcat9 git
       cd /home
       git clone https://github.com/arnabgcp/BookStore.git
       cp /home/BookStore/*.war /var/lib/tomcat9/webapps/
       echo 'export JAVA_OPTS="-DDB_HOST=${google_sql_database_instance.mtr.ip_address.0.ip_address} -DDB_USER=root -DDB_PASSWORD='"'${random_string.rs.id}'"'"' >/usr/share/tomcat9/bin/setenv.sh
       
       chmod +x /usr/share/tomcat9/bin/setenv.sh
       service tomcat9 stop
       service tomcat9 start
    EOF1
  }
 
  lifecycle {
    create_before_destroy = true
  }
}
