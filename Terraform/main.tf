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
  credentials = file("../${var.CREDENTIALS}") ##get credentials from parent folder
  project     = var.PROJECT_ID
  region      = var.REGION
}

// Create a Google Cloud Storage Bucket
resource "google_storage_bucket" "my_bucket" {
  name     = var.BUCKET_NAME
  location = var.REGION
  project  = var.PROJECT_ID
  force_destroy = true
}

// Create a Google BigQuery Datasets
resource "google_bigquery_dataset" "stg" {
  dataset_id = var.DATASET_STG
  location = var.REGION
  project = var.PROJECT_ID
}

resource "google_bigquery_dataset" "prod" {
  dataset_id = var.DATASET_PROD
  location = var.REGION
  project = var.PROJECT_ID
}

resource "google_compute_instance" "agent-vm" {
  name         = var.VM_NAME
  machine_type = var.VM_MACHINE_TYPE
  zone         = var.VM_ZONE

  boot_disk {
    initialize_params {
      image = var.VM_MACHINE_IMAGE
      size=40
    }
  }

  service_account {
    email = "${var.SERVICE_ACCOUNT_NAME}@${var.PROJECT_ID}.iam.gserviceaccount.com"
    scopes = [
      "cloud-platform",
    ]
  }

  metadata = {
    ssh-keys = "${var.VM_SSH_USER}:${file(var.SSH_PUB_KEY_FILE)}"
  }

  network_interface {
    network = "default"
    access_config {
        network_tier = "PREMIUM"
    }
  }

  scheduling {
    on_host_maintenance="MIGRATE"
  }

}