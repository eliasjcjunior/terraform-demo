variable name {
  type  = string
}

variable launch_type {
  type    = string
  default = "FARGATE"
}

variable cluster_id {
  type = string
}

variable task_role_arn {
  type = string
}

variable execution_role_arn {
  type = string
}

variable desired_count {
  type    = number
  default = 1
}

variable subnets {
  type = list(string)
}

variable security_groups {
  type = list(string)
}

variable assign_public_ip {
    type = bool
    default = true
}
