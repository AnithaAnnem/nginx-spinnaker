pipeline {
    agent any

    environment {
        SPINNAKER_WEBHOOK = "http://a45b1eea2d94d40d6afa2e1cfdaca2f9-317157311.us-east-1.elb.amazonaws.com/webhooks/webhook/webhook"
    }

    stages {

        stage('Checkout Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AnithaAnnem/nginx-spinnaker.git'
            }
        }

        stage('Read parameter.yaml') {
            steps {
                script {
                    echo "Reading parameter.yaml..."

                    // Read YAML file
                    def params = readYaml file: 'parameter.yaml'

                    // Convert YAML → JSON string
                    env.PARAM_JSON = groovy.json.JsonOutput.toJson(params)

                    echo "Parameters parsed:"
                    echo env.PARAM_JSON
                }
            }
        }

        stage('Trigger Spinnaker Pipeline') {
            steps {
                script {
                    echo "Triggering Spinnaker via Webhook..."

                    sh """
                    curl -X POST \
                    -H "Content-Type: application/json" \
                    ${SPINNAKER_WEBHOOK} \
                    -d '${env.PARAM_JSON}'
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Spinnaker pipeline triggered successfully!"
        }
        failure {
            echo "Failed to trigger Spinnaker pipeline"
        }
    }
}
