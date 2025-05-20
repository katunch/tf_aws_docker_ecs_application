output "application_pipeline_access_key" {
  value       = aws_iam_access_key.application-pipeline.id
  description = "Access key for the application pipeline"
  sensitive   = false
}

output "application_pipeline_secret_key" {
  value       = aws_iam_access_key.application-pipeline.secret
  description = "Secret key for the application pipeline"
  sensitive   = true
}

output "application_s3_access_policy_arn" {
  value       = aws_iam_policy.application-s3.arn
  description = "ARN of the application S3 access policy"
  sensitive   = false
}

output "application_user_name" {
  value       = aws_iam_user.application-task.name
  description = "IAM User name for the application"
  sensitive   = false
}

output "applicationTaskRoleArn" {
  value       = aws_iam_role.application-task-role.arn
  description = "IAM Role ARN for the application task"
  sensitive   = false
}

output "applicationTaskRoleName" {
  value       = aws_iam_role.application-task-role.name
  description = "IAM Role name for the application task"
  sensitive   = false
}

output "application_task_access_key" {
  value       = aws_iam_access_key.application-task.id
  description = "Access key for the application task"
  sensitive   = false
}

output "application_task_secret_access_key" {
  value       = aws_iam_access_key.application-task.secret
  description = "Secret key for the application task"
  sensitive   = true
}

output "application_service_name" {
  value       = aws_ecs_service.default.name
  description = "Service name for the application"
  sensitive   = false
}

output "application_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for the application."
  value       = aws_s3_bucket.application.arn
}

output "application_s3_bucket_name" {
  description = "The name of the S3 bucket for the application."
  value       = aws_s3_bucket.application.bucket
}

output "application_kms_key_arn" {
  description = "The ARN of the KMS key used for S3 bucket encryption."
  value       = aws_kms_key.s3.arn
}