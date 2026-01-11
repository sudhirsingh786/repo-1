pipeline {
  agent any

  environment {
    TF_IN_AUTOMATION = "true"
    GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-sa-key')
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
          for /f "tokens=2" %%v in ('terraform version ^| findstr /i "Terraform v"') do (
            echo Terraform version for this run = %%v
          )
          echo ============================================
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        bat '''
          terraform init -input=false
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        bat '''
          terraform plan -input=false -out=tfplan
        '''
      }
    }

    stage('Approval') {
      when {
        anyOf {
          branch 'main'
          
          branch pattern: "(bucket|sa|pubsub|secret)-.*", comparator: "REGEXP"
        }
      }
      steps {
        input message: "Approve Terraform Apply for branch: %BRANCH_NAME% ?"
      }
    }

    stage('Terraform Apply') {
      when {
        anyOf {
          branch 'main'
          branch pattern: "bucket.*", comparator: "REGEXP"
        }
      }
      steps {
        bat '''
          terraform apply -input=false tfplan
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
