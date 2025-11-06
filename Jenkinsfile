pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube'                  // Name you added under Manage Jenkins → Configure System
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS = 'http://<NEXUS_IP>:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        APP_NAME = "myapp"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-user>/<your-repo>.git'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn sonar:sonar \
                        -Dsonar.projectKey=${APP_NAME} \
                        -Dsonar.host.url=http://<SONARQUBE_IP>:9000 \
                        -Dsonar.login=${SONARQUBE_TOKEN}"
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

        stage('Package & Upload to Nexus') {
            steps {
                sh "mvn clean deploy -DaltDeploymentRepository=nexus::default::${NEXUS}"
            }
        }

        stage('Docker Build Image') {
            steps {
                sh """
                wget ${NEXUS}/${APP_NAME}/${APP_NAME}-${IMAGE_TAG}.war -O app.war
                docker build -t <your-dockerhub-username>/${APP_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push <your-dockerhub-username>/${APP_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
    }
}
