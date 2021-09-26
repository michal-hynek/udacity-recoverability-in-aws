#!/bin/bash

aws cloudformation delete-stack --stack-name PrimaryRDS --stack-region us-west-2 --profile udacity
aws cloudformation delete-stack --stack-name SecondaryRDS --stack-region us-east-1 --profile udacity
aws cloudformation delete-stack --stack-name PrimaryNetwork --stack-region us-west-2 --profile udacity
aws cloudformation delete-stack --stack-name SecondaryNetwork --stack-region us-east-1 --profile udacity