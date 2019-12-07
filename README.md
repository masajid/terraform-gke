# terraform-gke

## Create project

Create a new project and link it to your billing account

```
gcloud projects create masajid --set-as-default

gcloud beta billing projects link masajid --billing-account ${billing_account}
```

Billing account can be found by:

```
gcloud beta billing accounts list
```

## Create service account

Create the service account in the project and download the JSON credentials:

```
gcloud iam service-accounts create terraform \
 --display-name "It deploys infrastracture using Terraform"

gcloud iam service-accounts keys create /path-to-workspace/masajid/terraform-gke/service-account.json \
 --iam-account terraform@masajid.iam.gserviceaccount.com
```

Grant the service account permission to view the Admin Project and manage Cloud Storage

```
gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@masajid.iam.gserviceaccount.com \
 --role roles/viewer
 
gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@$masajid.iam.gserviceaccount.com \
 --role roles/storage.admin
```
 
## Create backend storage to tfstate file
 
Create the remote backend bucket in Cloud Storage for storage of the terraform.tfstate file
 
```
gsutil mb -p masajid -l asia-southeast1 gs://masajid-terraform
```
 
Enable versioning for said remote bucket:
 
```
gsutil versioning set on gs://masajid-terraform
```
 
Configure your environment for the Google Cloud terraform provider
 
```
export GOOGLE_APPLICATION_CREDENTIALS=/path-to-workspace/masajid/terraform-gke/service-account.json
```
 
## Terraform
 
### Initialize terraform

Terraform uses modular setup and in order to download specific plugin for cloud provider, terraform will need to be 1st initiated.
 
```
terraform init
```

### Apply terraform 

Terraform plan will simulate what changes terraform will be done on cloud provider

```
terraform plan
```

Apply terraform plan for selected environment

```
terraform apply
```
