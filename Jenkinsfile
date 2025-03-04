pipeline {
    agent any

    triggers {
        pollSCM('* * * * *')
    }

    stages {
        stage('Build') {
            when {
                branch 'dev'
            }
            steps {
                echo 'Hello, World!'
            }
        }
    }
}