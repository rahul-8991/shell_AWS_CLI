#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c353a79d89785c5b" # Allow all traffic SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")

for instance in ${INSTANCES[@]}
#for instance in $@
do
    INSTANCE_ID=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"
done