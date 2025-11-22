Below The Setup Steps u can find the Challenge over view and requirments.


Setup:
 Phase 2 & Phase 3 — AKS, Terraform, Kubernetes & CI/CD (GitHub Actions)

This README explains how to provision the infrastructure (AKS + ACR + Key Vault) using Terraform, deploy all Kubernetes resources (manifests + Helm charts), and configure the CI/CD pipeline using GitHub Actions.

Branch to clone:

https://github.com/NaderAshour/devops/tree/dev-k8s-cicd

📌 1. Tools Required

Install the following:

Tool	Purpose
Azure CLI	Authentication & resource management
Terraform ≥ 1.5	Provisioning infrastructure
kubectl	Working with AKS cluster
Helm ≥ 3	Deploying charts (Redis, PostgreSQL, Ingress)
Docker	Build images locally (optional)
GitHub CLI (optional)	Managing actions & secrets
📌 2. Clone the Repository
git clone -b dev-k8s-cicd https://github.com/NaderAshour/devops.git
cd devops

📌 3. Authenticate to Azure
3.1 Login
az login

3.2 Select subscription
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

📌 4. Phase 2 — Provision Infrastructure with Terraform

Infrastructure is inside:

terraform/
│── acr.tf
│── aks.tf
│── keyvault.tf
│── main.tf
│── outputs.tf
│── provider.tf
│── variables.tf
│── dev.tfvars
│── prod.tfvars

4.1 Initialize Terraform
cd terraform
terraform init

4.2 Validate
terraform validate

4.3 Apply (example: dev)
terraform apply -var-file="dev.tfvars"

📌 5. Terraform Outputs (Very Important)

Terraform will output:

Output	Purpose
acr_name	Used by AKS to pull images & by CI to push images
acr_server	Example: naderacr.azurecr.io
aks_name	Used to fetch kubeconfig
keyvault_name	Needed for CSI driver
kubeconfig_path	Generated locally
client_id / principal_id	Needed for RBAC and AKS integration
📌 6. Authenticate with AKS & ACR
6.1 Connect kubectl to cluster
az aks get-credentials --resource-group <RG> --name <AKS_NAME>

6.2 Allow AKS to pull from ACR

Terraform already created roles, but verify:

az aks update -n <AKS_NAME> -g <RG> --attach-acr <ACR_NAME>

📌 7. Phase 2 — Deploy Kubernetes Resources

All manifests & Helm charts are in:

k8s/
│── bringup.sh
│── dev/
│── prod/
│── helm/
│   ├── redis/
│   ├── postgres/
│   ├── ingress-controller/
│   └── ingress/
│── cert-manager/

7.1 Step 1 — Create Namespace
kubectl apply -f k8s/dev/namespace.yaml

7.2 Step 2 — Deploy Cert-Manager
kubectl apply -f k8s/cert-manager/

7.3 Step 3 — Install Redis via Helm
helm install redis k8s/helm/redis -f k8s/helm/redis/values-dev.yaml -n dev

7.4 Step 4 — Install PostgreSQL via Helm
helm install postgres k8s/helm/postgres -f k8s/helm/postgres/values-dev.yaml -n dev

7.5 Step 5 — Deploy Azure KeyVault CSI Driver Secrets
kubectl apply -f k8s/dev/secretproviderclass.yaml

7.6 Step 6 — Deploy Application Components

Includes:

✔ vote
✔ result
✔ worker
✔ seed-job

kubectl apply -f k8s/dev/

7.7 Step 7 — Deploy NGINX Ingress Controller
helm upgrade --install ingress-controller k8s/helm/ingress-controller -f k8s/helm/ingress-controller/values-dev.yaml -n dev

7.8 Step 8 — Deploy Application Ingress
helm upgrade --install dev-app-ingress k8s/helm/ingress -f k8s/helm/ingress/values-dev.yaml -n dev

📌 8. Phase 3 — CI/CD with GitHub Actions

GitHub workflows:

.github/workflows/
│── ci.yaml    # Build & push images → ACR
│── cd.yaml    # Deploy to AKS

📌 9. Required GitHub Secrets
9.1 Azure AD (Service Principal)
Secret	Description	Used In
AZURE_CLIENT_ID	App registration client ID	CI + CD
AZURE_TENANT_ID	Directory ID	CI + CD
AZURE_CLIENT_SECRET	Client secret	CI + CD
AZURE_SUBSCRIPTION_ID	Subscription ID	CI + CD
9.2 ACR Secrets
Secret	Description	Used In
ACR_NAME	ACR name	CI
ACR_LOGIN_SERVER	e.g. naderacr.azurecr.io	CI
ACR_USERNAME	Admin username	CI
ACR_PASSWORD	Admin password	CI
9.3 CD Secret (Created in Azure)
Secret	Purpose
github-cd-secret	Used by CD workflow to authenticate to Azure
📌 10. CI Pipeline (ci.yaml)

Runs on every push →
✔ Builds vote / result / worker / seed-job
✔ Tags with Git SHA
✔ Pushes to ACR

📌 11. CD Pipeline (cd.yaml)

Triggered after CI succeeds:

