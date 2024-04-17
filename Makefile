enable-apis:
	gcloud services enable \
	iam.googleapis.com \
	compute.googleapis.com \
	bigquery.googleapis.com 

create-sa:
	gcloud iam service-accounts \
	create ${GCP_SERVICE_ACCOUNT_NAME} --display-name="Master Service Account"

add-access:
	gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/storage.admin' ; \
	gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/storage.objectAdmin' ;\
    gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/bigquery.admin' ; \
    gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/compute.instanceAdmin' ; \
    gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/viewer' ; \
    gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
	--member='serviceAccount:'"${GCP_SERVICE_ACCOUNT_NAME}"'@'"${GCP_PROJECT_ID}"'.iam.gserviceaccount.com' \
	--role='roles/iam.serviceAccountUser'

get-key:
	gcloud iam service-accounts keys create \
	${GCP_CREDENTIALS} \
	--iam-account=${GCP_SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com

gcp-set-all:
	make enable-apis && \
	make create-sa && \
	make add-access && \
	make get-key
