# cloud_proxy/terraform.tfvars

# List of allowed IPs for accessing the proxy server
allowed_ips = ["94.58.136.27/32"]

# Username and password for proxy authentication
username = "user"
password = "password"

# Time interval (in hours) to rotate the proxy instance
life_hours = 3

# AWS key pair name
key_name = "wazuh-key-pair"
# AWS subnet ID
subnet_id = "subnet-0bd092711cebf2535"

life_minutes = 10