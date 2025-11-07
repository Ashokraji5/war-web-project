pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube'                     
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_URL = 'http://107.20.13.206:8081/repository/jenkins-maven-release-role/'
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USER = '<your-dockerhub-username>'
        APP_GROUP = 'koddas.web.war'                   
        APP_NAME = 'wwp'                            
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/Ashokraji5/war-web-project.git'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh 'mvn clean install -DskipTests=false'
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=${APP_NAME} \
                        -Dsonar.host.url=http://54.89.190.20:9000 \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Package & Upload WAR to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh """
                    mvn clean deploy \
                        -DaltDeploymentRepository=nexus::default::http://${NEXUS_USER}:${NEXUS_PASS}@107.20.13.206:8081/repository/jenkins-maven-release-role/
                    """
                }
            }
        }

        stage('Docker Build Image from Nexus WAR') {
            steps {
                script {
                    // Extract version from pom.xml dynamically
                    def WAR_VERSION = sh(
