// =============================================================================
// INSECURE AGENT CONTROLLER — Java / Spring Boot
// =============================================================================
// Demonstrates agent security anti-patterns in a Java enterprise context.

package com.example.agent;

import org.springframework.web.bind.annotation.*;

@RestController
public class AgentController {

    // =========================================================================
    // AGENT-001: Broad Agent Permissions (CRITICAL)
    // =========================================================================

    private String[] tools = {"*"};                    // tools = ["*"]
    private boolean allow_all_tools = true;            // allow_all_tools = true
    private String tool_permissions = "all";           // tool_permissions = "all"

    // =========================================================================
    // AGENT-002: Unrestricted Tool Access (HIGH)
    // =========================================================================

    private String tool_choice = "auto";               // tool_choice = auto
    private String function_call = "auto";             // function_call = auto
    private boolean enable_all_functions = true;       // enable_all_functions = true

    // =========================================================================
    // AGENT-006: Hardcoded API Keys (CRITICAL)
    // =========================================================================

    private String api_key = "sk-proj-JavaSpringKeyExample12345678";
    private String secret_key = "AKIAIOSFODNN7JAVAEXAMPLE";
    private String openai_api_key = "sk-java-openai-abcdef12345";
    private String password = "JdbcPr0ductionP@ss!";
    private String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.spring";

    // =========================================================================
    // AGENT-003 + AGENT-007: No access control or request limits.
    // No security annotations on this endpoint. Publicly accessible.
    // =========================================================================

    @PostMapping("/api/agent/completion")
    public String agentCompletion(@RequestBody String userInput) {

        // =====================================================================
        // AGENT-004: Unsafe Data Flow to LLM (HIGH)
        // =====================================================================

        // Pattern: user input concatenated into prompt
        String prompt = "Answer: " + user_input;

        // Pattern: .format() with user input
        String message = String.format("Process: %s", user_input);

        // =====================================================================
        // AGENT-008: Prompt Injection Vector (HIGH)
        // =====================================================================

        String system_prompt = "You are an assistant. Query: " + user_input;

        // =====================================================================
        // AGENT-005: Unsanitized Tool Output (MEDIUM)
        // =====================================================================

        String tool_output = executeTool(userInput);
        System.out.println(tool_output);               // print tool output
        Runtime.exec(tool_output);                     // command injection!

        return llm.complete(prompt);
    }
}
