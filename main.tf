module "network" {
    source = "./network"

    name = "demo"
    azs  = ["us-east-1a", "us-east-1b"]
}

module "cluster" {
    source = "./ecs/cluster"

    name = "demo"
}

module ecs_role {
  source = "./role"

  name = "ecsServiceRole"
}

module "service" {
    source = "./ecs/service"

    name = "nginx"
    cluster_id = module.cluster.id
    subnets = module.network.subnet_ids
    security_groups = [module.network.sg_service_id]
    task_role_arn = module.ecs_role.arn
    execution_role_arn = module.ecs_role.arn
}