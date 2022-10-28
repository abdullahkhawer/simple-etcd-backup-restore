#!/bin/bash
set -e

# create default variables
TIMESTAMP=`date +%F-%H-%M`
ETCD_HOST="0.0.0.0:2379"
ETCD_USER=""
ETCD_PASSWORD=""
ENABLE_DECOMPRESSION=""
BACKUP_S3_BUCKET_PATH_FILE=""

# handle input
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "etcd-restore.sh - Restore data to etcd from .json format file. Decompress and/or download it in .tar format from AWS S3 bucket if desired."
      echo ""
      echo "Usage: etcd-restore.sh [Options]"
      echo ""
      echo "Options:"
      echo "-h, --help                                show brief help"
      echo "--host=ETCD_HOST                          specify etcd host (e.g., 172.168.0.4:2379)"
      echo "--user=ETCD_USER                          specify etcd username (e.g., root)"
      echo "--password=ETCD_PASSWORD                  specify etcd password (e.g., password)"
      echo "--decompress=ENABLE_DECOMPRESSION         specify whether to decompress data or not (e.g., true)"
      echo "--s3-bucket=BACKUP_S3_BUCKET_PATH_FILE    specify AWS S3 bucket name with path and file name if any (e.g., my-s3-bucket/backups/etcd-backup-json-2022-10-28-16-50.tar)"
      echo ""
      echo "Examples:"
      echo "bash etcd-restore.sh"
      echo "bash etcd-restore.sh --host=172.168.0.5:2379"
      echo "bash etcd-restore.sh --host=172.125.0.5:2379 --decompress=true"
      echo "bash etcd-restore.sh --host=172.168.0.5:2379 --decompress=true --s3-bucket=my-s3-bucket/backups/etcd-backup-json-2022-10-28-16-50.tar"
      exit 0
      ;;
    --host*)
      export ETCD_HOST=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --user*)
      export ETCD_USER=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --password*)
      export ETCD_PASSWORD=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --decompress*)
      export ENABLE_DECOMPRESSION=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --s3-bucket*)
      export BACKUP_S3_BUCKET_PATH_FILE=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

# prepare etcdctl command
ETCDCTL_BASE_COMMAND="etcdctl --endpoints=$ETCD_HOST"
if [ "$ETCD_USER" ] && [ "$ETCD_PASSWORD" ]
then
  ETCDCTL_BASE_COMMAND="etcdctl --user=$ETCD_USER --password=$ETCD_PASSWORD --endpoints=$ETCD_HOST"
fi

# download compressed backup .tar file from on AWS S3 bucket
if [ "$BACKUP_S3_BUCKET_PATH_FILE" ]
then
    aws s3 cp s3://$BACKUP_S3_BUCKET_PATH_FILE etcd-backup-json.tar
    echo "etcd compressed backup .tar file downloaded from AWS S3 bucket."
fi

# decompress backup .tar file into .json file
if [ "$ENABLE_DECOMPRESSION" = "true" ]
then
    tar -xf etcd-backup-json.tar etcd-backup.json
    echo "etcd backup .tar file decompressed in etcd-backup.json file."
fi

# restore etcd backup from .json file
cat etcd-backup.json \
    | jq -r $'keys[] as $k | "\'\($k)\' \'\(.[$k])\'"' \
    | while read LINE; do eval "$ETCDCTL_BASE_COMMAND put ${LINE}"; done
echo "etcd backup in JSON format restored from etcd-backup.json file."

# delete local files
rm -rf etcd-snapshot*
