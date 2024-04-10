# ncaa_d1_baseball_stats
An end to end data pipeline that scrapes, stores, transforms and visualizes stats from all NCAA D1 Baseball Games. This project was created to demonstrate concepts learned in the 2024 Data Engineering Zoomcamp hosted by the Data Talks Club as well as a fun personal project for me to build a database and frontend that I wish had previously existed.



Setup Instructions:

- Download Terraform
- Setup a Google Cloud Account
- Create a New Project on GCP and Give it a Name and ID (You do not have to create or select an organization)
    - Suggested Name:
    - Suggested ID:
    - You can choose any ID and name that you want, but you will need to update certain variables with the ID and name that you chose for your Google Cloud Project. If you use the Suggested Name and Suggested ID, these variables will default to what was suggested.
- Create a Service Account and Generate a JSON Key to access and manage the project with Terraform
    - 
    - https://console.cloud.google.com/iam-admin/serviceaccounts
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

    - Next, we are required to enable Specific Google APIs (click following links and hit enable):
        - BigQuery API: https://console.developers.google.com/apis/api/bigquery.googleapis.com/overview?project=344681316515
        - 
- Update the variables.tf file:
    - The easiest way is to simply update the default values for each variable
    - You MUST update the following variables in variables.tf:
        - "credentials": with a path to your service account  JSON key in order for terraform to be granted access to create all the necessary resource
        - "project_id": the project_id of the Google Project you created in the earlier step. IF you used the suggested project_name you can leave this as is.
        - "project_name": the project_name of the Google Project you created in the earlier step. IF you used the suggested project_name you can leave this as is.
    - I would recommend updating the following variables.tf file based on where you are located:
        - "region": https://cloud.google.com/about/locations/
    - The other variables can be set to whatever you choose, BUT I WOULD RECOMMEND KEEPING THE DEFAULT VALUES SO THAT THE MAGE AND DBT SCRIPTS DON'T REQUIRE UPDATING
- From terminal, navigate to the terraform directory:
    - run: terraform apply
    - type: yes
    - hit enter
- Voila! Your Data Lake and Data Warehouse have been created.

- Updating Variables in Mage and Getting it to Run Pipelines (Terraform)
    - Need to spin up Mage using standalone repo outside of magic-zoomcamp
    - Make sure service account JSON key is accessible. Can i keep in same location and point in io_config.yml or does it have to be moved in mage folder.
    - Updating Variables to match terraform and Infrastructure
        - Service account,
        - bucket name
        - Location
        - project name
        - dataset_name
        - table_name
    - Must include mage in terraform portion
    - Or we can wrap mage and our pipelines in a docker container and have it trigger somehow automatically?
    - Update  GOOGLE_SERVICE_ACC_KEY_FILEPATH: in io_config.yml
- Setting Up DBT 
- Build Dashboard