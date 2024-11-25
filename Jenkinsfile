pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/ubuntu/.kube/config'
        FRONTEND_DIR = "frontend"
        BACKEND_DIR = "backend"
        FRONTEND_IMAGE = "react-app"
        BACKEND_IMAGE = "expressjs-app"
        K8S_NAMESPACE = "default"  // Kubernetes namespace, uygun şekilde güncellenebilir
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
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

        stage('Build and Deploy Frontend') {
            when {
                expression { env.FRONTEND_CHANGED.toBoolean() }
            }
            steps {
                echo "Building and Deploying Frontend"
                script {
                    sh """
                        docker build -t ${FRONTEND_IMAGE}:latest ${FRONTEND_DIR}
                        docker stop ${FRONTEND_IMAGE} || true
                        docker rm ${FRONTEND_IMAGE} || true
                        docker run -d --name ${FRONTEND_IMAGE} -p 80:80 ${FRONTEND_IMAGE}:latest
                    """
                }
            }
        }

        stage('Build and Deploy Backend') {
            when {
                expression { env.BACKEND_CHANGED.toBoolean() }
            }
            steps {
                echo "Building and Deploying Backend"
                script {
                    sh """
                        docker build -t ${BACKEND_IMAGE}:latest ${BACKEND_DIR}
                        docker stop ${BACKEND_IMAGE} || true
                        docker rm ${BACKEND_IMAGE} || true
                        docker run -d --name ${BACKEND_IMAGE} -p 3000:3000 ${BACKEND_IMAGE}:latest
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
                            kubectl get pods --field-selector=status.phase=Terminating -o name | xargs kubectl delete
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
