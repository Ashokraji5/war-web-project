pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_USERNAME = 'ashokraji'
        VERSION = "1.0.${BUILD_NUMBER}"
        DOCKER_IMAGE = "${DOCKER_USERNAME}/app:${VERSION}"
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build & Deploy to Nexus') {
            steps {
                // Build WAR
                sh "mvn clean package -DskipTests=true"

                // Optional: deploy to Nexus
                sh "mvn deploy -s ${MVN_SETTINGS} -DskipTests=true"
            }
        }

        stage('Docker Build & Scan') {
            steps {
                // Build Docker image using WAR from target/
                sh "docker build -t ${DOCKER_IMAGE} ."

                // Scan for vulnerabilities
                sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${DOCKER_IMAGE}"
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build ${BUILD_NUMBER} succeeded. Image: ${DOCKER_IMAGE}"
        }
        failure {
            echo "❌ Build ${BUILD_NUMBER} failed. Check Jenkins logs."
        }
    }
}
