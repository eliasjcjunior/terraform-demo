resource "aws_iam_role" "role" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = var.service
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy" {
  count      = length(var.policies)
  role       = aws_iam_role.role.name
  policy_arn = var.policies[count.index]
}