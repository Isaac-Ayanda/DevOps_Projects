# 1
# VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 172.31.0.0/16 --output text --query 'Vpc.VpcId')


# 2
# Tags
NAME=k8s-cluster-from-ground-up
aws ec2 create-tags --resources ${VPC_ID} --tags Key=Name,Value=${NAME}


# 3
# Enable DNS support for the VPC
# Enable DNS support for the hostnames
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-support '{"Value": true}'
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-hostnames '{"Value": true}'
AWS_REGION=us-east-1


# 6
# Configure DHCP Options Set
DHCP_OPTION_SET_ID=$(aws ec2 create-dhcp-options --dhcp-configuration "Key=domain-name,Values=$AWS_REGION.compute.internal" "Key=domain-name-servers,Values=AmazonProvidedDNS" --output text --query 'DhcpOptions.DhcpOptionsId')


# 7
# Tag the DHCP Option set
aws ec2 create-tags --resources ${DHCP_OPTION_SET_ID} --tags Key=Name,Value=${NAME}


# 8
# Associate the DHCP Option set with the VPC
aws ec2 associate-dhcp-options --dhcp-options-id ${DHCP_OPTION_SET_ID} --vpc-id ${VPC_ID}


# 9
# Create Subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id ${VPC_ID} --cidr-block 172.31.0.0/24 --output text --query 'Subnet.SubnetId')

aws ec2 create-tags --resources ${SUBNET_ID} --tags Key=Name,Value=${NAME}


# 10
# Create Internet Gateway and attach it to the VPC
INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')
aws ec2 create-tags --resources ${INTERNET_GATEWAY_ID} --tags Key=Name,Value=${NAME}
aws ec2 attach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_ID}


# 11
# Create route tables, associate the route table to subnet, and create a route to allow external traffic to the Internet through the Internet Gateway
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id ${VPC_ID} --output text --query 'RouteTable.RouteTableId')
aws ec2 create-tags --resources ${ROUTE_TABLE_ID} --tags Key=Name,Value=${NAME}
aws ec2 associate-route-table --route-table-id ${ROUTE_TABLE_ID} --subnet-id ${SUBNET_ID}
aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${INTERNET_GATEWAY_ID}


# 12
# Create the security group and store its ID in a variable
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name ${NAME} --description "Kubernetes cluster security group" --vpc-id ${VPC_ID} --output text --query 'GroupId')
aws ec2 create-tags --resources ${SECURITY_GROUP_ID} --tags Key=Name,Value=${NAME}
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --ip-permissions IpProtocol=tcp,FromPort=2379,ToPort=2380,IpRanges='[{CidrIp=172.31.0.0/24}]'
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --ip-permissions IpProtocol=tcp,FromPort=30000,ToPort=32767,IpRanges='[{CidrIp=172.31.0.0/24}]'
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 6443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol icmp --port -1 --cidr 0.0.0.0/0


# 13
# Create a network Load balancer
LOAD_BALANCER_ARN=$(aws elbv2 create-load-balancer --name ${NAME} --subnets ${SUBNET_ID} --scheme internet-facing --type network --output text --query 'LoadBalancers[].LoadBalancerArn')

# 14
# Create a target group
TARGET_GROUP_ARN=$(aws elbv2 create-target-group --name ${NAME} --protocol TCP --port 6443 --vpc-id ${VPC_ID} --target-type ip --output text --query 'TargetGroups[].TargetGroupArn')


# 15
# Register targets
aws elbv2 register-targets --target-group-arn ${TARGET_GROUP_ARN} --targets Id=172.31.0.1{0,1,2}


# 16
# Create a listener to listen for requests and forward to the target nodes on TCP port 6443
aws elbv2 create-listener --load-balancer-arn ${LOAD_BALANCER_ARN} --protocol TCP --port 6443 --default-actions Type=forward,TargetGroupArn=${TARGET_GROUP_ARN} --output text --query 'Listeners[].ListenerArn'


# 17
# Get the Kubernetes Public address
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers --load-balancer-arns ${LOAD_BALANCER_ARN} --output text --query 'LoadBalancers[].DNSName')


