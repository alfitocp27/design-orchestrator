# NeedMCP Integration Guide (Design Orchestrator v2.2)

> **Integration Type**: Optional Cloud MCP Server  
> **Target Version**: Design Orchestrator v2.2 (Sprint 2 Candidate)  
> **Provider**: Ruang Kula Indonesia ([needmcp.com](https://needmcp.com/))  
> **Official Docs**: [docs.needmcp.com](https://docs.needmcp.com/)  
> **Status**: `UNVERIFIED_RUNTIME` (Default clean PC state; requires external API key)  
> **License**: ISC (CLI package) / Proprietary SaaS Cloud Service  

---

## 1. Overview & Architecture

NeedMCP is an optional cloud-hosted Model Context Protocol (MCP) service providing design system styles, tokens, and structural component specifications.

Unlike local stdio MCP servers (such as FigCraft CLI or CodebaseMemoryMCP), NeedMCP operates as a **remote HTTP endpoint** (`https://needmcp.com/mcp`) authenticated via Bearer token in the `X-API-Key` HTTP header.

```
+-----------------------------------------------------------------------------------------+
| DESIGN ORCHESTRATOR v2.2 - HYBRID DESIGN INTELLIGENCE                                   |
+-----------------------------------------------------------------------------------------+
|                                                                                         |
|   [LOCAL DESIGN INTELLIGENCE]                    [OPTIONAL CLOUD REFERENCE]             |
|   +------------------------------------+         +----------------------------------+   |
|   | UI/UX Pro Max (192 Domain Palettes)|         | NeedMCP Cloud Service            |   |
|   | Impeccable (Craft Floor & Heuristics)|       | (https://needmcp.com/mcp)        |   |
|   | Dynamic Archetype Engine           |         | - 6 Verified Tools               |   |
|   +-----------------+------------------+         +----------------+-----------------+   |
|                     |                                             |                     |
|                     +----------------------+----------------------+                     |
|                                            |                                            |
|                                            v                                            |
|                        +---------------------------------------+                        |
|                        | CONCEPT FORMULATION (2-3 Directions)  |                        |
|                        +-------------------+-------------------+                        |
|                                            |                                            |
|                                            v                                            |
|                        +---------------------------------------+                        |
|                        |  [CONCEPT APPROVAL GATE (User Sign)]  |                        |
|                        +-------------------+-------------------+                        |
|                                            |                                            |
|                                            v                                            |
|                        +---------------------------------------+                        |
|                        | NATIVE FIGCRAFT CANVAS GENERATION     |                        |
|                        | (Master Components & Linked Instances)|                        |
|                        +---------------------------------------+                        |
+-----------------------------------------------------------------------------------------+
```

---

## 2. Verified Tool Catalog

Based on official documentation and upstream schema verification, NeedMCP exposes **strictly six (6) tools**. Speculative tools (such as `get_wireframe`, `get_section`, `design_dna`, or `agents_builder`) are unverified and must not be called.

| Tool Name | Parameters | Type | Orchestrator Stage | Description & Rule |
| :--- | :--- | :--- | :--- | :--- |
| **`getStyles`** | `{ query?: string }` | Read-Only | Stage 3 (Research) | Discovers available theme slugs in the NeedMCP cloud catalog. |
| **`getStyle`** | `{ slug: string }` | Read-Only | Stage 3 & 4 (Exploration) | Reads color scales, typography pairings, and border radii for a candidate theme. |
| **`getDesignSystem`** | `{ slug: string }` | Read-Only | Stage 4 (Concept Synthesis) | Reads structural spacing scales, elevation profiles, and layout tokens. |
| **`getComponents`** | `{ slug: string, category?: string }` | Read-Only | Stage 5 (Component Build) | Reads structural layout recipes for atomic UI elements (buttons, inputs, cards). |
| **`selectStyle`** | `{ slug: string }` | **Mutating** | **Post-Stage 4 Sign-Off ONLY** | **Locks active session to a theme slug.** Prohibited prior to human approval. |
| **`sendFeedback`** | `{ message: string, type?: string }` | Write-Only | Ad-hoc / Diagnostic | Submits developer feedback or error diagnostics to NeedMCP. |

---

## 3. Strict Guardrails & Policies

### 3.1 The Anti-Style-Locking Law
- **Exploration Allowed (`getStyle`)**: The agent is permitted to call `getStyle` during Stage 3 (Research) and Stage 4 (Creative Direction) to extract candidate styles as comparative benchmarks alongside UI/UX Pro Max profiles.
- **Locking Gated (`selectStyle`)**: Calling `selectStyle` prematurely locks the session and restricts creative flexibility. Therefore, calling `selectStyle` is **strictly prohibited** until the user has formally reviewed and approved the concept at the Stage 4 Concept Approval Gate.

### 3.2 Security & Privacy Boundaries
- **Zero Committed Secrets**: Never commit API keys, Sanctum Bearer tokens, or credentials to Git. Use `%NEEDMCP_API_KEY%` environment variables.
- **Zero Asset Vendoring**: Never commit proprietary NeedMCP style packs, raw CSS, or bundled tokens into the open-source repository.
- **Zero PII Transmission**: Never transmit client business logic, proprietary codebase context, or personal user data in NeedMCP queries. Only pass generic style queries or recognized slugs (e.g., `"minimal-dashboard"`, `"technical-slate"`).

---

## 4. Antigravity Configuration Guide

NeedMCP can be added to the user's personal Antigravity MCP configuration (`~/.gemini/config/mcp_config.json` or `~/.gemini/antigravity/mcp_config.json`).

> **Note**: This configuration is user-managed and optional. Core Mode and local Full Mode remain 100% operational without NeedMCP.

```json
{
  "mcpServers": {
    "needmcp": {
      "serverUrl": "https://needmcp.com/mcp",
      "headers": {
        "X-API-Key": "${NEEDMCP_API_KEY}"
      }
    }
  }
}
```

Alternatively, running `npx needmcp setup` in your terminal launches the official setup wizard, which prompts for your key and automatically updates your personal Antigravity configuration.

---

## 5. Three-Tier Degradation & Fallback Protocol

Design Orchestrator enforces deterministic degradation to guarantee zero agent disruption:

```
+-------------------------------------------------------------------------------------------------------+
| 3-TIER DEGRADATION MATRIX                                                                             |
+------------------------------+---------------------------+--------------------------------------------+
| State / Trigger              | Operational Status        | Action & Fallback                          |
+------------------------------+---------------------------+--------------------------------------------+
| Tier 1: Key Active & Valid   | VERIFIED_RUNTIME          | Use NeedMCP for candidate style benchmarks;|
|                              |                           | UI/UX Pro Max for primary domain tokens;   |
|                              |                           | FigCraft for canvas generation.            |
+------------------------------+---------------------------+--------------------------------------------+
| Tier 2: Quota Exceeded (429) | RATE_LIMITED              | Pause remote queries immediately;          |
| or Cloud Timeout (5xx)       |                           | switch to local Archetypes and UI/UX Pro   |
|                              |                           | Max without halting the design workflow.   |
+------------------------------+---------------------------+--------------------------------------------+
| Tier 3: Missing API Key      | UNVERIFIED_RUNTIME        | Core Mode and Full Mode proceed 100%       |
| or Guest Access Disabled     |                           | offline. Zero network calls; zero errors;  |
|                              |                           | zero simulation claims.                    |
+------------------------------+---------------------------+--------------------------------------------+
```

---

## 6. Translation Matrix to Native FigCraft Canvas

NeedMCP returns web/CSS representations of styles and components. The agent must translate these into native FigCraft canvas elements following Design Orchestrator's component architecture rules:

| NeedMCP Property / Spec | Target FigCraft Native Construct | Architectural Execution Rule |
| :--- | :--- | :--- |
| **Color Tokens (Hex / HSL)** | `variable.create` / `variable.bind` | Store as Figma Variables on `01_Tokens` page; bind fills/strokes. |
| **Typography Spec (Scale / Family)** | Text Node Properties | Apply exact `fontFamily`, `fontSize`, `lineHeight`, `letterSpacing`. |
| **Spacing & Padding Scale** | Auto Layout Properties | Set `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom`, `gap`. |
| **Atomic UI Control (Button/Input)** | Master `COMPONENT` | Create in `02_Components` page with Auto Layout. |
| **Component Variant (Hover/Active)** | `COMPONENT_SET` | Group related master components into variant sets. |
| **Repeating UI Item in Screen** | Linked `INSTANCE` | Must link to master component via `instance.create { component: masterId }`. |
| **Structural Screen Container** | Layout `FRAME` | Use Auto Layout `FRAME` for page shells, sidebars, and grid containers. |

---

## 7. Status & Validation

- **Repository Status**: `OPTIONAL_INTEGRATION`
- **Machine Dependency**: None. The repository provides schemas, test fixtures, and guidelines; no machine-specific paths or personal tokens are included.
- **Offline Integrity**: All offline regression suites (`scripts/test-runner.ps1`) pass without internet or NeedMCP credentials.