✔ Logs into Azure
✔ Gets kubeconfig
✔ Upgrades ingress + deployments
✔ Applies manifest updates

📌 12. Helper Commands
Check AKS Node Status
kubectl get nodes -o wide

Restart Deployment
kubectl rollout restart deployment vote -n dev

Check Pod Logs
kubectl logs -f <pod> -n dev

Test Ingress
curl http://<EXTERNAL_IP>/vote

Run Debug Pod
kubectl run -it --rm testpod --image=busybox -- sh

📌 13. Summary of Process

1️⃣ Clone repository
2️⃣ Install tools
3️⃣ Login to Azure
4️⃣ Apply Terraform to create AKS + ACR + KeyVault
5️⃣ Get kubeconfig
6️⃣ Deploy K8s resources
7️⃣ Install Helm charts (Redis, PostgreSQL, Ingress)
8️⃣ Configure GitHub Secrets
9️⃣ CI builds → pushes images
🔟 CD deploys to AKS automatically




Challenge over view and requirments:
# Voting Application - DevOps Challenge

## Project Overview

This is a distributed voting application that allows users to vote between two options and view real-time results. The application consists of multiple microservices that work together to provide a complete voting experience.

## Application Architecture

The voting application consists of the following components:

![Architecture Diagram](./architecture.excalidraw.png)

### Frontend Services
- **Vote Service** (`/vote`): Python Flask web application that provides the voting interface
- **Result Service** (`/result`): Node.js web application that displays real-time voting results

### Backend Services  
- **Worker Service** (`/worker`): .NET worker application that processes votes from the queue
- **Redis**: Message broker that queues votes for processing
- **PostgreSQL**: Database that stores the final vote counts

### Data Flow
1. Users visit the vote service to cast their votes
2. Votes are sent to Redis queue
3. Worker service processes votes from Redis and stores them in PostgreSQL
4. Result service queries PostgreSQL and displays real-time results via WebSocket

### Network Architecture
The application should use a **two-tier network architecture** for security and organization:

- **Frontend Tier Network**: 
  - Vote service (port 8080)
  - Result service (port 8081)
  - Accessible from outside the Docker environment

- **Backend Tier Network**:
  - Worker service
  - Redis
  - PostgreSQL
  - Internal communication only

This separation ensures that database and message queue services are not directly accessible from outside, while the web services remain accessible to users.

## Your Task

As a DevOps engineer, your task is to containerize this application and create the necessary infrastructure files. You need to create:

### 1. Docker Files
Create `Dockerfile` for each service:
- `vote/Dockerfile` - for the Python Flask application
- `result/Dockerfile` - for the Node.js application  
- `worker/Dockerfile` - for the .NET worker application
- `seed-data/Dockerfile` - for the data seeding utility

### 2. Docker Compose
Create `docker-compose.yml` that:
- Defines all services with proper networking using **two-tier architecture**:
  - **Frontend tier**: Vote and Result services (user-facing)
  - **Backend tier**: Worker, Redis, and PostgreSQL (internal services)
- Sets up health checks for Redis and PostgreSQL
- Configures proper service dependencies
- Exposes the vote service on port 8080 and result service on port 8081
- Uses the provided health check scripts in `/healthchecks` directory

### 3. Health Checks
The application includes health check scripts:
- `healthchecks/redis.sh` - Redis health check
- `healthchecks/postgres.sh` - PostgreSQL health check

Use these scripts in your Docker Compose configuration to ensure services are ready before dependent services start.

## Requirements

- All services should be properly networked using **two-tier architecture**:
  - **Frontend tier network**: Connect Vote and Result services
  - **Backend tier network**: Connect Worker, Redis, and PostgreSQL
  - Both tiers should be isolated for security
- Health checks must be implemented for Redis and PostgreSQL
- Services should wait for their dependencies to be healthy before starting
- The vote service should be accessible at `http://localhost:8080`
- The result service should be accessible at `http://localhost:8081`
- Use appropriate base images and follow Docker best practices
- Ensure the application works end-to-end when running `docker compose up`
- Include a seed service that can populate test data

## Data Population

The application includes a seed service (`/seed-data`) that can populate the database with test votes:

- **`make-data.py`**: Creates URL-encoded vote data files (`posta` and `postb`)
- **`generate-votes.sh`**: Uses Apache Bench (ab) to send 3000 test votes:
  - 2000 votes for option A
  - 1000 votes for option B

### How to Use Seed Data

1. Include the seed service in your `docker-compose.yml`
2. Run the seed service after all other services are healthy:
   ```bash
   docker compose run --rm seed
   ```
3. Or run it as a one-time service with a profile:
   ```bash
   docker compose --profile seed up
   ```

## Getting Started

1. Examine the source code in each service directory
2. Create the necessary Dockerfiles
3. Create the docker-compose.yml file with two-tier networking
4. Test your implementation by running `docker compose up`
5. Populate test data using the seed service
6. Verify that you can vote and see results in real-time

## Notes

- The voting application only accepts one vote per client browser
- The result service uses WebSocket for real-time updates
- The worker service continuously processes votes from the Redis queue
- Make sure to handle service startup order properly with health checks

Good luck with your challenge! 🚀
