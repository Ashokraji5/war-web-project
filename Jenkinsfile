pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven-3'
    }

    stages {
        stage('Compile') {
            steps { sh 'mvn clean compile' }
        }

        stage('Unit Tests') {
            steps { sh 'mvn test' }
        }

        stage('Package') {
            steps { sh 'mvn package' }
        }

        stage('Code Quality - SonarQube') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH -f json -o trivy-report.json ./target/*.war'
            }
        }

        stage('Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds',
                                                 usernameVariable: 'NEXUS_USER',
                                                 passwordVariable: 'NEXUS_PASS')]) {
                    sh 'mvn deploy -s /var/lib/jenkins/.m2/settings.xml'
                }
            }
        }

        stage('Publish Reports') {
            steps {
                archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Copy WAR into Docker build context
                    sh 'cp ./target/*.war ./ROOT.war'
                    // Build Docker image
                    sh 'docker build -t myapp:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag myapp:${BUILD_NUMBER} $DOCKER_USER/myapp:${BUILD_NUMBER}'
                    sh 'docker push $DOCKER_USER/myapp:${BUILD_NUMBER}'
                }
            }
        }
    }
}
