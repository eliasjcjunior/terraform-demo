# Terraform Demo

This project is just a simple example using some terraform concepts.

## Requirements

* Terraform 13+ instaled
* Bucket to store the state file (Here I'm using bucket name **state-tf-demo**). If you change de name you will need to change the new name in the backend configuration, on file **provider.tf**

## Instructions

* Configure aws credentials on your machine using [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) or [aws reserved environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
*  Run terraform init
*  Run terraform apply
*  After that you can take the public dns on application load balancer to access the server
