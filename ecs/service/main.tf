resource "aws_cloudwatch_log_group" "service" {
  name = "/ecs/${var.name}"
}

resource "aws_ecs_task_definition" "service" {
  depends_on = [aws_cloudwatch_log_group.service]

  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name  = var.name
      image = "library/nginx:latest"
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-group : aws_cloudwatch_log_group.service.name,
          awslogs-region : "us-east-1",
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.name}-tg"
  port                 = var.port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    matcher = 200
    path    = "/"
    port    = var.port
  }
}

resource "aws_ecs_service" "service" {
  depends_on = [aws_ecs_task_definition.service]

  name                 = var.name
  cluster              = var.cluster_id
  launch_type          = var.launch_type
  task_definition      = aws_ecs_task_definition.service.arn
  desired_count        = var.desired_count
  force_new_deployment = true

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.name
    container_port   = var.port
  }
}