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

5) create s3 bucket which contains frontend and communicates with backend by your api(api.test.com). need to have same name as domain(test.com)

6) create route53 hosted zone for your domain and configure it to work

7) there is no data in database. manually add. open database security groups 5432 port for all and add data using create_table.sh script 

8) copy all files to your repository
