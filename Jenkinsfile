pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📦 Checking out code..."
                git branch: 'master', url: 'https://github.com/UdaySingh-281/AWS_Infrastructure_Automation.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir('terraform/envs/dev') {
                        echo "🚀 Initializing and applying Terraform..."

                        // Run terraform plan first for visibility
                        sh '''
                        # Ensure Terraform is installed
                        terraform --version

                        # Initialize Terraform
                        terraform init -input=false

                        # Show planned changes
                        terraform plan -out=tfplan -input=false

                        # Apply the plan
                        terraform apply -auto-approve tfplan

                        # Export outputs to JSON
                        terraform output -json > ../outputs.json
                        '''
                    }
                }
            }
        }
        
        stage('Update Bastion Security Group') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    echo "🔒 Updating Bastion SG to allow Jenkins IP..."
                    sh '''
                    pip3 install --no-cache-dir -r scripts/requirements.txt
                    aws sts get-caller-identity
                    python3 scripts/update_bastion_sg.py
                    '''
                }
            }
        }

        stage('Generate SSH Config') {
            steps {
                echo "🧩 Generating SSH config file dynamically..."
                sh '''
                python3 scripts/generate_ssh_config.py
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    echo "⚙️ Running Ansible to configure servers..."

                    dir('.'){
                        sh '''
                    ansible --version
                    ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --ssh-common-args='-F ansible/ssh_config'
                    '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Verifying Nginx and MySQL setup..."
                sh '''
                ansible web -i ansible/inventory.ini -m shell -a "systemctl status nginx"
                ansible db -i ansible/inventory.ini -m shell -a "systemctl status mysql"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Infrastructure deployed and configured successfully!"
        }
        failure {
            echo "❌ Pipeline failed — check Jenkins logs for details."
        }
    }
}
