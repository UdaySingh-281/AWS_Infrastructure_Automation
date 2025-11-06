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

                        sh '''
                        terraform --version
                        terraform init -input=false
                        terraform plan -out=tfplan -input=false
                        terraform apply -auto-approve tfplan
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
                withCredentials([file(credentialsId: 'ssh-key', variable: 'SSH_KEY_PATH')]) {
                    echo "🧩 Generating SSH config file dynamically..."

                    sh '''
                    mkdir -p ~/.ssh
                    cp $SSH_KEY_PATH ~/.ssh/SlaveNode.pem
                    chmod 600 ~/.ssh/SlaveNode.pem

                    python3 scripts/generate_ssh_config.py
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                echo "⚙️ Running Ansible to configure servers..."

                dir('.') {
                    sh '''
                    ansible-playbook -i ansible/inventories/hosts.ini ansible/playbooks/site.yaml
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Verifying Nginx and MySQL setup..."
                sh '''
                ansible web -i ansible/inventories/hosts.ini -m shell -a "systemctl status nginx"
                ansible db -i ansible/inventories/hosts.ini -m shell -a "systemctl status mysql"
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