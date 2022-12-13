output "instancetemplateid" {
    value = google_compute_instance_template.default.id
  
}

output "name" {
  description = "Name of instance template"
  value       = google_compute_instance_template.default.name
}

output "selflink" {
    description = "self link"
    value = google_compute_instance_template.default.self_link
  
}