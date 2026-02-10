# TF-006: SageMaker endpoint without VPC
resource "aws_sagemaker_endpoint_configuration" "my_endpoint" {
  name = "my-ai-endpoint"

  production_variants {
    variant_name          = "primary"
    model_name            = aws_sagemaker_model.my_model.name
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
  }
}

# TF-003: Bedrock agent without guardrails
resource "aws_bedrock_agent" "my_agent" {
  agent_name = "my-bedrock-agent"
  foundation_model = "anthropic.claude-v2"
}
