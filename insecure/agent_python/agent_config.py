# =============================================================================
# INSECURE AGENT CONFIGURATION — Python / LangChain / OpenAI
# =============================================================================
# This file demonstrates insecure AI agent patterns that guardrail-scanner
# detects. Each section maps to a specific rule.

from langchain.agents import Agent, AgentExecutor
from langchain.tools import Tool
import openai

# =============================================================================
# AGENT-001: Broad Agent Permissions (CRITICAL)
# The agent is granted wildcard access to ALL tools. A compromised or
# jailbroken agent can invoke any tool — including destructive ones like
# file deletion, database drops, or email sending.
# =============================================================================

# Pattern 1: Wildcard in tools list
agent = Agent(
    tools=["*"],
    model="gpt-4",
)

# Pattern 2: allow_all_tools boolean flag
agent_executor = AgentExecutor(
    agent=agent,
    allow_all_tools=True,
)

# Pattern 3: Wildcard string in allowed_tools
allowed_tools = "*"

# Pattern 4: tool_permissions set to 'all'
tool_permissions = "all"

# Pattern 5: Wildcard in permissions list
permissions = ["*"]


# =============================================================================
# AGENT-002: Unrestricted Tool Access (HIGH)
# The LLM can autonomously choose which tool to call without any filtering
# or validation layer. An attacker who controls the prompt can direct the
# agent to call dangerous tools.
# =============================================================================

# Pattern 1: tool_choice set to auto
client = openai.ChatCompletion.create(
    model="gpt-4",
    tool_choice="auto",
    messages=messages,
)

# Pattern 2: tool_choice set to any
tool_choice = "any"

# Pattern 3: function_call set to auto (legacy OpenAI API)
function_call = "auto"

# Pattern 4: Explicit unrestricted flag
unrestricted_tool_access = True

# Pattern 5: Tool filter disabled
tool_filter = "none"

# Pattern 6: All functions enabled
enable_all_functions = True


# =============================================================================
# AGENT-006: Hardcoded API Keys and Secrets (CRITICAL)
# API keys and credentials are embedded directly in source code. Anyone
# with access to the repository can extract and abuse these keys.
# =============================================================================

# Pattern 1: OpenAI key (sk- prefix)
api_key = "sk-proj-1234567890abcdefghijklmnop"

# Pattern 2: AWS access key (AKIA prefix)
secret_key = "AKIAIOSFODNN7EXAMPLE1234"

# Pattern 3: Named provider keys
openai_api_key = "sk-live-abcdef123456789012345"
anthropic_api_key = "sk-ant-abcdef123456789"
google_api_key = "AIzaSyA-abcdef123456789"
cohere_api_key = "co-abcdef123456789012"
azure_api_key = "azure-key-abcdef12345678"
huggingface_token = "hf_abcdefghijklmnopqrst"

# Pattern 4: Generic password
password = "SuperS3cretP@ssw0rd!"

# Pattern 5: Bearer/access token
token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0"
access_token = "ghp_ABCDEFghijklmnopqrstuvwxyz012345"

# Pattern 6: Private key
private_key = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASC"
