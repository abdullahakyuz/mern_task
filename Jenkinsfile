pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // Jenkins'teki Docker Hub kimlik bilgisi ID'si
        DOCKER_REPO = 'aakyuz1'                          // Docker Hub kullanıcı adınız
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Changes') {
            steps {
                script {
                    // Değişiklik yapılan dosyaları kontrol et
                    def changedFiles = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true).trim()
                    echo "Changed files:\n${changedFiles}"

                    // Değişiklik yapılan klasörlere göre bayrak belirle
                    env.FRONTEND_CHANGED = changedFiles.contains('frontend/')
                    env.BACKEND_CHANGED = changedFiles.contains('backend/')
                }
            }
        }

        stage('Build and Push Docker Images') {
            parallel {
                stage('Build Frontend Docker Image') {
                    when {
                        expression { return env.FRONTEND_CHANGED.toBoolean() }
                    }
                    steps {
                        dir('frontend') {
                            script {
                                def frontendImage = "${DOCKER_REPO}/mern_frontend:latest"
                                sh "docker build -t ${frontendImage} ."
                                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh "docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD"
                                    sh "docker push ${frontendImage}"
                                }
                            }
                        }
                    }
                }

                stage('Build Backend Docker Image') {
                    when {
                        expression { return env.BACKEND_CHANGED.toBoolean() }
                    }
                    steps {
                        dir('backend') {
                            script {
                                def backendImage = "${DOCKER_REPO}/mern_backend:latest"
                                sh "docker build -t ${backendImage} ."
                                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh "docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD"
                                    sh "docker push ${backendImage}"
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    if (env.FRONTEND_CHANGED.toBoolean()) {
                        echo 'Updating Frontend Deployment'
                        sh """
                        kubectl set image deployment/react-app-deployment react-app=${DOCKER_REPO}/mern_frontend:latest
                        kubectl rollout restart deployment/react-app-deployment
                        """
                    }

                    if (env.BACKEND_CHANGED.toBoolean()) {
                        echo 'Updating Backend Deployment'
                        sh """
                        kubectl set image deployment/express-backend-deployment expressjs-app=${DOCKER_REPO}/mern_backend:latest
                        kubectl rollout restart deployment/express-backend-deployment
                        """
                    }
                }
            }
        }

        stage('Cleanup Unused Resources') {
            steps {
                script {
                    // Docker temizleme
                    sh "docker image prune -a -f --filter 'until=24h'"

                    // Kubernetes temizleme
                    withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
                        sh "kubectl delete pod --field-selector=status.phase=Failed"
                        sh "kubectl delete pod --field-selector=status.phase=Succeeded"
                        sh """
                        kubectl get pods | grep Evicted | awk '{print \$1}' | xargs kubectl delete pod || true
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline başarıyla tamamlandı!'
        }
        failure {
            echo 'Pipeline başarısız oldu.'
        }
    }
}
