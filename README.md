# ncaa_d1_baseball_stats
An end to end data pipeline that scrapes, stores, transforms and visualizes stats from all NCAA D1 Baseball Games. This project was created to demonstrate concepts learned in the 2024 Data Engineering Zoomcamp hosted by the Data Talks Club as well as a fun personal project for me to build a database and frontend that I wish had previously existed.



Setup Instructions:


0.0 DOWNLOAD PROJECT REPOSITORY

On your local machine run the following commands from terminal. Naviagate to the directory you want this project to be installed and run the following:

git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
cd ncaa_d1_baseball_stats
Rename env_template to .env

1.0 GOOGLE CLOUD SETUP 
1.1 Install Google SDK: Google SDK: Download from here: https://cloud.google.com/sdk/docs/downloads-interactive#linux-mac (Don't do the gcloud init step)

1.2 You can setup a Google Cloud from your terminal with the following commands:

Create the GCP Project named ncaa-d1-baseball-stats-project: by executing the below from the this project's folder in the terminal. GCP Documentation

    # Follow instructions to setup your project and do the initial project setup
    gcloud init --no-browser --skip-diagnostics
    # Select Option 2 - Create a new configuration
    # Enter configuration name (enter the project name here): ncaa-d1-baseball-stats-project
    # Choose the account you would like to use to perform operations for this configuration: 1 (your gmail account)
    # Pick cloud project to use: (Create new project)
    # Please enter project id: ncaa-d1-baseball-stats-project

    # To check that all is configured correctly and that your CLI is configured to use your created project use the command
    gcloud config get-value project


    WARNING: Double check that you have typed the project name and id exactly as shown: "ncaa-d1-baseball-stats-project". This name much match the environment variables provided (or must be changed to match the name/id that you chose)


<!-- - Setup a Google Cloud Account
- Enable Billing
- Create a New Project on GCP and Give it a Name and ID (You do not have to create or select an organization)
    - Suggested Name:
    - Suggested ID:
    - You can choose any ID and name that you want, but you will need to update certain variables with the ID and name that you chose for your Google Cloud Project. If you use the Suggested Name and Suggested ID, these variables will default to what was suggested. -->

1.3 UPDATE .ENV or variables.tf
- This is just a reminder to rename env_template to .env if you haven't already
- You must set the GCS_BUCKET_NAME variable. All bucket names across all of GCS are unique. Adding a few numbers to the end should work.
- You also have the option of updating the region and zone variables in the .env file to one that matches where you live.
- All the other environment variables should be set for you, but if you deviated from the project names/id's and or instructions provided, you will want to update the .env and variables.tf files accordingly. 

1.4 CREATE SERVICE ACCOUNT & SAVE CREDENTIALS, ENABLE API'S AND SETUP ACCESS VIA IAM ROLES:

First, you will need to install Make on your local machine if you do not already have it.

A Make file is provided for you to execute the below commands and finalize setup. NOTE: This command will take time to execute

    cd ~/ncaa_d1_baseball_stats

    # set the environment variables from the .env file
    set -o allexport && source .env && set +o allexport
    make gcp-set-all

<!-- - Create a Service Account and Generate a JSON Key to access and manage the project with Terraform
    - 
    - https://console.cloud.google.com/iam-admin/serviceaccounts
    - Suggested Service Account Name: ncaa_d1_baseball_stats_service (Can use makefile)
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
    - Rename the json file gcp-credentials.json and move it to the credentials folder in this project repository on your machine (If stored elsewhere you will need to update the file path variable in the .env file accordingly) -->

<!-- 1.2 ENABLE APIS
    - Next, we are required to enable Specific Google APIs (click following links and hit enable):
        - BigQuery API: https://console.developers.google.com/apis/api/bigquery.googleapis.com
        - Compute Engine API: https://console.cloud.google.com/marketplace/product/google/compute.googleapis.com -->

1.5 GENERATE SSH KEYS (FOR VM):

    Run the following:
    
    cd ~/.ssh
    ssh-keygen -t rsa -f ~/.ssh/ncaa_d1_baseball_stats -C project_user -b 2048
    
    You have the option of creating a config file in this directory to make connecting to the VM easy and enable port forwarding via VS Code Extension - 
    https://youtu.be/ae-CV2KfoN0?list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&t=1073 
    you can watch this video starting at 17:53 to see how to do this



2.0 TERRAFORM SETUP 
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


