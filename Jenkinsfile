pipeline {
    agent any

    stages {
        stage('Determine Branch') {
            steps {
                script {
                    // Multiple methods to try and get the branch name
                    env.DETECTED_BRANCH = env.BRANCH_NAME ?: 
                        env.GIT_BRANCH ?: 
                        sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    
                    echo "Detected Branch: ${env.DETECTED_BRANCH}"
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    return env.DETECTED_BRANCH == 'dev' || env.DETECTED_BRANCH == 'origin/dev'
                }
            }
            steps {
                echo 'Hello, World! This is running on the dev'
            }
        }

        stage('Fallback') {
            when {
                expression {
                    return env.DETECTED_BRANCH != 'dev' && env.DETECTED_BRANCH != 'origin/dev'
                }
            }
            steps {
                echo "Current branch is: ${env.DETECTED_BRANCH}"
            }
        }
    }
}