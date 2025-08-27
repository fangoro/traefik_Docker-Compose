output "project_id" {
  value = var.project_id
}

output "public_ip_address" {
  value = google_compute_address.main.address
}

output "ssh_connection_command" {
  value = "ssh ${var.admin_username}@${google_compute_address.main.address}"
}

output "instance_name" {
  value = google_compute_instance.main.name
}