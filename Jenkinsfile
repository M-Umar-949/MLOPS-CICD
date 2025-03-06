pipeline {
    agent any
    environment {
        // Define your Docker Hub repository (username/repo-name)
        DOCKER_REPO = 'umar949/mlops'
        // Generate a tag based on the commit hash or default to 'latest'
        DOCKER_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        // Define the full path to Docker executable
        DOCKER_PATH = '/Applications/Docker.app/Contents/Resources/bin/docker'
        PATH = "/Applications/Docker.app/Contents/Resources/bin:${PATH}"
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
                    sudo /Applications/Docker.app/Contents/Resources/bin/docker build -t ${DOCKER_REPO}:${DOCKER_TAG} .
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
                        ${DOCKER_PATH} login -u "$DOCKER_USERNAME" --password-stdin <<< "$DOCKER_PASSWORD"
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
                    sudo /Applications/Docker.app/Contents/Resources/bin/docker rmi ${DOCKER_REPO}:${DOCKER_TAG} || true
                    sudo /Applications/Docker.app/Contents/Resources/bin/docker rmi ${DOCKER_REPO}:latest || true
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Docker image successfully built and pushed to Docker Hub!'
            emailext (
                subject: "Pipeline Success: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                The pipeline ${env.JOB_NAME} - Build #${env.BUILD_NUMBER} completed successfully.
                View the build details: ${env.BUILD_URL}
                """,
                to: 'umarrajput930@gmail.com'
            )
        }
        failure {
            echo 'Docker build or push failed  :('
            emailext (
                subject: "Pipeline Failed: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                The pipeline ${env.JOB_NAME} - Build #${env.BUILD_NUMBER} failed.
                View the build details: ${env.BUILD_URL}
                """,
                to: 'umarrajput930@gmail.com'
            )
        }
        
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}