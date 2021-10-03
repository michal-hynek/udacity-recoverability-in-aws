#!/bin/bash

aws cloudformation delete-stack --stack-name PrimaryRDS --region us-west-2 --profile udacity
aws cloudformation delete-stack --stack-name SecondaryRDS --region us-east-1 --profile udacity
aws cloudformation delete-stack --stack-name PrimaryNetwork --region us-west-2 --profile udacity
aws cloudformation delete-stack --stack-name SecondaryNetwork --region us-east-1 --profile udacity
aws cloudformation delete-stack --stack-name PrimaryEC2 --region us-west-2 --profile udacity
aws cloudformation delete-stack --stack-name SecondaryEC2 --region us-east-1 --profile udacity