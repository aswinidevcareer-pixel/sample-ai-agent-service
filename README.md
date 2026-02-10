# Guardrail Scanner — Test Data

This directory contains curated example codebases that demonstrate every security pattern guardrail-scanner detects. Use these for demos, CI validation, and rule development.

## Directory Structure

```
testdata/
├── insecure/                    # Intentionally vulnerable — scanner SHOULD flag these
│   ├── agent_python/            # Python (Flask, LangChain, OpenAI)
│   │   ├── agent_config.py      # AGENT-001, AGENT-002, AGENT-006
│   │   └── chat_endpoint.py     # AGENT-003, AGENT-004, AGENT-005, AGENT-007, AGENT-008
│   ├── agent_typescript/        # TypeScript (Express, OpenAI SDK)
│   │   └── agent_service.ts     # All 8 AGENT rules
│   ├── agent_go/                # Go (net/http, Gin)
│   │   └── handler.go           # All 8 AGENT rules
│   ├── agent_java/              # Java (Spring Boot)
│   │   └── AgentController.java # All 8 AGENT rules
│   ├── terraform/               # Terraform IaC
│   │   ├── main.tf              # TF-001, TF-002, TF-004, TF-005, TF-007
│   │   └── ai_services.tf       # TF-003, TF-006
│   └── helm/                    # Helm / Kubernetes manifests
│       ├── deployment.yaml      # HELM-002 thru HELM-008
│       └── services.yaml        # HELM-001
├── secure/                      # Correctly hardened — scanner should find ZERO issues
│   ├── agent_python/
│   │   └── secure_endpoint.py   # Auth, rate limiting, input validation, env-based secrets
│   ├── terraform/
│   │   └── main.tf              # Private CIDR, least-privilege IAM, encrypted S3, VPC, guardrails
│   └── helm/
│       └── deployment.yaml      # Non-root, resource limits, secrets from K8s, NetworkPolicy
└── README.md
```

## Running the Tests

```bash
# Scan insecure testdata — should produce many findings
guardrail-scanner scan testdata/insecure

# Scan secure testdata — should produce zero findings
guardrail-scanner scan testdata/secure

# Generate HTML dashboard for insecure examples
guardrail-scanner scan --format html -o insecure-report.html testdata/insecure

# Scan only agent rules
guardrail-scanner scan -c agent-patterns testdata/insecure

# Scan only IaC rules
guardrail-scanner scan -c terraform,helm testdata/insecure
```

## Rule Coverage Matrix

### Agent Pattern Rules (8 rules)

| Rule | Severity | What It Detects | Python | TypeScript | Go | Java |
|------|----------|-----------------|--------|------------|----|------|
| AGENT-001 | CRITICAL | Wildcard tool permissions (`tools=["*"]`, `allow_all_tools=true`) | agent_config.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-002 | HIGH | Unrestricted tool access (`tool_choice=auto`, `function_call=auto`) | agent_config.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-003 | HIGH | Agent endpoint with no auth middleware | chat_endpoint.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-004 | HIGH | User input flowing directly to LLM calls | chat_endpoint.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-005 | MEDIUM | Tool output used in exec/HTML/format without sanitization | chat_endpoint.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-006 | CRITICAL | Hardcoded API keys and secrets (OpenAI, AWS, tokens) | agent_config.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-007 | MEDIUM | Agent endpoint with no rate limiting | chat_endpoint.py | agent_service.ts | handler.go | AgentController.java |
| AGENT-008 | HIGH | User input injected into system prompts | chat_endpoint.py | agent_service.ts | handler.go | AgentController.java |

### Terraform Rules (7 rules)

| Rule | Severity | What It Detects | Test File |
|------|----------|-----------------|-----------|
| TF-001 | HIGH | Open CIDR blocks (`0.0.0.0/0`, `::/0`) | main.tf |
| TF-002 | CRITICAL | Wildcard IAM permissions (`Action: "*"`) | main.tf |
| TF-003 | MEDIUM | Bedrock agent without guardrail resource | ai_services.tf |
| TF-004 | CRITICAL | Public S3 bucket ACLs | main.tf |
| TF-005 | HIGH | S3 bucket without encryption | main.tf |
| TF-006 | MEDIUM | SageMaker endpoint outside VPC | ai_services.tf |
| TF-007 | HIGH | Security group with all ports/protocols open | main.tf |

### Helm/Kubernetes Rules (8 rules)

| Rule | Severity | What It Detects | Test File |
|------|----------|-----------------|-----------|
| HELM-001 | HIGH | Service type LoadBalancer or NodePort | services.yaml |
| HELM-002 | MEDIUM | Deployment without NetworkPolicy | deployment.yaml |
| HELM-003 | CRITICAL | `privileged: true` | deployment.yaml |
| HELM-004 | HIGH | `runAsUser: 0` or `runAsNonRoot: false` | deployment.yaml |
| HELM-005 | MEDIUM | Container without resource limits | deployment.yaml |
| HELM-006 | MEDIUM | Workload without securityContext | deployment.yaml |
| HELM-007 | CRITICAL | Plaintext passwords/tokens in YAML | deployment.yaml |
| HELM-008 | HIGH | `hostNetwork: true` | deployment.yaml |

## Insecure vs Secure Comparison

Each insecure pattern has a secure counterpart showing the recommended fix:

| Insecure Pattern | Secure Fix | Rule |
|-----------------|------------|------|
| `tools = ["*"]` | `tools = ["search", "get_profile"]` | AGENT-001 |
| `tool_choice = "auto"` | `tool_choice = "none"` + explicit routing | AGENT-002 |
| No `@require_auth` on endpoint | `@require_auth` decorator with JWT validation | AGENT-003 |
| `prompt = f"Help: {user_input}"` | Validated input in user role, static system prompt | AGENT-004 |
| `exec(tool_output)` | `sanitize_output(tool_output)` | AGENT-005 |
| `api_key = "sk-..."` | `api_key = os.environ["OPENAI_API_KEY"]` | AGENT-006 |
| No rate limiter | `@limiter.limit("30/min")` | AGENT-007 |
| `system_prompt = f"... {user_input}"` | Static system prompt + separate user message | AGENT-008 |
| `cidr_blocks = ["0.0.0.0/0"]` | `cidr_blocks = ["10.0.0.0/16"]` | TF-001 |
| `Action = ["*"]` | `Action = ["bedrock:InvokeModel"]` | TF-002 |
| No `aws_bedrock_guardrail` | `aws_bedrock_guardrail` with content filters | TF-003 |
| `acl = "public-read"` | No ACL + `block_public_acls = true` | TF-004 |
| No encryption config | `server_side_encryption_configuration` with KMS | TF-005 |
| No `vpc_config` | `vpc_config` with private subnets | TF-006 |
| `from_port=0, to_port=65535` | `from_port=443, to_port=443` | TF-007 |
| `type: LoadBalancer` | `type: ClusterIP` | HELM-001 |
| No NetworkPolicy | NetworkPolicy with ingress/egress rules | HELM-002 |
| `privileged: true` | `privileged: false` | HELM-003 |
| `runAsUser: 0` | `runAsUser: 1000, runAsNonRoot: true` | HELM-004 |
| No resource limits | `limits: {cpu: "1", memory: "1Gi"}` | HELM-005 |
| No securityContext | Full securityContext with `drop: ALL` | HELM-006 |
| `password: "plaintext"` | `secretKeyRef` from K8s Secret | HELM-007 |
| `hostNetwork: true` | `hostNetwork: false` | HELM-008 |
