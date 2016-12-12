## Parameters

- KeyPairName  
- AMI;
- Subnets; ServerSubnets, ElbSubnets


## Resources

IAM Paths : /\<foldername>/\<template or component name>/

S3 Buckets
  - Names : Should always be empty
  - Deletion Policy : Should always be retain
  - All must ship access log
  - ?Allow conditional creation if bucket already exist and specified.

Load Balancers
  - All must ship access log

Auto Scaling Group
  - Must have resource signal
  - Must have cpu auto scale

RDS
  - Must have Name tag