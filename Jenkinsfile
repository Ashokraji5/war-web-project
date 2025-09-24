pipeline {
    agent any
    tools {
        maven 'Maven363'
    }
    environment {
        DOCKER_IMAGE = "yourdockerhubusername/wwp"
        DOCKER_TAG = "1.0.0"
    }
    options {
        timeout(10)
        buildDiscarder(logRotator(daysToKeepStr: '5', numToKeepStr: '5'))
    }
    stages {
        stage('Build Maven Project') {
            steps {
                sh "mvn clean package"
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                    """
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_IMAGE:$DOCKER_TAG
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            deleteDir()
        }
        failure {
            echo "Build failed!"
        }
        success {
            echo "Build and push successful!"
        }
    }
}
