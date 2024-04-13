# ncaa_d1_baseball_stats
An end to end data pipeline that scrapes, stores, transforms and visualizes stats from all NCAA D1 Baseball Games. This project was created to demonstrate concepts learned in the 2024 Data Engineering Zoomcamp hosted by the Data Talks Club as well as a fun personal project for me to build a database and frontend that I wish had previously existed.



Setup Instructions:


0.0 DOWNLOAD PROJECT REPOSITORY


1.0 GOOGLE CLOUD SETUP (Consider using CLI if that makes it easier)

- Setup a Google Cloud Account
- Enable Billing
- Create a New Project on GCP and Give it a Name and ID (You do not have to create or select an organization)
    - Suggested Name:
    - Suggested ID:
    - You can choose any ID and name that you want, but you will need to update certain variables with the ID and name that you chose for your Google Cloud Project. If you use the Suggested Name and Suggested ID, these variables will default to what was suggested.

1.1 CREATE SERVICE ACCOUNT AND SAVE JSON FILE:
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
    - Click on the Service Account and Select "Keys". Hit the "Add Key" button, select "Create Key", select the "JSON" button and create. This will save the JSON Key to your computer. 
    - Rename the json file gcp-credentials.json and move it to the credentials folder in this project repository on your machine (If stored elsewhere you will need to update the file path variable in the .env file accordingly)

1.2 ENABLE APIS
    - Next, we are required to enable Specific Google APIs (click following links and hit enable):
        - BigQuery API: https://console.developers.google.com/apis/api/bigquery.googleapis.com
        - Compute Engine API: https://console.cloud.google.com/marketplace/product/google/compute.googleapis.com

1.3 GENERATE SSH KEYS (FOR VM)
    Run the following:
    
    cd ~/.ssh
    ssh-keygen -t rsa -f ~/.ssh/ncaa_d1_baseball_stats -C project_user -b 2048

    Upload SSH Key to GCP: manually or through CLI
    Run: 
        cat ncaa_d1_baseball_stats.pub
    
    To receive ssh key to paste into metadata section in compute engine
    
    You have the option of creating a config file in this directory to make connecting to the VM easy and enable port forwarding via VS Code Extension - 
    https://youtu.be/ae-CV2KfoN0?list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&t=1073 
    you can watch this video starting at 17:53 to see how to do this

2.1 UPDATE .ENV or variables.tf
- Rename env_template to .env
- Update the following variables in your newly named .env file:
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
- Voila! Your Data Lake, Data Warehouse and VM have been created.


4.0 VM SETUP (OPTIONAL - If you want these pipelines to run on the cloud, this section must be completed. If you just want to run these pipelines locally, you can skip to instruction 4.2 but be warned that you will need to keep your computer running for 3 or 4 hours to fully complete the project setup)
    Run the VM:
        gcloud compute instances start $GCP_VM_NAME --zone $GCP_ZONE --project $GCP_PROJECT_ID
        This can also be done via GCP
    Get the External IP:
        ssh -i ~/.ssh/ncaa_d1_baseball_stats $GCP_VM_SSH_USER@[REPLACE_WITH_EXTERNAL_IP_OF_VM]
        If you created a config file in you ~/.ssh folder you can update the IP Address there and remote ssh into the VM


4.1 INSTALLING ALL REQUIREMENTS FOR VM ENVIRONMENT
    - Install Docker: (Can Include this in Terraform file)
        sudo apt-get update
        sudo apt-get install docker.io && y
        sudo groupadd docker
        sudo gpasswd -a $USER docker
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        - to verify:
        sudo docker-compose --version

4.2 Clone the Project repo on the VM
        git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
        cd ncaa_d1_baseball_stats
    Rename env_template
        mv env_template .env
    Copy JSON file with Service Account Credentials from your local repository to the same location in the cloned project repo in the VM
        Should keep the name as gcp-credentials.json and move to the credentials folder

5.0 RUNNING MAGE VIA DOCKER IMAGE 
    cd ~/ncaa_d1_baseball_stats
    - sudo docker-compose up
    - Enable Port Forwarding and connect to localhost:6789. You should see the UI for Mage. If you don't see anything ensure the Docker image is running on port 6789. You may have be having trouble with port forwarding if both are working properly.

5.1 TRIGGERING MAGE PIPELINES
    - There are two production pipelines in this Mage Project:
        scrape_ncaa_d1_baseball_stats: this pipeline scrapes data from all box scores from all d1 baseball games in the 2024 season that have not yet been scraped. THE FIRST TIME THIS PIPELINE RUNS WILL TAKE 2-4 HOURS (run the test pipeline if you don't have the time to wait)
        -ncaa_batting_gcs_to_big_query: this pipeline moves data from GCS storage bucket to BigQuery. It's set to run daily and also is triggered to run anytime "scrape_ncaa_d1_baseball_stats" or "test_scrape_ncaa_d1_baseball_stats" is run successfully

    - If you just want to test that everything is working i have created a test_pipeline script that only scrapes data from one day. Alternatively, you can run the "scrape_ncaa_d1_baseball_stats", leave the Docker image and VM running for a few hours and check back:
    - Click on the test pipeline "test_scrape_ncaa_d1_baseball_stats" and trigger it to "Run Once"
    - Run the first pipeline (the very first run may take up to 3 hours as data is scraped for every day since the beginning of the 2024 season 2/16/2024)
        - The script is built so that it will check what dates have already been scraped (in GCS) and only scrape remaining
        - If all dates have been scraped, it will rescrape the last two days worth of data in case there have been updates to box scores 
    - Pipeline triggers should already be active and should run every 6 hours. As long as you keep the VM the docker image on your VM running, these pipelines will run and you should receive stats from games that happen daily (until the end of the season of course 6/23/2024)

6.0 Partitioning and Data Warehouse Optimization
7.0 Build Dashboard

8.0 Destroying Resources

Either on your local machine or your VM, navigate to the parent directory of this project:
