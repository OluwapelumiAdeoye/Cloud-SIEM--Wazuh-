# Identity
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# S3
BUCKET_NAME="siem-cloudtrail-logs-patron999"

# SQS
QUEUE_URL=$(aws sqs get-queue-url --queue-name wazuh-cloudtrail-queue --query QueueUrl --output text)
QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query Attributes.QueueArn --output text)

# VPC and Security Group
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=wazuh-sg" --query "SecurityGroups[0].GroupId" --output text)

# Your IP
MY_IP=$(curl -s ifconfig.me)
AMI_ID="ami-017d3e24afcd69bab"
PUBLIC_IP=3.252.57.90
INSTANCE_ID=i-03a68c5a44d5daf8d
TOPIC_ARN=arn:aws:sns:eu-west-1:169424082452:wazuh-alerts
