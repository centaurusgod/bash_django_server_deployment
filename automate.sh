#!/bin/bash

#Let's first hardcode the public ip address
PUBLIC_IP="your_ec2_instance_public_ip"

# Update and upgrade the system
sudo apt update 
# Install necessary dependencies
sudo apt install virtualenv nginx -y

# Clone the Django repository from GitHub
git clone https://github.com/centaurusgod/django_rest_project_management_api.git
cd django_rest_project_management_api
cd project_management_system

# Create a virtual environment
virtualenv venv
source venv/bin/activate

# Install Gunicorn and dependencies from requirements.txt
pip install -r requirements.txt
pip install gunicorn

# Make necessary database migrations
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput

#Append the public ip address in the .env file of the allowed host
sed -i "/^ALLOWED_HOSTS=/s/$/,${PUBLIC_IP}/" .env
# Generate a new Django secret key and edit the SECRET_KEY
SECRET_KEY=$(python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
escaped_secret_key=$(printf '%s' "$SECRET_KEY" | sed 's/[&/\]/\\&/g')
sed -i "s/^SECRET_KEY=.*/SECRET_KEY=$escaped_secret_key/" .env
#Changing the debug mode to false for production
sed -i 's/^DEBUG=True/DEBUG=False/' .env


# Define the Nginx configuration path
NGINX_CONFIG="/etc/nginx/sites-available/django_rest_project_management"

# Use printf to pass the expanded content to sudo bash -c
sudo bash -c "printf 'server {
   listen 80;
   server_name $PUBLIC_IP;

   location /static/ {
       alias /home/ubuntu/django_rest_project_management_api/project_management_system/staticfiles/;
       autoindex on;
       allow all;
   }

   location /media/ {
       alias /home/ubuntu/django_rest_project_management_api/project_management_system/media/;
       autoindex on;
       allow all;
   }

   location / {
       proxy_pass http://127.0.0.1:8000;
       proxy_set_header Host \$host;
       proxy_set_header X-Real-IP \$remote_addr;
       proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto \$scheme;
   }

   error_log /var/log/nginx/django_rest_project_management_error.log;
   access_log /var/log/nginx/django_rest_project_management_access.log;
}
' > $NGINX_CONFIG"



#Setting proper ownership and making sure nginx user has access to the directory path
sudo chown -R www-data:www-data /home/ubuntu/django_rest_project_management_api/project_management_system/staticfiles/
sudo chmod -R 755 /home/ubuntu/django_rest_project_management_api/project_management_system/staticfiles/
sudo chmod 755 /home/ubuntu
sudo chmod 755 /home/ubuntu/django_rest_project_management_api
sudo chmod 755 /home/ubuntu/django_rest_project_management_api/project_management_system

#Create a symbolic link
sudo ln -s /etc/nginx/sites-available/django_rest_project_management /etc/nginx/sites-enabled/

#Create a gunicorn service
GUNICORN_SERVICE_CONF="/etc/systemd/system/gunicorn.service"
sudo bash -c "cat <<EOF > $GUNICORN_SERVICE_CONF
[Unit]
Description=Gunicorn service for Django application
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/django_rest_project_management_api/project_management_system
ExecStart=/home/ubuntu/django_rest_project_management_api/project_management_system/venv/bin/gunicorn \
          --workers 3 \
          --bind 127.0.0.1:8000 \
          project_management_system.wsgi:application

[Install]
WantedBy=multi-user.target
EOF"

#Reload the daemons after making system configurations
sudo systemctl daemon-reload
#Restart gunicorn and nginx service
sudo systemctl restart nginx
sudo systemctl restart gunicorn

#Enable nginx and gunicorn services so that those services will be automatically activated on instance reboot
sudo systemctl enable nginx
sudo systemctl enable gunicorn


