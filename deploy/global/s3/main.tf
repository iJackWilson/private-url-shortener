resource "aws_s3_bucket" "b" {
  bucket = "private-url-shortener.jackwilson.uk"
  acl    = "public-read"
  
  lifecycle_rule {
    id		= "DisposeShortUrls"
    enabled	= true
    prefix 	= "u/"
    
    expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
 }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

resource "aws_s3_bucket_object" "object" {

  bucket = "private-url-shortener.jackwilson.uk"

  key    = "index.html"

  acl    = "public-read"

  source = "../../../source/index.html"
}
