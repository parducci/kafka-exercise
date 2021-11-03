# Service Accounts
resource "google_service_account" "nat_gateway" {
  depends_on = [
    google_project_service.gcp_project,
  ]

  account_id   = "nat-gateway"
  display_name = "NAT Gateway"
}

resource "google_service_account" "bastion_account" {
  depends_on = [
    google_project_service.gcp_project,
  ]

  account_id   = "bastionaccount"
  display_name = "Bastion Server Account"
}

resource "google_service_account" "kafka_account" {
  depends_on = [
    google_project_service.gcp_project,
  ]

  account_id   = "kafkaaccount"
  display_name = "Kafka Brokers Account"

}
