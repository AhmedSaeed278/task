#!/bin/bash
# Update and install Squid proxy server
yum update -y
yum install -y squid
yum install -y httpd-tools

# Configure Squid proxy server
cat <<EOT > /etc/squid/squid.conf
http_port 3128
acl localnet src ${var.allowed_ips}
http_access allow localnet
http_access deny all

# Authentication settings
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic children 5
auth_param basic realm Squid proxy server
auth_param basic credentialsttl 2 hours

acl auth_user proxy_auth REQUIRED
http_access allow auth_user
EOT

# Create password file for authentication
# htpasswd -c /etc/squid/passwords ${username}
htpasswd -b -c /etc/squid/passwords  ${var.username} ${var.password}

# Start Squid proxy server
service squid enable
service squid start
