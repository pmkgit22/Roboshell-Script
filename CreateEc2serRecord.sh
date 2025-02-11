#!/bin/bash
NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0aa5eadb45a5e2e7b
DOMAIN_NAME=munidevops.shop
HOSTED_ZONE_ID=Z06548701E94N6E056HLX
#USERID=$(id -u )
#DATE=$(date +%F)
#LOGDIR=/home/centos/shellscript-logs
SUBNET_ID=subnet-054782327410188eb
# SCRIPT_NAME=$0
# LOGFILE=$LOGDIR/$0-$DATE.log
# R="\e[31m"
# N="\e[0m"
# B="\e[34m"
# (IF mysql or mongodb instance type is t3.medium otherwise t2.medium)

for i in $@
do
    if [[ $i == "mongodb" || $i == "mysql"]]
    then
    INSTANCE_TYPE="t3.medium"
    else
    INSTANCE_TYPE="t2.medium" 
    fi
    echo "creating $i instance "
    IP_ADDRESS=$(aws ec2 run-instances --imageid $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --subnet-id $SUBNET_ID --query "Instances[0].InstanceId" --output text)
    
    echo "created  $i instance : $IP_ADDRESS "
    aws route53 changes-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
                "changes":[{
                "Action": "CREATE",
                            "ResourceRecordSet": {
                                "Name": "'$i.$DOMAIN_NAME'",
                                "Type": "A",
                                "TTL": 300,
                                "ResourceRecords": [{ "Value": "'$IP_ADDRESS'" }]

                            }
                }]


    }
    '