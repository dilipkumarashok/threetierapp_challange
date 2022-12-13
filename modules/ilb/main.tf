# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "l7-ilb-proxy-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = var.network_id
  project = var.project_id
}

# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "l7-ilb-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = var.network_id
  project = var.project_id
}

resource "google_compute_region_health_check" "default" {
  name     = "l7-ilb-hc"
  provider = google-beta
  region   = var.region
  project = var.project_id
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  provider              = google-beta
  region                = "us-central1"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = var.network_id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "l7-ilb-target-http-proxy"
  provider = google-beta
  region   = "us-central1"
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-regional-url-map"
  provider        = google-beta
  region          = "us-central1"
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-ilb-backend-subnet"
  provider              = google-beta
  region                = "us-central1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  project = var.project_id
  backend {
    group           = var.igm
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}