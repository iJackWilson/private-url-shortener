# https://www.terraform.io/downloads.html

terraform {
  backend "s3" {
    bucket = "tfstate.jackwilson.uk"
    key    = "urlshortener.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
    region = "eu-central-1"
}

##############################
# CloudFront Distribution
##############################

resource "aws_cloudfront_distribution" "CloudFrontDistribution" {
//    aliases = [
//      "j-w.io",
//      "l.j-w.io"
//  ]
    origin {
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy = "match-viewer"
            origin_read_timeout = 30
            origin_ssl_protocols = [
                "TLSv1.2"
            ]
        }
        domain_name = "ddwlxseff8.execute-api.eu-central-1.amazonaws.com"
        origin_id = "OriginAPIGW"
        origin_path = "/prod"
    }
    default_cache_behavior {
        cached_methods  = [
            "GET",
            "HEAD"
        ]
        allowed_methods = [
            "HEAD",
            "GET"
        ]
        compress = false
        default_ttl = 86400
        forwarded_values {
            cookies {
                forward = "none"
            }
            query_string = false
        }
        max_ttl = 31536000
        min_ttl = 0
        smooth_streaming  = false
        target_origin_id = "OriginAPIGW"
        viewer_protocol_policy = "redirect-to-https"
    }
    ordered_cache_behavior {
        cached_methods  = [
            "GET",
            "HEAD"
        ]
        allowed_methods = [
            "HEAD",
            "DELETE",
            "POST",
            "GET",
            "OPTIONS",
            "PUT",
            "PATCH"
        ]
        compress = false
        default_ttl = 86400
        forwarded_values {
            cookies {
                forward = "none"
            }
            headers = [
                "Authorization"
            ]
            query_string = false
        }
        max_ttl = 31536000
        min_ttl = 0
        path_pattern = "/admin_*"
        smooth_streaming = false
        target_origin_id = "OriginAPIGW"
        viewer_protocol_policy = "https-only"
    }
    ordered_cache_behavior {
        cached_methods  = [
            "GET",
            "HEAD"
        ]
        allowed_methods = [
            "HEAD",
            "GET"
        ]
        compress = false
        default_ttl = 0
        forwarded_values {
            cookies {
                forward = "none"
            }
            headers = [
                "Authorization"
            ]
            query_string = false
        }
        max_ttl = 0
        min_ttl = 0
        path_pattern = "/"
        smooth_streaming = false
        target_origin_id = "OriginAPIGW"
        viewer_protocol_policy = "redirect-to-https"
    }
    comment = "CloudFront distribution used as a front end to the server-less URL Shortener"
    price_class = "PriceClass_All"
    enabled = true
    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:271537303292:certificate/0b5779b0-125d-4cec-98e9-946fcfc687b6"
        minimum_protocol_version = "TLSv1.2_2019"
        ssl_support_method = "sni-only"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    http_version = "http1.1"
    is_ipv6_enabled = true
}

##############################
# S3 Bucket
##############################

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
  }
}

##############################
# Redirect Lambda
##############################

resource "aws_lambda_function" "redirect" {
    description = ""
    
    filename = "../source/redirect.py.zip"

    function_name = "URLShortener-LambdaShortener-DYGM7AIWFOPQ"
    handler = "index.handler"
    memory_size = 384
    role = "arn:aws:iam::271537303292:role/URLShortener-LambdaExecRole-1QC699RU3EOPA"
    runtime = "python3.6"
    timeout = 10
    tracing_config {
        mode = "PassThrough"
    }
}

##############################
# Shorten Lambda
##############################

resource "aws_lambda_function" "shorten" {
    description = ""

    filename = "../source/shorten.py.zip"
    
    function_name = "URLShortener-LambdaRedirector-8E96CUR90EC"
    handler = "index.handler"
    memory_size = 384
    role = "arn:aws:iam::271537303292:role/URLShortener-LambdaExecRole-1QC699RU3EOPA"
    runtime = "python3.6"
    timeout = 5
    tracing_config {
        mode = "PassThrough"
    }
}

##############################
# API Gateway
##############################

resource "aws_api_gateway_rest_api" "ApiGatewayRestApi" {
    name = "URLShortener-LambdaShortener-DYGM7AIWFOPQ"
    description = "Rest API for URL Shortener"
    api_key_source = "HEADER"
    endpoint_configuration {
        types = [
            "EDGE"
        ]
    }
}

