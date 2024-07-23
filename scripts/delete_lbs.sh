#!/bin/bash
# list_lb.sh

# Set the AWS Region
REGION="eu-west-1"

# Get all Load Balancer ARNs and store them in an array
LB_ARNS=$(aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[*].LoadBalancerArn' --output text)

# Loop through the array of Load Balancer ARNs and delete each one
for LB_ARN in $LB_ARNS; do
  echo "Deleting Load Balancer: $LB_ARN"
  aws elbv2 delete-load-balancer --region $REGION --load-balancer-arn $LB_ARN
  echo "Deleted Load Balancer: $LB_ARN"
done