pipeline {
    agent any

    triggers {
        pollSCM('* * * * *') // Polls SCM every minute
    }

    stages {
        stage('Build') {
            when {
                expression {
                    return env.BRANCH_NAME == 'dev'
                }
            }
            steps {
                echo 'Hello, World! This is running on the dev branch'
            }
        }
    }
}
