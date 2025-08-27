# Create VPC network
resource "google_compute_network" "main" {
  name                    = "traefik-vpc"
  auto_create_subnetworks = false
}

# Create subnet
resource "google_compute_subnetwork" "main" {
  name          = "traefik-subnet"
  ip_cidr_range = "10.0.0.0/26"
  region        = var.region
  network       = google_compute_network.main.id
}

# Create firewall rules
resource "google_compute_firewall" "ssh" {
  name    = "traefik-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["traefik-server"]
}

resource "google_compute_firewall" "http" {
  name    = "traefik-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["traefik-server"]
}

resource "google_compute_firewall" "https" {
  name    = "traefik-allow-https"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["traefik-server"]
}

resource "google_compute_firewall" "dashboard" {
  name    = "traefik-allow-dashboard"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["traefik-server"]
}

# Create static IP
resource "google_compute_address" "main" {
  name   = "traefik-server-ip"
  region = var.region
}

# Create VM instance
resource "google_compute_instance" "main" {
  name         = "traefik-server"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["traefik-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
    
    access_config {
      nat_ip = google_compute_address.main.address
    }
  }

  metadata = {
    ssh-keys = "${var.admin_username}:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}