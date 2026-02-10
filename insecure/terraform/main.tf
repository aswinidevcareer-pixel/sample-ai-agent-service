# =============================================================================
# INSECURE TERRAFORM — AI Deployment Infrastructure
# =============================================================================
# This file contains every Terraform anti-pattern that guardrail-scanner
# detects. Each resource maps to a specific rule.


# =============================================================================
# TF-001: Exposed Endpoints (HIGH)
# Security group allows inbound traffic from the entire internet.
# An attacker can reach AI inference endpoints from any IP.
# =============================================================================

# Pattern 1: IPv4 wildcard CIDR
resource "aws_security_group_rule" "agent_api_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.agent_api.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Pattern 2: IPv6 wildcard CIDR
resource "aws_security_group_rule" "agent_api_ingress_v6" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.agent_api.id
  ipv6_cidr_blocks  = ["::/0"]
}

# Pattern 3: Inline ingress block (less secure than separate rules)
resource "aws_security_group" "agent_inline" {
  name = "agent-inline-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# =============================================================================
# TF-002: Permissive IAM Policy (CRITICAL)
# IAM policy grants wildcard permissions. The AI service can access ANY
# AWS resource and perform ANY action — full account takeover if compromised.
# =============================================================================

# Pattern 1: Wildcard actions in HCL
resource "aws_iam_policy" "agent_admin" {
  name = "agent-admin-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["*"]
      Resource = "*"
    }]
  })
}

# Pattern 2: JSON-style "Action": "*"
resource "aws_iam_role_policy" "agent_role" {
  name = "agent-role-policy"
  role = aws_iam_role.agent.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }]
  }
  EOF
}

# Pattern 3: JSON array form "Action": ["*"]
resource "aws_iam_policy" "agent_full_access" {
  name = "agent-full-access"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["*"],
      "Resource": "*"
    }]
  }
  EOF
}


# =============================================================================
# TF-004: Public S3 Bucket (CRITICAL)
# S3 bucket storing model artifacts is publicly readable. Anyone on the
# internet can download your proprietary model weights.
# =============================================================================

# Pattern 1: public-read ACL
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "prod-ai-model-artifacts"
  acl    = "public-read"
}

# Pattern 2: public-read-write ACL (even worse)
resource "aws_s3_bucket" "training_data" {
  bucket = "prod-ai-training-data"
  acl    = "public-read-write"
}

# Pattern 3: Public access block disabled
resource "aws_s3_bucket_public_access_block" "model_public" {
  bucket                  = aws_s3_bucket.model_artifacts.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# =============================================================================
# TF-005: Unencrypted S3 Storage (HIGH)
# S3 bucket has no server-side encryption. Model weights and training data
# are stored in plaintext on disk — violating most compliance frameworks.
# =============================================================================

resource "aws_s3_bucket" "unencrypted_models" {
  bucket = "ai-models-unencrypted"
  # No server_side_encryption_configuration block
  # No aws_s3_bucket_server_side_encryption_configuration resource
}


# =============================================================================
# TF-007: Permissive Security Group (HIGH)
# Security group allows ALL ports on ALL protocols from anywhere.
# Every service on the instance is exposed to the internet.
# =============================================================================

# Pattern 1: All ports (0-65535)
resource "aws_security_group" "agent_wide_open" {
  name = "agent-wide-open"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Pattern 2: Protocol "all"
resource "aws_security_group" "agent_all_proto" {
  name = "agent-all-protocols"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "all"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
