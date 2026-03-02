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
                sh "mvn clean package -DskipTests=true"
                sh "mvn deploy -s ${MVN_SETTINGS} -DskipTests=true"
            }
        }

        stage('Docker Build & Scan') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
                // Trivy scan reports vulnerabilities but does not fail the pipeline
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

        stage('Deploy to Dev Environment') {
            steps {
                echo "Deploying ${DOCKER_IMAGE} to Dev environment..."
                // Add a placeholder script in your repo: deploy-dev.sh
                sh "./deploy-dev.sh ${DOCKER_IMAGE}"
            }
        }

        stage('Deploy to QA Environment') {
            when {
                branch 'master'
            }
            steps {
                echo "Deploying ${DOCKER_IMAGE} to QA environment..."
                // Add a placeholder script in your repo: deploy-qa.sh
                sh "./deploy-qa.sh ${DOCKER_IMAGE}"
            }
        }

        stage('Deploy to Prod Environment') {
            when {
                branch 'master'
            }
            steps {
                input message: "Approve deployment to Production?"
                echo "Deploying ${DOCKER_IMAGE} to Production..."
                // Add a placeholder script in your repo: deploy-prod.sh
                sh "./deploy-prod.sh ${DOCKER_IMAGE}"
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
