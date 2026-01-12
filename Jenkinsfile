pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = "us-east-1"

    // Jenkins Credentials
    SLACK_WEBHOOK_URL = credentials('')

    // Terraform inputs
    TF_VAR_aws_region = "us-east-1"
    TF_VAR_project_name = "observability-stack"

    // Set these two to match your environment
    TF_VAR_key_name = "ec2-jenkins-cicd"
    TF_VAR_allowed_ssh_cidr = "0.0.0.0/0"
  }

  stages {

    stage('Notify Start') {
      steps {
        script {
          slackNotify("Starting Terraform deploy for Prometheus, Grafana, Node Exporter, Alertmanager.")
        }
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh '''
            terraform version
            terraform init -input=false
          '''
        }
      }
    }

    stage('Terraform Format and Validate') {
      steps {
        dir('terraform') {
          sh '''
            terraform fmt -check
            terraform validate
          '''
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('terraform') {
          sh '''
            terraform plan -out=tfplan -input=false
          '''
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh '''
            terraform apply -input=false -auto-approve tfplan
          '''
        }
      }
    }

    stage('Show URLs') {
      steps {
        dir('terraform') {
          sh '''
            echo "Outputs:"
            terraform output
          '''
        }
      }
    }

    stage('Notify Success') {
      steps {
        script {
          slackNotify("Deploy succeeded. Prometheus and Grafana should be reachable. Check terraform outputs for URLs.")
        }
      }
    }
  }

  post {
    failure {
      script {
        slackNotify("Deploy failed. Check Jenkins console output for the failing step.")
      }
    }
  }
}

def slackNotify(String msg) {
  // Simple Slack webhook message using curl.
  // Keeps it plugin-free and easy to run anywhere.
  sh """
    curl -X POST -H 'Content-type: application/json' \
      --data '{\"text\": \"${msg}\"}' \
      ${SLACK_WEBHOOK_URL}
  """
}
