pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📦 Checking out code..."
                git branch: 'main', url: 'https://github.com/your-repo/infrastructure.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    echo "🚀 Initializing and applying Terraform..."
                    sh '''
                    terraform init -input=false
                    terraform apply -auto-approve -input=false
                    terraform output -json > ../outputs.json
                    '''
                }
            }
        }

        stage('Update Bastion Security Group') {
            steps {
                echo "🔒 Updating Bastion SG to allow Jenkins IP..."
                sh '''
                python3 scripts/update_bastion_sg.py
                '''
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
                echo "⚙️ Running Ansible to configure servers..."
                sh '''
                ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --ssh-common-args='-F ansible/ssh_config'
                '''
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
