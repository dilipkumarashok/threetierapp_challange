module "vpc" {
    source  = "./modules/vpc"

    project_id  = var.project_id
    network_name = var.networkname
    routing_mode = "GLOBAL"
}

module "subnets" {
    source = "./modules/subnets"
    network_name = module.vpc.network_name
    project_id  = var.project_id
    
    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "europe-west1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-central1"
            subnet_private_access = "false"
            subnet_flow_logs      = "false"
            description           = "This subnet has a description"
        },
        {
            subnet_name               = "subnet-03"
            subnet_ip                 = "10.10.30.0/24"
            subnet_region             = "us-west1"
            subnet_flow_logs          = "false"
        }
    ]

    secondary_ranges = {
        subnet-01 = [],
        subnet-02 = []
    }
}

module "routes" {
    source = "./modules/routes"
    network_name = module.vpc.network_name
    project_id  = var.project_id
    module_depends_on = [module.subnets.subnets]
    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]
}

module "mysqldb" {
    source = "./modules/mysql"
    privatenetworkid = module.vpc.network_id
    project_id  = var.project_id

}


module "instance-template" {
    source = "./modules/instance-templates"
    instance-template-name="frontend-template"
    network_name = module.vpc.network_id
    subnetwork = "https://www.googleapis.com/compute/v1/projects/playground-s-11-ae58ac63/regions/europe-west1/subnetworks/subnet-01"
    project_id  = var.project_id
    # compute_zone = "europe-west1-b"
    # diskname = "frontenddisk"
    tags = ["egress-inet"]
    region = "europe-west1"

}

module "backend-template" {
    source = "./modules/instance-templates"
    instance-template-name="backend-template"
    network_name = module.vpc.network_id
    subnetwork = "https://www.googleapis.com/compute/v1/projects/playground-s-11-ae58ac63/regions/us-central1/subnetworks/subnet-02"
    project_id  = var.project_id
    # compute_zone = "us-central1-a"
    # diskname = "backenddisk"
    tags = ["backend-inet"]
    region = "us-central1"

}


module "frontendmig" {
    source = "./modules/mig"
    igm_name = "frontend-igm"
    healthcheck_name = "frontend-healthcheck"
    targetpool_helathcheck="frontend"
    targetpool_name = "frontendpool"
    baseinstance_name = "egress-inet"
    instance-template-name = module.instance-template.selflink
    project_id  = var.project_id
    computeregion = "europe-west1"
}

module "backendmig" {
    source = "./modules/mig"
    igm_name = "backend-igm"
    healthcheck_name = "backend-healthcheck"
    targetpool_helathcheck = "backend"
    targetpool_name = "backendpool"
    baseinstance_name = "backend-inet"
    instance-template-name = module.backend-template.selflink
    project_id  = var.project_id
    computeregion = "us-central1"
}

module "frontendvm" {
    source = "./modules/compute-instance"
    source_instance_template = module.instance-template.selflink
    tier = "frontend"
    instance_name="egress-internet"
    project_id = var.project_id
    region = "europe-west1"

}

module "backendvm" {
    source = "./modules/compute-instance"
    source_instance_template = module.instance-template.selflink
    tier = "backend"
    instance_name="backend-inet"
    project_id = var.project_id
    region = "us-central1"

}

module "ilb" {
    source = "./modules/ilb"
    network_id = module.vpc.network_id
    igm = module.backendmig.mig_selflink
    project_id = var.project_id

}

module "elb" {
    source = "./modules/httplb"
    project_id = var.project_id
    instance_group = module.frontendmig.mig_selflink
    network_name = module.vpc.network_id
     
}