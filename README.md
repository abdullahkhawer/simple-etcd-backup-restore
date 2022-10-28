# simple-etcd-backup-restore

-   Founder: Abdullah Khawer (LinkedIn: https://www.linkedin.com/in/abdullah-khawer/)
-   Version: v1.0

## Introduction

Simple etcd Backup Restore is a repository having simple bash/shell scripts to backup or restore data in etcd in JSON format.

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
-   Bash/Shell scripts having the main logic for backup and restore data in etcd.
-   etcdctl to communicate with etcd.
-   sed for data formatting.
-   jq to convert data into JSON.
-   tar to compress data.
-   AWS S3 Bucket to store backup files.
-   AWS CLI to access AWS S3 commands.

## Usage Notes

### Backup

```
etcd-backup.sh - Backup data in etcd in JSON format.
 
Usage: etcd-backup.sh [Options]
 
Options:
-h, --help                           show brief help
--host=ETCD_HOST                     specify etcd host (e.g., 172.168.0.4:2379)
--user=ETCD_USER                     specify etcd username (e.g., root)
--password=ETCD_PASSWORD             specify etcd password (e.g., password)
--compress=ENABLE_COMPRESSION        specify whether to compress data or not (e.g., true)
--s3-bucket=BACKUP_S3_BUCKET         specify AWS S3 bucket name with path (e.g., my-s3-bucket/backups)

Examples:
etcd-backup.sh
etcd-backup.sh --host=172.168.0.4:2379
etcd-backup.sh --host=172.168.0.4:2379 --compress=true
```

### Restore

```
???
```

#### *Any contributions, improvements and suggestions will be highly appreciated.*
