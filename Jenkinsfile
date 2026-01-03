pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: 'maven', type: 'maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
        DOCKER_USERNAME = 'ashokraji'
        VERSION = "1.0.${BUILD_NUMBER}"
    }

    stages {
        stage('Initialize variables') {
            steps {
                script {
                    IS_SNAPSHOT = VERSION.contains('SNAPSHOT')
                    NEXUS_REPO = IS_SNAPSHOT ? 'snapshots' : 'releases'
                    WAR_URL = "http://nexus.example.com/repository/${NEXUS_REPO}/com/example/app/${VERSION}/app-${VERSION}.war"
                    DOCKER_IMAGE = "ashokraji/app:${VERSION}"
                }
            }
        }

        stage('Checkout from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/ashokraji/app.git'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh "mvn clean package -s $MVN_SETTINGS -DskipTests=false"
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                sh "mvn sonar:sonar -s $MVN_SETTINGS"
            }
        }

        stage('Trivy Scan WAR') {
            steps {
                sh "trivy fs target/ --exit-code 1 --severity CRITICAL --output trivy-war-report.json"
            }
        }

        stage('Package & Upload WAR to Nexus') {
            steps {
                sh "mvn deploy -s $MVN_SETTINGS"
            }
        }

        stage('Validate WAR URL on Nexus') {
            steps {
                script {
                    def status = sh(script: "curl --silent --head --fail $WAR_URL", returnStatus: true)
                    if (status != 0) {
                        error "WAR file not found at ${WAR_URL}"
                    }
                }
            }
        }

        stage('Download WAR from Nexus') {
            steps {
                sh "mkdir -p target && curl -o target/app.war $WAR_URL"
            }
        }

        stage('Docker Build Image from WAR') {
            steps {
                sh """
                docker build --build-arg WAR_URL=$WAR_URL -t $DOCKER_IMAGE .
                """
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                sh "trivy image $DOCKER_IMAGE --exit-code 1 --severity CRITICAL --output trivy-image-report.json"
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh "docker push $DOCKER_IMAGE"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "target/app.war", fingerprint: true
            cleanWs()
        }
    }
}
