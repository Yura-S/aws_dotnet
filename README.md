This project creates three-tier application:

FRONTEND - locates in s3 bucket. pairs with domain by route53. uses api to connect with backend

BACKEND - locates in EKS cluster. runs in 3 pods behind load balancer which paired with api by route53. creates using dockerhub image

DATABASE - locates in RDS. its postgre


For running this application in your repository you need to:

1) create secrets in your repository

   -your aws credentials and region(needs us-east-1)

   AWS_ACCESS_KEY_ID
   AWS_REGION
   AWS_SECRET_ACCESS_KEY

   -your terraform token

   TF_API_TOKEN

   -your domains certificate files contents
   
   CERT
   CHAIN
   PRIVKEY

   -your api's certificate files contents(if domain test.com then api is api.test.com)
   
   CERT1
   CHAIN1
   PRIVKEY1

   -your database password(not configured yet, now uses 12453265 password)

   DB_PASSWORD

2) clone this repository for making changes

3) raplace your domain(here is ysahakyan.devopsaca.site) and subdomain(here is api.ysahakyan.devopsaca.site) name in terraform files:

   /terraform/main.tf
   
   /terraform/route53.tf
   
   /teraform1/main.tf

4) create s3 bucket which contains frontend and communicates with backend by your api(api.test.com). need to have same name as domain(test.com)

   frontend in https://github.com/Yura-S/ad_frontend.git
   
   clone it
   
   change in /src/App.js "api.ysahakyan.devopsaca.site" to your api(api.test.com)
   
   build code(npm run build)
   
   copy all files in created /build to your s3 bucket

5) create route53 hosted zone for your domain and configure it to work

6) copy all files to your repository(runs while pushing anything in actions_test)

7) there is no data in database. manually add. open database security groups 5432 port for all and add data using create_table.sh script

   needs installed psql for it
