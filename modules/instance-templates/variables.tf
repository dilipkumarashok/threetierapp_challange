variable "instance-template-name" {
  
}

variable "machine_type" {
  default = "f1-micro"
}

variable "network_name" {
  
}

variable "service_account" {
    default = "cli-service-account-1@playground-s-11-ae58ac63.iam.gserviceaccount.com"
  
}

variable "compute_family" {
    default = "debian-11"
  
}

variable "image_project" {
    default = "debian-cloud"
  
}

variable "startupscript" {
    default = "   #! /bin/bash \n apt update \n apt -y install apache2 \n cat <<EOF > /var/www/html/index.html \n <html><body><p>Linux startup script added directly.</p></body></html>"
}

variable "tags" {
    type = list
}

variable "project_id" {
    
}

# variable "compute_zone" {

  
# }

variable "subnetwork" {
  
}

# variable "diskname" {

# }

variable "region" {
  
}