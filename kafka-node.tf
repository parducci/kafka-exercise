resource "google_compute_disk" "kafka-disk" {
  count        = "${var.instance_count}"
  name         = "kafka-0${count.index+1}-datadisk"
  zone         = "${google_compute_subnetwork.subnet_kafka.region}-b"
  type         = "${var.kafka_disk["type"]}"
  size         = "${var.kafka_disk["size"]}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_instance" "kafka-node" {
  name         = "kafka-0${count.index+1}"
  zone         = "${google_compute_subnetwork.subnet_kafka.region}-b"
  machine_type = "${var.gce_machine_type["kafka"]}"

  depends_on = ["google_compute_instance.bastion"]
  deletion_protection = false
  lifecycle {
    prevent_destroy = false
  }
  allow_stopping_for_update = true

  tags         = [
    "kafka-nodes"
  ]

  boot_disk {
    initialize_params {
      image = "${var.gce_image_name["kafka"]}"
      size  = "${var.os_disk_size["kafka"]}"
    }
  }

  attached_disk {
    source      = "${element(google_compute_disk.kafka-disk.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.kafka-disk.*.name, count.index)}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_kafka.self_link}"
  }

  metadata {
    ssh-keys = "${var.kafka_user}:${file(var.kafka_pubkey)}"
  }

  service_account {
    email  = "${google_service_account.kafka_account.email}"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  count = "${var.instance_count}"
}

resource "null_resource" "kafka-data-mount" {

  depends_on = ["google_compute_instance.kafka-node", "google_compute_disk.kafka-disk"]

  connection {
        agent = false
        user = "${var.kafka_user}"
        private_key = "${file(var.kafka_privkey)}"
        timeout = "2m"
        host = "${element(google_compute_instance.kafka-node.*.network_interface.0.network_ip, count.index)}"
        bastion_host = "${google_compute_address.bastion_public_ip.address}"
        bastion_user = "${var.kafka_user}"
        bastion_private_key = "${file(var.kafka_privkey)}"
   }

  provisioner "file" {
    source      = "scripts/kafka_disk_mount.sh"
    destination = "/tmp/kafka_disk_mount.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kafka_disk_mount.sh",
      "sudo /tmp/kafka_disk_mount.sh",
    ]
  }
  count = "${var.instance_count}"
}
