#!/bin/bash

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")

for instance in "${INSTANCES[@]}"
do
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$instance" "Name=instance-state-name,Values=running" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$instance" "Name=instance-state-name,Values=running" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
    fi
    echo "$instance IP address: $IP"
done
