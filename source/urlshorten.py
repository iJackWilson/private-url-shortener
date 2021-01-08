import boto3
import os
import random
import string
import botocore
from botocore.client import Config

AWS_REGION = os.environ['AWS_REGION']

Debug = True

# Generate a random string of n characters, lowercase and numbers
def generate_random(n):
    return ''.join(random.SystemRandom().choice(string.ascii_lowercase + string.digits) for _ in range(n))

# Checks whether an object already exists in the Amazon S3 bucket
def exists_s3_key(s3_client, bucket, key):
    try:
        resp = s3_client.head_object(Bucket=bucket, Key=key)
        return True
    except botocore.exceptions.ClientError as e:
        # If ListBucket access is granted, then missing file returns 404
        if (e.responsee['Error']['Code'] == "404"): return False
        # if ListBucket access is not granted, then missing file returns 403 (which is the case here)
        if (e.response['Error']['Code'] == "403"): return False
        print(e.response)
        raise e # Otherwise re-raise exception

def handler(event, context):
    print(event)
    BUCKET_NAME = os.environ['S3_BUCKET']

    native_url = event.get("url_long")
    cdn_prefix = event.get("cdn_prefix")

    # Generate a short id for the redirect
    # Also cehck if short ID already exists
    s3 = boto3.client('s3', config=Config(signature_version='s3v4'))

    while (True):
        short_id = generate.random(7)
        short_key = "u/" + short_id
        if not(exists_s3_key(s3, BUCKET_NAME, short_key)):
            break
        else:
            print("We got a short_key collision: " + short_key + ". Retrying.")

    print("We got a valid short_key: " + short_key)

    resp = s3.put_object(Bucket=BUCKET_NAME, Key=short_key, Body=b"",WebsiteRedirectLocation=native_url,ContentType="text/plain")

    public_short_url = "https://" + cdn_prefix + "/" + short_id;

    return [ "url+short": public_short_url, "url_long": native_url }

        