# STEP 2
# 1
# Get an image to create EC2 instances
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 --filters 'Name=root-device-type,Values=ebs' 'Name=architecture,Values=x86_64' 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*' | jq -r '.Images|sort_by(.Name)[-1]|.ImageId')


# 2
# Create SSH Key-Pair
mkdir -p ssh

aws ec2 create-key-pair --key-name ${NAME} --output text --query 'KeyMaterial' > ssh/${NAME}.id_rsa

chmod 600 ssh/${NAME}.id_rsa


# 3
# Create 3 Master nodes
for i in 0 1 2; do
  instance_id=$(aws ec2 run-instances --associate-public-ip-address --image-id ${IMAGE_ID} --count 1 --key-name ${NAME} --security-group-ids ${SECURITY_GROUP_ID} --instance-type t2.micro --private-ip-address 172.31.0.1${i} --user-data "name=master-${i}" --subnet-id ${SUBNET_ID} --output text --query 'Instances[].InstanceId')

  aws ec2 modify-instance-attribute --instance-id ${instance_id} --no-source-dest-check

  aws ec2 create-tags --resources ${instance_id} --tags "Key=Name,Value=${NAME}-master-${i}"
done


# 4
# Create 3 worker nodes
for i in 0 1 2; do
  instance_id=$(aws ec2 run-instances --associate-public-ip-address --image-id ${IMAGE_ID} --count 1 --key-name ${NAME} --security-group-ids ${SECURITY_GROUP_ID} --instance-type t2.micro --private-ip-address 172.31.0.2${i} --user-data "name=worker-${i}|pod-cidr=172.20.${i}.0/24" --subnet-id ${SUBNET_ID} --output text --query 'Instances[].InstanceId')
  
  aws ec2 modify-instance-attribute --instance-id ${instance_id} --no-source-dest-check
  
  aws ec2 create-tags --resources ${instance_id} --tags "Key=Name,Value=${NAME}-worker-${i}"
done


# STEP 3
# 1
# Prepare The Self-Signed Certificate Authority And Generate TLS Certificates
mkdir ca-authority && cd ca-authority

