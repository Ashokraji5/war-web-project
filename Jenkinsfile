pipeline {
    agent any

    tools {
        jdk 'jdk17'       // JDK configured in Jenkins global tools
        maven 'maven-3'   // Maven configured in Jenkins global tools
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-creds'
            }
        }

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
                // Archive Trivy report so it’s downloadable in Jenkins
                archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
            }
        }
    }
}
