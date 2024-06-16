locals {
  hf_token = var.hf_token
}

resource "aws_iam_role" "apprunner_access_role" {
  name = "apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_access_policy_attachment" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "chatbot" {
  service_name = "chatbot"
  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          HUGGINGFACEHUB_API_TOKEN = local.hf_token
        }
      }
      image_identifier      = "211125601087.dkr.ecr.us-east-1.amazonaws.com/test-chatbot:tag"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }
  }
auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
  network_configuration {
    egress_configuration {
      egress_type = "DEFAULT"
    }
  }
}
