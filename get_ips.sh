#!/bin/bash

# Dynamically fetch all instance names (tag:Name) for running instances
INSTANCES=($(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value[]" \
  --output text))

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
