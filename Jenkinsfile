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
                // Generate JSON report for Jenkins to archive
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

        // 🚀 New Docker Steps
        stage('Build Docker Image') {
            steps {
                script {
                    // Pull WAR from Nexus (example, adjust URL/path)
                    sh 'curl -u $NEXUS_USER:$NEXUS_PASS -o app.war http://nexus.example.com/repository/maven-releases/com/example/app/1.0/app-1.0.war'

                    // Copy WAR into Docker build context
                    sh 'cp app.war ./docker/'

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
                    sh 'docker tag myapp:latest $DOCKER_USER/myapp:latest'
                    sh 'docker push $DOCKER_USER/myapp:latest'
                }
            }
        }
    }
}
