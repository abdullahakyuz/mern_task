pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "mern_frontend"
        BACKEND_IMAGE = "mern_backend"
        K8S_NAMESPACE = "default"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_USERNAME = 'aakyuz1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        echo "Logging into Docker Hub..."
                        sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
                    }
                }
            }
        }

        stage('Setup KUBECONFIG') {
            steps {
                echo "Setting up KUBECONFIG..."
                withCredentials([file(credentialsId: 'kubeconfig-credential-id', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                        mkdir -p ~/.kube
                        cp ${KUBECONFIG_FILE} ~/.kube/config
                    """
                }
            }
        }

        stage('Check for Changes') {
            steps {
                script {
                    // Checking if any changes exist in frontend or backend directories
                    def changes = sh(script: 'git diff --name-only HEAD~1', returnStdout: true).trim()
                    echo "Changes: ${changes}"

                    // Default to false if there are no changes detected
                    env.FRONTEND_CHANGED = changes.contains('frontend') ? "true" : "false"
                    env.BACKEND_CHANGED = changes.contains('backend') ? "true" : "false"

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
                    def frontendTag = "latest"
                    sh """
                        docker image build -t ${FRONTEND_IMAGE}:latest ./frontend
                        docker tag ${FRONTEND_IMAGE}:latest ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest
                        docker push ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest
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
                    def backendTag = "latest"
                    sh """
                        docker image build -t ${BACKEND_IMAGE}:latest ./backend
                        docker tag ${BACKEND_IMAGE}:latest ${DOCKER_USERNAME}/${BACKEND_IMAGE}:latest
                        docker push ${DOCKER_USERNAME}/${BACKEND_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                anyOf {
                    expression { env.FRONTEND_CHANGED == "true" }
                    expression { env.BACKEND_CHANGED == "true" }
                }
            }
            steps {
                script {
                    echo "Deploy to Kubernetes started"

                    if (env.FRONTEND_CHANGED == "true") {
                        echo "Restarting Frontend Deployment in Kubernetes..."
                        sh """
                            set -e
                            kubectl rollout restart deployment/react-app --namespace=${K8S_NAMESPACE} || echo "Failed to restart frontend deployment"
                        """
                    }

                    if (env.BACKEND_CHANGED == "true") {
                        echo "Restarting Backend Deployment in Kubernetes..."
                        sh """
                            set -e
                            kubectl rollout restart deployment/expressjs-app --namespace=${K8S_NAMESPACE} || echo "Failed to restart backend deployment"
                        """
                    }
                }
            }
        }

        stage('Cleanup Unused Images') {
            steps {
                echo "Cleaning up unused Docker images"
                script {
                    sh """
                        docker system prune -af
                        docker volume prune -f
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
                        kubectl get pods --namespace=${K8S_NAMESPACE} --field-selector=status.phase=Terminating -o name | xargs -r kubectl delete --force --grace-period=0
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
            script {
                echo "Cleaning up KUBECONFIG..."
                sh 'rm -f ~/.kube/config'
            }
        }
    }
}
