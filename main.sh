#!/bin/bash

DB_ENDPOINT=""
LB_DNS=""

echo 1

cd ./terraform

echo 2

terraform init

echo 3

terraform apply -auto-approve

echo 4

DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`postgrestestdb`].[Endpoint.Address]' --output text)

echo "4.5"

echo $DB_ENDPOINT

echo 5

DB_ENDPOINT="Server="$DB_ENDPOINT

echo 6

#DB_ENDPOINT="${DB_ENDPOINT::-5}"

echo 7

DB_ENDPOINT=$DB_ENDPOINT";Port=5432;Database=PostgresTestDb;User Id=postgres;Password=12453265"

echo 8

echo $DB_ENDPOINT

echo 9

cd ../kub

echo 10
aws eks update-kubeconfig --name my-eks-cluster --region us-east-1

echo 11

kubectl create secret generic my-secret --from-literal=var2-key="$DB_ENDPOINT"

echo 12

kubectl apply -f deployment.yaml

echo 14

kubectl apply -f service.yaml

echo 15

#kubectl delete secret my-secret

echo 16

while [ -z "$LB_DNS" ]; do
  LB_DNS=`kubectl get service my-service --namespace default -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"`
  echo "load balancer dns is null. Waiting..."
  sleep 1
done

echo $LB_DNS

echo 17

cd ../terraform1

echo 18

terraform init

echo 19

terraform apply -var="lb_dns_name=$LB_DNS" -auto-approve

echo 20


