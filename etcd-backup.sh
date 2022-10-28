#!/bin/bash
set -e

# create default variables
TIMESTAMP=`date +%F-%H-%M`
ETCD_HOST="0.0.0.0:2379"
ETCD_USER=""
ETCD_PASSWORD=""
ENABLE_COMPRESSION=""
BACKUP_S3_BUCKET_PATH=""

# handle input
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "etcd-backup.sh - Backup data from etcd in .json format file. Compress and/or upload it in .tar format to AWS S3 bucket if desired."
      echo ""
      echo "Usage: etcd-backup.sh [Options]"
      echo ""
      echo "Options:"
      echo "-h, --help                           show brief help"
      echo "--host=ETCD_HOST                     specify etcd host (e.g., 172.168.0.4:2379)"
      echo "--user=ETCD_USER                     specify etcd username (e.g., root)"
      echo "--password=ETCD_PASSWORD             specify etcd password (e.g., password)"
      echo "--compress=ENABLE_COMPRESSION        specify whether to compress data or not (e.g., true)"
      echo "--s3-bucket=BACKUP_S3_BUCKET_PATH    specify AWS S3 bucket name with path if any (e.g., my-s3-bucket/backups)"
      echo ""
      echo "Examples:"
      echo "bash etcd-backup.sh"
      echo "bash etcd-backup.sh --host=172.168.0.5:2379"
      echo "bash etcd-backup.sh --host=172.125.0.5:2379 --compress=true"
      echo "bash etcd-backup.sh --host=172.168.0.5:2379 --compress=true --s3-bucket=my-s3-bucket/backups"
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
    --compress*)
      export ENABLE_COMPRESSION=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --s3-bucket*)
      export BACKUP_S3_BUCKET_PATH=`echo $1 | sed -e 's/^[^=]*=//g'`
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

# take etcd backup in .json file
index=1
echo "{" > etcd-backup.json
eval "$ETCDCTL_BASE_COMMAND get '' --prefix=true" \
  | while read LINE; do index=$((index+1)) && if [ $((index%2)) -eq 0 ]; then printf "\"${LINE}\":"; else echo "\"${LINE}\""; fi; done \
  | sed '$!s/$/,/' >> etcd-backup.json
echo "}" >> etcd-backup.json
JSON_DATA=$(cat etcd-backup.json)
echo "$JSON_DATA" | jq '.' > etcd-backup.json
echo "etcd backup in .json format saved in etcd-backup.json file."

# compress backup .json file into .tar file with timestamp in name
if [ "$ENABLE_COMPRESSION" = "true" ]
then
  tar -cf etcd-backup-json-$TIMESTAMP.tar etcd-backup.json
  echo "etcd backup .json file compressed in etcd-backup-json-$TIMESTAMP.tar file."
fi

# upload compressed backup .tar file on AWS S3 bucket
if [ "$BACKUP_S3_BUCKET_PATH" ]
then
  aws s3 cp etcd-backup-json-$TIMESTAMP.tar s3://$BACKUP_S3_BUCKET_PATH/etcd-backup-json-$TIMESTAMP.tar
  echo "etcd compressed backup .tar file uploaded on AWS S3 bucket."
fi
