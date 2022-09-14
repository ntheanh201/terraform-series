resource "aws_s3_bucket" "static" {
  bucket = var.s3_bucket_name
  tags   = {
    Name = "Terraform Bucket"
  }
}

resource "aws_s3_bucket_acl" "static-acl" {
  bucket = var.s3_bucket_name
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "static-policy" {
  bucket = var.s3_bucket_name
  policy = file("s3_static_policy.json")
}

resource "aws_s3_bucket_website_configuration" "static-website" {
  bucket = var.s3_bucket_name
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

locals {
  mime_types = {
    html = "text/html"
  }
}

resource "aws_s3_object" "static-object" {
  for_each     = fileset(path.module, "static/*")
  bucket       = var.s3_bucket_name
  key          = replace(each.value, "static", "")
  source       = each.value
  etag         = filemd5(each.value)
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

output "s3" {
  value = { index_document = aws_s3_bucket_website_configuration.static-website.index_document }
}