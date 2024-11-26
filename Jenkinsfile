pipeline {
    agent any

    environment {
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
                            docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASSWORD}
                        """
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

        stage('Build, Tag, and Push Frontend') {
            steps {
                echo "Building, tagging, and pushing Frontend"
                script {
                    def frontendTag = "latest"
                    sh """
                        docker image build -t ${FRONTEND_IMAGE}:latest .
                        docker tag ${FRONTEND_IMAGE}:latest ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest
                        docker push ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:latest
                    """
                }
            }
        }

        stage('Build, Tag, and Push Backend') {
            steps {
                echo "Building, tagging, and pushing Backend"
                script {
                    def backendTag = "latest"
                    sh """
                        docker image build -t ${BACKEND_IMAGE}:latest .
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
                    if (env.FRONTEND_CHANGED == "true") {
                        echo "Restarting Frontend Deployment in Kubernetes..."
                        sh """
                            kubectl rollout restart deployment/react-app --namespace=${K8S_NAMESPACE}
                        """
                    }

                    if (env.BACKEND_CHANGED == "true") {
                        echo "Restarting Backend Deployment in Kubernetes..."
                        sh """
                            kubectl rollout restart deployment/expressjs-app --namespace=${K8S_NAMESPACE}
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
