import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_name = os.environ['INSTANCE_NAME']
    instance_id = get_instance_id_from_name(instance_name)
    # Terminate the existing instance
    ec2.terminate_instances(InstanceIds=[instance_id])

    # Launch a new instance with similar configurations
    ami_id = os.environ['AMI_ID']
    instance_type = os.environ['INSTANCE_TYPE']
    key_name = os.environ['KEY_NAME']
    subnet_id = os.environ['SUBNET_ID']
    security_group_id = os.environ['SECURITY_GROUP_ID']
    user_data = os.environ['USER_DATA']

    new_instance = ec2.run_instances(
        ImageId=ami_id,
        InstanceType=instance_type,
        KeyName=key_name,
        SubnetId=subnet_id,
        SecurityGroupIds=[security_group_id],
        UserData=user_data,
        MinCount=1,
        MaxCount=1,
        TagSpecifications=[
        {
            'ResourceType': 'instance',  # Specifies that you are tagging an EC2 instance
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': 'proxy-instance'  # Replace with your desired tag value
                }

            ]
        }
    ]
    )

    new_instance_id = new_instance['Instances'][0]['InstanceId']

    return {
        'statusCode': 200,
        'body': f'New instance launched with ID: {new_instance_id}'
    }

def get_instance_id_from_name(instance_name):
    # Create an EC2 client
    ec2 = boto3.client('ec2')

    # Use describe_instances API call to filter instances by tag
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',  # Filter instances by the "Name" tag
                'Values': [instance_name]
            }
        ]
    )

    # Iterate through the response to find the instance with the specified name
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            # Return the instance ID if found
            return instance['InstanceId']

    # Return None if no instance is found
    return None