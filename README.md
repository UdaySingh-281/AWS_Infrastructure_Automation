# 🧩 AWS Infrastructure Automation with Terraform, Ansible & Jenkins

This project demonstrates a **complete DevOps Infrastructure Automation Pipeline** — provisioning AWS infrastructure with **Terraform**, configuring servers with **Ansible**, and orchestrating the workflow using **Jenkins CI/CD**.

---

## 🚀 Project Overview

The goal of this project is to automate end-to-end deployment of a secure, scalable, and configurable AWS infrastructure that includes:

- **Bastion Host (Jump Server)** for secure SSH access  
- **Web Server Layer** (NGINX setup via Ansible)  
- **Database Server Layer** (MySQL setup via Ansible)  
- **CI/CD Pipeline** using Jenkins to:
  - Run Terraform to provision infrastructure
  - Update Bastion Security Group dynamically
  - Generate SSH configuration automatically
  - Apply Ansible configurations on provisioned servers

---

## 🏗️ Architecture Diagram

             ┌─────────────────────┐
             │     Jenkins Master   │
             │ (CI/CD Orchestration)│
             └──────────┬───────────┘
                        │
                        │ SSH + Terraform + Ansible
                        │
             ┌──────────▼──────────┐
             │   Bastion Host (EIP)│
             │   Public Subnet     │
             └──────────┬──────────┘
                        │
        ┌───────────────┼────────────────┐
        │                                │
    ┌───────▼─────────┐             ┌────────▼────────┐
    │ Web Server (EC2)│             │ DB Server (EC2) │
    │ NGINX Configured│             │ MySQL Configured│
    │ via Ansible     │             │ via Ansible     │
    └─────────────────┘             └─────────────────┘



---

## ⚙️ Tech Stack

| Tool | Purpose |
|------|----------|
| **Terraform** | Infrastructure provisioning (VPC, Subnets, EC2, Security Groups, EIP) |
| **Ansible** | Configuration management (NGINX, MySQL setup) |
| **Jenkins** | CI/CD orchestration and automation |
| **AWS** | Cloud infrastructure platform |
| **Python** | Helper scripts for automation (SG update, SSH config generation) |

---

## 📂 Project Structure

AWS_Infrastructure_Automation/
    │
    ├── ansible/
    │   ├── inventories/
    │   │   └── hosts.ini
    │   ├── playbooks/
    │   │   └── site.yaml
    │   ├── roles/
    │   │   ├── common/
    │   │   ├── web/
    │   │   └── db/
    │   ├── ansible.cfg
    │   └── scripts/
    │       ├── generate_ssh_config.py
    │       └── update_bastion_sg.py
    │
    ├── terraform/
    │   ├── envs/dev/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── variables.tf
    │   │   └── terraform.tfvars
    │   ├── modules/
    │   │   ├── vpc/
    │   │   └── ec2/
    │   └── provider.tf
    │
    ├── Jenkinsfile
    └── .gitignore


---

## 🔁 Jenkins CI/CD Workflow

1. **Checkout Code** from GitHub  
2. **Terraform Plan & Apply** to provision AWS infra  
3. **Extract Outputs** (public/private IPs, SG IDs, etc.)  
4. **Run Python Scripts**
   - Update Bastion SG with Master Node’s current IP
   - Generate dynamic SSH config file
5. **Run Ansible Playbook** via Bastion for configuration management  
6. **Destroy Infra (optional)** on pipeline teardown

---

