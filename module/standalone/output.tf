

output "lb" {
  
  value=google_compute_global_forwarding_rule.default.ip_address
}

output "sqlip" {

value = google_sql_database_instance.mtr.ip_address.0.ip_address

}
