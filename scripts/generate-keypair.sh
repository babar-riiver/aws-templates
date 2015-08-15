#!/usr/bin/env sh
key=$(aws ec2 create-key-pair --key-name $1 --region ap-southeast-2 --query KeyMaterial --output text)

if [ $? != 0 ]; then
    exit 1
fi

echo $key > $1.pem
echo "Key $1 created and written ./$1.pem"
