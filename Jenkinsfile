pipeline {
    agent { label 'maven' }

    tools {
        maven 'maven'
    }

    environment {
        DOCKER_USERNAME = 'ashokraji'
        VERSION = "1.0.${BUILD_NUMBER}"
        DOCKER_IMAGE = "${DOCKER_USERNAME}/app:${VERSION}"
        MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Ashokraji5/war-web-project.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Set Maven Version') {
            steps {
                sh '''
                    mvn versions:set \
                        -DnewVersion=${VERSION} \
                        -DgenerateBackupPoms=false
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Deploy WAR to Nexus') {
            steps {
                sh '''
                    mvn deploy \
                        -s ${MVN_SETTINGS} \
                        -DskipTests=true
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t ${DOCKER_IMAGE} .
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([
                    credentialsId: 'dockerhub-credentials',
                    url: ''
                ]) {
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }
    }

    post {
        success {
            echo "Build ${BUILD_NUMBER} succeeded."
            echo "Maven version: ${VERSION}"
            echo "WAR: wwp-${VERSION}.war"
            echo "Docker image: ${DOCKER_IMAGE}"
        }

        failure {
            echo "Build ${BUILD_NUMBER} failed. Check Jenkins logs."
        }
    }
}
