# Insecure agent configuration for testing
from langchain import Agent

# AGENT-001: Overly broad tool permissions
agent = Agent(
    tools=["*"],
    allow_all_tools=True,
)

# AGENT-002: Unrestricted tool access
tool_choice = "any"

# AGENT-006: Hardcoded API key
api_key = "sk-proj-1234567890abcdef1234567890abcdef"
secret_key = "AKIAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
