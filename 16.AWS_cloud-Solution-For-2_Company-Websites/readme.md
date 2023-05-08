# AWS Cloud Solution For Two Company Websites Using A Reserve Proxy Technology
In this project, I built a secure three-teir infrastructure solutin inside AWS VPC (Virtual Private Cloud) network for a fictitious company that uses WordPress CMS for its corperate website, and a [Tooling](https://github.com/Isaac-Ayanda/tooling) Website for their DevOps team - As part of the company’s desire for improved security and performance, a decision has been made to realize the infrastructure setup using NGINX reverse proxy technology. The infrastructure would need to be resilient and at optimized cost.

## Project Architecture Diagram
#
![](./images/architecture.png)

## First Step: Setup a Virtual Private Network (VPC)

1. Create a [VPC](https://console.aws.amazon.com/vpc/home) on Amazon Web Services portal.

![create VPC](./images/create-vpcs.jpg)
![create VPC](./images/create-vpcs2.jpg)

2. Edit and enable DNS hostnames.

![enable DNS hostnames](./images/enable-dnshn.jpg)

3. Create Internet G
gateway and attach it to the VPC.

![create internet gateway and attach it to vpc](./images/create-igw.jpg)
![create internet gateway and attach it to vpc](./images/attach-to-vpc.jpg)
![create internet gateway and attach it to vpc](./images/attach-to-vpc1.jpg)

4. Create public subnet and availability zone using an allocation scheme.

![create subnet](./images/create-subnet1.jpg)
![create subnet](./images/create-subnet2.jpg)
![create subnet](./images/create-subnet3.jpg)
![create subnet](./images/create-subnet4.jpg)
![create subnet](./images/create-subnet5.jpg)

5. Create private subnet and availability zone using an allocation scheme.

![create subnet](./images/create-privatesub1.jpg)
![create subnet](./images/create-privatesub2.jpg)

6. Create two route tables - Public and private.

![create route table](./images/create-Routetable1.jpg)
![create route table](./images/create-Routetable2.jpg)
![create route table](./images/create-Routetable3.jpg)

7. Associate the public subnet to the public route table and associate the private subnet to the private route table via corresponding association tab.

![associate subnet to route table](./images/associate-subnet-2-routetable1.jpg)
![associate subnet to route table](./images/associate-subnet-2-routetable2.jpg)
![associate subnet to route table](./images/associate-subnet-2-routetable3.jpg)

8. Create an elastic IP that is going to be attached to the NAT gateway. 

![create elastic IP](./images/create-elasticip1.jpg)
![create elastic IP](./images/create-elasticip.jpg)
![create elastic IP](./images/create-elasticip2.jpg)
![create elastic IP](./images/create-elasticip3.jpg)

9. Edit the route of the public subnet  to use the internet gateway and edit the route of the private subnet to use the NAT gateway.

![edit the route of each route table](./images/edit-route1.jpg)
![edit the route of each route table](./images/edit-route2.jpg)
![edit the route of each route table](./images/edit-route3.jpg)
![edit the route of each route table](./images/edit-route4.jpg)
![edit the route of each route table](./images/edit-route5.jpg)

10. Create security groups for application loadbancer.

![create security group](./images/create-securitygroup1.jpg)
![create security group](./images/create-securitygroup2.jpg)
![create security group](./images/create-securitygroup3.jpg)

11. Create security group for bastion server.

![create security group](./images/create-sgbastion1.jpg)
![create security group](./images/create-sgbastion2.jpg)
![create security group](./images/create-sgbastion3.jpg)


12. Create security group for nginx reverse proxy server. Inbound rule should only allow traffic from the application loadbalancer (i.e. refering the security group of the application loadbalancer) and ensure that bastion server have ssh access to the reverse proxy server.

![create security group](./images/create-sgnginx1.jpg)
![create security group](./images/create-sgnginx2.jpg)
![create security group](./images/create-sgnginx3.jpg)

13. Create security group for the internal loadbalancer. Inbound rule allows traffic (http/https) only from nginx reverse proxy.

![create security group](./images/create-sginternallb1.jpg)
![create security group](./images/create-sginternallb2.jpg)
![create security group](./images/create-sginternallb3.jpg)

14. Create security group for the webserver such that its inbound rule should only allow SSH traffic from the Bastion and https/http traffic from the internal loadbalancer.

![create security group](./images/create-sgwebservers1.jpg)
![create security group](./images/create-sgwebservers2.jpg)
![create security group](./images/create-sgwebservers3.jpg)

15. Create security group for the data layer such that Mysql/Aurora access specified for bastion and webserver, and NFS access specified for webserver.

![create security group](./images/create-sgdatalayer1.jpg)
![create security group](./images/create-sgdatalayer2.jpg)
![create security group](./images/create-sgdatalayer3.jpg)

16. First register a domain name. This can be obtained from freenom and transfer its settings to AWS to ensure cost savings. Then go to AWS certificate manager to create the certificate to be attached to the application loadbalancer.

![create domain name](./images/create-certificate1.jpg)
![create certificate](./images/create-certificate2.jpg)
![create certificate](./images/create-certificate3.jpg)
![create certificate](./images/create-certificate4.jpg)
![create certificate](./images/create-certificate5.jpg)


17. Create Amazon Elastic file system. Add mount target (i.e. specify it in private subnets 1 and 2 and select the datalayer security group). Then create each access points for the tooling and wordpress sites on the AE file system. The webservers will have seperate mounts. This will avoid file overide.

![create Amazon Elastic file system](./images/create-aefs1.jpg)
![create Amazon Elastic file system](./images/create-aefs2.jpg)
![create Amazon Elastic file system](./images/create-aefs3.jpg)
![create Amazon Elastic file system](./images/create-aefs4.jpg)
![create Amazon Elastic file system](./images/create-aefs5.jpg)
![create Amazon Elastic file system](./images/create-aefs6.jpg)
![create Amazon Elastic file system](./images/create-aefs7.jpg)

18. Create a KMS Key to be used to encrypt the database instance, and a subnet group before creating the RDS. The kms key can be selected under production and dev/test setting to  encrypt the database but not available under the free teir.

![create RDS](./images/create-kmskey1.jpg)
![create RDS](./images/create-kmskey2.jpg)
![create RDS](./images/create-kmskey3.jpg)
![create subnet group](./images/create-subnetg1.jpg)
![create subnet group](./images/create-subnetg2.jpg)
![create subnet group](./images/create-subnetg3.jpg)
![create RDS](./images/create-rds1.png)
![create RDS](./images/create-rds2.png)
![create RDS](./images/create-rds3.png)
![create RDS](./images/create-rds5.png)
![create RDS](./images/create-rds4.png)
![create RDS](./images/create-rds6.png)


Second Step: Setup Compute Resources
1. Before creating an autoscalling group there is need to first create a target group, launch template (Consist of AMIs and user data) and Loandbalancers. The autoscalling group will make use of launch templates and loadbalancers to spinup instances. Create AMIs by launching 3 t-2micro RedHat instances for nginx, bastion and webserver then install AMI dependencies starting with the bastion server.

![create 3 instances](./images/create-3instances.jpg)

- Connect and install ami dependencies on bastion server. 
    - Run `yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`
    - `yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm`
    - `yum install wget vim python3 telnet htop git mysql net-tools chrony -y`
    - `systemctl start chronyd`
    - `systemctl enable chronyd`
![installation on bastion](./images/installation-bastion.jpg)
![installation on bastion](./images/installation-bastion1.jpg)

2. Connect and install ami dependencies on nginx reverseproxy server.
    - Run `yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`
    - `yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm`
    - `yum install wget vim python3 telnet htop git mysql net-tools chrony -y`
    - `systemctl start chronyd`
    - `systemctl enable chronyd`

![installation on nginx](./images/installation-nginx.jpg)
![installation on nginx](./images/installation-nginxx1.jpg)
![installation on nginx](./images/installation-nginxx2.jpg)
![installation on nginx](./images/installation-bastion1.jpg)

- Configure selinux policies for nginx server.
    -   Run `setsebool -P httpd_can_network_connect=1`
    -   `setsebool -P httpd_can_network_connect_db=1`
    -   `setsebool -P httpd_execmem=1`
    -   `setsebool -P httpd_use_nfs 1`

![installation on nginx](./images/installation-nginx1.jpg)

- Install the amazon efs utils for mounting the target on elastic file system.
    -   Run `git clone https://github.com/aws/efs-utils`
    -   `cd efs-utils`
    -   `yum install -y make`
    -   `yum install -y rpm-build`
    -   `make rpm`
    -   `yum install -y ./build/amazon-efs-utils*rpm`
    
![installation on nginx](./images/installation-nginx2.jpg)

- Install self-signed certificate (use the private ip dns of the nginx instance as the server host name).
    -   Run `sudo mkdir /etc/ssl/private`
    -   `sudo chmod 700 /etc/ssl/private`
    -   `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ACS.key -out /etc/ssl/certs/ACS.crt`
    -   `sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048`
       
![installation on nginx](./images/installation-nginx3.jpg)

- Confirm setup by runing an ls -l command on path `/etc/ssl/certs/`

![installation on nginx](./images/installation-nginx4.jpg)

3. Connect and install ami dependencies on webserver.
 - Run `yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`
    - `yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm`
    - `yum install wget vim python3 telnet htop git mysql net-tools chrony -y`
    - `systemctl start chronyd`
    - `systemctl enable chronyd`

![installation on webserver](./images/installation-webserver1.jpg)

- Configure selinux policies for webserver.
    -   Run `setsebool -P httpd_can_network_connect=1`
    -   `setsebool -P httpd_can_network_connect_db=1`
    -   `setsebool -P httpd_execmem=1`
    -   `setsebool -P httpd_use_nfs 1`

![installation on nginx](./images/installation-webserver2.jpg)

- Install the amazon efs utils for mounting the target on elastic file system.
    -   Run `git clone https://github.com/aws/efs-utils`
    -   `cd efs-utils`
    -   `yum install -y make`
    -   `yum install -y rpm-build`
    -   `make rpm`
    -   `yum install -y ./build/amazon-efs-utils*rpm`
    
![installation on webserver](./images/installation-webserver3.jpg)

- Install self-signed certificate using apache setup (use the private ip dns of the webserver instance as the server hostname). Also edit the ssl.conf file and specify the path to the ssl certificate and KEY. ie. SSLCertificateFile /etc/pki/tls/certs/ACS.crt and SSLCertificateKeyFile /etc/pki/tls/private/ACS.key)
    -   Run `yum install -y mod_ssl`
    -   `openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/ACS.key -x509 -days 365 -out /etc/pki/tls/certs/ACS.crt`
    - `vi /etc/httpd/conf.d/ssl.conf`
       
![installation on webserver](./images/installation-webserver4.jpg)
![installation on webserver](./images/installation-webserver5.jpg)

4. Create AMI from each of the instances.

![create image from webserver](./images/create-ami-webserver1.jpg)
![create image from Bastion](./images/create-ami-bastion1.jpg)
![create image from nginx](./images/create-ami-nginx1.jpg)
![all amis](./images/all-amis.jpg)

5. Create target group for instances to be placed behind the loadbalancer -(then create target group. the autoscalling group will launch instance into the nginx target group) nginx, wordpress and tooling.

![create target group for nginx](./images/create-nginx-targetgroup1.jpg)
![create target group for wordpress](./images/create-wordpress-targetgroup1.jpg)
![create target group for tooling](./images/create-tooling-targetgroup1.jpg)
![all created target groups for nginx, wordpress and tooling](./images/all-target-groups.jpg)

Step Three: Configure Application Load Balancer (ALB)
1. Create loadbalancers in order to specify the target groups.

![create external loadbalancers](./images/create-ext-loadbalancer1.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer2.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer3.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer4.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer5.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer6.jpg)
![create external loadbalancers](./images/create-ext-loadbalancer7.jpg)

- Create internal loadbalancer with https protocol, two availability zones in private subnet, select internal lb security group, configure routing and select wordpress target as the existing target.

![create internal loadbalancer](./images/create-int-loadbalancer1.jpg)


- Set rules on the internal loadbalancer. Click listeners tab then click on view & edit rules. Insert rule:select Host header: tooling.mtrone.lm.

![create internal loadbalancer](./images/create-int-loadbalancer3.jpg)
![create internal loadbalancer](./images/create-int-loadbalancer4.jpg)


2. Create Launch templates.
- Create launch template for bastion server. Network interface placed in public subnet, select bastion security group, auto assign IP: enabled then go to advance details section and add the bastion user data. 

![create launch template](./images/create-launch-temp1.jpg)


- Create launch template for nginx. Placed in public subnet and add the user data. 

![create nginx launch template](./images/create-nginx-launch-temp1.jpg)

- Create launch template for wordpress in a private subnet. Webserver security group. Disable public ip. Also update the mount point to the filesystem by copying the command without the efs and also update the rds end point in the 'wordpress user data.md file. Remember to login to the rds to create the database. Also ensure all other credentials are correct.

![create wordpress launch template](./images/create-wordpress-launch-temp2.jpg)
![create wordpress launch template](./images/create-wordpress-launch-temp5.jpg)

- Create launch template for tooling using the same AMI used for wordpress. It is created in a private subnet with webserver security group. Disable public ip. Then add the user-data under advanced but ensure the credentials are correct. Update the RDS endpoint for tooling in the user data file . Also update the mount point to the assess point filesystem by copying the command without the efs. Remember to login to the RDS to create the database.

![create tooling launch template](./images/create-tooling-launch-temp1.jpg)
![create tooling launch template](./images/create-tooling-launch-temp2.jpg)
![create tooling launch template](./images/create-tooling-launch-temp3.jpg)
![create tooling launch template](./images/create-tooling-launch-temp4.jpg)
![all created launch template](./images/all-launch-template.jpg)


3. Create Autoscaling group.
- Create autoscaling group for bastion to adhere to bastion launch template with public subnet1 & public subnet2, No attached loadbalancer, ELB health checked, Target tracking scaling policy to 90 and add notifications.

![create bastion autoscalling group](./images/create-bastion-autoscalling1.jpg)
![create bastion autoscalling group](./images/create-bastion-autoscalling2.jpg)
![create bastion autoscalling group](./images/create-bastion-autoscalling3.jpg)

- Create autoscaling group for nginx with adhere to nginx launch template in public subnet1 & public subnet2, attach to existing mtrone-nginx-target HTTPS loadbalancer, ELB health checked, target tracking scaling policy value of 90 and add notifications.

![create nginx autoscalling group](./images/create-nginx-autoscalling1.jpg)

- Login to RDS via bastion to create dbs for wordpress and tooling.  

![create db on bastion](./images/create-db-onbastion1.jpg)

- Create autoscaling group for wordpress. (ensure target group are healthy before proceeding) Create autoscaling group for wordpress with adhere to wordpress launch template in private subnet1 & private subnet2, attach to existing mtrone-wordpress-target HTTPS loadbalancer, ELB health checked, target tracking scaling policy value of 90 and add notifications. 

![create wordpress autoscalling group](./images/create-wordpress-autosg1.jpg)
![create wordpress autoscalling group](./images/create-wordpress-autosg2.jpg)
![create wordpress autoscalling group](./images/create-wordpress-autosg3.jpg)

![create wordpress autoscalling group](./images/create-tooling-autosg2.jpg)


- Create autoscaling group for tooling. Create autoscaling group for tooling with adhere to tooling launch template in private subnet1 & private subnet2, attach to existing mtrone-tooling-target HTTPS loadbalancer, ELB health checked, target tracking scaling policy value of 90 and add notifications. 

![create tooling autoscalling group](./images/create-tooling-autosg1.jpg)
![create tooling autoscalling group](./images/create-tooling-autosg2.jpg)
![create tooling autoscalling group](./images/create-tooling-autosg3.jpg)


- Add further records to mtrone.ml domain at route 53 for the loadbalancer.
- Current status:
![current status](./images/status-route53.jpg)

- Create record for tooling. i.e for every request the domain receives it should be forwarded to the loadbalancer.

![create record](./images/status-route531.jpg)
![create record](./images/status-route532.jpg)
![create record](./images/status-route533.jpg)

- The tooling and wordpress websites accessible via web browser follows:

![website accessible](./images/url-access1.jpg)
![website accessible](./images/url-access2.jpg)
