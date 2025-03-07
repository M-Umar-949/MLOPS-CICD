pipeline {
    agent any
    environment {
        // Define your Docker Hub repository (username/repo-name)
        DOCKER_REPO = 'umar949/mlops_cicd'
        // Generate a tag based on the commit hash or default to 'latest'
        DOCKER_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
        // Define the full path to Docker executable
        DOCKER_PATH = '/Applications/Docker.app/Contents/Resources/bin/docker'
        PATH = "/Applications/Docker.app/Contents/Resources/bin:${PATH}"
        
    }
    
    triggers {
        githubPush() // GitHub webhook trigger for code changes
    }
    
    stages {
        stage('Verify Test to Main Merge') {
            steps {
                script {
                    // Get the current branch name
                    def branch = env.GIT_BRANCH ?: env.BRANCH_NAME
                    echo "Current branch: ${branch}"
                    
                    // First check: we should only be on main branch
                    if (!(branch == 'origin/main' || branch == 'main')) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: This should only run on main branch. Current branch: ${branch}")
                    }
                    
                    // Get the current commit hash
                    def currentCommit = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    echo "Current commit: ${currentCommit}"
                    
                    // Let's check if this is a merge commit
                    echo "Examining commit to verify it's a merge from test branch..."
                    
                    // Get the commit message to see if it mentions a merge from test
                    def commitMsg = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    echo "Commit message: ${commitMsg}"
                    
                    // Check how many parents this commit has (merge commits have 2+)
                    def parentCount = sh(script: 'git log -1 --pretty=%P | wc -w', returnStdout: true).trim().toInteger()
                    echo "Number of parent commits: ${parentCount}"
                    
                    if (parentCount < 2) {
                        // Not a merge commit
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: This doesn't appear to be a merge commit")
                    }
                    
                    // Get the parent commits
                    def parentCommits = sh(script: 'git log -1 --pretty=%P', returnStdout: true).trim().split(" ")
                    
                    // Determine the source branch of the merge
                    // The second parent is typically the branch being merged in
                    def sourceBranch = sh(
                        script: "git name-rev --name-only ${parentCommits[1]}", 
                        returnStdout: true
                    ).trim()
                    
                    echo "Source branch appears to be: ${sourceBranch}"
                    
                    // Check if the source branch contains 'test'
                    if (!sourceBranch.contains('test')) {
                        // It's a merge, but not from test branch
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: This is a merge to main, but not from the test branch")
                    }
                    
                    // For merge commits, check what files changed between the source branch and destination branch
                    def changedFiles = sh(
                        script: "git diff --name-only ${parentCommits[0]}...${parentCommits[1]}",
                        returnStdout: true
                    ).trim()
                    
                    echo "Files changed in this merge: ${changedFiles}"
                    
                    if (changedFiles.isEmpty()) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: No files changed in this merge")
                    }
                    
                    // Verify this is a recent merge by checking the timestamp
                    def mergeTimestamp = sh(
                        script: "git show -s --format=%ct ${currentCommit}",
                        returnStdout: true
                    ).trim().toLong()
                    
                    def currentTime = System.currentTimeMillis() / 1000
                    def ageInMinutes = (currentTime - mergeTimestamp) / 60
                    
                    echo "Merge age: ${ageInMinutes} minutes"
                    
                    // If the merge is older than a reasonable threshold (e.g., 60 minutes),
                    // it might not be related to the current CI run
                    if (ageInMinutes > 60) {
                        currentBuild.result = 'ABORTED'
                        error("Pipeline aborted: The merge commit is too old (${ageInMinutes} minutes). This might be a build triggered for another reason.")
                    }
                    
                    echo "✅ Verified: This is a recent merge from test branch to main branch - proceeding with build"
                }
            }
        }
        
        // Rest of your pipeline stages remain the same
        stage('Checkout Code') {
            steps {
                // Checkout the code from the repository
                checkout scm
                echo "Code checkout complete - ready to build"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image with tag: ${DOCKER_TAG}"
                    // Build Docker image using the provided Dockerfile
                    sh """
                    sudo ${DOCKER_PATH} build -t ${DOCKER_REPO}:${DOCKER_TAG} .
                    """
                    echo "Docker image built successfully"
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Preparing to push image to Docker Hub"
                    // Login to Docker Hub and push the image with both tags
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                        ${DOCKER_PATH} login -u "$DOCKER_USERNAME" --password-stdin <<< "$DOCKER_PASSWORD"
                        
                        echo "Pushing image with commit hash tag: ${DOCKER_TAG}"
                        sudo ${DOCKER_PATH} push ${DOCKER_REPO}:${DOCKER_TAG}
                        
                        echo "Tagging image as latest"
                        sudo ${DOCKER_PATH} tag ${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REPO}:latest
                        
                        echo "Pushing latest tag"
                        sudo ${DOCKER_PATH} push ${DOCKER_REPO}:latest
                        """
                    }
                    echo "Images successfully pushed to Docker Hub"
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    echo "Cleaning up local Docker images to free space"
                    // Remove local Docker images to save disk space
                    sh """
                    sudo ${DOCKER_PATH} rmi ${DOCKER_REPO}:${DOCKER_TAG} || true
                    sudo ${DOCKER_PATH} rmi ${DOCKER_REPO}:latest || true
                    """
                    echo "Cleanup complete"
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully! Docker image built and pushed to Docker Hub.'
            emailext (
                subject: "✅ Pipeline Success: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                Good news! The pipeline job ${env.JOB_NAME} (build #${env.BUILD_NUMBER}) has completed successfully.
                
                A new Docker image has been pushed to Docker Hub with the following tags:
                - ${DOCKER_REPO}:${DOCKER_TAG}
                - ${DOCKER_REPO}:latest
                
                You can view the build details here: ${env.BUILD_URL}
                """,
                to: 'umarrajput930@gmail.com'
            )
        }
        failure {
            echo '❌ Pipeline failed. Check the logs for details.'
            emailext (
                subject: "❌ Pipeline Failed: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                The pipeline job ${env.JOB_NAME} (build #${env.BUILD_NUMBER}) has failed.
                
                Please check the logs to identify the issue: ${env.BUILD_URL}console
                """,
                to: 'umarrajput930@gmail.com'
            )

        }
        always {
            // Always clean up workspace regardless of success/failure
            cleanWs()
            echo "Workspace cleaned"
        }
    }
}