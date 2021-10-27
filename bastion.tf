data "google_compute_default_service_account" "default" {}

resource "google_compute_address" "bastion_public_ip" {
  name   = "bastion-public-ip"
  region = "${google_compute_subnetwork.subnet_public.region}"
}

resource "google_compute_firewall" "allow_public_ssh_ingress_bastion" {
  name     = "allow-public-ssh-ingress-bastion"
  network  = "${google_compute_network.kafka_network.name}"
  priority = 100

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.source_ext_cidr}"]
  target_tags   = ["bastion-network"]
}

data "template_file" "metadata_startup_script" {
   template = "${file("scripts/bastion_init.sh")}"
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  zone         = "${google_compute_subnetwork.subnet_public.region}-b"
  machine_type = "${var.gce_machine_type["bastion"]}"

  deletion_protection = false

  can_ip_forward = true

  lifecycle {
    prevent_destroy = false
  }

  allow_stopping_for_update = true

  tags = [
    "bastion-network",
    "kafka-network"
  ]

  boot_disk {
    initialize_params {
      image = "${var.gce_image_name["bastion"]}"
      size  = "${var.os_disk_size["bastion"]}"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.subnet_public.self_link}"
    network_ip    = "${var.ip_addr["bastion"]}"

    access_config {
      nat_ip = "${google_compute_address.bastion_public_ip.address}"
    }
  }

  metadata {
    ssh-keys = "${var.kafka_user}:${file(var.kafka_pubkey)}"
  }

  metadata_startup_script = "${data.template_file.metadata_startup_script.rendered}"

  service_account {
    email  = "${google_service_account.bastion_account.email}"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}
