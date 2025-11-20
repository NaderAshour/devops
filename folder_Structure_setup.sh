#!/bin/bash

BASE_PATH="/drives/e/DevOps/Quest_Tactfful/Phase2_AKS_IAC"


# Helm directories and files

mkdir -p $BASE_PATH/helm/postgres/templates
mkdir -p $BASE_PATH/helm/redis/templates

# Helm Postgres files
touch $BASE_PATH/helm/postgres/Chart.yaml
touch $BASE_PATH/helm/postgres/values.yaml
touch $BASE_PATH/helm/postgres/templates/deployment.yaml
touch $BASE_PATH/helm/postgres/templates/pvc.yaml
touch $BASE_PATH/helm/postgres/templates/secret.yaml

# Helm Redis files
touch $BASE_PATH/helm/redis/Chart.yaml
touch $BASE_PATH/helm/redis/values.yaml
touch $BASE_PATH/helm/redis/templates/deployment.yaml
touch $BASE_PATH/helm/redis/templates/pvc.yaml
touch $BASE_PATH/helm/redis/templates/secret.yaml

# -------------------------------
# Kubernetes directories and files
# -------------------------------
mkdir -p $BASE_PATH/k8s/common
mkdir -p $BASE_PATH/k8s/vote
mkdir -p $BASE_PATH/k8s/result
mkdir -p $BASE_PATH/k8s/worker

# Common files
touch $BASE_PATH/k8s/common/namespace.yaml
touch $BASE_PATH/k8s/common/networkpolicy.yaml
touch $BASE_PATH/k8s/common/resourcequotas.yaml

# Vote files
touch $BASE_PATH/k8s/vote/deployment.yaml
touch $BASE_PATH/k8s/vote/service.yaml

# Result files
touch $BASE_PATH/k8s/result/deployment.yaml
touch $BASE_PATH/k8s/result/service.yaml

# Worker files
touch $BASE_PATH/k8s/worker/deployment.yaml
touch $BASE_PATH/k8s/worker/service.yaml


# Terraform files
touch $BASE_PATH/terraform/main.tf
touch $BASE_PATH/terraform/variables.tf
touch $BASE_PATH/terraform/outputs.tf
touch $BASE_PATH/terraform/dev.tfvars
touch $BASE_PATH/terraform/prod.tfvars
touch $BASE_PATH/terraform/provider.tf
touch $BASE_PATH/terraform/acr.tf
touch $BASE_PATH/terraform/aks.tf
touch $BASE_PATH/terraform/keyvault.tf