3.0 VM SETUP (If you want these pipelines to run on the cloud, this section must be completed. If you just want to run these pipelines locally, you can skip sections 3 and 4 and just run docker from your local machine)

    Run the VM:
        gcloud compute instances start $GCP_VM_NAME --zone $GCP_ZONE --project $GCP_PROJECT_ID
        This can also be done via GCP

    If you created a config file in you ~/.ssh folder you can update the IP Address there and remote ssh into the VM

    Host ncaa-d1-baseball-stats
    Hostname 34.168.166.185
    User project_user
    IdentityFile ~/.ssh/ncaa_d1_baseball_stats

    
    Get the External IP:
        ssh -i ~/.ssh/ncaa_d1_baseball_stats $GCP_VM_SSH_USER@[REPLACE_WITH_EXTERNAL_IP_OF_VM]
        

4.0 Clone the Project repo on the VM
        git clone https://github.com/beaubranton4/ncaa_d1_baseball_stats.git
        cd ncaa_d1_baseball_stats
    Copy the .env file from your local machine to the parent folder of this project in the VM
    Copy JSON file with Service Account Credentials from your local repository to the same location in the cloned project repo in the VM
        Should keep the name as gcp-credentials.json and move to the credentials folder


5.0 RUNNING MAGE VIA DOCKER IMAGE 
    cd ~/ncaa_d1_baseball_stats
    Docker and docker compose should have been installed via Terraform, if it hasn't you can find instructions in this video:

    To run Mage via Docker:

    - sudo docker-compose up
    - Enable Port Forwarding and connect to localhost:6789. You should see the UI for Mage. If you don't see anything ensure the Docker image is running on port 6789. You may have be having trouble with port forwarding if both are working properly.

5.1 TRIGGERING MAGE PIPELINES

###LEFT OFF HERE!!!!!!!!!!!!!!!!

- In the mage UI, click Pipelines in the left hand menu. You will see 4 pipelines:
    - test_scrape_ncaa_d1_baseball_stats
    - scrape_ncaa_d1_baseball_stats
    - ncaa_batting_gcs_to_big_query
    - dbt_transform_ncaa_d1_baseball

- Depending, on how much time you have, I have built two nearly identical sets of pipelines. The only difference is that one will scrape baseball stats from a single day, write to GCS, transfer and store in BQ and perform dbt transformations. The other will do this for the entire season up to the date that you run the pipeline. As of writing we are nearly 60 days into the season and the full pipeline takes about 2 hours to run.
    - Option 1 (5 min to complete): 
        - Click the test_scrape_ncaa_d1_baseball_stats pipeline
        - Click Run@once 
        - Click Run Now
    - Option 2 (2-3 hours to complete): 
        - Click the scrape_ncaa_d1_baseball_stats pipeline
        - Click Run@once 
        - Click Run Now

Whichever option you choose will run the pipeline that scrapes the data from the NCAA stats website. Once completed it will trigger ncaa_batting_gcs_to_big_query and dbt_transform_ncaa_d1_baseball.

More magic! You now have all the data you need in both Google Cloud Storage and in BigQuery:

You should see:

    In Google Cloud Storage:
        - A bucket created with the bucket name you defined in your .env file
        - Folders for each date scraped by your pipeline runs thus far each containing a parquet file with raw data with stats from games on that date

    In Big Query:

If you want to keep this entire pipeline up and running, you can create a new scheduled trigger on scrape_ncaa_d1_baseball_stats pipeline.  This will run the entire end-to-end pipeline for as long as you keep the docker image and your virtual machine running (but be aware that this will cost a few dollars a day)


7.0 Dashboard

Create a Looker Instance: https://console.cloud.google.com/looker/instances?referrer=search&authuser=0&walkthrough_id=looker-studio--looker-studio-onboarding&project=ncaa-d1-baseball-stats-project

You must first create OAuth 2.0 Authorization Credentials by following the steps here: https://developers.google.com/identity/protocols/oauth2/web-server#creatingcred

- Enable the Looker API

The data visualization portion of this project was built in Looker. Here are instructions on how to start using Looker, connect it to Big Query and replicate the same visualizations that I have created. Unfortunately, this is the one part of the project that I was not able to "automate" and would not advise trying to rebuild my dashboard unless you have the time!

Link to Looker Dashboard: https://lookerstudio.google.com/s/nWiTVPz6SUw
Link to Embed: <iframe width="600" height="450" src="https://lookerstudio.google.com/embed/reporting/a4fcf765-aa8c-4337-bdbe-6a165cbb5266/page/p_z3bay2lggd" frameborder="0" style="border:0" allowfullscreen sandbox="allow-storage-access-by-user-activation allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox"></iframe>

8.0 Destroying Resources

Either on your local machine or your VM, navigate to the parent directory of this project:
    set -o allexport && source .env && set +o allexport
    terraform -chdir=terraform init


Future Enhancements:

- Provide detailed documentation of all tables with fields, types and descriptions of each
- I had also written 80% of a script to scrape data from college rosters. I hope to upload this as seed data to enable filtering in the dashboard by hometown, grade and other player attributes