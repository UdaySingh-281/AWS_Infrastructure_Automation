pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out code..."
                git branch: 'master', url: 'https://github.com/UdaySingh-281/AWS_Infrastructure_Automation.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir('terraform/envs/dev') {
                        echo "Initializing and applying Terraform..."

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
                    echo "Updating Bastion SG to allow Jenkins IP..."
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
                    echo "Generating SSH config file dynamically..."

                    sh '''
                    mkdir -p ~/.ssh
                    cp $SSH_KEY_PATH ~/.ssh/SlaveNode.pem
                    chmod 600 ~/.ssh/SlaveNode.pem

                    # Always overwrite old SSH config
                    rm -f ~/.ssh/config
                    python3 scripts/generate_ssh_config.py
                    chown -R jenkins:jenkins /var/lib/jenkins/.ssh
                    chmod 600 /var/lib/jenkins/.ssh/config

                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                echo "Running Ansible to configure servers..."

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir('ansible') {
                        sh '''
                        # Clean up known hosts
                        rm -f /var/lib/jenkins/.ssh/known_hosts
                        touch /var/lib/jenkins/.ssh/known_hosts
                        chmod 600 /var/lib/jenkins/.ssh/known_hosts

                        mkdir -p /var/lib/jenkins/.ssh
                        chmod 700 /var/lib/jenkins/.ssh
                        chown -R jenkins:jenkins /var/lib/jenkins/.ssh

                        export ANSIBLE_HOST_KEY_CHECKING=False

                        cd ../terraform/envs/dev
                        terraform init -input=false > /dev/null 2>&1
                        BASTION_IP=$(terraform output -raw bastion_public_ip || echo "")
                        cd ../../../ansible

                        if [ -z "$BASTION_IP" ]; then
                        echo "ERROR: Bastion IP not found in Terraform outputs."
                        exit 1
                        fi

                        echo "Detected Bastion IP: $BASTION_IP"

                        # Add bastion to known_hosts to avoid prompt
                        ssh-keyscan -H $BASTION_IP >> /var/lib/jenkins/.ssh/known_hosts
                        echo "Updated known_hosts with bastion IP."

                        ansible all -i inventories/hosts.ini -m ping --ssh-common-args='-F /var/lib/jenkins/.ssh/config'
                        ansible-playbook -i inventories/hosts.ini playbooks/site.yaml --ssh-common-args='-F /var/lib/jenkins/.ssh/config'
                        '''
                    }
                }
            }
        }




        stage('Verify Deployment') {
            steps {
                echo "Verifying Nginx and MySQL setup..."
                sh '''
                ansible web -i ansible/inventories/hosts.ini -m shell -a "systemctl status nginx"
                ansible db -i ansible/inventories/hosts.ini -m shell -a "systemctl status mysql"
                '''
            }
        }
    }

    post {
        success {
            echo "Infrastructure deployed and configured successfully!"
        }
        failure {
            echo "Pipeline failed — check Jenkins logs for details."
        }
    }
}