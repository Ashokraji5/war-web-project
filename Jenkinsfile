pipeline {
    agent any

    tools {
        maven 'maven'   // Name of Maven installation in Jenkins
        
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
        }

        stage('Deploy') {
            steps {
                sh '''
                # Example: copy WAR file to Tomcat server
                cp target/myapp.war /opt/tomcat/webapps/
                '''
            }
        }
    }

    post {
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Pipeline failed. Check logs!'
        }
    }
}
