resource "google_compute_health_check" "autohealing" {
  name                = var.healthcheck_name
  timeout_sec         = 5
  project = var.project_id 

  http_health_check {
    port         = "80"
  }
}

resource "google_compute_http_health_check" "default" {
  project = var.project_id
  name               = var.targetpool_helathcheck
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_target_pool" "default" {
  name = var.targetpool_name
  region = var.computeregion
  project = var.project_id

  health_checks = [
    google_compute_http_health_check.default.id
  ]
}


resource "google_compute_region_instance_group_manager" "appserver" {
  name = var.igm_name

  base_instance_name         = var.baseinstance_name
  region                     = var.computeregion
  project = var.project_id

  version {
    instance_template = var.instance-template-name
  }

#   all_instances_config {
#     metadata = {
#       metadata_key = "metadata_value"
#     }
#     labels = {
#       label_key = "label_value"
#     }
#   }

  target_pools = [google_compute_target_pool.default.id]
  target_size  = 6

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}