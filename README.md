# kafka-exercise

The goal of this exercise is to be able to use terraform and ansible to deploy kafka clusters in the cloud. It's also desireable to do so within one single "terraform apply" command.

This repo is using cp-ansible playbooks from confluence, and was tested using terraform v1.0.7 on darwin_amd64 (OSx)
The selected OS images for the kafka nodes are centos-7.
Compute Engine instances have been setup to avoid un-needed alerts, this is not meant to be a fully production server and was built on best practices but not contemplating any particular use case or real world load.

This kafka deployment uses zookeeper for coordination as default, as at the time of writing this zookeeper-less kafka deployments are not yet considered production ready. Also cp-ansible is not yet ready to contemplate that (again, at the time of writing this code).

## Pre-steps

* Create the GCP project
* Create a bucket to use as the terraform state backend, and add it's name into the remotestate.tf file
* A Service Account with admin privileges over the project needs to be created, and a correspondent JSON credentials file exported for use
* Create your terraform.tfvars file (see more about this below)
* Load your ssh keys as an ssh-agent
* Run "terraform plan", then "terraform apply"

## SSH keys

To load your ssh keys you can do so by executing:
$ eval $(ssh-agent)
$ ssh-add <priv-cert-filename>

# Terraform tfvars

A terraform.tfvars.example has been included. Copy it and rename it as terraform.tfvars with the correct values:

```
$ cat terraform.tfvars.example
gcp_project_id          = "your-project-name"
gcp_credentials_file    = "your-gcpproject-service-credentials-file-path"
gcp_region		= "us-west1"
kafka_privkey           = "~/.ssh/id_rsa"
kafka_pubkey            = "~/.ssh/id_rsa.pub"
source_ext_cidr         = "your-source-public-ip"
cp_ansible_version      = "cp_ansible_version_branch"
```

