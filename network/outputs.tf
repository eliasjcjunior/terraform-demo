output vpc_id {
  value = aws_vpc.main.id
}

output subnet_ids {
  value = aws_subnet.public.*.id
}

output sg_service_id {
  value = aws_security_group.service.id
}