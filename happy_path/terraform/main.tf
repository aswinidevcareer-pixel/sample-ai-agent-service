# =============================================================================
# SECURE TERRAFORM — AI Deployment Infrastructure
# =============================================================================
# This file demonstrates the CORRECT way to configure AI infrastructure.
# The scanner should produce ZERO findings on this file.


# SECURE: Restricted CIDR — only internal VPC traffic
resource "aws_security_group_rule" "agent_api_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.agent_api.id
  cidr_blocks       = ["10.0.0.0/16"]
}

# SECURE: Least-privilege IAM policy — specific actions on specific resources
resource "aws_iam_policy" "agent_policy" {
  name = "agent-least-privilege"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "s3:GetObject",
      ]
      Resource = [
        "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet*",
        "arn:aws:s3:::prod-knowledge-base/*",
      ]
    }]
  })
}

# SECURE: Private S3 bucket with encryption
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "prod-ai-model-artifacts"
  # No ACL (defaults to private)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "model_encryption" {
  bucket = aws_s3_bucket.model_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.model_key.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "model_private" {
  bucket                  = aws_s3_bucket.model_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SECURE: SageMaker endpoint inside a VPC
resource "aws_sagemaker_endpoint_configuration" "ai_endpoint" {
  name = "production-fraud-detection"
  production_variants {
    variant_name           = "primary"
    model_name             = aws_sagemaker_model.fraud_model.name
    initial_instance_count = 2
    instance_type          = "ml.g4dn.xlarge"
  }
  # VPC configuration present
  vpc_config {
    security_group_ids = [aws_security_group.sagemaker.id]
    subnets            = var.private_subnet_ids
  }
}

# SECURE: Bedrock agent WITH guardrails
resource "aws_bedrockagent_agent" "customer_support" {
  agent_name       = "customer-support-agent"
  foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction      = "You are a customer support agent."
}

resource "aws_bedrock_guardrail" "content_filter" {
  name                      = "content-safety-guardrail"
  blocked_input_messaging   = "This request was blocked by content safety filters."
  blocked_outputs_messaging = "This response was blocked by content safety filters."
  content_policy_config {
    filters_config {
      type            = "HATE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  }
}

# SECURE: Restrictive security group — single port, specific protocol
# Uses a separate aws_security_group_rule instead of inline ingress block
resource "aws_security_group" "agent_sg" {
  name = "agent-restricted-sg"
}

resource "aws_security_group_rule" "agent_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.agent_sg.id
  source_security_group_id = aws_security_group.alb.id
}
