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

Note: Only if necessary 

Gran the Service Account Key Admin role `roles/iam.serviceAccountKeyAdmin` to the owner user, that he is able to manage service account keys.

## Create service account

Create the service account in the project and download the JSON credentials:

```
gcloud iam service-accounts create terraform \
 --display-name "terraform" \
 --description "Automate our infrastructure"

gcloud iam service-accounts keys create /path-to-workspace/masajid/terraform-gke/terraform-service-account.json \
 --iam-account terraform@masajid.iam.gserviceaccount.com
```

Grant the service account permission to view the Admin Project and manage Cloud Storage

```
gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@masajid.iam.gserviceaccount.com \
 --role roles/viewer

gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@masajid.iam.gserviceaccount.com \
 --role roles/storage.admin

gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@masajid.iam.gserviceaccount.com \
 --role roles/container.admin

gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:terraform@masajid.iam.gserviceaccount.com \
 --role roles/iam.serviceAccountUser
```

## Create backend storage to tfstate file
 
Create the remote backend bucket in Cloud Storage for storage of the terraform.tfstate file
 
```
gsutil mb gs://masajid-terraform
```
 
Enable versioning for said remote bucket:
 
```
gsutil versioning set on gs://masajid-terraform
```

Maybe not needed. We can grant read/write permissions on this bucket to our service account:

```
gsutil iam ch serviceAccount:terraform@masajid.iam.gserviceaccount.com:legacyBucketWriter gs://masajid-terraform
gsutil iam ch serviceAccount:travis-deployer@masajid.iam.gserviceaccount.com:legacyBucketWriter gs://masajid-terraform
```
 
Configure your environment for the Google Cloud terraform provider
 
```
export GOOGLE_APPLICATION_CREDENTIALS=/path-to-workspace/masajid/terraform-gke/terraform-service-account.json
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

## Generate a kubeconfig entry

To run kubectl commands against a cluster created by terraform, you need to generate a kubeconfig entry in your environment:

```
gcloud container clusters get-credentials masajid-cluster
```

## Create google cloud storage bucket for images

Create the gcs bucket in Cloud Storage for storage of the images

```
gsutil mb gs://masajid-active-storage-bucket
```

To view uploaded images in the app, we set the bucket's default access control list (ACL) to public-read:

```
gsutil defacl set public-read gs://masajid-active-storage-bucket
```

Create the service account in the project to enable server-to-server communication and download the JSON credentials:

```
gcloud iam service-accounts create masajid-active-storage \
 --display-name "active-storage" \
 --description "Storage of app images"

gcloud iam service-accounts keys create /path-to-workspace/masajid/masajid/active-storage-service-account.json \
 --iam-account masajid-active-storage@masajid.iam.gserviceaccount.com
```

Grant the service account permission to manage Cloud Storage

```
gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:masajid-active-storage@masajid.iam.gserviceaccount.com \
 --role roles/owner
```

Grant read/write permissions on this bucket to our service account

```
gsutil iam ch serviceAccount:masajid-active-storage@masajid.iam.gserviceaccount.com:legacyBucketWriter gs://masajid-active-storage-bucket
```

## Create travis deployer account service

Create the service account in the project for automated deployment and download the JSON credentials:

```
gcloud iam service-accounts create travis-deployer \
 --display-name "travis-deployer" \
 --description "Automatic deployment from travis"

gcloud iam service-accounts keys create /path-to-workspace/masajid/masajid/travis-deployer-service-account.json \
 --iam-account travis-deployer@masajid.iam.gserviceaccount.com
```

Grant the service account permission to manage deployment

```
gcloud projects add-iam-policy-binding masajid \
 --member serviceAccount:travis-deployer@masajid.iam.gserviceaccount.com \
 --role roles/storage.admin
```

Finally, encrypt the JSON file and commit the `.json.enc` file to the repository

```
gem install travis # If it is not installed

travis encrypt-file travis-deployer-service-account.json -r masajid/masajid
```

Configure Cloud Shell for use with GitHub

- In the GCP Console, click Activate Cloud Shell

- Generate a new SSH key

```
ssh-keygen -t rsa -b 4096 -C "admin@masajid.world"
eval "$(ssh-agent -s)"
```

- Add the new SSH key to your GitHub account

```
pbcopy < ~/.ssh/id_rsa.pub
```

- Verify that your SSH key can communicate with GitHub

```
ssh -T git@github.com
```

## Create necessary disk

Create disk for postgres

```
gcloud compute disks create --size 200GB postgres-disk --zone europe-west3-a
```

Create disk for redis

```
gcloud compute disks create --size 1GB redis-disk --zone europe-west3-a
```
