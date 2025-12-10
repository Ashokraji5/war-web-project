pipeline {
    agent { label 'linux' }

    tools {
        jdk 'jdk17'
        maven 'maven-3'
    }

    environment {
        APP_NAME     = "myapp"
        IMAGE_TAG    = "${BUILD_NUMBER}"
        NEXUS_CFG    = "/var/lib/jenkins/.m2/settings.xml"
        VERSION      = "1.0.0" // use 1.0.0-SNAPSHOT for dev builds
        DOCKER_USER  = "ashokraji"
        GIT_BRANCH   = "master"
        NEXUS_IP     = "100.27.216.116"
        NEXUS_REPO   = "jenkins-maven"   // aligned with pom.xml
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-pat-token'
            }
        }

        stage('Build & Test') {
            steps {
                sh "mvn clean compile test package -s $NEXUS_CFG"
            }
        }

        stage('Quality Checks') {
            parallel {
                stage('SonarQube') {
                    steps {
                        withSonarQubeEnv('sonarqube-server') {
                            sh "mvn sonar:sonar -s $NEXUS_CFG"
                        }
                    }
                }
                stage('Trivy Scan') {
                    steps {
                        sh 'trivy image alpine --download-db-only || true'
                        sh 'trivy fs --exit-code 1 --severity HIGH -o trivy-report.json ./target/*.war'
                    }
                }
            }
        }

        stage('Push WAR to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds',
                                                 usernameVariable: 'NEXUS_USER',
                                                 passwordVariable: 'NEXUS_PASS')]) {
                    sh "mvn deploy -s $NEXUS_CFG"
                }
            }
        }

        stage('Validate WAR in Nexus') {
            steps {
                script {
                    def WAR_URL = "http://${NEXUS_IP}:8081/repository/${NEXUS_REPO}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"
                    def status = sh(script: "curl --silent --head --fail $WAR_URL", returnStatus: true)
                    if (status != 0) {
                        error "❌ WAR file not accessible at $WAR_URL"
                    }
                }
            }
        }

        stage('Download & Rename WAR for Docker') {
            steps {
                script {
                    def WAR_URL = "http://${NEXUS_IP}:8081/repository/${NEXUS_REPO}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"
                    sh "mkdir -p target && curl -o target/${APP_NAME}-${VERSION}.war $WAR_URL"
                    sh "cp target/${APP_NAME}-${VERSION}.war ROOT.war"
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def DOCKER_IMAGE = "${DOCKER_USER}/${APP_NAME}:${IMAGE_TAG}"
                    sh "docker build -t $DOCKER_IMAGE ."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push $DOCKER_IMAGE"
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
            cleanWs()
        }
    }
}
