terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "s3_random_id" {
 byte_length = 4
}

resource "aws_s3_bucket" "s3-remote-backend-terraform" {
  bucket = "s3-remote-backend-terraform-${random_id.s3_random_id.hex}"

  tags = {
    Name = "s3-remote-backend-terraform-${random_id.s3_random_id.hex}"
  }
}

resource "aws_s3_bucket_versioning" "s3-remote-backend-terraform_version" {

  bucket = aws_s3_bucket.s3-remote-backend-terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {

  bucket = aws_s3_bucket.s3-remote-backend-terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "remote_backend_bucket_policy" {
  bucket = aws_s3_bucket.s3-remote-backend-terraform.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowTerraformAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.terraform_state_role.arn
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3-remote-backend-terraform.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3-remote-backend-terraform.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform_state_lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform_state_lock"
  }
}

resource "aws_iam_role" "terraform_state_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "terraform_state_role"
  }
}

resource "aws_iam_policy" "terraform_state_policy" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::s3-remote-backend-terraform-${random_id.s3_random_id.hex}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:209479301555:table/terraform_state_lock"
      }
    ]
  })

  tags = {
    Name = "terraform_state_policy"
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.terraform_state_role.name
  policy_arn = aws_iam_policy.terraform_state_policy.arn
}
