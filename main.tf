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
  bucket = "application-${var.applicationName}"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.application.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "aws/s3"
      sse_algorithm     = "aws:kms"
    }
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
        Resource = ["${aws_cloudwatch_log_group.application.arn}/*"]
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "applicationCreateLogStreams" {
  role       = aws_iam_role.application-task-execution-role.name
  policy_arn = aws_iam_policy.applicationCreateLogStreams.arn
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

resource "aws_ecs_task_definition" "application" {
  family = "${var.applicationName}-application"
  cpu    = var.cpu
  memory = var.memory
  container_definitions = jsonencode([
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
      environment = [for key, value in merge(var.environment_variables, {
        "AWS_SDK_ACCESS_KEY" = aws_iam_access_key.application-task.id
        "AWS_SDK_SECRET"     = aws_iam_access_key.application-task.secret
        }) : {
        name  = key
        value = value
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
  name        = "ecs-application-${var.applicationName}"
  port        = var.host_port
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
      values = [var.application_fqdn]
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
    container_name   = var.applicationName
    container_port   = var.container_port
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