# simple-etcd-backup-restore

-   Founder: Abdullah Khawer (LinkedIn: https://www.linkedin.com/in/abdullah-khawer/)
-   Version: v1.0

## Introduction

A simple etcd backup and restore solution based on bash/shell scripts to backup/restore data from/to etcd in JSON format with the ability to compress/decompress the backup file and upload/download it on/from AWS S3.

Basically, the backup script actually fetches all the keys along with their values from the latest revision and store them in a file in a JSON format while the restore script actually puts all the keys along with their values using the JSON format file that we just prepared.

## Features

-   Works even if authentication is enabled on etcd.
-   You can compress the backup file if you want.
-   You can get/put the backup files from/into AWS S3 bucket respectively if required.

## Benefits

-   Speeds up the process of backup and restore.
-   Reduces the size of backup files.
-   Data remains readable as JSON.

## Components Used

Following are the components used in this framework:
-   etcd key-value store/database.
-   Bash/Shell scripts having the main logic for backup and restore data in etcd.
-   etcdctl to communicate with etcd.
-   sed for data formatting.
-   jq to convert data into JSON.
-   tar to compress data.
-   AWS S3 Bucket to store backup files.
-   AWS CLI to access AWS S3 bucket.

## Usage Notes

### Backup

```
etcd-backup.sh - Backup data from etcd in .json format file. Compress and/or upload it in .tar format to AWS S3 bucket if desired.

Usage: etcd-backup.sh [Options]

Options:
-h, --help                           show brief help
--host=ETCD_HOST                     specify etcd host (e.g., 172.168.0.4:2379)
--user=ETCD_USER                     specify etcd username (e.g., root)
--password=ETCD_PASSWORD             specify etcd password (e.g., password)
--compress=ENABLE_COMPRESSION        specify whether to compress data or not (e.g., true)
--s3-bucket=BACKUP_S3_BUCKET_PATH    specify AWS S3 bucket name with path if any (e.g., my-s3-bucket/backups)

Examples:
bash etcd-backup.sh
bash etcd-backup.sh --host=172.168.0.5:2379
bash etcd-backup.sh --host=172.125.0.5:2379 --compress=true
bash etcd-backup.sh --host=172.168.0.5:2379 --compress=true --s3-bucket=my-s3-bucket/backups
```

### Restore

```
etcd-restore.sh - Restore data to etcd from .json format file. Decompress and/or download it in .tar format from AWS S3 bucket if desired.

Usage: etcd-restore.sh [Options]

Options:
-h, --help                                show brief help
--host=ETCD_HOST                          specify etcd host (e.g., 172.168.0.4:2379)
--user=ETCD_USER                          specify etcd username (e.g., root)
--password=ETCD_PASSWORD                  specify etcd password (e.g., password)
--decompress=ENABLE_DECOMPRESSION         specify whether to decompress data or not (e.g., true)
--s3-bucket=BACKUP_S3_BUCKET_PATH_FILE    specify AWS S3 bucket name with path and file name if any (e.g., my-s3-bucket/backups/etcd-backup-json-2022-10-28-16-50.tar)

Examples:
bash etcd-restore.sh
bash etcd-restore.sh --host=172.168.0.5:2379
bash etcd-restore.sh --host=172.125.0.5:2379 --decompress=true
bash etcd-restore.sh --host=172.168.0.5:2379 --decompress=true --s3-bucket=my-s3-bucket/backups/etcd-backup-json-2022-10-28-16-50.tar
```

#### *Any contributions, improvements and suggestions will be highly appreciated.*
