terraform {
  backend "gcs" {
    bucket = "masajid-test-terraform"
    prefix = "masajid-gke"
  }
}
