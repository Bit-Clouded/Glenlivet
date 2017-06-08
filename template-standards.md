## Parameters

- KeyPairName  
- AMI;
- Subnets; ServerSubnets, ElbSubnets


## Resources

IAM Paths : /\<foldername>/\<template or component name>/

S3 Buckets
  - Names : Should always be empty
  - Deletion Policy : Should always be retain
  - All must ship access log with prefix <stack name>-<bucket logical name>
  - ?Allow conditional creation if bucket already exist and specified.
  - Must have full event life cycle notification set up

Load Balancers
  - All must ship access log
  - Must be fronted with WAF

Auto Scaling Group
  - Must have resource signal
  - Must have cpu auto scale

RDS
  - Must have Name tag

Lambda
  - Must have log groups provisioned against its name (This ensures log clean up with stack.)
  - Must have log groups subscribed to the lambda log stream
  - Must not have create log stream permission (This ensure cloudformation creation do not fail.)

KMS
  - All KMS encryptable resources must have a default and overridable key
  - KMS key to have retained deletion policy if the datastores are retained


another kinesis stream for all lambda functions
all lambda functions log must be subscribed to the kinesis stream
ebs should all be encrypted with overridable key
rds should all be encrypted with overridable key
rds CopyTagsToSnapshot should be true