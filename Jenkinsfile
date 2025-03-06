pipeline {
    agent any
    environment {
        // Define your Docker Hub repository (username/repo-name)
        DOCKER_REPO = 'umar949/mlops'
        // Generate a tag based on the commit hash or default to 'latest'
        DOCKER_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        // Define the full path to Docker executable
        DOCKER_PATH = '/Applications/Docker.app/Contents/Resources/bin/docker'
    }
        
    triggers {
        githubPush() // GitHub webhook trigger
    }
    
    stages {
        stage('Verify Branch') {
            steps {
                script {
                    def branch = env.GIT_BRANCH ?: env.BRANCH_NAME
                    echo "Current branch: ${branch}"
                    
                    // Only run on dev branch
                    if (!(branch == 'origin/dev' || branch == 'dev')) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: not a push to dev branch. Current branch: ${branch}")
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
                    // Build Docker image
                    sh """
                    sudo ${DOCKER_PATH} build -t ${DOCKER_REPO}:${DOCKER_TAG} .
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Push image with commit hash tag and latest tag
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                        echo "$DOCKER_PASSWORD" | ${DOCKER_PATH} login -u "$DOCKER_USERNAME" --password-stdin
                        sudo ${DOCKER_PATH} push ${DOCKER_REPO}:${DOCKER_TAG}
                        sudo ${DOCKER_PATH} tag ${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REPO}:latest
                        sudo ${DOCKER_PATH} push ${DOCKER_REPO}:latest
                        """
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    // Remove local images to save disk space
                    sh """
                    sudo ${DOCKER_PATH} rmi ${DOCKER_REPO}:${DOCKER_TAG} || true
                    sudo ${DOCKER_PATH} rmi ${DOCKER_REPO}:latest || true
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
            // Clean up workspace
            cleanWs()
        }
    }
}
