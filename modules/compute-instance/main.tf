data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "random_integer" "priority" {
  min = 0
  max = 2
}

resource "google_compute_instance_from_template" "frontend" {
  
  name = var.instance_name
  source_instance_template = var.source_instance_template
  project = var.project_id
  zone  = var.zone == null ? data.google_compute_zones.available.names[random_integer.priority.result]:var.zone

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    tier = var.tier
  }
}
