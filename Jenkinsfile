pipeline {
    agent any

    environment {
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
                        docker image build -f ${FRONTEND_DIR}/Dockerfile -t ${FRONTEND_IMAGE}:${frontendTag} ${FRONTEND_DIR}
                        docker image tag ${FRONTEND_IMAGE}:${frontendTag} ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${frontendTag}
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${frontendTag}
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
                        docker image build -f ${BACKEND_DIR}/Dockerfile -t ${BACKEND_IMAGE}:${backendTag} ${BACKEND_DIR}
                        docker image tag ${BACKEND_IMAGE}:${backendTag} ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${BACKEND_IMAGE}:${backendTag}
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${BACKEND_IMAGE}:${backendTag}
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
