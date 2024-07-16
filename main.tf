terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

resource "aws_iam_user" "application-pipeline" {
  name = "${var.applicationName}-pipeline"
  path = "/${var.applicationName}/"
}
resource "aws_iam_access_key" "application-pipeline" {
  user = aws_iam_user.application-pipeline.name
}

resource "aws_iam_user_policy_attachment" "application-pipeline" {
  user       = aws_iam_user.application-pipeline.name
  policy_arn = var.ecr_access_policy_arn
}

resource "aws_s3_bucket" "application" {
  bucket = "${var.application_S3_bucket_prefix}-${var.applicationName}"
}

data "aws_caller_identity" "current" {}
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_kms_key" "s3" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.application.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.application.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "application-s3" {
  name        = "${var.applicationName}-application-s3"
  description = "Allow S3 access for ${var.applicationName}"
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
        Resource = ["${aws_s3_bucket.application.arn}/*", aws_s3_bucket.application.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = [aws_kms_key.s3.arn]
      }
    ]
  })
}

resource "aws_iam_role" "application-task-role" {
  name = "${var.applicationName}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "application-s3" {
  role       = aws_iam_role.application-task-role.name
  policy_arn = aws_iam_policy.application-s3.arn
}

resource "aws_iam_role_policy_attachment" "applicationTaskEcr" {
  role       = aws_iam_role.application-task-role.name
  policy_arn = var.applicationTaskEcrArn
}

locals {
  environment_secrets = merge(var.environment_secrets, {
    "AWS_SDK_ACCESS_KEY" = aws_iam_access_key.application-task.id
    "AWS_SDK_SECRET"     = aws_iam_access_key.application-task.secret
  })
}


resource "aws_secretsmanager_secret_version" "application" {
  secret_id = aws_secretsmanager_secret.application.id
  secret_string = jsonencode(local.environment_secrets)
}

resource "aws_iam_role" "application-task-execution-role" {
  name = "${var.applicationName}-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "applicationTaskExecution" {
  role       = aws_iam_role.application-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "applicationTaskExecutionEcr" {
  role       = aws_iam_role.application-task-execution-role.name
  policy_arn = var.applicationTaskExecutionEcrArn
}

resource "aws_iam_policy" "applicationCreateLogStreams" {
  name        = "${var.applicationName}-create-log-streams"
  description = "Allow ECS to create log streams"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream"
        ],
        Resource = [
          "${aws_cloudwatch_log_group.application.arn}/*",
          "${aws_cloudwatch_log_group.nginx.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "applicationCreateLogStreams" {
  role       = aws_iam_role.application-task-execution-role.name
  policy_arn = aws_iam_policy.applicationCreateLogStreams.arn
}

resource "aws_iam_policy" "applicationExecutionReadSecrets" {
  name        = "${var.applicationName}-execution-read-secrets"
  description = "Allow ECS to read secrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          "${aws_secretsmanager_secret.application.arn}",
          "${aws_secretsmanager_secret.application.arn}:*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "secretsAccess" {
  role       = aws_iam_role.application-task-execution-role.name
  policy_arn = aws_iam_policy.applicationExecutionReadSecrets.arn
}

resource "aws_iam_user" "application-task" {
  name = "${var.applicationName}-task"
  path = "/${var.applicationName}/"
}
resource "aws_iam_access_key" "application-task" {
  user = aws_iam_user.application-task.name
}

resource "aws_iam_user_policy_attachment" "task-s3-access" {
  user       = aws_iam_user.application-task.name
  policy_arn = aws_iam_policy.application-s3.arn
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/ecs/${var.applicationName}"
  retention_in_days = var.aws_cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.applicationName}-nginx"
  retention_in_days = var.aws_cloudwatch_log_retention
}

resource "aws_secretsmanager_secret" "application" {
  name = "${var.applicationName}-secrets"
}

resource "aws_ecs_task_definition" "application" {
  family = "${var.applicationName}-application"
  cpu    = var.cpu
  memory = var.memory
  ephemeral_storage {
    size_in_gib = 30
  }
  container_definitions = jsonencode([
    {
      name                   = "${var.applicationName}-nginx"
      image                  = "ghcr.io/katunch/tf_aws_docker_ecs_application:v1.1.1"
      readonlyRootFilesystem = false
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.nginx.name}"
          "awslogs-region"        = var.aws_cloudwatch_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 20
        timeout     = 5
        retries     = 3
        startPeriod = 120
      }
      environment = [{
        name = "NGINX_PROXY_URL"
        value = "http://localhost:${var.container_port}"
      },
      {
        name = "NGINX_VPC_CIDR_BLOCK"
        value = data.aws_vpc.selected.cidr_block
      }]
    },
    {
      name      = var.applicationName
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.host_port
        }
      ]
      environment = [for key, value in var.environment_variables : {
        name  = key
        value = value
      }]
      secrets = [for key, value in local.environment_secrets : {
        name      = key
        valueFrom = "${aws_secretsmanager_secret.application.arn}:${key}::"
      }]
      healthCheck = {
        command     = var.container_healtCheck_commands
        interval    = 20
        timeout     = 5
        retries     = 3
        startPeriod = 120
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.application.name
          "awslogs-region"        = var.aws_cloudwatch_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.application-task-execution-role.arn
  task_role_arn      = aws_iam_role.application-task-role.arn
}

resource "aws_lb_target_group" "application" {
  name        = var.applicationName
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  slow_start  = 90
  health_check {
    path                = var.health_check_path
    interval            = 60
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = var.health_check_matcher
  }
}

resource "aws_route53_record" "application" {
  zone_id = var.route53_zone_id
  name    = var.application_fqdn
  type    = "A"
  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener_rule" "application" {
  listener_arn = var.lb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
  condition {
    host_header {
      values = concat([var.application_fqdn], var.additional_domain_names)
    }
  }
}

resource "aws_ecs_service" "default" {
  name                              = var.applicationName
  cluster                           = var.ecs_cluster_arn
  task_definition                   = aws_ecs_task_definition.application.arn
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.container_health_check_grace_period_seconds

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider
    weight            = 1
    base              = 1
  }

  network_configuration {
    subnets          = [var.private-subnet-id]
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.application.arn
    container_name   = "${var.applicationName}-nginx"
    container_port   = 80
  }

  depends_on = [
    aws_ecs_task_definition.application,
    aws_iam_role.application-task-execution-role,
    aws_iam_role.application-task-role,
    aws_lb_target_group.application
  ]
}

resource "aws_iam_policy" "ecsDevDeployPolicy" {
  name        = "${var.applicationName}-ecsDevDeployPolicy"
  description = "Policy for ECS Dev Deploy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
        ]
        Resource = [aws_ecs_service.default.id]
      }
  ] })
  depends_on = [aws_ecs_service.default]
}

resource "aws_iam_user_policy_attachment" "application-pipeline-deploy-ecs" {
  user       = aws_iam_user.application-pipeline.name
  policy_arn = aws_iam_policy.ecsDevDeployPolicy.arn
}

resource "aws_iam_policy" "ecsDevDeployListTaskPolicy" {
  name        = "${var.applicationName}-ecsDevDeployTaskPolicy"
  description = "Policy for ECS Dev Deploy Task"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:ListTaskDefinitions",
        ]
        Resource = ["*"]
      }
  ] })
  depends_on = [aws_ecs_task_definition.application]
}

resource "aws_iam_user_policy_attachment" "application-pipeline-deploy-listTasks" {
  user       = aws_iam_user.application-pipeline.name
  policy_arn = aws_iam_policy.ecsDevDeployListTaskPolicy.arn
}