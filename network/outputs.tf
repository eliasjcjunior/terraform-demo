output vpc_id {
  value = aws_vpc.main.id
}

output public_subnet_ids {
  value = aws_subnet.public.*.id
}

output private_subnet_ids {
  value = aws_subnet.private.*.id
}

output sg_service_id {
  value = aws_security_group.service.id
}

output sg_lb_id {
  value = aws_security_group.lb.id
}