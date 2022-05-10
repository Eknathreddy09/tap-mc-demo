#!/bin/bash
read -p "Enter the number of attendees for the workshop: " usercount
read -p "Enter Azure Subscription ID: " subscription
read -p "Enter the region to deploy AKS Cluster: " regionaks
read -p "Enter the region to deploy EKS Cluster: " regioneks
echo "#################  Installing AZ cli #####################"
#curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo "#################  Authenticate to Azure portal #####################"
az login
aws configure
read -p "Enter AWS session token: " aws_token
aws configure set aws_session_token $aws_token
echo "#################  Creating Resource group in Azure region: $regionaks #####################"
az group create --name tapdemo-mc-cluster-RG --location $regionaks --subscription $subscription
echo "################## Creating IAM Roles for EKS Cluster and nodes ###################### "
cat <<EOF > cluster-role-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
cat <<EOF > node-role-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
aws iam create-role --role-name tap-EKSClusterRole --assume-role-policy-document file://"cluster-role-trust-policy.json"
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy --role-name tap-EKSClusterRole
aws iam create-role --role-name tap-EKSNodeRole --assume-role-policy-document file://"node-role-trust-policy.json"
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy --role-name tap-EKSNodeRole
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name tap-EKSNodeRole
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy --role-name tap-EKSNodeRole

echo "########################### Creating VPC Stacks in Amazon through cloud formation ##############################"
aws cloudformation create-stack --region $regioneks --stack-name tap-demo-vpc-stack --template-url https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
echo "############## Waiting for VPC stack to get created ###################"
echo "############## Paused for 5 mins ##########################"
sleep 300
pubsubnet1=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=tap-demo-vpc-stack-PublicSubnet01 --query Subnets[0].SubnetId --output text)
pubsubnet2=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=tap-demo-vpc-stack-PublicSubnet02 --query Subnets[0].SubnetId --output text)
rolearn=$(aws iam get-role --role-name tap-EKSClusterRole --query Role.Arn --output text)
sgid=$(aws ec2 describe-security-groups --filters Name=description,Values="Cluster communication with worker nodes" --query SecurityGroups[0].GroupId --output text)

u=$usercount
if [ $u -lt 10 ];
then

for i in $(seq $u)
do
echo "#################  Creating $u AKS clusters in region: $regionaks #####################"
echo "#################  Creating build cluster in AKS ######################"
        az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s00$i-build --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1

echo "#################  Creating Run cluster in AKS ######################"
az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s00$i-run --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1

echo "#################  Creating View cluster in EKS ######################"
ekscreatecluster=$(aws eks create-cluster --region $regioneks --name partnersetap-w01-s00$i-view --kubernetes-version 1.21 --role-arn $rolearn --resources-vpc-config subnetIds=$pubsubnet1,$pubsubnet2,securityGroupIds=$sgid)
aws eks update-kubeconfig --region $regioneks --name partnersetap-w01-s00$i-view
rolenodearn=$(aws iam get-role --role-name tap-EKSNodeRole --query Role.Arn --output text)
sleep 600
echo "#################  Creating Node group for View cluster partnersetap-w01-s00$i-view in EKS ######################"
aws eks create-nodegroup --cluster-name partnersetap-w01-s00$i-view --nodegroup-name partnersetap-w01-s00$i-view-ng --node-role $rolenodearn --instance-types t2.2xlarge --scaling-config minSize=1,maxSize=1,desiredSize=1 --disk-size 40  --subnets $pubsubnet1

done
else
for i in $(seq 1 9)
do
echo "#################  Creating $u AKS clusters in region: $regionaks #####################"
echo "#################  Creating build cluster in AKS ######################"
az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s00$i-build --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1
echo "#################  Creating Run cluster in AKS ######################"
az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s00$i-run --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1
echo "#################  Creating View cluster in EKS ######################"
ekscreatecluster=$(aws eks create-cluster --region $regioneks --name partnersetap-w01-s00$i-view --kubernetes-version 1.21 --role-arn $rolearn --resources-vpc-config subnetIds=$pubsubnet1,$pubsubnet2,securityGroupIds=$sgid)
aws eks update-kubeconfig --region $regioneks --name partnersetap-w01-s00$i-view
rolenodearn=$(aws iam get-role --role-name tap-EKSNodeRole --query Role.Arn --output text)
sleep 600
echo "#################  Creating Node group for View cluster partnersetap-w01-s00$i-view in EKS ######################"
aws eks create-nodegroup --cluster-name partnersetap-w01-s00$i-view --nodegroup-name partnersetap-w01-s00$i-view-ng --node-role $rolenodearn --instance-types t2.2xlarge --scaling-config minSize=1,maxSize=1,desiredSize=1 --disk-size 40  --subnets $pubsubnet1
done
for i in $(seq 10 $u)
do
echo "#################  Creating build cluster in AKS ######################"
az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s0$i-build --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1
echo "#################  Creating Run cluster in AKS ######################"
az aks create --resource-group tapdemo-mc-cluster-RG --name partnersetap-w01-s0$i-run --subscription $subscription --node-count 1 --enable-addons monitoring --generate-ssh-keys --node-vm-size Standard_D8S_v3 -z 1 --enable-cluster-autoscaler --min-count 1 --max-count 1
echo "#################  Creating View cluster in EKS ######################"
ekscreatecluster=$(aws eks create-cluster --region $regioneks --name partnersetap-w01-s0$i-view --kubernetes-version 1.21 --role-arn $rolearn --resources-vpc-config subnetIds=$pubsubnet1,$pubsubnet2,securityGroupIds=$sgid)
aws eks update-kubeconfig --region $regioneks --name partnersetap-w01-s0$i-view
rolenodearn=$(aws iam get-role --role-name tap-EKSNodeRole --query Role.Arn --output text)
sleep 600
echo "#################  Creating Node group for View cluster partnersetap-w01-s0$i-view in EKS ######################"
aws eks create-nodegroup --cluster-name partnersetap-w01-s0$i-view --nodegroup-name partnersetap-w01-s0$i-view-ng --node-role $rolenodearn --instance-types t2.2xlarge --scaling-config minSize=1,maxSize=1,desiredSize=1 --disk-size 40  --subnets $pubsubnet1
done
fi
