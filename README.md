# Django Server Deployment Automation Script

⚠️ **Note: This script is a work in progress and needs several improvements**

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

## Getting Started

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

