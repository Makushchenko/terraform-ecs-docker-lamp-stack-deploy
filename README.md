# LAMP Stack on AWS ECS

This repository contains a LAMP (Linux, Apache, MySQL, PHP) stack deployed on AWS ECS using Terraform, with a local Docker Compose setup for development and testing.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) configured with appropriate credentials
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install)

## Repository Structure

```

├── lamp\_custom\_ecs\_cluster    # ECS cluster and services
│   ├── docker-compose.yaml    # Local development setup
│   ├── Dockerfile             # PHP application image
│   ├── ecs-cluster.tf         # ECS cluster definition
│   ├── main.tf                # ECS services (app, webserver, db)
│   └── ...                    # supporting configs (nginx, php, mysql)
├── nginx\_ecs\_ecr              # Nginx service pushed to ECR
│   ├── Dockerfile
│   ├── backend.tf             # S3 backend for Terraform state
│   ├── main.tf                # ECS task & service for nginx
│   └── ...
├── s3\_backend                 # Central S3 backend setup
│   └── main.tf
├── s3\_with\_file               # Static website bucket example
│   └── main.tf
├── lamp-stack-install.sh      # Wrapper script for full deployment
└── README.md                  # This guide

````

## Local Development & Testing

1. **Start the stack locally**
   ```bash
   cd lamp_custom_ecs_cluster
   docker-compose up -d
````

2. **Verify**

   * PHP app: [http://localhost](http://localhost)
   * MySQL: `docker exec -it db mysql -uroot -proot`
   * Logs: `docker-compose logs -f`
3. **Stop & cleanup**

   ```bash
   docker-compose down -v
   ```

## AWS Deployment with Terraform

1. **Configure S3 Backend**

   ```bash
   cd s3_backend
   terraform init
   terraform apply -auto-approve
   ```
2. **Deploy ECS Cluster & Services**

   ```bash
   cd ../lamp_custom_ecs_cluster
   terraform init
   terraform apply -auto-approve
   ```
3. **Push & Deploy Nginx Image**

   ```bash
   cd ../nginx_ecs_ecr
   terraform init
   terraform apply -auto-approve
   ```
4. **Optional: Static Website Bucket**

   ```bash
   cd ../s3_with_file
   terraform init
   terraform apply -auto-approve
   ```

## Full-stack Installer

Run the wrapper script to provision all components in sequence:

```bash
bash lamp-stack-install.sh
```

## Cleanup

To tear down resources:

```bash
# In each Terraform folder:
terraform destroy -auto-approve
```