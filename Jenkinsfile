pipeline {
    agent any

    tools {
        // This must match the Maven installation name in Jenkins Global Tool Configuration
        maven 'maven'
    }

    environment {
        APP_NAME    = "sample-app"       // Non-sensitive
        TOMCAT_HOST = "tomcat-server"    // Non-sensitive
        TOMCAT_PORT = "8081"             // Non-sensitive
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Ashokraji5/war-web-project.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/target/*.war', fingerprint: true
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'tomcat-cred',
                                                 usernameVariable: 'TOMCAT_USER',
                                                 passwordVariable: 'TOMCAT_PASS')]) {
                    sh """
                    curl -u $TOMCAT_USER:$TOMCAT_PASS \
                         "http://$TOMCAT_HOST:$TOMCAT_PORT/manager/text/deploy?path=/$APP_NAME&update=true" \
                         --upload-file target/$APP_NAME.war
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished!'
        }
    }
}
