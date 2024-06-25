# AWS Wordpress instances with TERRAFORM

How to install a wordpress environment in AWS Cloud, using modules.
 
```txt
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── modules
│   ├── vpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── autoscaling-lb
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── bastion
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
└── wordpress_aws.sh
```

## 1. Test terraform \

Prepair your infrastructure :
```bash
cd Wordpress-Terraform
terraform fmt
terraform validate
```

## 2. Hide your sensibles data \

Use 
```bash
export TF_VAR_db_name="yourdbname"
export TF_VAR_db_username="yourdbusername"
export TF_VAR_db_user_password="password"
# Security ! those environment variables will be available only for this session.
# Think about checking inside modules
```

## 3. Launch the Terraform infrastructure \

```bash
terraform plan -out "launch infra"
terraform apply "launch infra"
# if you don't want to save your plan, forget -out "xx"
```
main.tf will launch automaticly each modules
```yml
module "vpc"
module "rds"
module "autoscaling" 
module "bastion" 
```

Our autoscaling will be launched with the script "wordpress_aws.sh" and let's go !

Each module will automaticly launch resources and then deploy every part of our wordpress application.

![imagewp](https://raw.githubusercontent.com/Sanourith/Wordpress-Terraform/main/img/wordpress-succes.png)

Right after, you can get your load-balancer DNS to get into your internet browser then Wordpress will be available ! :D

Congratz' !


