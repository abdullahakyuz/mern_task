# MERN Stack Project with Terraform, Docker, Kubernetes, and Jenkins

This project is a **MERN Stack** application that integrates several tools and services including **Terraform**, **Docker**, **Kubernetes**, and **Jenkins** for a complete DevOps setup. The project includes frontend and backend services with monitoring and CI/CD automation.

## Prerequisites

- AWS EC2 instances
- Docker
- Kubernetes
- Jenkins
- Terraform
- Prometheus & Grafana (for monitoring)

## Project Structure

### AWS EC2 Infrastructure with Terraform

The infrastructure for this project is managed using **Terraform**. To set up the architecture, follow these steps:

1. Review and customize the **Terraform** files to suit your environment.
2. Run `terraform init` to initialize the working directory.
3. Run `terraform apply` to create the resources in AWS.

This project utilizes **3 AWS EC2 instances**:
- One EC2 instance acts as the **Kubernetes master-node**.
- Another EC2 instance serves as the **worker-node**.
- The third EC2 instance hosts the **MongoDB** database.

### Docker Setup

- The **frontend** Docker image can be built from the `frontend/Dockerfile` located in the frontend directory. 
  - Log in to Docker, and upload the image to your Docker Hub.
  
- Similarly, the **backend** Docker image is built using the `backend/Dockerfile` in the backend directory.

Once the images are ready, use the `docker-compose.yml` file located in the project’s root directory to bring up the application:

```bash
docker-compose up
