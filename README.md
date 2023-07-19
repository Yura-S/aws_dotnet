For running this application in your repository you need to:

1) create secrets in your repository

   -your aws credentials and region(needs us-east-1)

   AWS_ACCESS_KEY_ID
   AWS_REGION
   AWS_SECRET_ACCESS_KEY

   -your terraform token

   TF_API_TOKEN

   -your domains certificate files content
   
   CERT
   CHAIN
   PRIVKEY

   -your api's certificate files content(if domain test.com then api is api.test.com)
   
   CERT1
   CHAIN1
   PRIVKEY1

   -your database password

   DB_PASSWORD
   

3) raplace your domain(here is ysahakyan.devopsaca.site) and subdomain(here is api.ysahakyan.devopsaca.site) name in terraform files:

terraform/main.tf
terraform/route53.tf
teraform1/main.tf

4) create s3 bucket

5) create hosted zone

6) manually add data to db

7) copy all files to your repository
