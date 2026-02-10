# =============================================================================
# SECURE AGENT ENDPOINT — Python / Flask
# =============================================================================
# This file demonstrates the CORRECT way to build an AI agent endpoint.
# The scanner should produce ZERO findings on this file.

import os
from flask import Flask, request, jsonify
from flask_limiter import Limiter
from functools import wraps
import jwt
import openai

app = Flask(__name__)

# SECURE: API key loaded from environment variable, never hardcoded
client = openai.OpenAI(api_key=os.environ["OPENAI_API_KEY"])

# SECURE: Rate limiter configured with reasonable limits
limiter = Limiter(app=app, default_limits=["100 per hour"])

# SECURE: Explicit tool allowlist — only the tools the agent needs
ALLOWED_TOOLS = ["search_knowledge_base", "get_user_profile", "create_ticket"]

agent_config = {
    "tools": ALLOWED_TOOLS,
    "allow_all_tools": False,
    "tool_choice": "none",     # Explicit tool routing, not auto
}


# SECURE: Authentication middleware
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization", "").replace("Bearer ", "")
        if not token:
            return jsonify({"error": "Missing token"}), 401
        try:
            payload = jwt.decode(token, os.environ["JWT_SECRET"], algorithms=["HS256"])
            request.user = payload
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401
        return f(*args, **kwargs)
    return decorated


# SECURE: Input validation
def validate_chat_input(data):
    if not isinstance(data, dict):
        raise ValueError("Invalid input format")
    message = data.get("message", "")
    if not isinstance(message, str) or len(message) > 4000:
        raise ValueError("Message must be a string under 4000 characters")
    return message.strip()


# SECURE: Output sanitization
def sanitize_output(text):
    if not isinstance(text, str):
        return str(text)
    return text[:10000]  # Truncate to prevent cost/memory issues


@app.post("/agent/chat")
@require_auth                    # Auth middleware applied
@limiter.limit("30 per minute")  # Rate limiting applied
def agent_chat():
    try:
        user_message = validate_chat_input(request.get_json())
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    # SECURE: User input goes in user role, system prompt is static
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a helpful customer support assistant."},
            {"role": "user", "content": user_message},
        ],
        tool_choice="none",
    )

    result = sanitize_output(response.choices[0].message.content)
    return jsonify({"response": result})
