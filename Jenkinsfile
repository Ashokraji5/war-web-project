pipeline {
    agent any

    tools {
        jdk 'jdk17'       // JDK configured in Jenkins global tools
        maven 'maven-3'   // Maven configured in Jenkins global tools
    }

    stages {
        stage('Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
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
                // Scan the WAR file in target directory
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
                    // Copy WAR from Jenkins workspace into Docker build context
                    sh 'cp ./target/*.war ./docker/app.war'

                    // Build Docker image
                    sh 'docker build -t myapp:latest ./docker'
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag myapp:latest $DOCKER_USER/myapp:${BUILD_NUMBER}'
                    sh 'docker push $DOCKER_USER/myapp:${BUILD_NUMBER}'
                }
            }
        }
    }
}
