variable "aws_cloudwatch_region" {
  type        = string
  description = "AWS CloudWatch region"
  default     = "eu-central-1"
}

variable "aws_cloudwatch_log_retention" {
  type        = number
  description = "AWS CloudWatch log retention in days"
  default     = 14
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "applicationName" {
  type        = string
  description = "Name of the application"
  validation {
    condition     = length(var.applicationName) <= 32
    error_message = "The variable 'applicationName' must not exceed 32 characters in length."
  }
}

variable "application_S3_bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket"
}

variable "application_fqdn" {
  type        = string
  description = "value for the development backend fqdn"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster"
}

variable "ecs_capacity_provider" {
  type        = string
  description = "The name of the ECS capacity provider"
  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT"], var.ecs_capacity_provider)
    error_message = "Capacity provider must be either FARGATE or FARGATE_SPOT"
  }
  default = "FARGATE_SPOT"
}

variable "route53_zone_id" {
  type        = string
  description = "The ID of the Route53 hosted zone"
}

variable "lb_dns_name" {
  type        = string
  description = "The DNS name of the load balancer"
}

variable "lb_listener_arn" {
  type        = string
  description = "The ARN of the load balancer listener"
}

variable "lb_zone_id" {
  type        = string
  description = "The zone ID of the load balancer"
}

variable "private-subnet-id" {
  type        = string
  description = "The ID of the private subnet"
}

variable "security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups"
}

variable "ecr_access_policy_arn" {
  type        = string
  description = "The ARN of the ECR access policy"
}

variable "applicationTaskEcrArn" {
  type        = string
  description = "The ARN of the ECR policy"
}

variable "applicationTaskExecutionEcrArn" {
  type        = string
  description = "The ARN of the ECR policy"
}

variable "image" {
  type        = string
  description = "The Docker image"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the application"
}

variable "environment_secrets" {
  type        = map(string)
  description = "Environment secrets for the application, stored in AWS Secrets Manager"
  default     = {}
}

variable "cpu" {
  type        = number
  description = "The amount of CPU units to reserve for the container"
  default     = 1024
}

variable "memory" {
  type        = number
  description = "The amount of memory to reserve for the container"
  default     = 3072
}

variable "container_port" {
  type        = number
  description = "The port the container listens on"
  default     = 8080
}

variable "container_healtCheck_commands" {
  type        = list(string)
  description = "The command to run to check the health of the container"
  default     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
}

variable "container_health_check_grace_period_seconds" {
  type        = number
  description = "The grace period for health checks"
  default     = 0
}

variable "host_port" {
  type        = number
  description = "The port the host listens on"
  default     = 8080
}

variable "health_check_path" {
  type        = string
  description = "The path to the health check endpoint"
  default     = "/"
}

variable "health_check_matcher" {
  type        = string
  description = "The expected response from the health check"
  default     = "200"
}

variable "desired_count" {
  type        = number
  description = "The desired number of tasks to run"
  default     = 1
}

variable "additional_domain_names" {
  type        = list(string)
  description = "Additional domain names for the application"
  default     = []
}