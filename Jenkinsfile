pipeline {
    agent any

    tools {
        maven 'Maven3.9.11'   // Make sure this matches the Maven installation name in Jenkins "Global Tool Configuration"
    }

    environment {
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USER = '<your-dockerhub-username>'    // Replace with your actual DockerHub username
        APP_GROUP = 'koddas.web.war'                     // Maven groupId
        APP_NAME = 'wwp'                                 // Maven artifactId
        SONARQUBE_URL = "http://44.203.118.214:9000"
        NEXUS_URL = "http://54.164.217.128:8081/repository/jenkins-maven-release-role/"
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                git branch: 'master', url: 'https://github.com/Ashokraji5/war-web-project.git'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh 'mvn clean install -DskipTests=false'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // Make sure Jenkins SonarQube Server name is exactly "SonarQube"
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.host.url=${SONARQUBE_URL} \
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

        stage('Package & Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh """
                        mvn clean deploy \
                            -DaltDeploymentRepository=nexus::default::http://${NEXUS_USER}:${NEXUS_PASS}@54.164.217.128:8081/repository/jenkins-maven-release-role/
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def WAR_VERSION = sh(script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout", returnStdout: true).trim()

                    def WAR_URL = "${NEXUS_URL}${APP_GROUP.replace('.', '/')}/${APP_NAME}/${WAR_VERSION}/${APP_NAME}-${WAR_VERSION}.war"

                    echo "Building Docker image with WAR from Nexus: ${WAR_URL}"

                    sh """
                        docker build \
                            --build-arg WAR_URL=${WAR_URL} \
                            -t ${DOCKERHUB_USER}/${APP_NAME}:${BUILD_NUMBER} .
                    """
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKERHUB_USER}/${APP_NAME}:${BUILD_NUMBER}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
        success {
            echo "✅ Pipeline finished successfully!"
        }
        failure {
            echo "❌ Pipeline failed! Check logs."
        }
    }
}
