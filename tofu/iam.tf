data "aws_iam_policy_document" "allow_get_ipdb_param" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [data.aws_ssm_parameter.ipdb.arn]
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ssm:parameterarn"
      values   = [data.aws_ssm_parameter.ipdb.arn]
    }
  }
}

resource "aws_iam_policy" "allow_get_ipdb_param" {
  name   = "allow-get-ipdb-param"
  policy = data.aws_iam_policy_document.allow_get_ipdb_param.json
}

resource "aws_iam_role_policy_attachment" "lambda_can_get_ipdb_param" {
  role       = aws_iam_role.lambda_exc.name
  policy_arn = aws_iam_policy.allow_get_ipdb_param.arn
}