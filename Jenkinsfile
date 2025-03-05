pipeline {
    agent any
    
    environment {
        // Define Docker Hub credentials ID from Jenkins credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        // Define your Docker Hub repository (username/repo-name)
        DOCKER_REPO = 'umar949/mlops'
        // Generate a tag based on the commit hash or build number
        DOCKER_TAG = "${env.GIT_COMMIT.take(7)}"
    }
    
    triggers {
        githubPush() // GitHub webhook trigger
    }
    
    stages {
        stage('Verify Branch') {
            steps {
                script {
                    // Ensure the job only runs on merge to main
                    def branch = env.GIT_BRANCH ?: env.BRANCH_NAME
                    if (!(branch == 'origin/main' || branch == 'main')) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: not merging to main branch")
                    }
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using the Dockerfile in the project
                    sh """
                        docker build -t ${DOCKER_REPO}:${DOCKER_TAG} .
                    """
                }
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using Jenkins credentials
                    sh """
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Push image with commit hash tag
                    sh """
                        docker push ${DOCKER_REPO}:${DOCKER_TAG}
                        
                        # Also tag and push as latest
                        docker tag ${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REPO}:latest
                        docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    // Remove local images to save disk space
                    sh """
                        docker rmi ${DOCKER_REPO}:${DOCKER_TAG}
                        docker rmi ${DOCKER_REPO}:latest
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Docker image successfully built and pushed to Docker Hub!'
        }
        failure {
            echo 'Docker build or push failed'
        }
        always {
            // Logout from Docker Hub
            sh 'docker logout'
            
            // Clean up workspace
            cleanWs()
        }
    }
}