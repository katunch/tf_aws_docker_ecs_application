## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_access_key.application-pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_access_key.application-task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.application-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.applicationCreateLogStreams](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecsDevDeployListTaskPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecsDevDeployPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.application-task-execution-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.application-task-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.application-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.applicationCreateLogStreams](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.applicationTaskEcr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.applicationTaskExecution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.applicationTaskExecutionEcr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.application-pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.application-task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.application-pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.application-pipeline-deploy-ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.application-pipeline-deploy-listTasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.task-s3-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb_listener_rule.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_secretsmanager_secret.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_domain_names"></a> [additional\_domain\_names](#input\_additional\_domain\_names) | Additional domain names for the application | `list(string)` | `[]` | no |
| <a name="input_applicationName"></a> [applicationName](#input\_applicationName) | Name of the application | `string` | n/a | yes |
| <a name="input_applicationTaskEcrArn"></a> [applicationTaskEcrArn](#input\_applicationTaskEcrArn) | The ARN of the ECR policy | `string` | n/a | yes |
| <a name="input_applicationTaskExecutionEcrArn"></a> [applicationTaskExecutionEcrArn](#input\_applicationTaskExecutionEcrArn) | The ARN of the ECR policy | `string` | n/a | yes |
| <a name="input_application_S3_bucket_prefix"></a> [application\_S3\_bucket\_prefix](#input\_application\_S3\_bucket\_prefix) | The prefix for the S3 bucket | `string` | n/a | yes |
| <a name="input_application_fqdn"></a> [application\_fqdn](#input\_application\_fqdn) | value for the development backend fqdn | `string` | n/a | yes |
| <a name="input_aws_cloudwatch_log_retention"></a> [aws\_cloudwatch\_log\_retention](#input\_aws\_cloudwatch\_log\_retention) | AWS CloudWatch log retention in days | `number` | `14` | no |
| <a name="input_aws_cloudwatch_region"></a> [aws\_cloudwatch\_region](#input\_aws\_cloudwatch\_region) | AWS CloudWatch region | `string` | `"eu-central-1"` | no |
| <a name="input_container_healtCheck_commands"></a> [container\_healtCheck\_commands](#input\_container\_healtCheck\_commands) | The command to run to check the health of the container | `list(string)` | <pre>[<br>  "CMD-SHELL",<br>  "curl -f http://localhost:8080/health || exit 1"<br>]</pre> | no |
| <a name="input_container_health_check_grace_period_seconds"></a> [container\_health\_check\_grace\_period\_seconds](#input\_container\_health\_check\_grace\_period\_seconds) | The grace period for health checks | `number` | `0` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container listens on | `number` | `8080` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The amount of CPU units to reserve for the container | `number` | `1024` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The desired number of tasks to run | `number` | `1` | no |
| <a name="input_ecr_access_policy_arn"></a> [ecr\_access\_policy\_arn](#input\_ecr\_access\_policy\_arn) | The ARN of the ECR access policy | `string` | n/a | yes |
| <a name="input_ecs_capacity_provider"></a> [ecs\_capacity\_provider](#input\_ecs\_capacity\_provider) | The name of the ECS capacity provider | `string` | `"FARGATE_SPOT"` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | The ARN of the ECS cluster | `string` | n/a | yes |
| <a name="input_environment_secrets"></a> [environment\_secrets](#input\_environment\_secrets) | Environment secrets for the application, stored in AWS Secrets Manager | `map(string)` | `{}` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the application | `map(string)` | n/a | yes |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | The expected response from the health check | `string` | `"200"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The path to the health check endpoint | `string` | `"/"` | no |
| <a name="input_host_port"></a> [host\_port](#input\_host\_port) | The port the host listens on | `number` | `8080` | no |
| <a name="input_image"></a> [image](#input\_image) | The Docker image | `string` | n/a | yes |
| <a name="input_lb_dns_name"></a> [lb\_dns\_name](#input\_lb\_dns\_name) | The DNS name of the load balancer | `string` | n/a | yes |
| <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn) | The ARN of the load balancer listener | `string` | n/a | yes |
| <a name="input_lb_zone_id"></a> [lb\_zone\_id](#input\_lb\_zone\_id) | The zone ID of the load balancer | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to reserve for the container | `number` | `3072` | no |
| <a name="input_private-subnet-id"></a> [private-subnet-id](#input\_private-subnet-id) | The ID of the private subnet | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | The ID of the Route53 hosted zone | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The IDs of the security groups | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applicationTaskRoleArn"></a> [applicationTaskRoleArn](#output\_applicationTaskRoleArn) | IAM Role ARN for the application task |
| <a name="output_applicationTaskRoleName"></a> [applicationTaskRoleName](#output\_applicationTaskRoleName) | IAM Role name for the application task |
| <a name="output_application_pipeline_access_key"></a> [application\_pipeline\_access\_key](#output\_application\_pipeline\_access\_key) | Access key for the application pipeline |
| <a name="output_application_pipeline_secret_key"></a> [application\_pipeline\_secret\_key](#output\_application\_pipeline\_secret\_key) | Secret key for the application pipeline |
| <a name="output_application_s3_access_policy_arn"></a> [application\_s3\_access\_policy\_arn](#output\_application\_s3\_access\_policy\_arn) | ARN of the application S3 access policy |
| <a name="output_application_service_name"></a> [application\_service\_name](#output\_application\_service\_name) | Service name for the application |
| <a name="output_application_task_access_key"></a> [application\_task\_access\_key](#output\_application\_task\_access\_key) | Access key for the application task |
| <a name="output_application_task_secret_access_key"></a> [application\_task\_secret\_access\_key](#output\_application\_task\_secret\_access\_key) | Secret key for the application task |
| <a name="output_application_user_name"></a> [application\_user\_name](#output\_application\_user\_name) | IAM User name for the application |
