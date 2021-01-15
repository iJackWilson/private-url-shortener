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

resource "aws_s3_bucket" "S3Bucket" {
    bucket = "urlshortener-s3bucketforurls-typ7eb6pxavv"
}

resource "aws_lambda_function" "LambdaFunction" {
    description = ""
    environment {
        variables = {
            S3_BUCKET = "urlshortener-s3bucketforurls-typ7eb6pxavv"
        }
    }
    function_name = "URLShortener-LambdaShortener-DYGM7AIWFOPQ"
    handler = "index.handler"
    s3_bucket = "awslambda-eu-cent-1-tasks"
    s3_key = "/snapshots/271537303292/URLShortener-LambdaShortener-DYGM7AIWFOPQ-cea99048-935f-4258-b426-3b24f6a63515"
    s3_object_version = "zZeKysAIZwVbHCqsiv5g9GMi6Vetc2Fn"
    memory_size = 384
    role = "arn:aws:iam::271537303292:role/URLShortener-LambdaExecRole-P65E5YDU494S"
    runtime = "python3.6"
    timeout = 10
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "LambdaFunction2" {
    description = ""
    environment {
        variables = {
            S3_BUCKET = "urlshortener-s3bucketforurls-typ7eb6pxavv"
        }
    }
    function_name = "URLShortener-LambdaRedirector-8E96CUR90EC"
    handler = "index.handler"
    s3_bucket = "awslambda-eu-cent-1-tasks"
    s3_key = "/snapshots/271537303292/URLShortener-LambdaRedirector-8E96CUR90EC-24713968-e5ac-432b-aa7d-d1e9558feb52"
    s3_object_version = "rDD8QxwaEjv8a.2WBi2uga_SHlvVsJew"
    memory_size = 384
    role = "arn:aws:iam::271537303292:role/URLShortener-LambdaExecRole-P65E5YDU494S"
    runtime = "python3.6"
    timeout = 5
    tracing_config {
        mode = "PassThrough"
    }
}

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

