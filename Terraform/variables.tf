variable "credentials" {
  description = "My Credentials"
  default     = "/Users/beaubranton/de-zoomcamp/ncaa_d1_baseball_stats/ncaa-d1-baseball-stats-project-da5969b42075.json"
  
  #Update the above with the path to your JSON keys to your Google Cloud Project's Service Account
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}

variable "region" {
  description = "Region of the Google Cloud Storage"
  default     = "us-west1"

  #Update the default value to your desired region
}

variable "project_id" {
    description = "The ID of the Google Cloud project"
    default     = "ncaa-d1-baseball-stats-project"
    type        = string

  #Update the default value to the project id of the Google Project you created
}

variable "project_name" {
    description = "The name of the Google Cloud project"
    default     = "ncaa-d1-baseball-stats-project"
    type        = string

  #Update the default value to the project name of the Google Project you created
}

variable "bucket_name" {
    description = "The name of the Google Cloud Storage bucket"
    default     = "ncaa_d1_baseball_stats_bucket"
    type        = string

    #You can update the default value if you would like, but the pipeline will use this default name and you will be required to update the dataset variable in other places if you change this.
}

variable "dataset_id" {
    description = "The ID of the Google BigQuery dataset"
    default     = "ncaa_d1_baseball_stats"
    type        = string

    #You can update the default value if you would like, but the pipeline will use this default name and you will be required to update the dataset variable in other places if you change this.
}
