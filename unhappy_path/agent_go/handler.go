// =============================================================================
// INSECURE AGENT HANDLER — Go / Gin Framework
// =============================================================================
// Demonstrates agent security anti-patterns in a Go HTTP service.

package main

import (
	"fmt"
	"net/http"
)

// =============================================================================
// AGENT-001: Broad Agent Permissions (CRITICAL)
// =============================================================================

var agentTools = []string{"*"}                       // tools = ["*"]
var agentConfig = map[string]interface{}{
	"allow_all_tools":  true,                         // allow_all_tools = true
	"tool_permissions": "all",                        // tool_permissions = "all"
}

// =============================================================================
// AGENT-002: Unrestricted Tool Access (HIGH)
// =============================================================================

var toolSettings = map[string]interface{}{
	"tool_choice":              "auto",                // tool_choice = auto
	"function_call":            "auto",                // function_call = auto
	"unrestricted_tool_access": true,                  // explicit flag
	"enable_all_functions":     true,                  // all functions
}

// =============================================================================
// AGENT-006: Hardcoded API Keys (CRITICAL)
// =============================================================================

var api_key = "sk-proj-GoServiceKeyExample1234567890ab"
var secret_key = "AKIAIOSFODNN7GOEXAMPLEKEY"
var openai_api_key = "sk-go-example-key-12345678"
var password = "GoServiceDbP@ssw0rd!!"
var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc123"

// =============================================================================
// AGENT-003 + AGENT-007: No access control or request limits.
// Endpoint is publicly accessible.
// =============================================================================

func agentChatHandler(w http.ResponseWriter, r *http.Request) {
	userInput := r.FormValue("message")

	// =========================================================================
	// AGENT-004: Unsafe Data Flow to LLM (HIGH)
	// =========================================================================

	// Pattern: direct request data to completion call
	response := llm.complete(r.FormValue("message"))

	// Pattern: string concatenation
	prompt := "Answer this: " + user_input

	// =========================================================================
	// AGENT-008: Prompt Injection Vector (HIGH)
	// =========================================================================

	system_prompt := "You are helpful. User says: " + user_input

	// =========================================================================
	// AGENT-005: Unsanitized Tool Output (MEDIUM)
	// =========================================================================

	tool_output := runTool(userInput)
	fmt.Println(tool_output)                            // format/print with tool output
	exec(tool_output)                                   // command injection

	fmt.Fprintf(w, "%s", response)
}

// Route: /agent/chat — triggers endpoint detection
func main() {
	http.HandleFunc("/agent/chat", agentChatHandler)
	http.ListenAndServe(":8080", nil)
}
