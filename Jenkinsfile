pipeline {
    agent any

    // Remove pollSCM, as it conflicts with GitHub webhooks
    triggers {
        githubPush() // This enables GitHub webhook trigger
    }

    stages {
        stage('Webhook Debug') {
            steps {
                script {
                    echo "Triggered by GitHub Webhook"
                    echo "Branch: ${env.GIT_BRANCH}"
                    echo "Commit: ${env.GIT_COMMIT}"
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    // More flexible branch matching
                    def branch = env.GIT_BRANCH ?: env.BRANCH_NAME
                    return branch == 'origin/dev' || branch == 'dev'
                }
            }
            steps {
                echo 'Hello, World! This is running on the dev branch via webhook :) x2'
            }
        }
    }
}