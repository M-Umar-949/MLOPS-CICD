pipeline {
    agent any

    triggers {
        pollSCM('* * * * *') // Polls SCM every minute
    }

    stages {
        stage('Debug Branch') {
            steps {
                script {
                    echo "Current Branch Name: ${env.BRANCH_NAME}"
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    return env.DETECTED_BRANCH == 'origin/dev'
                }
            }
            steps {
                echo 'Hello, World! This is running on the dev branch'
            }
        }

        // Optional: Add an else branch stage
        stage('Other Branches') {
            when {
                expression {
                    return env.BRANCH_NAME != 'dev'
                }
            }
            steps {
                echo "This is running on branch: ${env.BRANCH_NAME}"
            }
        }
    }
}