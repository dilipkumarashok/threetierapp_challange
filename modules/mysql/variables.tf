variable "dbname" {
    type = string
    default = "my-database-instance"
     
}

variable "dbregion" {
    type = string
    default = "us-west1"
  
}

variable "database_version" {
    type = string
    default = "MYSQL_8_0"
  
}

variable "dbtier" {
    type = string
    default = "db-f1-micro"
  
}

variable "privatenetworkid" {
    type = string
}

variable "project_id" {
  
}