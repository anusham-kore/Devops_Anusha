# CI/CD + Jenkins

Your strongest section.

## Key Concepts

- **Pipeline Stages**: Build, Test, Deploy.
- **Shared Libraries**: Reusable code in Jenkins.
- **Parallel Execution**: Run stages concurrently.
- **Artifact Management**: Store build outputs (e.g., JARs).
- **Rollback**: Revert to previous version.
- **Deployment Automation**: Automate releases.
- **Git Branching**: Feature branches, main, releases.

## Pipeline Example (Jenkinsfile)

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
    post {
        failure {
            echo 'Build failed'
        }
    }
}
```

## Real-Time Scenarios

- **Build Failed**: Check logs for compilation errors. Fix code or dependencies.
- **Deployment Failed**: Rollback with `kubectl rollout undo deployment/app`.
- **Jenkins Slave Offline**: Restart slave or check network. Use labels for redundancy.
- **Parallel Execution**: Run unit and integration tests simultaneously to save time.
- **Artifact Management**: Upload to Nexus; download in deploy stage.
- **Git Branching**: Merge feature to main; trigger pipeline on PR.