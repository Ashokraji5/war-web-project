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
        VERSION = '1.0.0' // Change to '1.0.0-SNAPSHOT' for dev builds
    }

    stages {
        stage('Initialize Variables') {
            steps {
                script {
                    IS_SNAPSHOT = VERSION.contains("SNAPSHOT")
                    NEXUS_REPO = IS_SNAPSHOT ? 'maven-snapshots' : 'jenkins-maven-release-role'
                    WAR_URL = "http://54.237.235.174:8081/repository/${NEXUS_REPO}/koddas/web/war/wwp/${VERSION}/wwp-${VERSION}.war"
                    DOCKER_IMAGE = "${DOCKER_USERNAME}/myapp:${VERSION}"
                }
            }
        }

        stage('Checkout from GitHub') {
            steps {
                git url: 'https://github.com/Ashokraji5/war-web-project.git', credentialsId: 'github-pat'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh "mvn clean package -s $MVN_SETTINGS -DskipTests=false"
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh "mvn sonar:sonar -s $MVN_SETTINGS"
                }
            }
        }

        stage('Package & Upload WAR to Nexus') {
            steps {
                script {
                    try {
                        sh "mvn deploy -s $MVN_SETTINGS"
                    } catch (err) {
                        error "❌ Maven deploy failed: ${err}"
                    }
                }
            }
        }

        stage('Verify WAR Exists') {
            steps {
                sh 'ls -l target'
            }
        }

        stage('Validate WAR URL') {
            steps {
                script {
                    def status = sh(script: "curl --silent --head --fail $WAR_URL", returnStatus: true)
                    if (status != 0) {
                        error "❌ WAR file not accessible at $WAR_URL"
                    }
                }
            }
        }

        stage('Docker Build Image from Nexus WAR') {
            steps {
                sh """
                docker build --build-arg WAR_URL=$WAR_URL -t $DOCKER_IMAGE .
                """
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
        success {
            archiveArtifacts artifacts: "target/wwp-${VERSION}.war", fingerprint: true
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
        always {
            cleanWs()
        }
    }
}
