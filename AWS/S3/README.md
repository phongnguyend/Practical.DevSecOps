## Amazon S3 Storage Classes
 - [Performance across the S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/)
 - [Amazon S3 pricing](https://aws.amazon.com/s3/pricing/)
 - [How to Cut your S3 Cost in Half by Using the S3 Infrequent Access Storage Class](https://www.concurrencylabs.com/blog/save-money-using-s3-infrequent-access/)
 - [Amazon S3 – Object Expiration](https://aws.amazon.com/blogs/aws/amazon-s3-object-expiration/)
 - [Organizing objects in the Amazon S3 console using folders](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-folders.html)

## Useful Commands:
https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html#cli-aws-s3api
```
aws s3api list-buckets
aws s3api list-objects --bucket BUCKETNAME
aws s3api put-object --bucket BUCKETNAME --key test.txt --body d:\test.txt

aws s3api list-objects --bucket BUCKETNAME --prefix test
aws s3api list-objects --bucket BUCKETNAME --query "Contents[?contains(Key, '.txt')]"
aws s3api list-objects --bucket BUCKETNAME --query "Contents[?contains(LastModified, '2021-08-05')]"
```
