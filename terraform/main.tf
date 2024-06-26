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
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "development" {
  dataset_id = "dev_ncaa_d1_baseball_stats"
  location = var.REGION
  project = var.PROJECT_ID
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "prod" {
  dataset_id = var.DATASET_PROD
  location = var.REGION
  project = var.PROJECT_ID
  delete_contents_on_destroy = true
}

resource "google_compute_instance" "agent-vm" {
  boot_disk {
    auto_delete = true
    device_name = var.VM_NAME

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240307b"
      size  = 30
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.VM_MACHINE_TYPE
  name         = var.VM_NAME

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "$projects/${var.PROJECT_ID}/regions/us-west1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "${var.SERVICE_ACCOUNT_NAME}@${var.PROJECT_ID}.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    ssh-keys = "${var.VM_SSH_USER}:${file(var.SSH_PUB_KEY_FILE)}"
    startup-script = <<-EOS
      #!/bin/bash
      # Update and install prerequisites
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

      # Add Docker's official GPG key
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

      # Add Docker's repository
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

      # Install Docker CE
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io

      # Install Docker Compose
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose

      # Manage Docker as a non-root user (Specify the actual username instead of $USER)
      sudo usermod -aG docker [username]

      # Enable and restart Docker service
      sudo systemctl enable docker
      sudo systemctl restart docker
    EOS
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = var.VM_ZONE
}


