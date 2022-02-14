resource "google_project_service" "project" {
  project = var.project
 count =    length(var.apis)
  service = var.apis[count.index]
}