resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.privatenetworkid
  project  = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = var.privatenetworkid
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider = google-beta

  name             = "private-instance-${random_id.db_name_suffix.hex}"
  region           = var.dbregion
  database_version = var.database_version

  depends_on = [google_service_networking_connection.private_vpc_connection]

  deletion_protection  = "false"
  project  = var.project_id

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.privatenetworkid
    }
  }
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

resource "google_sql_user" "users" {
  name     = "admin"
  instance = google_sql_database_instance.instance.name
  password = "admin"
  project  = var.project_id
}
