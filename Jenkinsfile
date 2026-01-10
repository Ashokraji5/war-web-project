pipeline {
    agent any

    environment {
        DOCKER_USERNAME = 'ashokraji'
        VERSION = "1.0.${BUILD_NUMBER}"   // expands build number correctly
        DOCKER_IMAGE = "${DOCKER_USERNAME}/app:${VERSION}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/ashokraji/myapp.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully. Image pushed: ${DOCKER_IMAGE}"
        }
        failure {
            echo "❌ Pipeline failed. Please check logs."
        }
    }
}
