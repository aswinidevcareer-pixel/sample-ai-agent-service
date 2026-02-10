# =============================================================================
# INSECURE AGENT ENDPOINT — Python / Flask
# =============================================================================
# This file demonstrates an AI agent HTTP endpoint with multiple security
# issues: no access controls, no request limits, unsafe data flows, and
# prompt injection vulnerabilities.

from flask import Flask, request, jsonify
import openai

app = Flask(__name__)


# =============================================================================
# AGENT-003 + AGENT-007: No access control or request limits on this endpoint.
# It is publicly accessible. Anyone can call it, draining API tokens.
# =============================================================================

@app.post("/agent/chat")
def agent_chat():
    user_input = request.body

    # =========================================================================
    # AGENT-004: Unsafe Data Flow to LLM (HIGH)
    # User input flows directly into the LLM call without any validation,
    # sanitization, or schema enforcement. The attacker controls what the
    # model sees.
    # =========================================================================

    # Pattern 1: request.body passed directly to LLM call
    response = openai.chat.completions.create(request.body)

    # Pattern 2: f-string interpolation with user-controlled variable
    prompt = f"Process this request: {user_input}"

    # Pattern 3: Direct assignment of request data to prompt
    prompt = request.body

    # Pattern 4: String concatenation with user input
    prompt = "Answer this question: " + user_input

    # Pattern 5: %-formatting with user input
    prompt = "User asked: %s" % user_input

    # Pattern 6: .format() with user input
    prompt = "Handle this query: {}".format(user_input)

    # =========================================================================
    # AGENT-008: Prompt Injection Vector (HIGH)
    # User input is injected directly into the SYSTEM prompt. The attacker
    # can override the agent's instructions, personality, and safety rules.
    # This is distinct from AGENT-004 — here the injection targets the
    # system role, which has higher privilege in the LLM's attention.
    # =========================================================================

    # Pattern 1: f-string into system_prompt
    system_prompt = f"You are a helpful assistant. The user said: {user_input}"

    # Pattern 2: Concatenation into system_message
    system_message = "You are an AI assistant. Process: " + user_input

    # Pattern 3: .format() into system_content
    system_content = "Instructions: handle {}".format(user_input)

    # Pattern 4: %-formatting into system_prompt
    system_prompt = "You assist users. Query: %s" % user_input

    # Pattern 5: Template literal style (for JS reference)
    # system_prompt = `You are helpful. User: ${user_input}`

    # Pattern 6: User input in system role message
    messages = [
        {"role": "system", "content": user_input},
    ]

    # Pattern 7: User input sandwiched in prompt construction
    prompt = "Begin task: " + user_input + " End task."

    # Pattern 8: Jinja/template rendering with user input
    rendered = Template(user_input)

    # =========================================================================
    # AGENT-005: Unsanitized Tool Output (MEDIUM-HIGH)
    # Output from tool calls is used without sanitization. A malicious tool
    # result (e.g., from a web search returning attacker-controlled content)
    # can inject HTML, execute code, or manipulate logs.
    # =========================================================================

    tool_output = run_tool(user_input)

    # Pattern 1: Tool output in format string
    fmt.Println(tool_output)

    # Pattern 2: f-string with tool output
    result = f"The tool returned: {tool_output}"

    # Pattern 3: Direct return of tool output
    return tool_output

    # Pattern 4: Tool output in HTML (XSS risk)
    html = f"<div innerHTML={tool_output}></div>"

    # Pattern 5: Tool output passed to exec (command injection!)
    exec(tool_output)

    # Pattern 6: %-formatting with tool result
    log_msg = "Tool result: %s" % tool_result

    return jsonify({"response": response})
