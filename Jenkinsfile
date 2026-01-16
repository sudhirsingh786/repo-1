pipeline {
  agent any

  environment {
    TF_IN_AUTOMATION = "true"
    GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-sa-key')
    TF_BIN = "E:\\aws\\terraform\\tf-diff-versions\\tf_1-0\\terraform.exe"
     
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Show Terraform Version') {
      steps {
        bat '''
          echo ============================================
          "%TF_BIN%" version
          echo ============================================
    
          where terraform
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        bat '''
          "%TF_BIN%" init -input=false
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        bat '''
          "%TF_BIN%" plan -input=false -out=tfplan
        '''
      }
    }

    stage('Approval') {
      steps {
        input message: "Approve Terraform Apply for branch: %BRANCH_NAME% ?"
      }
    }

    stage('Terraform Apply') {
      steps {
        bat '''
          "%TF_BIN%" apply -input=false tfplan
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tfplan', fingerprint: true
    }
  }
}
