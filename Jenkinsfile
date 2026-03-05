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
        SONARQUBE_TOKEN = credentials('sonarqube-token')   // Jenkins SonarQube server config name
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

        stage('Build WAR') {
            steps {
                sh "mvn clean package -DskipTests=true"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBEsERVER}") {
                    sh "mvn sonar:sonar -DskipTests=true"
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                sh "mvn deploy -s ${MVN_SETTINGS} -DskipTests=true"
            }
        }

        stage('Docker Build & Scan') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
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
