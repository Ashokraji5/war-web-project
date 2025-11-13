environment {
    MAVEN_HOME = tool name: 'maven', type: 'maven'
    PATH = "${env.MAVEN_HOME}/bin:${env.PATH}"
    SONARQUBE_TOKEN = credentials('sonarqube-token')
    NEXUS_CREDENTIALS = credentials('nexus-credentials')
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    MVN_SETTINGS = '/var/lib/jenkins/.m2/settings.xml'
    WAR_URL = 'http://54.237.235.174:8081/repository/jenkins-maven-release-role/koddas/web/war/wwp/1.0.0/wwp-1.0.0.war'
    DOCKER_USERNAME = 'ashokraji'
    DOCKER_IMAGE = "$DOCKER_USERNAME/myapp:latest"
}

stages {
    stage('Checkout from GitHub') {
        steps {
            git url: 'https://github.com/Ashokraji5/war-web-project.git', credentialsId: 'github-pat'
        }
    }

    stage('Build & Test with Maven') {
        steps {
            sh "$MAVEN_HOME/bin/mvn clean install -s $MVN_SETTINGS -DskipTests=false"
        }
    }

    stage('Code Quality - SonarQube Analysis') {
        steps {
            withSonarQubeEnv('SonarQubeServer') {
                sh "$MAVEN_HOME/bin/mvn sonar:sonar -s $MVN_SETTINGS"
            }
        }
    }

    stage('Package & Upload WAR to Nexus') {
        steps {
            sh "$MAVEN_HOME/bin/mvn deploy -s $MVN_SETTINGS"
        }
    }

    stage('Docker Build Image from Nexus WAR') {
        steps {
            // Ensure that the WAR file URL is correct and accessible from Nexus
            sh """
            docker build --build-arg WAR_URL=$WAR_URL -t myapp:latest .
            """
        }
    }

    stage('Push Docker Image to DockerHub') {
        steps {
            withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                sh 'docker tag myapp:latest $DOCKER_IMAGE'
                sh 'docker push $DOCKER_IMAGE'
            }
        }
    }
}

post {
    success {
        // Archive the WAR file from Nexus or from the target directory directly
        archiveArtifacts artifacts: 'target/wwp-1.0.0.war', fingerprint: true
        echo "✅ Pipeline completed successfully!"
    }
    failure {
        echo "❌ Pipeline failed. Check logs for details."
    }
    always {
        // Cleaning up the workspace after everything is done, so no data loss occurs
        cleanWs()
    }
}
