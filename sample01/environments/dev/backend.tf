terraform {
  backend "gcs" {
    bucket = "sakai-nako-dev-tf-state"
    # prefix = "terraform/state"
  }
}
