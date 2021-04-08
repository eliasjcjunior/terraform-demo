variable cidr_block {
  type        = string
  default     = "10.0.0.0/16"
}

variable azs {
  type        = list(string)
}

variable name {
  type        = string
}

