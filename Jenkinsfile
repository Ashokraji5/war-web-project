pipeline {
    agent { label 'linux' }

    tools {
        jdk 'jdk17'
        maven 'maven-3'
    }

    environment {
        APP_NAME   = "myapp"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        NEXUS_CFG  = "/var/lib/jenkins/.m2/settings.xml"
    }

    stages {
        stage('Build & Test') {
            steps {
                sh 'mvn clean compile test package'
            }
        }

        stage('Quality Checks') {
            parallel {
                stage('SonarQube') {
                    steps {
                        withSonarQubeEnv('sonarqube-server') {
                            sh 'mvn sonar:sonar'
                        }
                    }
                }
                stage('Trivy Scan') {
                    steps {
                        sh 'trivy fs --exit-code 1 --severity HIGH -o trivy-report.json ./target/*.war'
                    }
                }
            }
        }

        stage('Deploy & Docker') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds',
                                                 usernameVariable: 'NEXUS_USER',
                                                 passwordVariable: 'NEXUS_PASS')]) {
                    sh "mvn deploy -s $NEXUS_CFG"
                }
                sh 'cp ./target/*.war ./ROOT.war'
                sh "docker build -t $APP_NAME:$IMAGE_TAG ."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker tag $APP_NAME:$IMAGE_TAG $DOCKER_USER/$APP_NAME:$IMAGE_TAG"
                    sh "docker push $DOCKER_USER/$APP_NAME:$IMAGE_TAG"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
        }
    }
}
