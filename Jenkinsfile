pipeline {
    agent any

    environment {
        DOCKER_CRED = "docker-cred"
        SONARQUBE_CRED = "sonarqube-cred"
        GITHUB_CRED = "github-cred"
        KUBERNETES_CRED = "kubernetes-cred"
        SONARQUBE_HOST = "http://192.168.103.2:32000" // replace with your SonarQube URL
    }

    stages {

        stage("Checkout Code") {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'main', credentialsId: "${GITHUB_CRED}", url: 'https://github.com/ahmedsayedtalib/asto.git'
            }
            post {
                always { echo "GITHUB STAGE FINISHED" }
                success { echo "Successfully checked out code" }
                failure { echo "Failed to check out code" }
            }
        }

        stage("SonarQube Static Code Analysis") {
            steps {
                echo "Running SonarQube analysis..."
                withCredentials([string(credentialsId: "${SONARQUBE_CRED}", variable: 'SONARQUBE_TOKEN')]) {
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=asto \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONARQUBE_HOST} \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
            post {
                always { echo "SONARQUBE STAGE FINISHED" }
                success { echo "SonarQube analysis completed successfully" }
                failure { echo "SonarQube analysis failed" }
            }
        }

        stage("Install Requirements & Run Tests") {
            steps {
                echo "Setting up Python environment and running tests..."
                sh """
                    python3 -m venv venv
                    . venv/bin/activate && pip install --upgrade pip
                    . venv/bin/activate && pip install -r requirements.txt
                    . venv/bin/activate && pytest
                    . venv/bin/activate && pylint asto
                    . venv/bin/activate && flake8 asto
                    . venv/bin/activate && mypy asto
                """
            }
            post {
                always { echo "TESTS STAGE FINISHED" }
                success { echo "All tests and code checks passed successfully" }
                failure { echo "Tests or code checks failed" }
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                echo "Building and pushing Docker image..."
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "docker login -u $USERNAME -p $PASSWORD"
                    sh "docker build -t ahmedsayedtalib/asto ."
                    sh "docker push ahmedsayedtalib/asto"
                }
            }
            post {
                always { echo "DOCKER STAGE FINISHED" }
                success { echo "Docker image built and pushed successfully" }
                failure { echo "Docker build/push failed" }
            }
        }

        stage("Verify Kubernetes Deployment") {
            steps {
                echo "Listing pods in namespace dev..."
                sh "kubectl -n dev get pods"
            }
            post {
                always { echo "KUBERNETES VERIFICATION FINISHED" }
                success { echo "Pods listed successfully" }
                failure { echo "Failed to list pods" }
            }
        }

    } // stages
}
