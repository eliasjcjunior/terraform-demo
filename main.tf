module network {
  source = "./network"

  name = "demo"
  azs  = ["us-east-1a", "us-east-1b"]
}

module cluster {
  source = "./ecs/cluster"

  name = "demo"
}

module ecs_execution_task_role {
  source = "./role"

  name     = "ecsExecutionRole"
  service  = "ecs-tasks.amazonaws.com"
  policies = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

module ecs_task_role {
  source = "./role"

  name     = "ecsTaskRole"
  service  = "ecs-tasks.amazonaws.com"
  policies = []
}

module "service" {
  source = "./ecs/service"

  name               = "nginx"
  cluster_id         = module.cluster.id
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnet_ids
  security_groups    = [module.network.sg_service_id]
  task_role_arn      = module.ecs_task_role.arn
  execution_role_arn = module.ecs_execution_task_role.arn
}

module "alb" {
  source = "./load_balancer"

  name             = "demo"
  target_group_arn = module.service.target_group_arn
  subnets          = module.network.public_subnet_ids
  security_groups  = [module.network.sg_lb_id]
}