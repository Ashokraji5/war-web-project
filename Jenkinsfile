pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube'                     // SonarQube name in Jenkins config
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_URL = 'http://<NEXUS_IP>:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USER = '<your-dockerhub-username>'
        APP_GROUP = 'com/example'                   // Update to your actual Maven groupId path
        APP_NAME = 'wwp'                            // Update to match your artifactId
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-user>/<your-repo>.git'
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
                        -Dsonar.host.url=http://<SONARQUBE_IP>:9000 \
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
                sh "mvn clean deploy -DaltDeploymentRepository=nexus::default::${NEXUS_URL}"
            }
        }

        stage('Docker Build Image from Nexus WAR') {
            steps {
                script {
                    // Extract version from pom.xml dynamically
                    def WAR_VERSION = sh(
                        script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout",
                        returnStdout: true
                    ).trim()

                    // Compose Nexus WAR download URL
                    def WAR_URL = "${NEXUS_URL}${APP_GROUP.replace('.', '/')}/${APP_NAME}/${WAR_VERSION}/${APP_NAME}-${WAR_VERSION}.war"

                    echo "Building Docker image using WAR from Nexus: ${WAR_URL}"

                    // Build Docker image, passing WAR_URL as argument
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
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
