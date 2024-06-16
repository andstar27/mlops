locals {
  hf_token = var.hf_token
}

resource "aws_apprunner_service" "chatbot" {
  service_name = "chatbot"
  source_configuration {
    image_repository {
      image_identifier      = "211125601087.dkr.ecr.us-east-1.amazonaws.com/test-chatbot:tag"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          HUGGINGFACEHUB_API_TOKEN = local.hf_token
      }
    }
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
  tags = {
    Name        = "Chatbot"
    Environment = "Production"
  }
}
