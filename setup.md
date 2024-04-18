# NCAA Division 1 Baseball Stats Pipeline Setup

## Overview
This guide provides detailed instructions to replicate this project: an end-to-end data engineering pipeline to ultimately store D1 Baseball stats from the current season  in BigQuery and build a dashboard to visualize that data. The pipeline involves setting up resources on Google Cloud Platform using Terraform, configuring service accounts, and automating data flows with dbt and Mage.

## Prerequisites
- Git
- Google Cloud SDK
- Terraform
- Make (for automation on local machine)

## 1. Download Project Repository

Navigate to your desired directory and clone the repository:

```bash
git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
cd ncaa_d1_baseball_stats
mv env_template .env  # Rename env_template to .env
2. Google Cloud Setup
2.1 Install Google SDK
Download and install the Google SDK but skip the gcloud init step as described here: Google SDK Installation.

2.2 Initialize Google Cloud Project
bash
Copy code
# Initialize your GCP configuration
gcloud init --no-browser --skip-diagnostics

# Follow prompts:
# - Select Option 2 to create a new configuration
# - Enter configuration name: ncaa-d1-baseball-stats-project
# - Choose the account and new project ID as prompted
gcloud config get-value project  # Verify the correct project is set
WARNING: Ensure the project ID matches exactly with the provided environment variables or update the .env and variables.tf files accordingly.

2.3 Update Environment Variables
Ensure the .env file is correctly renamed and update it with the unique GCS_BUCKET_NAME and any other regional settings.

2.4 Create Service Account & Setup Access
Ensure Make is installed on your machine. Use the provided Makefile to setup the project:

bash
Copy code
cd ~/ncaa_d1_baseball_stats
set -o allexport && source .env && set +o allexport
make gcp-set-all  # This will create the service account and configure IAM roles
2.5 Generate SSH Keys
bash
Copy code
ssh-keygen -t rsa -b 2048 -f ~/.ssh/ncaa_d1_baseball_stats -C project_user
# Optionally configure SSH to connect to VMs easily
3. Terraform Setup
Navigate to the project's Terraform directory and initialize and apply the configuration:

bash
Copy code
set -o allexport && source .env && set +o allexport
terraform -chdir=terraform init
terraform -chdir=terraform plan
terraform -chdir=terraform apply
Confirm the setup by typing yes when prompted.

4. VM Setup
bash
Copy code
# Start the VM
gcloud compute instances start $GCP_VM_NAME --zone $GCP_ZONE --project $GCP_PROJECT_ID

# Connect to the VM
ssh -i ~/.ssh/ncaa_d1_baseball_stats $GCP_VM_SSH_USER@[VM_EXTERNAL_IP]
5. Setup on VM
Clone the project and prepare the environment on the VM:

bash
Copy code
git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
cd ncaa_d1_baseball_stats
# Ensure environment variables and credentials are copied over
6. Running Mage via Docker
bash
Copy code
cd ~/ncaa_d1_baseball_stats
sudo docker-compose up
7. Triggering Mage Pipelines
Access the Mage UI to run the pipelines. Choose between quick tests or full season data scraping.

8. Looker Dashboard Setup
Set up Looker for data visualization by connecting it to BigQuery. Follow the steps provided here to configure OAuth 2.0 credentials.

9. Destroy Resources
To clean up resources, navigate to the Terraform directory and run:

bash
Copy code
set -o allexport && source .env && set +o allexport
terraform -chdir=terraform destroy
Additional Resources
Looker Instance Setup
Embedding Looker Dashboards