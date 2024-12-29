# Django Server Deployment Automation Script

⚠️ **Note: This script is a work in progress and needs several improvements**

⚠️ **Compatibility Note: This script is specifically designed and tested for Ubuntu Server 24.04 LTS and has not been tested with other distributions.**

This repository contains an automation script for deploying a Django REST API project on an EC2 instance with Nginx and Gunicorn. This script is specifically designed as an example for deploying the project from [django_rest_project_management_api](https://github.com/centaurusgod/django_rest_project_management_api.git).



> **Note**: The Nginx and Gunicorn configurations in this script are tailored for the example repository mentioned above. You should modify these configurations according to your specific project requirements if using with a different Django project.

## Important Improvements Needed

1. **Error Handling**: Add proper error checking for each command execution
2. **Logging**: Implement comprehensive logging for better debugging
3. **Command Success Verification**: Add checks to verify if each step completed successfully
4. **Rollback Mechanism**: Implement rollback functionality for failed deployments
5. **AWS CLI Integration**: Future improvement to automatically fetch EC2 public IP using AWS CLI
6. **Environment Variables**: Move hardcoded values to environment variables
7. **Backup Mechanism**: Add backup functionality before making changes
8. **Security Enhancements**: Implement additional security checks and validations

## Prerequisites

- An AWS EC2 instance running Ubuntu
- SSH access to the EC2 instance (using .pem file)
- Git installed on the EC2 instance
- Proper AWS security group settings (Port 80 open for HTTP)

## Deployment Methods

### Method 1: Using SSH with .pem file
```bash
# Connect to EC2 instance
ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
# Create the automation script file in the home directory
nano automate.sh
# Copy the contents of the script into the file
# Save and exit
# Make the script executable    
chmod +x automate.sh
# Run the script
./automate.sh
```

### Method 1: Using AWS CLI (Windows)

#### Prerequisites
1. **AWS Account Setup**:
   - Create an AWS account if you haven't already
   - Create an IAM user and generate Access Key ID and Secret Access Key
   - Note down these credentials for AWS CLI configuration

2. **AWS CLI Setup**:
   ```bash
   # Create a virtual environment
   python -m venv awsvenv
   
   # Activate the virtual environment
   .\awsvenv\Scripts\activate
   
   # Install AWS CLI
   pip install awscli
   
   # Configure AWS CLI
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your preferred region (e.g., ap-south-1)
   # Enter output format (json)
   ```

3. **Security Group Setup**:
   - Create a security group in AWS Console
   - Add inbound rule for HTTP (Port 80) from anywhere (0.0.0.0/0)
   - Add inbound rule for SSH (Port 22) from your IP
   - Note down the security group ID

4. **SSH Key Setup**:
   - Create a key pair in AWS Console
   - Download the .pem file
   - Place it in your working directory

#### Deployment Steps

1. Create a file named `deployment.sh` with the following content:
   ```bash
   #!/bin/bash

   # Step 1: Launch EC2 Instance
   INSTANCE_ID=$(aws ec2 run-instances \
     --image-id "ami-053b12d3152c0cc71" \
     --instance-type "t2.micro" \
     --key-name "<YOUR-KEY-PAIR-NAME>" \
     --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":8,"VolumeType":"gp3"}}]' \
     --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["<YOUR-SECURITY-GROUP-ID>"]}' \
     --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"django_server"}]}' \
     --count "1" \
     --query 'Instances[0].InstanceId' \
     --output text)

   echo "Launched EC2 Instance ID: $INSTANCE_ID"
   sleep 10

   # Step 3: Fetch Public IP
   PUBLIC_IP=$(aws ec2 describe-instances \
     --instance-ids "$INSTANCE_ID" \
     --query "Reservations[*].Instances[?State.Name=='running'].[PublicIpAddress]" \
     --output text)

   if [[ -z "$PUBLIC_IP" ]]; then
     echo "Failed to fetch public IP. Terminating instance."
     aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
     exit 1
   fi

   echo "Public IP: $PUBLIC_IP"
   sleep 10

   # Step 4: Deploy application
   ssh -o StrictHostKeyChecking=no -i <YOUR-PEM-FILE>.pem ubuntu@$PUBLIC_IP "git clone https://github.com/centaurusgod/bash_django_server_deployment.git && cp bash_django_server_deployment/automate.sh /home/ubuntu/ && chmod +x /home/ubuntu/automate.sh && sed -i 's|your_ec2_instance_public_ip|$PUBLIC_IP|' /home/ubuntu/automate.sh && bash /home/ubuntu/automate.sh"

   # Step 5: Open browser
   msedge http://$PUBLIC_IP/api/docs/
   ```

2. Open Git Bash in your working directory and run:
   ```bash
   # In windows
   bash deployment.sh

   # In linux
   chmod +x deployment.sh
   ./deployment.sh
   ```

> **Note**: Replace the following placeholders in the script:
> - `<YOUR-AMI-ID>`: Your Ubuntu Server 24.04 LTS AMI ID
> - `<YOUR-KEY-PAIR-NAME>`: Name of your key pair
> - `<YOUR-SECURITY-GROUP-ID>`: Your security group ID
> - `<YOUR-PEM-FILE>`: Name of your .pem file

## What the Script Does

1. Fetch the Update So the necessary package urls can be reached
2. Installs required dependencies (virtualenv, nginx, gunicorn)
3. Clones the Django project repository
4. Sets up a Python virtual environment
5. Installs project dependencies
6. Configures Django settings (SECRET_KEY, DEBUG, ALLOWED_HOSTS)
7. Sets up Nginx configuration
8. Configures Gunicorn service
9. Sets appropriate file permissions
10. Starts and enables required services

## Script Components

- **System Updates**: Initial system preparation
- **Dependencies**: Installation of required packages
- **Project Setup**: Django project configuration
- **Nginx Configuration**: Web server setup for the example project
- **Gunicorn Setup**: WSGI server configuration
- **Security Settings**: Basic security configurations
- **Service Configuration**: System service setup

## Future Improvements

1. **AWS CLI Integration**:
   ```bash
   # Future implementation will include:
   PUBLIC_IP=$(aws ec2 describe-instances \
     --filters "Name=instance-state-name,Values=running" \
     --query "Reservations[].Instances[].PublicIpAddress" \
     --output text)
   ```

2. **Enhanced Error Handling**
3. **Configuration Validation**
4. **Automated Backup System**
5. **Health Checks**
6. **Performance Monitoring Setup**
