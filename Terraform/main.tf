terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

// Configure the Google Cloud provider
provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

// Create a Google Cloud Storage Bucket
resource "google_storage_bucket" "my_bucket" {
  name     = var.bucket_name
  location = var.region
  project  = var.project_id
}

// Create a Google BigQuery Datasets
resource "google_bigquery_dataset" "stg" {
  dataset_id = "${var.dataset_id}_stg"
  location = var.region
  project = var.project_id
}

resource "google_bigquery_dataset" "prod" {
  dataset_id = "${var.dataset_id}_prod"
  location = var.region
  project = var.project_id
}

// Create a Google Compute Engine instance
resource "google_compute_instance" "my_instance" {
    name         = "ncaa_d1_baseball_stats_vm"
    machine_type = "n1-standard-1"
    zone         = var.zone
    project      = var.project_id

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }

    network_interface {
        network = "default"
        access_config {
            // Optional access configuration settings
        }
    }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
  EOF
}
