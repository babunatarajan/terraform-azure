# terraform-azure
Provisioning Azure resources using Terraform

## Clone the repository and run init command to download the Azure provider/plugin for Terraform.
git clone https://github.com/babunatarajan/terraform-azure.git
cd terraform-azure
terraform init

## The stack consists the following resources.
1. Virtual Network 10.0.110.0/25
2. Subnet 10.0.110.0/27 for internal network
3. Network security group for VM communication (80/TCP, 22/TCP, 443/TCP)
4. VM - Ubuntu 18.04 (Basci A0, 30GB Standard SSD_LRS)
5. SSH Private/Public key - create a private and public key and place the public key under ~/.ssh/ (e.g. /home/username/.ssh/tfdemo-azure.pub)
6. Script to install Nginx, Docker and Certbot
7. Load Balancer (TCP and non-HTTP(S), you can configure Certbot/LetsEncrypt or own CA Cert on Linux instance, this is to reduce the cost for not using the Application Gateway (HTTPs). Refer (https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview#decision-tree-for-load-balancing-in-azure). Azure Load Balancer is a high-performance, ultra low-latency Layer 4 load-balancing service (inbound and outbound) for all UDP and TCP protocols. It is built to handle millions of requests per second while ensuring your solution is highly available. Azure Load Balancer is zone-redundant, ensuring high availability across Availability Zones.
8. DNS Zone is nowhere used in the stack, if needed disable/remove the dns.tf file.
9. MySQL - Adding now...

## The vars.tf contains basic information, make sure you review and update the information before running terraform command.
e.g.  location, prefix and tags for environment and customer name

## Launching the stack.
terraform plan -out=.out.txt

## Review the stack resources and run the following command provision the enivornment.
terraform apply ".out.txt"

