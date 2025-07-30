output "s3_arn" {
 description = "arn of s3 bucket"
 value = aws_s3_bucket.s3_remote_backend.arn
}

output "dynamodb_arn" {
 description = "arn oddynamodb"
 value = aws_dynamodb_table.terraform_state_lock.arn
}

output"IAM_role_arn" {
 description = "arn of iam role"
 value = aws_iam_role.terraform_state_lock.arn
}