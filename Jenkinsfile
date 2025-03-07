pipeline {
    agent any

    environment {
        DOCKER_REPO = 'umar949/mlops'
        DOCKER_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        DOCKER_PATH = '/Applications/Docker.app/Contents/Resources/bin/docker'
        PATH = "/Applications/Docker.app/Contents/Resources/bin:${PATH}"
    }

    stages {
        stage('Verify Merge to Main') {
            when {
                allOf {
                    branch 'main'
                    changeset "**"  // Ensures pipeline triggers on changes
                }
            }
            steps {
                script {
                    def sourceBranch = env.CHANGE_BRANCH ?: env.GIT_BRANCH
                    def targetBranch = env.CHANGE_TARGET ?: 'main'

                    echo "Source Branch: ${sourceBranch}"
                    echo "Target Branch: ${targetBranch}"

                    if (sourceBranch != 'test' || targetBranch != 'main') {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: Only merges from 'test' to 'main' are allowed.")
                    }
                }
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    sudo ${DOCKER_PATH} build -t ${DOCKER_REPO}:${DOCKER_TAG} .
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
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
            cleanWs()
        }
    }
}
