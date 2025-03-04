pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {
        stage('Build') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo 'Hello, World!'
                    } else {
                        echo 'Skipped as the branch is not dev'
                    }
                }
            }
        }
    }
}
