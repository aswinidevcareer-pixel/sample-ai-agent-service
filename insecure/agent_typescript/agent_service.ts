// =============================================================================
// INSECURE AGENT SERVICE — TypeScript / Express / OpenAI SDK
// =============================================================================
// Demonstrates the same agent security anti-patterns in a Node/TypeScript
// codebase. Each pattern is annotated with the rule it triggers.

import express from "express";
import OpenAI from "openai";

const app = express();
app.use(express.json());

const openai = new OpenAI();

// =============================================================================
// AGENT-001: Broad Agent Permissions (CRITICAL)
// =============================================================================
const agentConfig = {
  tools: ["*"],                    // Wildcard tool list
  allow_all_tools: true,           // All tools enabled
  allowed_tools: "*",              // Wildcard string
  tool_permissions: "all",         // Unrestricted permissions
};

// =============================================================================
// AGENT-002: Unrestricted Tool Access (HIGH)
// =============================================================================
const toolConfig = {
  tool_choice: "auto",             // LLM picks any tool freely
  function_call: "auto",           // Legacy: auto function calling
  unrestricted_tool_access: true,  // Explicit unrestricted flag
  tool_filter: "none",             // No filtering
  enable_all_functions: true,      // All functions available
};

// =============================================================================
// AGENT-006: Hardcoded API Keys (CRITICAL)
// =============================================================================
const api_key = "sk-proj-ABCDEFghijklmnopqrstuvwxyz0123456789";
const secret_key = "AKIAIOSFODNN7EXAMPLEKEY";
const anthropic_api_key = "sk-ant-api-key-example123";
const password = "ProductionDBPassword123!";
const access_token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// =============================================================================
// AGENT-003 + AGENT-007: No access control or request limits.
// Endpoint is publicly accessible. Anyone can call it.
// =============================================================================

app.post("/api/chat/completion", async (req, res) => {

  // ===========================================================================
  // AGENT-004: Unsafe Data Flow to LLM (HIGH)
  // ===========================================================================

  // Pattern: request body directly in LLM call
  const result = await openai.chat.completions.create(req.body);

  // Pattern: template literal interpolation
  const prompt = `Answer this question: ${user_input}`;

  // Pattern: string concatenation
  const message = "Process: " + user_message;

  // ===========================================================================
  // AGENT-008: Prompt Injection Vector (HIGH)
  // ===========================================================================

  // Pattern: template literal into system prompt
  const system_prompt = `You are helpful. User said: ${user_input}`;

  // Pattern: concatenation into system message
  const system_message = "You are an assistant. Handle: " + user_query;

  // ===========================================================================
  // AGENT-005: Unsanitized Tool Output (MEDIUM)
  // ===========================================================================
  const tool_output = await executeTool(req.body.tool);

  // Pattern: template literal with tool output
  const display = `Result: ${tool_output}`;

  // Pattern: innerHTML assignment (XSS)
  document.innerHTML = tool_output;

  // Pattern: eval with tool result (RCE)
  eval(tool_result);

  res.json({ response: result });
});

app.listen(3000);
