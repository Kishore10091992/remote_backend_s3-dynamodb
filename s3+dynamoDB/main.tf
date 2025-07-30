resource "aws_s3_bucket" "s3_remote_backend" {
 versioning {
  enabled = var.versioning
 }

 server_side_encryption_configuration {
  rule {
   apply_server_side_encription_by_default {
    sse_algorithm = "AES256"
   }
  }
 }

 tags = {
  Name = "s3_remote_backend"
 }
}

resource "aws_s3_bucket_policy" "remote_backend_bucket_policy" {
 bucket = aws_s3_bucket.s3_remote_backend.id
 policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
  {
   Sid = "TerraformStateAccess"
   Effect = "Allow"
   principal = {
    AWS = "arn_aws_iam:::role/terraform_state_role"
   }
   Action = [
    "s3:GetObject",
    "s3:PitObject",
    "s3:DeleteObject",
    "s3:ListBucket"
   ]
   Resource = [
    "arn:aws:s3:::s3_remote_backend/*"
   ]
  }
  ]
 })
}

resource "aws_dynamodb_table" "terraform_state_lock" {
 billing_mode = "PAY_PER_REQUEST"
 hash_key = "LockID"
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
  version = "2012-10-17",
  statement = [
   {
    Effect = "Allow",
    Principle = {
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
  version = "2012-10-17",
  Statement = [
   {
    Effect = "Allow"
    Action = [
     "s3:GetObject",
     "s3:PutObject",
     "s3:DeleteObject",
     "s3:ListBucket"
    ],
    Resource = [
     "arn:aws:s3:::s3_remote_backend/*"
    ]
   },
   {
   Effect = "Allow"
   Action = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:DeleteItem",
    "dynamodb:Scan",
    "dynamodb:Query",
    "dynamodb:UpdateItem"
   ],
   Resource = "arn:aws:dynamodb:us-east-1::table/terraform_state_lock"
   }
  ]
 })

 tags = {
  Name = "terraform_state_policy"
 }
}

resource "aws_iam_role_policy_attachement" "attach_policy" {
 role = aws_iam_role.terraform_state_role.name
 policy_arn = aws_iam_policy.terraform_state_policy.arn
}