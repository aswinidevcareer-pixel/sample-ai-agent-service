# Insecure Terraform config for testing

# TF-001: Exposed endpoint
resource "aws_security_group_rule" "allow_all" {
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
}

# TF-002: Permissive IAM policy
resource "aws_iam_policy" "ai_admin" {
  name = "ai-admin-policy"
  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = ["*"]
      Resource = "*"
    }]
  })
}

# TF-004: Public S3 bucket
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "ai-model-artifacts"
  acl    = "public-read"
}

# TF-007: Permissive security group
resource "aws_security_group" "wide_open" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
