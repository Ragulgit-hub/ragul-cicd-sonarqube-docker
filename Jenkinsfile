pipeline {
    agent any

    tools {
        maven 'MAVEN'
        jdk 'JAVA_HOME'
    }

    environment {
        DOCKER_IMAGE = "ragul/demoapp"
        DOCKER_TAG   = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checkout source code"
                git branch: 'main',
                    url: 'https://github.com/Ragulgit-hub/ragul-cicd-sonarqube-docker.git'
            }
        }

        stage('Build') {
            steps {
                echo "Build application"
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo "Run unit tests"
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Run SonarQube scan"
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
                echo "Waiting for SonarQube Quality Gate"
                timeout(time: 15, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "Build Docker image"
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Docker Push') {
            steps {
                echo "Push Docker image"
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
                echo "Deploy container"
                sh '''
                    docker rm -f ragul-app || true
                    docker run -d --name ragul-app -p 8080:8080 $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed due to Quality Gate or build error"
        }
    }
}
