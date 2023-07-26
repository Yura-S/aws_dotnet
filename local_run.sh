#!/bin/bash

DB_ENDPOINT=""
LB_DNS=""

cd ./terraform
terraform init
terraform apply -auto-approve

DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`postgrestestdb`].[Endpoint.Address]' --output text)
DB_ENDPOINT="Server="$DB_ENDPOINT
DB_ENDPOINT=$DB_ENDPOINT";Port=5432;Database=PostgresTestDb;User Id=postgres;Password=12453265"

cd ../kub
aws eks update-kubeconfig --name my-eks-cluster --region us-east-1
kubectl create secret generic my-secret --from-literal=var2-key="$DB_ENDPOINT"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

while [ -z "$LB_DNS" ]; do
  LB_DNS=`kubectl get service my-service --namespace default -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"`
  sleep 1
done

cd ../terraform1
terraform init
terraform apply -var="lb_dns_name=$LB_DNS" -auto-approve