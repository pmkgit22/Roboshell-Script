#!/bin/bash
NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0aa5eadb45a5e2e7b
DOMAIN_NAME=munidevops.shop
HOSTED_ZONE_ID=Z06548701E94N6E056HLX
SUBNET_ID=subnet-054782327410188eb

for i in $@
do
    if [[ $i == "mongodb" || $i == "mysql" ]]; then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    echo "creating $i instance"
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $IMAGE_ID \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids $SECURITY_GROUP_ID \
        --subnet-id $SUBNET_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query "Instances[0].InstanceId" \
        --output text)
    echo "created $i instance: $INSTANCE_ID"

    # Wait for the instance to be running
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    # Retrieve the public IP address of the instance
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text)
    echo "Public IP for instance $INSTANCE_ID is: $PUBLIC_IP"

    # Create the Route 53 DNS record using the public IP address
    read -r -d '' CHANGE_BATCH <<EOF
{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "$i.$DOMAIN_NAME",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{ "Value": "$PUBLIC_IP" }]
        }
    }]
}
EOF

    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch "$CHANGE_BATCH"
done
