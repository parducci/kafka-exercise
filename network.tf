resource "google_compute_network" "kafka_network" {
  name                    = "kafka-network"
  project                 = "${var.gcp_project_id}"
  auto_create_subnetworks = "false"
  description             = "Kafka Network"
}

resource "google_compute_subnetwork" "subnet_public" {
  name          = "subnet-public"
  ip_cidr_range = "${lookup(var.subnet_cidr, "public_subnet")}"
  network       = "${google_compute_network.kafka_network.self_link}"
  region        = "${var.gcp_region}"
  description   = "Public Network for Bastion"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_kafka" {
  name          = "subnet-kafka"
  ip_cidr_range = "${lookup(var.subnet_cidr, "kafka")}"
  network       = "${google_compute_network.kafka_network.self_link}"
  region        = "${var.gcp_region}"
  description   = "Kafka Brokers Network"
  private_ip_google_access = true
}

resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  region  = "${var.gcp_region}"
  network  = "${google_compute_network.kafka_network.self_link}"
}

resource "google_compute_router_nat" "nat-route-service" {
  name                               = "nat-route-service"
  router                             = "${google_compute_router.nat-router.name}"
  region                             = "${var.gcp_region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_all_internal" {
  name     = "kafka-allow-internal"
  network  = "${google_compute_network.kafka_network.name}"
  priority = 65534

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = [
    "kafka-network",
    "bastion-network"
  ]

  source_ranges = [
    "${google_compute_subnetwork.subnet_public.ip_cidr_range}",
    "${var.subnet_cidr["kafka"]}"
  ]

  target_tags = ["kafka-nodes", "vault-nodes"]
}

resource "google_compute_firewall" "kafka_allow_all_egress" {
  name     = "kafka-allow-all-egress"
  network  = "${google_compute_network.kafka_network.name}"
  priority = 200

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "icmp"
  }

  target_tags = ["kafka-nodes", "vault-nodes"]
}

resource "google_compute_firewall" "kafka_allow_ssh_ingress" {
  name     = "kafka-allow-ssh-ingress"
  network  = "${google_compute_network.kafka_network.name}"
  priority = 100

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [
    "bastion-network",
    "kafka-network"
  ]

  source_ranges = [
    "${google_compute_subnetwork.subnet_public.ip_cidr_range}",
    "${google_compute_subnetwork.subnet_kafka.ip_cidr_range}"
  ]

  target_tags = ["kafka-nodes", "vault-nodes"]
}
