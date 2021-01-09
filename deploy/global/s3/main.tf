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