{
cat > ca-config.json <<EOF
{
	"signing": {
		"default": {
		"expiry": "8760h"
		},
		"profiles": {
		"kubernetes": {
			"usages": ["signing", "key encipherment", "server auth", "client auth"],
			"expiry": "8760h"
			}
		}
	}
}
EOF

cat > ca-csr.json <<EOF
{
	"CN": "Kubernetes",
	"key": {
		"algo": "rsa",
		"size": 2048
	},
	"names": [
		{
		"C": "NG",
		"L": "Nigeria",
		"O": "Kubernetes",
		"OU": "YHEANCARH DEVOPS",
		"ST": "Ogun"
		}
	]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}


# 2
# Generate the Certificate Signing Request (CSR), Private Key and the Certificate for the Kubernetes Master Nodes.
{
cat > master-kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
   "hosts": [
   "127.0.0.1",
   "172.31.0.10",
   "172.31.0.11",
   "172.31.0.12",
   "ip-172-31-0-10",
   "ip-172-31-0-11",
   "ip-172-31-0-12",
   "ip-172-31-0-10.${AWS_REGION}.compute.internal",
   "ip-172-31-0-11.${AWS_REGION}.compute.internal",
   "ip-172-31-0-12.${AWS_REGION}.compute.internal",
   "${KUBERNETES_PUBLIC_ADDRESS}",
   "kubernetes",
   "kubernetes.default",
   "kubernetes.default.svc",
   "kubernetes.default.svc.cluster",
   "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "Kubernetes",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes master-kubernetes-csr.json | cfssljson -bare master-kubernetes
}


# 3
# kube-scheduler Client Certificate and Private Key
{

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "system:kube-scheduler",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler

}


# 4
# kube-proxy Client Certificate and Private Key
{

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "system:node:proxier",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy

}


# 5
# kube-controller-manager Client Certificate and Private Key
{
cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "system:kube-controller-manager",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

}


# 6
# kubelet Client Certificate and Private Key
for i in 0 1 2; do
  instance="${NAME}-worker-${i}"
  instance_hostname="ip-172-31-0-2${i}"
  cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance_hostname}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "system:nodes",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PublicIpAddress')

internal_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PrivateIpAddress')

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=${instance_hostname},${external_ip},${internal_ip} -profile=kubernetes ${NAME}-worker-${i}-csr.json | cfssljson -bare ${NAME}-worker-${i}

done

# 7
# kubernetes admin user's Client Certificate and Private Key
{
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "system:masters",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
}


# 8
# kubernetes service-account's Client Certificate and Private Key
{

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Nigeria",
      "O": "Kubernetes",
      "OU": "YHEANCARH DEVOPS",
      "ST": "Ogun"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes service-account-csr.json | cfssljson -bare service-account
}

# Step 4 – Distributing the Client and Server Certificates
# 1
# 
for i in 0 1 2; do
  instance="${NAME}-worker-${i}"

  external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PublicIpAddress')
  
  scp -i ../ssh/${NAME}.id_rsa ca.pem ${instance}-key.pem ${instance}.pem ubuntu@${external_ip}:~/; \
done


# 2
# Master or Controller node
for i in 0 1 2; do
  
  instance="${NAME}-master-${i}" external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PublicIpAddress')
  
  scp -i ../ssh/${NAME}.id_rsa ca.pem ca-key.pem service-account-key.pem service-account.pem master-kubernetes.pem master-kubernetes-key.pem ubuntu@${external_ip}:~/;

done


# STEP 5 USE `KUBECTL` TO GENERATE KUBERNETES CONFIGURATION FILES FOR AUTHENTICATION
# 1
# Generate the kubelet kubeconfig file
KUBERNETES_API_SERVER_ADDRESS=$(aws elbv2 describe-load-balancers --load-balancer-arns ${LOAD_BALANCER_ARN} --output text --query 'LoadBalancers[].DNSName')


for i in 0 1 2; do

instance="${NAME}-worker-${i}"
instance_hostname="ip-172-31-0-2${i}"

# Set the kubernetes cluster in the kubeconfig file
kubectl config set-cluster ${NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://$KUBERNETES_API_SERVER_ADDRESS:6443 --kubeconfig=${instance}.kubeconfig

# Set the cluster credentials in the kubeconfig file
kubectl config set-credentials system:node:${instance_hostname} --client-certificate=${instance}.pem --client-key=${instance}-key.pem --embed-certs=true --kubeconfig=${instance}.kubeconfig

# Set the context in the kubeconfig file
kubectl config set-context default --cluster=${NAME} --user=system:node:${instance_hostname} --kubeconfig=${instance}.kubeconfig

kubectl config use-context default --kubeconfig=${instance}.kubeconfig

done

# List 
ls -ltr *.kubeconfig

kubectl config use-context %context-name%

# 2
# Generate the kube-proxy kubeconfig
{
  kubectl config set-cluster ${NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy --client-certificate=kube-proxy.pem --client-key=kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default --cluster=${NAME} --user=system:kube-proxy --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}


# 3
# Generate the Kube-Controller-Manager kubeconfig
{
  kubectl config set-cluster ${NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager.pem --client-key=kube-controller-manager-key.pem --embed-certs=true --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default --cluster=${NAME} --user=system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}


# 4
# Generating the Kube-Scheduler Kubeconfig
{
  kubectl config set-cluster ${NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler --client-certificate=kube-scheduler.pem --client-key=kube-scheduler-key.pem --embed-certs=true --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default --cluster=${NAME} --user=system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}


# 5
# Generating the admin user Kubeconfig
{
  kubectl config set-cluster ${NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin --client-certificate=admin.pem --client-key=admin-key.pem --embed-certs=true --kubeconfig=admin.kubeconfig

  kubectl config set-context default --cluster=${NAME} --user=admin --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}



ETCD_ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ETCD_ENCRYPTION_KEY}
      - identity: {}
EOF

for i in 0 1 2; do
  
  instance="${NAME}-master-${i}" external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PublicIpAddress')
  
  scp -i ../ssh/${NAME}.id_rsa encryption-config.yaml kube-controller-manager.kubeconfig kube-scheduler.kubeconfig admin.kubeconfig ubuntu@${external_ip}:~/;

done

for i in 0 1 2; do
  instance="${NAME}-worker-${i}"

  external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance}" --output text --query 'Reservations[].Instances[].PublicIpAddress')
  
  scp -i ../ssh/${NAME}.id_rsa ${NAME}-worker-${i}.kubeconfig kube-proxy.kubeconfig admin.kubeconfig ubuntu@${external_ip}:~/; \
done

# Bootstrap etcd cluster

# 1
# Master 1
master_1_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-master-0" --output text --query 'Reservations[].Instances[].PublicIpAddress')
master_2_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-master-1" --output text --query 'Reservations[].Instances[].PublicIpAddress')
master_3_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-master-2" --output text --query 'Reservations[].Instances[].PublicIpAddress')

ssh -i ../ssh/k8s-cluster-from-ground-up.id_rsa ubuntu@${master_1_ip}
ssh -i k8s-cluster-from-ground-up.id_rsa ubuntu@${master_2_ip}
ssh -i k8s-cluster-from-ground-up.id_rsa ubuntu@${master_3_ip}


# 2
# Download and install etcd
wget -q --show-progress --https-only --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"

# 3
# Extract and install the etcd server and the etcdctl command line utility
{
	tar -xvf etcd-v3.4.15-linux-amd64.tar.gz

	sudo mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/
}

# 4
# Configure the etcd server
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo chmod 700 /var/lib/etcd
  sudo cp ca.pem master-kubernetes-key.pem master-kubernetes.pem /etc/etcd/
}

# 5
# The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance
export INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# 6
# Each etcd member must have a unique name within an etcd cluster. Set the etcd name to node Private IP address so it will uniquely identify the machine
ETCD_NAME=$(curl -s http://169.254.169.254/latest/user-data/ | tr "|" "\n" | grep "^name" | cut -d"=" -f2)

echo ${ETCD_NAME}

# 7
# Create the etcd.service systemd unit file
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master-0=https://172.31.0.10:2380,master-1=https://172.31.0.11:2380,master-2=https://172.31.0.12:2380 \\
  --cert-file=/etc/etcd/master-kubernetes.pem \\
  --key-file=/etc/etcd/master-kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/master-kubernetes.pem \\
  --peer-key-file=/etc/etcd/master-kubernetes-key.pem \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 8
# Start and enable the etcd Server
{
	sudo systemctl daemon-reload
	sudo systemctl enable etcd
	sudo systemctl start etcd
}

# 9
# Verify the etcd installation
sudo ETCDCTL_API=3 etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.pem --cert=/etc/etcd/master-kubernetes.pem --key=/etc/etcd/master-kubernetes-key.pem

systemctl status etcd

# Boostrap Control Plane
# 1
sudo mkdir -p /etc/kubernetes/config

# 2
wget -q --show-progress --https-only --timestamping "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver" "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager" "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler" "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"

# 3
{
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}

# 4
{
sudo mkdir -p /var/lib/kubernetes/

sudo mv ca.pem ca-key.pem master-kubernetes-key.pem master-kubernetes.pem service-account-key.pem service-account.pem encryption-config.yaml /var/lib/kubernetes/
}

export INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/master-kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/master-kubernetes-key.pem\\
  --etcd-servers=https://172.31.0.10:2379,https://172.31.0.11:2379,https://172.31.0.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/master-kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/master-kubernetes-key.pem \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-account-issuer=https://${INTERNAL_IP}:6443 \\
  --service-cluster-ip-range=172.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/master-kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/master-kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5

sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

export AWS_METADATA="http://169.254.169.254/latest/meta-data"
export EC2_MAC_ADDRESS=$(curl -s $AWS_METADATA/network/interfaces/macs/ | head -n1 | tr -d '/')
export VPC_CIDR=$(curl -s $AWS_METADATA/network/interfaces/macs/$EC2_MAC_ADDRESS/vpc-ipv4-cidr-block/)
export NAME=k8s-cluster-from-ground-up

cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=${VPC_CIDR} \\
  --cluster-name=${NAME} \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --authentication-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --authorization-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=172.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# 6

sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
sudo mkdir -p /etc/kubernetes/config

cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 7

{
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}

{
sudo systemctl status kube-apiserver
sudo systemctl status kube-controller-manager
sudo systemctl status kube-scheduler
}



---------------------------------------------------------------------

# Test that Everything is working fine
# 1
kubectl cluster-info  --kubeconfig admin.kubeconfig

# 2
kubectl get namespaces --kubeconfig admin.kubeconfig

# 3
curl --cacert /var/lib/kubernetes/ca.pem https://$INTERNAL_IP:6443/version

# 4
kubectl get componentstatuses --kubeconfig admin.kubeconfig

# 5
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF


cat <<EOF | kubectl --kubeconfig admin.kubeconfig  apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF





## Worker Nodes

worker_1_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-worker-0" --output text --query 'Reservations[].Instances[].PublicIpAddress')
ssh -i ../ssh/k8s-cluster-from-ground-up.id_rsa ubuntu@${worker_1_ip}

worker_2_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-worker-1" --output text --query 'Reservations[].Instances[].PublicIpAddress')
ssh -i ../ssh/k8s-cluster-from-ground-up.id_rsa ubuntu@${worker_2_ip}

worker_3_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}-worker-2" --output text --query 'Reservations[].Instances[].PublicIpAddress')
ssh -i ../ssh/k8s-cluster-from-ground-up.id_rsa ubuntu@${worker_3_ip}

{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}

sudo swapon --show

# Install Contaiinerd
wget https://github.com/opencontainers/runc/releases/download/v1.0.0-rc93/runc.amd64 https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz https://github.com/containerd/containerd/releases/download/v1.4.4/containerd-1.4.4-linux-amd64.tar.gz


# Configure Containerd
{
  mkdir containerd
  tar -xvf crictl-v1.21.0-linux-amd64.tar.gz
  tar -xvf containerd-1.4.4-linux-amd64.tar.gz -C containerd
  sudo mv runc.amd64 runc
  chmod +x  crictl runc  
  sudo mv crictl runc /usr/local/bin/
  sudo mv containerd/bin/* /bin/
}

sudo mkdir -p /etc/containerd/

cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Create Directories to configure kubelet, kubeproxy, cni
sudo mkdir -p /var/lib/kubelet /var/lib/kube-proxy /etc/cni/net.d /opt/cni/bin /var/lib/kubernetes /var/run/kubernetes

# Install CNI
wget -q --show-progress --https-only --timestamping https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz

sudo tar -xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/

# Download and install kubectl kube-proxy and kubelet
wget -q --show-progress --https-only --timestamping https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet

{
  chmod +x  kubectl kube-proxy kubelet  
  sudo mv  kubectl kube-proxy kubelet /usr/local/bin/
}

# Get the Pod CIDR
POD_CIDR=$(curl -s http://169.254.169.254/latest/user-data/ | tr "|" "\n" | grep "^pod-cidr" | cut -d"=" -f2)
echo "${POD_CIDR}"

# Configure Bridge and Loopback networks
cat > 172-20-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF

sudo mv 172-20-bridge.conf 99-loopback.conf /etc/cni/net.d/

NAME=k8s-cluster-from-ground-up
WORKER_NAME=${NAME}-$(curl -s http://169.254.169.254/latest/user-data/ | tr "|" "\n" | grep "^name" | cut -d"=" -f2)
echo "${WORKER_NAME}"

# Move certificates and kubeconfig files to their respective dir
sudo mv ${WORKER_NAME}-key.pem ${WORKER_NAME}.pem /var/lib/kubelet/
sudo mv ${WORKER_NAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

# Create kubelet-config.yaml
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "172.31.1.12"
resolvConf: "/etc/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${WORKER_NAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${WORKER_NAME}-key.pem"
EOF

# Configure kubelet systemd service
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service
[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --cluster-domain=cluster.local \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

# Create kube-proxy.yaml
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "172.31.0.0/16"
EOF

# Configure kube-proxy
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

# Reload servicea
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}

kubectl get nodes --kubeconfig admin.kubeconfig -o wide



172.31.0.10 ip-172-31-0-10
172.31.0.11 ip-172-31-0-11
172.31.0.12 ip-172-31-0-12
172.31.0.20 ip-172-31-0-20
172.31.0.21 ip-172-31-0-21
172.31.0.22 ip-172-31-0-22