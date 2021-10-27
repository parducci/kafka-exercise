# GCP config
variable "gcp_credentials_file" {}
variable "gcp_project_id"       {}
variable "gcp_region"           { default = "us-west1" }
variable "gcp_storage_region"   { default = "us"}

variable "gcp_project_services" {
  type    = "list"
  default = [
    # NAME                                    TITLE
    "compute.googleapis.com",              # Google Compute Engine API
    "iam.googleapis.com",                  # Google Identity and Access Management (IAM) API
    "serviceusage.googleapis.com",         # Google Service Usage API
    "storage-component.googleapis.com",    # Google Cloud Storage
    "cloudapis.googleapis.com",            # Google Cloud APIs
    "servicemanagement.googleapis.com",    # Google Service Management API
    "storage-api.googleapis.com",          # Google Cloud Storage JSON API
    "cloudresourcemanager.googleapis.com", # Google Cloud Resource Manager API
    "deploymentmanager.googleapis.com",    # Google Cloud Deployment Manager V2 API
  ]
}

# Network variables

variable "subnet_cidr" {
  type    = "map"
  default = {
    "public_subnet"  = "10.0.10.0/24"
    "kafka" = "10.0.11.0/24"
  }
}

variable "source_ext_cidr" {}

variable "instance_hostname" {
  type = "map"
  default = {
    "bastion"          = "bastion"
    "kafka"            = "kafka"
  }
}

# GCE details
variable "gce_machine_type" {
  type = "map"
  default = {
    "bastion"          = "n1-standard-1"
    "kafka"            = "n1-standard-1"
  }
}

variable "gce_image_name" {
  type = "map"
  default = {
    "bastion"          = "centos-cloud/centos-7"
    "kafka"            = "centos-cloud/centos-7"
  }
}

variable "kafka_disk" {
  type    = "map"
  default = {
    "type"          = "pd-standard"
    "size"          = "10"
  }
}

variable "os_disk_size" {
  type = "map"
  default = {
    "bastion"          = "20"
    "kafka"            = "20"
  }
}

variable "ip_addr" {
  type = "map"
  default = {
    "bastion"      = "10.0.10.2"
  }
}

variable "instance_count" { default = "3" }

variable "kafka_user"    { default = "kafka" }
variable "kafka_pubkey"  {}
variable "kafka_privkey" {}
