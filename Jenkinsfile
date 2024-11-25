pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        DOCKER_REPO = 'aakyuz1'
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
                    // Geçici çözüm: tüm aşamalar çalıştırılacak
                    env.FRONTEND_CHANGED = true
                    env.BACKEND_CHANGED = true
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
                    withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
                        if (env.FRONTEND_CHANGED.toBoolean()) {
                            sh """
                            kubectl set image deployment/react-app-deployment react-app=${DOCKER_REPO}/mern_frontend:latest
                            kubectl rollout restart deployment/react-app-deployment
                            """
                        }
                        if (env.BACKEND_CHANGED.toBoolean()) {
                            sh """
                            kubectl set image deployment/express-backend-deployment expressjs-app=${DOCKER_REPO}/mern_backend:latest
                            kubectl rollout restart deployment/express-backend-deployment
                            """
                        }
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
