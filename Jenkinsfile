pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/ubuntu/.kube/config'
        FRONTEND_DIR = "frontend"
        BACKEND_DIR = "backend"
        FRONTEND_IMAGE = "react-app"
        BACKEND_IMAGE = "expressjs-app"
        K8S_NAMESPACE = "default"  // Kubernetes namespace, uygun şekilde güncellenebilir
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
                    echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin ${DOCKER_REGISTRY}
                """
                    }
                }
            }
        }

        stage('Determine Changes') {
            steps {
                script {
                    // Git değişikliklerini kontrol et
                    def changes = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true).trim()
                    env.FRONTEND_CHANGED = changes.contains("${FRONTEND_DIR}/")
                    env.BACKEND_CHANGED = changes.contains("${BACKEND_DIR}/")
                }
            }
        }

        stage('Build, Tag, and Push Frontend') {
            when {
                expression { env.FRONTEND_CHANGED.toBoolean() }
            }
            steps {
                echo "Building, tagging, and pushing Frontend"
                script {
                    sh """
                        docker image build -f Dockerfile -t mern_${FRONTEND_DIR}:latest
                        docker image tag mern_${FRONTEND_DIR}:latest 
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/mern_${FRONTEND_DIR}:latest
                    """
                }
            }
        }

        stage('Build, Tag, and Push Backend') {
            when {
                expression { env.BACKEND_CHANGED.toBoolean() }
            }
            steps {
                echo "Building, tagging, and pushing Backend"
                script {
                    sh """
                        docker image build -f Dockerfile -t mern_${BACKEND_DIR}:latest
                        docker image tag mern_${BACKEND_DIR}:latest 
                        docker push ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/mern_${BACKEND_DIR}:latest
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
                    // 30 saniye bekleme
                    sleep 30

                    echo "Force deleting old pods in terminating state"
                    try {
                        // Kubernetes komutlarını çalıştır
                        sh """
                            kubectl get pods --field-selector=status.phase=Terminating -o name | xargs kubectl delete --force --grace-period=0
                        """
                    } catch (Exception e) {
                        echo "Failed to delete terminating pods: ${e.getMessage()}"
                    }
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
