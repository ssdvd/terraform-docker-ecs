resource "aws_iam_role" "cargo" {
  name = "${var.cargo-iam}-cargo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com",
          "ecs-tasks.amazon.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs-ecr" {
  name = "ecs-ecr"
  role = aws_iam_role.cargo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BactchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "perfil" {
  name = "${var.cargo-iam}-perfil"
  role = aws_iam_role.cargo.name
}
