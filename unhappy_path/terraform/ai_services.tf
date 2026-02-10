# =============================================================================
# INSECURE TERRAFORM — AI-Specific Service Configurations
# =============================================================================


# =============================================================================
# TF-006: SageMaker Endpoint Missing VPC Configuration (MEDIUM)
# SageMaker inference endpoint is deployed outside a VPC. It communicates
# over the public internet instead of a private network — exposing model
# inference traffic to interception.
# =============================================================================

resource "aws_sagemaker_endpoint_configuration" "ai_endpoint" {
  name = "production-fraud-detection"

  production_variants {
    variant_name           = "primary"
    model_name             = aws_sagemaker_model.fraud_model.name
    initial_instance_count = 2
    instance_type          = "ml.g4dn.xlarge"
  }
  # Missing: subnet_ids, vpc_config, or network_config
  # The endpoint is NOT inside a VPC
}

resource "aws_sagemaker_endpoint_configuration" "embedding_endpoint" {
  name = "text-embedding-endpoint"

  production_variants {
    variant_name           = "primary"
    model_name             = "huggingface-embedding"
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
  }
  # Also missing VPC configuration
}


# =============================================================================
# TF-003: Missing Bedrock Guardrails (MEDIUM)
# AWS Bedrock agent is deployed WITHOUT a guardrail resource. The agent
# has no content filtering, no topic restrictions, and no PII redaction.
# =============================================================================

resource "aws_bedrockagent_agent" "customer_support" {
  agent_name                  = "customer-support-agent"
  foundation_model            = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction                 = "You are a customer support agent."
  idle_session_ttl_in_seconds = 600
}

resource "aws_bedrockagent_agent" "code_assistant" {
  agent_name                  = "code-assistant-agent"
  foundation_model            = "anthropic.claude-3-haiku-20240307-v1:0"
  instruction                 = "You help developers write code."
  idle_session_ttl_in_seconds = 300
}

# No aws_bedrock_guardrail resource exists anywhere in this configuration.
# Both agents operate without content guardrails.
