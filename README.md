# MERN Stack Project with Terraform, Docker, Kubernetes, and Jenkins

This project is a **MERN Stack** application that integrates several tools and services including **Terraform**, **Docker**, **Kubernetes**, and **Jenkins** for a complete DevOps setup. The project includes frontend and backend services with monitoring and CI/CD automation.

## Prerequisites

Before you begin, make sure you have the following installed and configured:

- **AWS EC2 instances**
- **Docker**
- **Kubernetes**
- **Jenkins**
- **Terraform**
- **Prometheus & Grafana** (for monitoring)

## Project Structure

### AWS EC2 Infrastructure with Terraform

The infrastructure for this project is managed using **Terraform**. To set up the architecture, follow these steps:

1. Review and customize the **Terraform** files to suit your environment.
2. Initialize the Terraform directory by running:
    ```bash
    terraform init
    ```
3. Apply the configuration to create resources in AWS:
    ```bash
    terraform apply
    ```

This project utilizes **3 AWS EC2 instances**:

- **Master-node**: Acts as the **Kubernetes master-node**.
- **Worker-node**: Serves as the **Kubernetes worker-node**.
- **MongoDB instance**: Hosts the **MongoDB database**.

### Docker Setup

#### Frontend Docker Image

- The **frontend** Docker image can be built from the `frontend/Dockerfile` located in the frontend directory.
- Log in to Docker and upload the image to your Docker Hub.

#### Backend Docker Image

- Similarly, the **backend** Docker image is built using the `backend/Dockerfile` located in the backend directory.

Once both images are built, you can use the `docker-compose.yml` file located in the project’s root directory to bring up the entire application:

    ```bash
    docker-compose up -d
    ```

### Congratulations! Your MERN stack is now running!

## Kubernetes Setup

To run the project on **Kubernetes**, utilize the configuration files in the `k8s` directory. This setup includes:

- **Prometheus** and **Grafana** for monitoring.
- **Horizontal Pod Autoscaler (HPA)** for auto-scaling, adjusting Kubernetes pod replicas based on demand.

You can access **Grafana** at port `32000` to view project metrics and monitor your application.

To deploy the project on Kubernetes, run:


    ```bash
    kubectl apply -f /k8s
    ```

## Congratulations! Your project is now running on Kubernetes with auto-scaling.

---

## CI/CD with Jenkins

To integrate your project into a **CI/CD pipeline** using **Jenkins**:

1. Access the **Jenkins** server at port `8080`.
2. Set up a **GitHub Webhook** to trigger builds from your GitHub repository.
3. Install the necessary **Jenkins plugins** for **Docker** and **Kubernetes** support.
4. Create a **Jenkins pipeline** using the `Jenkinsfile` located in the project’s root directory to automate the entire process.

With Jenkins, you can easily automate deployments and manage your **CI/CD workflows**!

---

## Conclusion

By following the steps above, you can deploy and manage a **MERN stack** application with the full power of **Docker**, **Kubernetes**, **Terraform**, and **Jenkins**. Enjoy your automated and scalable **DevOps** environment!
