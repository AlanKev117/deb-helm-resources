#!/bin/bash

# Save current worrking directory
CALL_DIR=$(pwd)

# Use absolute paths here
TERRAFORM_DIR= # folder where you ran 'terraform apply'
CREDENTIALS_FILE= # your cloud provider credentials file

cd $TERRAFORM_DIR

# Get AWS EKS cluster context
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
export NFS_SERVER=$(terraform output -raw efs)

# Secrets env vars (airflow vars and connections) to inject to pods
# using Terraform output data. This section will change if you are
# using a service provider different to AWS or if you need more or
# less variables for your implementation.

## Creating the cloud provider connection URI based on the content of
## the credentials path
CREDENTIALS=$(head -2 $CREDENTIALS_FILE | tail -1)
AWS_REGION=$(terraform output -raw region)
AFCONN_AWS="aws://${CREDENTIALS/,/:}@?region_name=${AWS_REGION}"

## Creating the connection URI for the database you'll use in your project.
## You may not need to use this section if you work in GCP.
DB_USER=$(terraform output -raw rds_username)
DB_PASSWORD=$(terraform output -raw rds_password)
DB_ENDPOINT=$(terraform output -raw rds_endpoint)
DB_NAME=$(terraform output -raw rds_database)
AFCONN_POSTGRES="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"

## Env vars for data related to the rest of the services
AFVAR_BUCKET=$(terraform output -raw s3_bucket_name)
AFVAR_LOGREV_KEY=$(terraform output -raw s3_csv_log_reviews_key)
AFVAR_MOVREV_KEY=$(terraform output -raw s3_csv_movie_review_key)
AFVAR_USRPUR_KEY=$(terraform output -raw s3_csv_user_purchase_key)
AFVAR_USRPUR_TABLE="user_purchase"
AFVAR_USRPUR_SCHEMA="raw_data"
AFVAR_USRPUR_QUERY="create_schema_and_table.sql"  # must match file name in Docker image.
AFVAR_GLUEJOB=$(terraform output -raw gj_name)
AFVAR_GLUE_SCRIPT=$(terraform output -raw gj_script_location)
AFVAR_REGION=$(terraform output -raw region)
AFVAR_ATHDB=$(terraform output -raw ath-db-name)
AFVAR_ATHBUCKET=$(terraform output -raw ath-out-bucket)

cd $CALL_DIR

# Enable nfs server for cluster
kubectl create namespace storage
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace storage \
    --set nfs.server=$NFS_SERVER \
    --set nfs.path=/

# Create airflow namespace
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org

# Inject env vars calculated earlier as secrets
kubectl create secret generic af-connections \
    --from-literal=aws=${AFCONN_AWS} \
    --from-literal=postgres=${AFCONN_POSTGRES} \
    --namespace airflow

kubectl create secret generic af-variables \
    --from-literal=bucket=${AFVAR_BUCKET} \
    --from-literal=logrev_key=${AFVAR_LOGREV_KEY} \
    --from-literal=movrev_key=${AFVAR_MOVREV_KEY} \
    --from-literal=usrpur_key=${AFVAR_USRPUR_KEY} \
    --from-literal=usrpur_table=${AFVAR_USRPUR_TABLE} \
    --from-literal=usrpur_schema=${AFVAR_USRPUR_SCHEMA} \
    --from-literal=usrpur_query=${AFVAR_USRPUR_QUERY} \
    --from-literal=gluejob=${AFVAR_GLUEJOB} \
    --from-literal=glue_script_location=${AFVAR_GLUE_SCRIPT} \
    --from-literal=region=${AFVAR_REGION} \
    --from-literal=athdb=${AFVAR_ATHDB} \
    --from-literal=athbucket=${AFVAR_ATHBUCKET} \
    --namespace airflow

# Install airflow after secrets set
helm install airflow apache-airflow/airflow -n airflow -f values.yaml
