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
        TRIVY_CACHE = '/var/lib/jenkins/trivy-cache' // custom cache dir
        TMPDIR = '/var/lib/jenkins/tmp'              // redirect tmp usage
    }

    stages {
        stage('Initialize Variables') {
            steps {
                script {
                    IS_SNAPSHOT = VERSION.contains("SNAPSHOT")
                    NEXUS_REPO = IS_SNAPSHOT ? 'maven-snapshots' : 'jenkins-maven-release-role'
                    WAR_URL = "http://34.228.30.244:8081/repository/${NEXUS_REPO}/koddas/web/war/wwp/${VERSION}/wwp-${VERSION}.war"
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

        stage('Trivy Scan WAR') {
            steps {
                // Fail only if CRITICAL vulnerabilities are found in WAR
                sh "trivy fs --exit-code 1 --severity CRITICAL --cache-dir $TRIVY_CACHE -o trivy-report-war.json ./target/*.war"
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

        stage('Validate WAR URL on Nexus') {
            steps {
                script {
                    def status = sh(script: "curl --silent --head --fail $WAR_URL", returnStatus: true)
                    if (status != 0) {
                        error "❌ WAR file not accessible at $WAR_URL"
                    }
                }
            }
        }

        stage('Download WAR from Nexus') {
            steps {
                sh "mkdir -p target && curl -o target/wwp-${VERSION}.war $WAR_URL"
            }
        }

        stage('Docker Build Image from Nexus WAR') {
            steps {
                sh """
                docker build --build-arg WAR_URL=$WAR_URL -t $DOCKER_IMAGE .
                """
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                // Fail only if CRITICAL vulnerabilities are found in Docker image
                sh "trivy image --exit-code 1 --severity CRITICAL --cache-dir $TRIVY_CACHE -o trivy-report-image.json $DOCKER_IMAGE"
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
            script {
                def warFile = "target/wwp-${VERSION}.war"
                if (fileExists(warFile)) {
                    archiveArtifacts artifacts: warFile, fingerprint: true
                    echo "📦 WAR file archived: ${warFile}"
                } else {
                    echo "⚠️ WAR file not found for archiving: ${warFile}"
                }
            }
            archiveArtifacts artifacts: 'trivy-report-*.json', fingerprint: true

            // ✅ Correct cleanup command
            sh "trivy clean --scan-cache"
            cleanWs(deleteDirs: true, notFailBuild: true)
        }
    }
}
