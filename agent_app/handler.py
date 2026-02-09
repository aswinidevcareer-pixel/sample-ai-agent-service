# Insecure agent endpoint for testing
from flask import Flask, request

app = Flask(__name__)

# AGENT-003: Missing auth on agent endpoint (no auth middleware in file)
# AGENT-007: Missing rate limiting (no rate limit middleware in file)
@app.post("/agent/chat")
def agent_chat():
    user_input = request.body

    # AGENT-004: User input direct to LLM
    response = llm.complete(request.body)

    # AGENT-008: Prompt injection vector
    system_prompt = f"You are a helpful assistant. User says: {user_input}"

    # AGENT-005: Unsanitized tool output
    result = tool_output.format(user_data=user_input)

    return response
