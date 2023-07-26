This project creates three-tier application:

FRONTEND - is located in S3 bucket, paired with domain with Route53. Frontend uses API to connect with Backend.

BACKEND - is located in EKS cluster, is ran on 3 pods behind load balancer, which is paired with API by Route53. Backend is created using DockerHUB image.

DATABASE - is located in RDS, type: Postgres.


To run this application in Github repository, you need to:

1) Create secrets in your repository:

   a) your AWS credentials and region (NOTE: you should use us-east-1 for region)

   AWS_ACCESS_KEY_ID
   AWS_REGION
   AWS_SECRET_ACCESS_KEY

   b) your terraform TOKEN

   TF_API_TOKEN

   c) you need to copy the content of locally saved secret keys to Github Secrets with the same naming as below

   CERT
   CHAIN
   PRIVKEY

   d) for API's certificates copy the content from local files to GitHub Secrets with the same naming as below (for instance: GIVEN Domain URL -> test.com, THEN API URL -> api.test.com)

   CERT1
   CHAIN1
   PRIVKEY1

   e) your DB password (NOTE: is not configured, USE: <12453265>)

   DB_PASSWORD

2) Clone this repository to be able to make changes

3) Replace your Domain (I'm using <ysahakyan.devopsaca.site>) and Subdomain (I'm using <api.ysahakyan.devopsaca.site>) names in terraform files:

   /terraform/main.tf
   
   /terraform/route53.tf
   
   /teraform1/main.tf

4) Create S3 Bucket that contains Frontend. S3 Bucket name should be the same as Domain.

   a) frontend location: https://github.com/Yura-S/ad_frontend.git
   
   b) clone repo
   
   c) replace this <"api.ysahakyan.devopsaca.site"> data in /src/App.js with your API URL
   
   d) build code -> npm run build (this creates a new folder with the name <buikd>)
   
   e) copy all files from newly created /build folder to your S3 Bucket

5) Create Route53 hosted zone for your domain and configure it as needed

6) Push the code from 1-3 steps to your remote repository ///(run starts automatically when changes is pushed to action_test)/// -> change this line after removing action_test

7) Initially DB is empty. Manually add data to DB. To be able to make changes in DB, you need to open DB Security Groups 5432 port for all and add data using create_table.sh script

   a) psql is needed

   b) after the data migration remove security group rule
