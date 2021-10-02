#!/bin/bash

# create new stack
# aws cloudformation create-stack --stack-name primary-network --stack-region us-west-2 --template-body file://./vpc.yaml --parameters ParameterKey=VpcName,ParameterValue=Primary --profile udacity
# aws cloudformation create-stack --stack-name secondary-network --stack-region us-east-1 --template-body file://./vpc.yaml --parameters ParameterKey=VpcName,ParameterValue=Secondary --profile udacity

# create VPC resources
aws cloudformation deploy \
    --stack-name PrimaryNetwork \
    --template-file ./vpc.yaml \
    --parameter-overrides VpcName=Primary VpcCIDR=10.1.0.0/16 PublicSubnet1CIDR=10.1.10.0/24 PublicSubnet2CIDR=10.1.11.0/24 PrivateSubnet1CIDR=10.1.20.0/24 PrivateSubnet2CIDR=10.1.21.0/24 \
    --profile udacity \
    --region us-west-2

aws cloudformation deploy \
    --stack-name SecondaryNetwork \
    --stack-region us-east-1 \
    --template-file ./vpc.yaml \
    --parameter-overrides VpcName=Secondary VpcCIDR=10.2.0.0/16 PublicSubnet1CIDR=10.2.10.0/24 PublicSubnet2CIDR=10.2.11.0/24 PrivateSubnet1CIDR=10.2.20.0/24 PrivateSubnet2CIDR=10.2.21.0/24 \
    --profile udacity \
    --region us-east-1

# create RDS resources
PRIMARY_DB_SG=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='DatabaseSecurityGroup'].OutputValue" --output text --profile udacity --region us-west-2`
PRIMARY_APP_SG=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='ApplicationSecurityGroup'].OutputValue" --output text --profile udacity --region us-west-2`
PRIMARY_PUBLIC_SUBNET1_ID=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1'].OutputValue" --output text --profile udacity --region us-west-2`
PRIMARY_PUBLIC_SUBNET2_ID=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2'].OutputValue" --output text --profile udacity --region us-west-2`
PRIMARY_PRIVATE_SUBNET1_ID=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1'].OutputValue" --output text --profile udacity --region us-west-2`
PRIMARY_PRIVATE_SUBNET2_ID=`aws cloudformation describe-stacks --stack-name PrimaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2'].OutputValue" --output text --profile udacity --region us-west-2`
SECONDARY_DB_SG=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='DatabaseSecurityGroup'].OutputValue" --output text --profile udacity --region us-east-1`
SECONDARY_APP_SG=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='ApplicationSecurityGroup'].OutputValue" --output text --profile udacity --region us-east-1`
SECONDARY_PUBLIC_SUBNET1_ID=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1'].OutputValue" --output text --profile udacity --region us-east-1`
SECONDARY_PUBLIC_SUBNET2_ID=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2'].OutputValue" --output text --profile udacity --region us-east-1`
SECONDARY_PRIVATE_SUBNET1_ID=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1'].OutputValue" --output text --profile udacity --region us-east-1`
SECONDARY_PRIVATE_SUBNET2_ID=`aws cloudformation describe-stacks --stack-name SecondaryNetwork --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2'].OutputValue" --output text --profile udacity --region us-east-1`

aws cloudformation deploy \
    --stack-name PrimaryRDS \
    --template-file ./rds.yaml \
    --parameter-overrides Subnet1=$PRIMARY_PRIVATE_SUBNET1_ID Subnet2=$PRIMARY_PRIVATE_SUBNET2_ID DatabaseSecurityGroup=$PRIMARY_DB_SG DBUsername=root DBPassword=testtest1 SourceDBId='' SourceDBRegion='' \
    --profile udacity \
    --region us-west-2

PRIMARY_DB_ID=`aws cloudformation describe-stacks --stack-name PrimaryRDS --query "Stacks[0].Outputs[?OutputKey=='DatbaseId'].OutputValue" --output text --profile udacity --region us-west-2`

aws cloudformation deploy \
    --stack-name SecondaryRDS \
    --template-file ./rds.yaml \
    --parameter-overrides Subnet1=$SECONDARY_PRIVATE_SUBNET1_ID Subnet2=$SECONDARY_PRIVATE_SUBNET2_ID DatabaseSecurityGroup=$SECONDARY_DB_SG \
    --profile udacity \
    --region us-east-1

# create EC2 instances
PRIMARY_IMAGE_ID=ami-03d5c68bab01f3496 # ubuntu 20.04 in us-west-2
aws cloudformation deploy \
    --stack-name PrimaryEC2 \
    --template-file ./ec2.yaml \
    --parameter-overrides ApplicationSecurityGroup=$PRIMARY_APP_SG SSHKeyName=udacity-ssh InstanceImageId=$PRIMARY_IMAGE_ID SubnetId=$PRIMARY_PUBLIC_SUBNET1_ID \
    --profile udacity \
    --region us-west-2

SECONDARY_IMAGE_ID=ami-09e67e426f25ce0d7 # ubuntu 20.04 in us-east-1
aws cloudformation deploy \
    --stack-name SecondaryEC2 \
    --template-file ./ec2.yaml \
    --parameter-overrides ApplicationSecurityGroup=$SECONDARY_APP_SG SSHKeyName=udacity-ssh InstanceImageId=$SECONDARY_IMAGE_ID SubnetId=$SECONDARY_PUBLIC_SUBNET1_ID \
    --profile udacity \
    --region us-east-1