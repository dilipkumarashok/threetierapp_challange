output "healthcheckname" {
    value = google_compute_health_check.autohealing.name
  
}

output "healthcheckselflink" {
    value = google_compute_health_check.autohealing.*.self_link
}

output "mig_selflink" {
    value = google_compute_region_instance_group_manager.appserver.instance_group
  
}