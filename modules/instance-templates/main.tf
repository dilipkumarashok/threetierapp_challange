resource "google_compute_instance_template" "default" {
  name        = var.instance-template-name
  description = "This template is used to create frontend nginx server instances."
  project = var.project_id
  tags = var.tags
  region = var.region

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  # lifecycle {
  #   create_before_destroy = "true"
  # }

  // Create a new boot disk from an image
  disk {
    source_image      = "debian-cloud/debian-11"
    auto_delete       = true
    boot              = true
    // backup the disk every day
  }

  // Use an existing disk resource
  # disk {
  #   // Instance Templates reference disks by name, not self link
  #   source      = google_compute_disk.foobar.name
  #   auto_delete = false
  #   boot        = false
  # }

  network_interface {
    network = var.network_name
    subnetwork = var.subnetwork
  }

  metadata = {
    "foo":"bar"
}

  metadata_startup_script = var.startupscript

 service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
}

data "google_compute_image" "my_image" {
  family  = var.compute_family
  project = var.image_project
}

# resource "google_compute_disk" "foobar" {
#   name  = var.diskname
#   image = data.google_compute_image.my_image.self_link
#   size  = 10
#   type  = "pd-ssd"
#   zone  = var.compute_zone
#   project = var.project_id
# }