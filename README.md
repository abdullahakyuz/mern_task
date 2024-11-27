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

1. **Frontend Docker Image**:
    - The **frontend** Docker image can be built from the `frontend/Dockerfile` located in the frontend directory.
    - Log in to Docker, and upload the image to your Docker Hub.

2. **Backend Docker Image**:
    - Similarly, the **backend** Docker image is built using the `backend/Dockerfile` in the backend directory.

Once the images are ready, use the `docker-compose.yml` file located in the project’s root directory to bring up the application:

```bash
docker-compose up

Congratulations! Your MERN stack is now running!
Kubernetes Setup

To run the project on Kubernetes, utilize the files in the k8s directory:

    The project is configured with Kubernetes, Prometheus, and Grafana for monitoring.
    Access Grafana at port 32000 to view project metrics and monitor your application.
    The Horizontal Pod Autoscaler (HPA) is used for auto-scaling, adjusting Kubernetes pod replicas based on demand.

To deploy the project on Kubernetes, run the following command:

kubectl apply -f /k8s

Congratulations! Your project is now running on Kubernetes with auto-scaling.
CI/CD with Jenkins

Integrate your project into a CI/CD pipeline using Jenkins:

    Access the Jenkins server at port 8080.
    Set up a GitHub Webhook to trigger builds from your GitHub repository.
    Install necessary Jenkins plugins for Docker and Kubernetes support.
    Create a Jenkins pipeline using the Jenkinsfile located in the project’s root directory to automate the entire process.

With Jenkins, you can easily automate deployments and manage your CI/CD workflows!
Conclusion

By following the steps above, you can deploy and manage a MERN stack application with the full power of Docker, Kubernetes, Terraform, and Jenkins. Enjoy your automated and scalable DevOps environment!
