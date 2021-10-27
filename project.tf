resource "google_project_service" "gcp_project" {
  project            = "${var.gcp_project_id}"
  service            = "${element(var.gcp_project_services, count.index)}"
  disable_on_destroy = false

  count = "${length(var.gcp_project_services)}"
}
