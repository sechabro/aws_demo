resource "aws_lambda_function" "ipdb" {
    function_name = "ipabuse_check"

    s3_bucket = "python-ipdb"
    s3_key = "v1.0.0/ipdb_003.zip"

    handler = "ipdb_call.main"
    runtime = "python3.12"
    source_code_hash = filebase64sha256("../ipdb_003.zip")

    role = aws_iam_role.lambda_exc.arn

    timeout = 10
    memory_size = 128

    environment {
        variables = {
            IPDB = data.aws_ssm_parameter.ipdb.name
        }
    }
}



resource "aws_iam_role" "lambda_exc" {
  name = "ipdb_lambda_exc"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "apigw_v2_exc" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ipdb.arn
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/$default/GET/check"
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exc.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_ssm_parameter" "ipdb" {
  name            = "/prod/ipdb/api-key"
  with_decryption = false
}