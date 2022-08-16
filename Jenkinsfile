pipeline {
    agent {
		label 'slavenode1'
	}	
    tools{
        maven 'maven'
        jdk 'jdk11'
        //ansible 'ansible'
        terraform 'terraform'
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        ANSIBLE_HOST_KEY_CHECKING="False"
    }
    stages{
        stage('scm checkout') {
            steps {
                git(credentialsId: 'jenkinscicdpat', url: 'https://github.com/ganesh5556/sailorawsproject.git')
            }
        }
        stage('build') {
            steps {
                sh '''
                  mvn clean verify
                '''
            }
        }
        stage('setup environment') {
            steps {
                sh '''
                  terraform init
                  terraform apply --auto-approve
                  terraform output "public_ip" > hosts
		  terraform destroy
                '''
            }
        }
       
    }
}
