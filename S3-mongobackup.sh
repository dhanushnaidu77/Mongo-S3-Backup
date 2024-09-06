#!/bin/bash


MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_DB="db_name"
BACKUP_DIR="/path/to/backup/directory"
TIMESTAMP=$(date +"%F-%H%M")
BACKUP_NAME="mongodb-backup-$TIMESTAMP"
S3_BUCKET_NAME="bucketname"
AWS_PROFILE="default"  # Change this if you use a specific AWS CLI profile


echo "Creating MongoDB backup..."
mongodump --host $MONGO_HOST --port $MONGO_PORT --db $MONGO_DB --out $BACKUP_DIR/$BACKUP_NAME

if [ $? -eq 0 ]; then
  echo "MongoDB backup successful."
else
  echo "MongoDB backup failed"
  exit 1
fi


echo "Compressing the backup..."
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz -C $BACKUP_DIR $BACKUP_NAME

if [ $? -eq 0 ]; then
  echo "Backup compression successful."
else
  echo "Backup compression failed"
  exit 1
fi


echo "Uploading backup to S3..."
aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz s3://$S3_BUCKET_NAME/ --profile $AWS_PROFILE

if [ $? -eq 0 ]; then
  echo "Backup successfully uploaded to S3."
else
  echo "Failed to upload backup"
  exit 1
fi


echo "Cleaning up local backup files..."
rm -rf $BACKUP_DIR/$BACKUP_NAME
rm $BACKUP_DIR/$BACKUP_NAME.tar.gz

echo "Backup process completed."