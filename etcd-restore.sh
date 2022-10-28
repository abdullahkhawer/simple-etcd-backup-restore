#!/bin/bash

if [ -z "$1" ]; then echo "ERROR: JSON Backup File Name from S3 is Empty." && exit 0; fi

# Create variables
BACKUP_S3_BUCKET_NAME=${BACKUP_S3_BUCKET_NAME}
ETCD_HOST=$(hostname -i):2379
ETCD_USER=$(/usr/local/bin/aws ssm get-parameter --name ${ETCD_USERNAME_PARAMETER_NAME} --with-decryption --output text --query Parameter.Value)
ETCD_PASSWORD=$(/usr/local/bin/aws ssm get-parameter --name ${ETCD_PASSWORD_PARAMETER_NAME} --with-decryption --output text --query Parameter.Value)

# Download compressed backup json file from S3
/usr/local/bin/aws s3 cp s3://$BACKUP_S3_BUCKET_NAME/backups/$1 etcd-snapshot-json.tar

# Decompress backup json file
tar -xf etcd-snapshot-json.tar etcd-snapshot.json

# Restore etcd from backup json file
cat etcd-snapshot.json \
    | jq -r $'keys[] as $k | "\'\($k)\' \'\(.[$k])\'"' \
    | while read LINE; do eval "/usr/bin/etcd/etcdctl --user=$ETCD_USER --password=$ETCD_PASSWORD --endpoints=$ETCD_HOST put ${LINE}"; done
echo "etcd restored from etcd-snapshot.json"

# Delete local files
rm -rf etcd-snapshot*