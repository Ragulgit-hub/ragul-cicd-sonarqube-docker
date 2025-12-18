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
                git branch: 'main',
                    url: 'https://github.com/Ragulgit-hub/ragul-cicd-sonarqube-docker.git'
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

        stage('SonarQube Analysis + Quality Gate') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=ragul-cicd-sonarqube-docker \
                        -Dsonar.projectName=ragul-cicd-sonarqube-docker \
                        -Dsonar.qualitygate.wait=true
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Docker Push') {
            steps {
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
                sh '''
                    docker rm -f ragul-app || true
                    docker run -d --name ragul-app -p 8080:8080 $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully (Quality Gate PASSED)"
        }
        failure {
            echo "❌ Pipeline failed due to Quality Gate or build error"
        }
    }
}
