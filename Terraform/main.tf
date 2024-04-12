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
