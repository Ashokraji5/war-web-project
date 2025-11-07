pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: 'maven', type: 'maven'   // Name of Maven tool in Jenkins
        PATH = "${env.MAVEN_HOME}/bin:${env.PATH}"
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                git url: 'https://github.com/Ashokraji5/war-web-project.git', credentialsId: 'github-pat'
            }
        }

        stage('Build & Test with Maven') {
            steps {
                sh "mvn clean install -s ${MVN_SETTINGS} -DskipTests=false"
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {  // <-- Use Jenkins SonarQube server name here
                    sh "mvn sonar:sonar -s ${MVN_SETTINGS}"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Package & Upload WAR to Nexus') {
            steps {
                sh "mvn deploy -s ${MVN_SETTINGS}"
            }
        }

        stage('Docker Build Image from Nexus WAR') {
            steps {
                sh """
                docker build -t myapp:latest .
                """
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh "docker tag myapp:latest your-dockerhub-username/myapp:latest"
                    sh "docker push your-dockerhub-username/myapp:latest"
                }
            }
        }
    }

    post {
        success {
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
