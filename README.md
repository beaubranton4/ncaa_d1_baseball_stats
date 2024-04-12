# ncaa_d1_baseball_stats
An end to end data pipeline that scrapes, stores, transforms and visualizes stats from all NCAA D1 Baseball Games. This project was created to demonstrate concepts learned in the 2024 Data Engineering Zoomcamp hosted by the Data Talks Club as well as a fun personal project for me to build a database and frontend that I wish had previously existed.



Setup Instructions:

1.0 GOOGLE CLOUD SETUP (Consider using CLI if that makes it easier)

- Setup a Google Cloud Account
- Enable Billing
- Create a New Project on GCP and Give it a Name and ID (You do not have to create or select an organization)
    - Suggested Name:
    - Suggested ID:
    - You can choose any ID and name that you want, but you will need to update certain variables with the ID and name that you chose for your Google Cloud Project. If you use the Suggested Name and Suggested ID, these variables will default to what was suggested.
1.1 SERVICE ACCOUNT:
- Create a Service Account and Generate a JSON Key to access and manage the project with Terraform
    - 
    - https://console.cloud.google.com/iam-admin/serviceaccounts
    - Suggested Service Account Name:ncaa_d1_baseball_stats_service (Can use makefile)
    - Suggested Service Account ID: ncaa_d1_baseball_stats_service (Can use makefile)
    - Grant proper permissions to Service Account
        - Owner: This should give access to most everything but just in case...
        - Specific Roles for Terraform (IaC) Setup:
            - BigQuery Admin
            - Storage Admin
            - Storage Object Admin
        - Specific Roles for Mage (Cloud Orchestrator):
            - Artifact Registry Reader
            - Artifact Registry Writer
            - Cloud Run Developer
            - Cloud SQL Admin
            - Service Account Token Creator
        - Specific Roles for dbt (Transformations) - these are redundant roles:
            - BigQuery Admin
            - Storage Admin
            - Storage Object Admin
        - In a real world scenario this may require 3 seperate service accounts, but for 
        setup you can just create a single service account with all of the following 
        roles.
    - Create the Service Account
    - Click on the Service Account and Select "Keys". Hit the "Add Key" button, select "Create Key", select the "JSON" button and create. This will save the JSON Key to your computer. Move the JSON key to the rootpath of the downloaded repo and also to the mage folder?
1.2 ENABLE APIS
    - Next, we are required to enable Specific Google APIs (click following links and hit enable):
        - BigQuery API: https://console.developers.google.com/apis/api/bigquery.googleapis.com
        - Compute Engine API: https://console.cloud.google.com/marketplace/product/google/compute.googleapis.com
1.3 GENERATE SSH KEYS
    Run the following:
    
    cd ~/.ssh
    ssh-keygen -t rsa -f ~/.ssh/ncaa_d1_baseball_stats -C project_user -b 2048

    Upload SSH Key to GCP:

    manually or through CLI

2.0 DOWNLOAD REPOSITORY

2.1 UPDATE .ENV or variables.tf
- Update the variables.tf file:
    - The easiest way is to simply update the default values for each variable
    - You MUST update the following variables in variables.tf:
        - "credentials": with a path to your service account  JSON key in order for terraform to be granted access to create all the necessary resource
        - "project_id": the project_id of the Google Project you created in the earlier step. IF you used the suggested project_name you can leave this as is.
        - "project_name": the project_name of the Google Project you created in the earlier step. IF you used the suggested project_name you can leave this as is.
    - I would recommend updating the following variables.tf file based on where you are located:
        - "region": https://cloud.google.com/about/locations/
    - The other variables can be set to whatever you choose, BUT I WOULD RECOMMEND KEEPING THE DEFAULT VALUES SO THAT THE MAGE AND DBT SCRIPTS DON'T REQUIRE UPDATING

3.0 TERRAFORM SETUP 
- Install Terraform
- From terminal, navigate to the parent directory of this project:
    
    set -o allexport && source .env && set +o allexport
    terraform -chdir=terraform init
    terraform -chdir=terraform plan
    terraform -chdir=terraform apply

    - run: terraform apply
    - type: yes
    - hit enter
- Voila! Your Data Lake, VM and Data Warehouse have been created.


4.0 VM SETUP
    Run the VM:
        gcloud compute instances start $GCP_VM_NAME --zone $GCP_ZONE --project $GCP_PROJECT_ID
    Get the External IP:
        ssh -i ~/.ssh/ncaa_d1_baseball_stats $GCP_VM_SSH_USER@[REPLACE_WITH_EXTERNAL_IP_OF_VM]
    Clone the Project repo on the VM
        git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
        cd ncaa_d1_baseball_stats
    Rename env_template
        mv env_template .env
4.1 INSTALLING ALL REQUIREMENTS FOR VM ENVIRONMENT
    - Install Docker: (Can Include this in Terraform file)
        sudo apt-get update
         sudo apt-get install docker.io
            type in Y
         sudo gpasswd -a $USER docker
         sudo service docker restart
         exit (exit out of VM)
         ssh -i ~/.ssh/ncaa_d1_baseball_stats $GCP_VM_SSH_USER@[REPLACE_WITH_EXTERNAL_IP_OF_VM] (log back in)

        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        - to verify:
        docker-compose --version

NEED TO DO THIS ALL AGAIN AND SEE WHAT's NEEDED

    - Need to install Anaconda, POSTGRESQL, PGCLI, CHECK MAGE VIDEOS, CHECK DBT VIDEOS
    - Must install Docker on machine (or should i install Docker for them in VM)
4.2 RUNNING DOCKER IMAGE 
    - docker-compose up
    - port forwarding
4.3 TRIGGERING PIPELINE
    - instructions
        - Make sure service account JSON key is accessible. Can i keep in same location and point in io_config.yml or does it have to be moved in mage folder.
        - Updating Variables to match terraform and Infrastructure
        - Update  GOOGLE_SERVICE_ACC_KEY_FILEPATH: in io_config.yml
        - Run and Schedule
5.0 Setting Up DBT 
6.0 Build Dashboard

7.0 Destroying Resources