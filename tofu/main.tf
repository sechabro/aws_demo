terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    required_version = ">= 1.7.0"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_apigatewayv2_api" "http_api" {
    name = "ipdb-http-api"
    protocol_type = "HTTP"

    cors_configuration {
    allow_origins     = ["https://ipcheck.seanbrown.org"]
    allow_methods     = ["GET"]
    allow_headers     = ["Content-Type"]
    expose_headers    = ["X-Request-Id"]
    max_age           = 1800
    allow_credentials = false
  }
}

# Integration from API Gateway -> Lambda
resource "aws_apigatewayv2_integration" "ipdb" {
    api_id = aws_apigatewayv2_api.http_api.id
    integration_type = "AWS_PROXY" # change to "AWS_PROXY" for Lambda
    integration_method = "POST" # must be POST for Lambda proxy
    integration_uri = aws_lambda_function.ipdb.invoke_arn
    payload_format_version = "2.0" #2.0 for Lambda
}

resource "aws_apigatewayv2_route" "check" {
    api_id = aws_apigatewayv2_api.http_api.id
    route_key = "GET /check"
    target = "integrations/${aws_apigatewayv2_integration.ipdb.id}"
}

resource "aws_apigatewayv2_stage" "default" {
    api_id = aws_apigatewayv2_api.http_api.id
    name = "$default"
    auto_deploy = true
}

output "api_endpoint" {
    value = aws_apigatewayv2_api.http_api.api_endpoint
}