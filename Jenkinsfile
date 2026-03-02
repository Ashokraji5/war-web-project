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
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
        SLACK_CHANNEL = '#devops-alerts'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Code Quality & Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv('SonarQubeServer') {
                            sh "mvn sonar:sonar -Dsonar.login=${SONARQUBE_TOKEN}"
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
                // Security scan with Trivy (fail if HIGH/CRITICAL vulnerabilities found)
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE}"
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
                sh "./deploy-dev.sh ${DOCKER_IMAGE}"
            }
        }

        stage('Deploy to QA Environment') {
            when {
                branch 'master'
            }
            steps {
                echo "Deploying ${DOCKER_IMAGE} to QA environment..."
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
                sh "./deploy-prod.sh ${DOCKER_IMAGE}"
            }
        }
    }

    post {
        success {
            slackSend(channel: SLACK_CHANNEL, message: "✅ Build ${BUILD_NUMBER} succeeded. Image: ${DOCKER_IMAGE}")
        }
        failure {
            slackSend(channel: SLACK_CHANNEL, message: "❌ Build ${BUILD_NUMBER} failed. Check Jenkins logs.")
        }
    }
}
