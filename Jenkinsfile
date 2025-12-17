pipeline {
    agent any

    tools {
        maven 'MAVEN'        // MUST match Global Tool Configuration
        jdk 'JAVA_HOME'     // MUST match Global Tool Configuration
    }

    environment {
        DOCKER_IMAGE = "raguldochub/ragul-cicd-app"
        DOCKER_TAG   = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Cloning source code from GitHub"
                git branch: 'main',
                    url: 'https://github.com/Ragulgit-hub/ragul-cicd-sonarqube-docker.git'
            }
        }

        stage('Build') {
            steps {
                echo "🔨 Building the project"
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Running unit tests"
                sh 'mvn test'
            }
        }

        stage('SonarQube Scan') {
            steps {
                echo "🔍 Running SonarQube analysis"
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=ragul-cicd-sonarqube-docker \
                        -Dsonar.projectName=ragul-cicd-sonarqube-docker
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo "🚦 Waiting for Quality Gate"
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image"
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Docker Push') {
            steps {
                echo "📤 Pushing image to DockerHub"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "🚀 Deploying application"
                sh '''
                    docker rm -f ragul-app || true
                    docker run -d --name ragul-app -p 8080:8080 $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check logs."
        }
    }
}
