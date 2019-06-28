
s# echo "Enter the name of the Vpc you want to add your AMI"
# read vpcName

# vpcId=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpcName" --output text --query 'Vpcs[0].VpcId' 2> /dev/null)
# echo $vpcId
# if [ "$vpcId" = "None" ]
# then
#     echo "No vpc with the name $vpcName exists"
#     exit
# fi

# subnetId=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcId" --output text \
# --query 'Subnets[0].SubnetId' 2> /dev/null)
# echo $subnetId
# if [ "$subnetId" = "None" ]
# then
#     echo "No Subnets exists in $vpcName"
#     exit
# fi

# status=$(packer validate centos-ami-template.json)
# if [ $? -ne 0 ]
# then
#     echo $status
#     exit
# fi

# sgId=$(aws ec2 create-security-group --group-name EC2WebAppSG \
# --description "Allows all TCP,SSH connections in & out" \
# --vpc-id $vpcId --output text --query GroupId 2> /dev/null)
# echo $sgId
# if [ "$sgId" = "" ]
# then
#     echo "Not able to create security group"
#     exit
# fi

# status=$(aws ec2 revoke-security-group-egress --group-id $sgId --protocol all \
# --cidr 0.0.0.0/0)
# if [ $? -ne 0 ]
# then
#     echo "failed to revoke all rule"
#     exit
# fi

# status=$(aws ec2 authorize-security-group-egress --group-id $sgId --protocol tcp \
# --cidr 0.0.0.0/0 --port 8080)
# if [ $? -ne 0 ]
# then
#     echo "failed to add outbound rule"
#     exit
# fi

# status=$(aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp \
# --cidr 0.0.0.0/0 --port 8080)
# if [ $? -ne 0 ]
# then
#     echo "failed to add inbound rule"
#     exit
# fi

# status=$(aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp \
# --cidr 0.0.0.0/0 --port 22)
# if [ $? -ne 0 ]
# then
#     echo "failed to add inbound rule"
#     exit
# fi

# status=$(packer validate centos-ami-template.json)
# if [ $? -eq 0 ]
# then
#     echo $status
# fi


# packer build -var "subnetId=$subnetId" -var "vpcId=$vpcId" -var "securityGroupId=$securityGroupId" centos-ami-template.json

packer build centos-ami-template.json