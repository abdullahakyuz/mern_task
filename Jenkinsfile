pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/ubuntu/.kube/config'
        FRONTEND_DIR = "frontend"
        BACKEND_DIR = "backend"
        FRONTEND_IMAGE = "mern_frontend"
        BACKEND_IMAGE = "mern_backend"
        K8S_NAMESPACE = "default"
        DOCKER_REGISTRY = "docker.io"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    echo "Logging into Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin ${DOCKER_REGISTRY}
                        """
                    }
                }
            }
        }

        stage('Determine Changes') {
            steps {
                script {
                    echo "Determining changes..."
                    def changes = sh(script: "git diff --name-only origin/main...HEAD", returnStdout: true).trim()
                    env.FRONTEND_CHANGED = changes.contains("${FRONTEND_DIR}/") ? "true" : "false"
                    env.BACKEND_CHANGED = changes.contains("${BACKEND_DIR}/") ? "true" : "false"
                    echo "Frontend Changed: ${env.FRONTEND_CHANGED}"
                    echo "Backend Changed: ${env.BACKEND_CHANGED}"
                }
            }
        }

        stage('Build, Tag, and Push Frontend') {
            when {
                expression { env.FRONTEND_CHANGED == "true" }
            }
            steps {
                echo "Building, tagging, and pushing Frontend"
                script {
                    sh """
                        docker build -t ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest .
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest
                    """
                }
            }
        }

        stage('Build, Tag, and Push Backend') {
            when {
                expression { env.BACKEND_CHANGED == "true" }
            }
            steps {
                echo "Building, tagging, and pushing Backend"
                script {
                    sh """
                        docker build -t ${DOCKER_USERNAME}/${BACKEND_IMAGE}:latest .
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${BACKEND_IMAGE}:latest
                    """
                }
            }
        }

        stage('Cleanup Unused Images') {
            steps {
                echo "Cleaning up unused Docker images"
                script {
                    sh """
                        docker image prune -f
                        docker container prune -f
                    """
                }
            }
        }

        stage('Force Delete Old Pods') {
            steps {
                echo "Waiting 30 seconds before force deleting old pods"
                script {
                    sleep 30
                    echo "Force deleting old pods in terminating state"
                    sh """
                        kubectl get pods --field-selector=status.phase=Terminating -o name | xargs kubectl delete --force --grace-period=0
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
    }
}
