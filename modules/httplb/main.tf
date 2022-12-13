resource "google_compute_subnetwork" "default" {
  name          = "l7-xlb-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-central1"
  network       = var.network_name
  project = var.project_id
}

# reserved IP address
resource "google_compute_global_address" "default" {
  provider = google-beta
  name     = "l7-xlb-static-ip"
  project = var.project_id
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "l7-xlb-forwarding-rule"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  project = var.project_id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "l7-xlb-target-http-proxy"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "l7-xlb-url-map"
  provider        = google-beta
  default_service = google_compute_backend_service.default.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  name                    = "l7-xlb-backend-service"
  provider                = google-beta
  protocol                = "HTTP"
  port_name               = "my-port"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  enable_cdn              = false
  health_checks           = [google_compute_health_check.default.id]
  project = var.project_id
  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "default" {
  name     = "l7-xlb-hc"
  provider = google-beta
  project = var.project_id
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
