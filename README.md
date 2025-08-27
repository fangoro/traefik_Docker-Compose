
# Traefik Docker-Compose Infrastructure Project

This project provides a ready-to-use solution for deploying Traefik reverse proxy on cloud platforms using Terraform and Ansible.It supports AWS, Azure and GCP deployments with automated Docker and Traefik setup.

please note that this is not a complete Traefik / Terraform / Ansible tutorial. this project is meant to help you not waste time on setting up Traefik on your cloud platform.

## 📋 Project Structure

```
traefik_Docker-Compose/
├── terraform/
│   ├── terraform-AWS/     # AWS infrastructure
│   ├── terraform-Azure/   # Azure infrastructure
│   └── terraform-GCP/     # GCP infrastructure
├── ansible/
│   ├── files/
│   │   ├── docker-compose.yml  # Traefik and sample app
│   │   └── traefik.yml        # Traefik configuration
│   ├── inventory.ini          # Ansible inventory
│   └── playbook.yml          # Ansible playbook
└── .gitignore

```

## 🚀 Quick Start Guide

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/

installation_guide/intro_installation.html) >= 2.9
- SSH key pair (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)
- Cloud provider CLI tools configured:
  - AWS CLI (for AWS)
  - Azure CLI (for Azure)
  - gcloud CLI (for GCP)

### Step 1: Choose Your Cloud Provider

Navigate to your preferred cloud provider directory:

```bash
# For AWS
cd terraform/terraform-AWS

# For Azure
cd terraform/terraform-Azure

# For GCP
cd terraform/terraform-GCP
```

### Step 2: Configure Variables

Create a `terraform.tfvars` file in your chosen provider 
directory:

#### For AWS:
```hcl
aws_region    = "eu-west-3"
instance_type = "t3.micro"
key_name      = "your-aws-key-pair-name"
```

#### For Azure:
```hcl
resource_group_location = "France Central"
vm_size                = "Standard_B1s"
admin_username         = "traefikadmin"
```

#### For GCP:
```hcl
project_id    = "your-gcp-project-id"
region        = "europe-west1"
zone          = "europe-west1-b"
machine_type  = "e2-micro"
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan # (or terraform plan -out plan if you want to generate a plan file)"

# Apply the configuration
terraform apply
```

### Step 4: Get the Public IP

After successful deployment, get the public IP address:

```bash
# Get the public IP from Terraform outputs
terraform output public_ip_address
```

**Example output:**
```
"203.0.113.45"

```

### Step 5: Update Ansible Inventory

Update the `ansible/inventory.ini` file with your VM's 
public IP:

```ini
[traefik]
203.0.113.45 ansible_user=traefikadmin ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Step 6: Update Docker Compose Configuration

Update the `ansible/files/docker-compose.yml` file to use 
your VM's public IP:

```yaml
# Replace the Host rule with your actual IP
- "traefik.http.routers.cats-http.rule=Host(`203.0.113.45`)"
```

### Step 7: Run Ansible Playbook

Navigate to the ansible directory and run the playbook:

```bash
cd ../../ansible

# Test connectivity
ansible -i inventory.ini -m ping

# Run the playbook
ansible-playbook -i inventory.ini playbook.yml
```

## 🔧 What the Ansible Playbook Does

The playbook performs the following tasks:

1. **System Updates**: Updates package cache and installs required packages
2. **Docker Installation**: 
   - Adds Docker GPG key and repository
   - Installs Docker CE, CLI, and compose plugin
   - Enables and starts Docker service
3. **User Configuration**: Adds the admin user to the docker group
4. **Traefik Setup**:
   - Creates `/home/traefikadmin/traefik` directory
   - Copies `traefik.yml` static configuration file
   - Copies `docker-compose.yml` with Traefik and sample app


### Step 8: Start Traefik Services

SSH into your VM and start the services:

```bash
# SSH into the VM
ssh traefikadmin@YOUR_VM_IP

# Navigate to traefik directory
cd traefik

# Start services
docker compose up -d

# Check status
docker compose ps
```

## 🌐 Accessing Services

### Traefik Dashboard

Access the Traefik dashboard at:
http://YOUR_VM_IP:8080


**Example:** `http://203.0.113.45:8080`

### Sample Application (Cats App)

Access the sample cats application at:

http://YOUR_VM_IP


**Example:** `http://203.0.113.45`


## 🔒 HTTPS Configuration (Optional)

To enable HTTPS with Let's Encrypt:

1. **Get a domain name** and point it to your VM's IP
2. **Update docker-compose.yml**:
   - Replace IP addresses with your domain name
   - Uncomment the HTTPS configuration block
   - Update the email in `traefik.yml`

3. **Restart services**:
   ```bash
   docker compose down
   docker compose up -d
   ```

## 📊 Monitoring and Logs

### View Traefik Logs
```bash
docker compose logs traefik
```

### View Application Logs
```bash
docker compose logs cats
```

### Real-time Logs
```bash
docker compose logs -f
```

## 🛠️ Troubleshooting

### Common Issues

1. **SSH Connection Failed**:
   - Verify the public IP is correct
   - Check security group/firewall rules allow SSH (port 22)
   - Ensure SSH key path is correct

2. **Ansible Playbook Fails**:
   - Test SSH connectivity: `ssh traefikadmin@YOUR_VM_IP`
   - Verify inventory.ini has correct IP and user

3. **Services Not Accessible**:
   - Check if services are running: `docker compose ps`
   - Verify firewall rules allow HTTP (80), HTTPS (443), and dashboard (8080)
   - Check Traefik logs for errors

4. **Let's Encrypt Certificate Issues**:
   - Ensure domain points to correct IP
   - Check email configuration in traefik.yml
   - Verify port 80 is accessible for HTTP challenge

### Useful Commands

```bash
# Check VM status
terraform show

# SSH connection test
ssh -i ~/.ssh/id_rsa traefikadmin@YOUR_VM_IP

# Restart Traefik services
docker compose restart

# View Traefik configuration
docker compose exec traefik cat /etc/traefik/traefik.yml
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
# Stop services (SSH into VM first)
docker compose down

# Destroy infrastructure
cd terraform/terraform-[PROVIDER]
terraform destroy
```

## 📝 Configuration Files Explained

### traefik.yml
- Defines entry points (HTTP/HTTPS)
- Configures Docker provider
- Enables dashboard
- Sets up Let's Encrypt resolver

### docker-compose.yml
- **Traefik service**: Main reverse proxy
- **Cats service**: Sample application with Traefik labels
- **Labels**: Configure routing rules and SSL

### Ansible Playbook
- Installs Docker and dependencies
- Configures user permissions
- Deploys Traefik configuration files

## 🔐 Security Considerations

- Change default passwords and usernames
- Use strong SSH keys
- Configure proper firewall rules
- Use HTTPS in production
- Regularly update Docker images
- Monitor access logs

## 📚 Additional Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Happy containerizing! 🐳**