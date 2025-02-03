import boto3
import os

# Initialize EC2 client
ec2 = boto3.client('ec2', region_name=os.environ['AWS_REGION'])

# Get instance ID from environment variable
INSTANCE_ID = os.environ['INSTANCE_ID']

def lambda_handler(event, context):
    action = event.get("action", "")
    
    if action == "start":
        ec2.start_instances(InstanceIds=[INSTANCE_ID])
        return f"EC2 instance {INSTANCE_ID} started successfully."
    
    elif action == "stop":
        ec2.stop_instances(InstanceIds=[INSTANCE_ID])
        return f"EC2 instance {INSTANCE_ID} stopped successfully."
    
    else:
        return "Invalid action. Use 'start' or 'stop'."
    

#  I need to package the Lambda Code into a ZIP File and run below command
# zip lambda_function.zip lambda_function.py