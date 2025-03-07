pipeline {
    agent any
    environment {
        // Define the Docker Hub repository (username/repo-name)
        DOCKER_REPO = 'umar949/mlops'
        // Generate a tag based on the commit hash or default to 'latest'
        DOCKER_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        // Define the full path to Docker executable
        DOCKER_PATH = '/Applications/Docker.app/Contents/Resources/bin/docker'
        PATH = "/Applications/Docker.app/Contents/Resources/bin:${PATH}"
    }
        
    triggers {

        pullRequest(
            events: ['opened', 'synchronize', 'reopened', 'closed'],
            branches: ['main']
         )
         }
    
    stages {
        stage('Verify Merge to Main') {
            steps {
                script {
                    // Get the current branch and the target branch of the pull request
                    def currentBranch = env.GIT_BRANCH ?: env.BRANCH_NAME
                    def targetBranch = env.CHANGE_TARGET ?: 'main' // Default to 'main' if CHANGE_TARGET is not set

                    echo "Current branch: ${currentBranch}"
                    echo "Target branch: ${targetBranch}"

                    // Check if the target branch is 'main' and the source branch is 'test'
                    if (!(targetBranch == 'main' && currentBranch == 'test')) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: not a merge from 'test' to 'main'. Current branch: ${currentBranch}, Target branch: ${targetBranch}")
                    }
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                // Check out the code from the repository
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile in the project
                    sh """
                    sudo ${DOCKER_PATH} build -t ${DOCKER_REPO}:${DOCKER_TAG} .
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Push the Docker image with the commit hash tag and latest tag
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
                    // Remove local Docker images to save disk space
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
            // Clean up the workspace
            cleanWs()
        }
    }
}