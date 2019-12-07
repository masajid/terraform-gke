terraform {
  backend "gcs" {
    bucket = "terraform_bucket-masajid"
    prefix = "masajid"
  }
}
