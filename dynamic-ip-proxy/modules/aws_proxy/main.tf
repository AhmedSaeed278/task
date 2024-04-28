resource "aws_instance" "proxy" {
  ami                    = "ami-0aef871962c23384f"  # Update with appropriate AMI
  instance_type          = "t2.micro"  # Update instance type as necessary
  key_name               = var.key_name
  user_data              = file("${path.module}/userdata.sh")  # Reference to userdata.sh
  vpc_security_group_ids = [aws_security_group.proxy_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "proxy-instance"
  }

  lifecycle {
    create_before_destroy = true  # Create new instance before destroying old one
  }

  # Output the public IP address of the instance
  
}
resource "aws_cloudwatch_event_rule" "rotation_rule" {
  name                = "proxy-rotation"
  schedule_expression = "rate(${var.life_minutes} minutes)"
}
resource "aws_cloudwatch_event_target" "rotation_target" {
    rule      = aws_cloudwatch_event_rule.rotation_rule.name
    target_id = "EC2InstanceManager"
    arn       = aws_lambda_function.ec2_management_function.arn  # Lambda function ARN
}
resource "aws_security_group" "proxy_sg" {
  name        = "proxy-sg"
  description = "Security group for the proxy server"
  vpc_id = "vpc-03305cd6e0598c528"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  }
    
  resource "aws_lambda_function" "ec2_management_function" {
    filename         = "./lambda_function.zip"
    function_name    = "EC2InstanceManager"
    role             = aws_iam_role.lambda_role.arn
    handler          = "lambda_function.lambda_handler"
    runtime          = "python3.8"
    timeout          = 300  # Adjust the timeout as needed
    memory_size      = 128  # Adjust the memory size as needed

    environment {
    variables = {
        INSTANCE_ID = aws_instance.proxy.id
        AMI_ID = aws_instance.proxy.ami
        INSTANCE_TYPE = aws_instance.proxy.instance_type
        INSTANCE_NAME = aws_instance.proxy.tags["Name"]
        KEY_NAME = aws_instance.proxy.key_name
        SUBNET_ID = aws_instance.proxy.subnet_id
        SECURITY_GROUP_ID = aws_security_group.proxy_sg.id
        USER_DATA = <<-EOT
                #!/bin/bash
                yum update -y
                yum install -y squid
                yum install -y httpd-tools
                cat <<EOF > /etc/squid/squid.conf
                http_port 3128
                acl localnet src ${var.allowed_ips[0]}
                http_access allow localnet
                http_access deny all
                auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
                auth_param basic children 5
                auth_param basic realm Squid proxy server
                auth_param basic credentialsttl 2 hours
                acl auth_user proxy_auth REQUIRED
                http_access allow auth_user
                EOF
                
                htpasswd -b -c /etc/squid/passwords  ${var.username} ${var.password}
                service squid enable
                service squid start
            EOT
    }
}

}
# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
    name = "lambda_ec2_management_role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "lambda.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Define the IAM policy
resource "aws_iam_policy" "lambda_policy" {
    name   = "lambda_ec2_management_policy"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "ec2:*"],
                Resource = "*"
            }
        ]
    })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}
