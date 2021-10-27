output "bastion_external_ip_address" {
  value = "${google_compute_address.bastion_public_ip.address}"
}
