pipeline {
    agent any

    tools {
        maven 'maven'   // Use Maven configured in Jenkins Global Tools
    }

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_USERNAME = 'ashokraji'
        VERSION = "1.0.${BUILD_NUMBER}"   // expands build number correctly
        DOCKER_IMAGE = "${DOCKER_USERNAME}/app:${VERSION}"
        SONARQUBE_TOKEN = credentials('sonarqube-token')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master',    // ✅ ensure this matches your repo branch
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh "mvn sonar:sonar -Dsonar.login=${SONARQUBE_TOKEN}"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
