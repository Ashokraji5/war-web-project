pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                // Pull the latest code from GitHub
                https://github.com/Ashokraji5/war-web-project.git
            }
        }
        stage('Build WAR') {
            steps {
                // Run Maven build to create the WAR file
                sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                // Build Docker image with the WAR file
                sh 'docker build -t yourdockerhubusername/your-image-name:latest .'
            }
        }
        stage('Push to Docker Hub') {
            steps {
                // Push Docker image to Docker Hub using withRegistry (automatically handles login)
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        sh 'docker push yourdockerhubusername/your-image-name:latest'
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up the workspace after each build to save space
            deleteDir()
        }
        failure {
            // Log when the build fails
            echo "Build failed!"
        }
        success {
            // Log when the build and push succeed
            echo "Build and push successful!"
        }
    }
}
