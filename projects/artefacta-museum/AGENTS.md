# Agent Instructions: [Project Name]

> **Target Project Directory**: `projects/[project-slug]/`  
> **Primary Design File**: `projects/[project-slug]/[project-slug].figcraft`  
> **Framework**: Design Orchestrator 2.1 (Antigravity 2.0 + FigCraft)

---

## 1. Project Boundary & Strict Isolation

1. **Self-Contained Workspace**: All design work, tokens, frame notes, screenshots, and handoffs must reside exclusively inside `projects/[project-slug]/`.
2. **Zero Cross-Contamination**: Under no circumstances should you read, modify, overwrite, or move files belonging to other project directories (`projects/<other-slug>/`) or the workspace root.
3. **Shared Tools & MCPs**: Shared skills (`design-orchestrator`, `ui-ux-pro-max`, `antislop`, `impeccable`) and MCP servers (`figcraft`, `codebase-memory-mcp`) are available across all projects, but canvas operations must target ONLY this project's primary file.

---

## 2. Discovery & Visual Consultation Protocols

### A. Dual Discovery Modes

#### Mode 1: From Scratch (No PRD)
- Default Anti-Slop mode to `DURING` automatically.
- Pacing constraint: **Maximum 1–2 questions per turn**.
- Consultative framing: Accompany options with concise explanations, highlight **1 primary recommendation**, and explain operational/UX reasoning.
- Staging Priority: System Needs first, Target Users & Roles second, Information Architecture & Surface Mode third. Settle functional foundations before discussing visual styling.

#### Mode 2: PRD-Driven Design (Specification Provided)
1. **Read-Only Ingestion**: Ingest PRDs, user stories, or plans completely in read-only mode (`references/PRD.md` or external paths).
2. **Domain Extraction**: Identify system goals, modules, user personas, roles & permissions, workflows, business rules, and screen-by-screen requirements.
3. **Zero Redundant Questions**: **NEVER** ask questions that are already answered in the PRD.
4. **Isolate Open Visual/UX Decisions**: Systematically isolate visual styles, density preferences, layout choices, and UX behaviors not defined in the PRD.
5. **Targeted Interview**: Conduct interviews **ONLY** for unresolved decisions.
6. **Separation of Concerns**: Treat the PRD as the **functional source of truth** and `DESIGN.md` as the **visual source of truth**.
7. **Requirements Mapping**: Document full requirement-to-screen traceability in `REQUIREMENTS_MAP.md`.
8. **Conflict Resolution**: If a visual technique conflicts with a PRD requirement, report the conflict explicitly and request a user decision. **NEVER silently modify or bypass the PRD.**

---

### B. Visual Reference Research Protocol

Before constructing the design system:
1. **Tool Verification**: Check active tools (Mobbin MCP, `browser-use` CLI, or UI/UX Pro Max). Never assume an MCP is connected without checking.
2. **Targeted Search**: Query references based on product domain, specific screen types (e.g. data table, audit dashboard), UI components, and UX patterns.
3. **Curate 3 to 5 References**: Select 3–5 benchmark references that demonstrate relevant craft floor, typography, or interaction patterns.
4. **Structured Logging**: Record source URLs, analyzed design aspects, and explicit rationale for selection in `DESIGN.md`.
5. **No Direct Cloning**: Translate external references into original design decisions. Never copy layouts identically or use unlicensed assets.
6. **Privacy & Confidentiality Hard Rule**: **NEVER** send confidential PRD text, proprietary business logic, client company names, or PII into external search tools. Use generalized, generic industry keywords.

---

## 3. Design System First & Atomic Construction Protocols

1. **Document Partitioning**:
   - `01_Foundations`: 3-Tier tokens, native variable collections, specimen boards (Typography, Colors, Dual Elevation), Central Vector Icon Library.
   - `02_Components`: Atomic `(Item)` components and variant sets organized into family artboards with title cards.
   - `03_Patterns`: Composite `(Group)` assemblies and operational patterns (`Data_Tables`, `Modals`, `Instances_Showcase`).
   - `04_Screens`: Application frames composed 100% of linked instances from approved library.
   - *(Optional)*: `00_Cover` & `00_Guidelines`.
2. **Atomic Decomposition (Item $\rightarrow$ Group $\rightarrow$ Pattern)**:
   - Always build atomic items first. Assemble groups using `instance.create` of atomic items.
   - Never duplicate raw layers when an atomic item exists.
3. **Central Vector Icon Library (Zero Emojis)**:
   - Use crisp SVG vector paths (`vector.create`). Emojis are strictly banned.
   - Master icons live in `01_Foundations` and are instanced/swapped into buttons and inputs.
4. **3-Tier Tokens & Variables**:
   - Register Primitives and Semantic Tokens via `variable.createCollection` and `variable.create`.
   - Bind via `variable.bind`. Provide documented fallback to `styles` and `DESIGN.md` if binding fails.
5. **Figma Import Fidelity Awareness**:
   - Distinguish data structure import from visual rendering fidelity.
   - Verify native FigCraft capabilities before declaring rules mandatory.
   - Adapt architectural patterns without copying potential import defects or external brand identities.
6. **🛑 DESIGN SYSTEM APPROVAL GATE (Mandatory Hard Stop)**:
   - You MUST export previews of all component and pattern artboards to `exports/`.
   - Update `SESSION_HANDOFF.md` with status `PENDING_USER_APPROVAL`.
   - **STOP execution and await explicit user approval** before generating application screens in `04_Screens`.

---

## 4. Execution Commands Quick Reference

### Open & Verify Document Identity
```json
call_mcp_tool("figcraft", "open_file", { "path": "projects/[project-slug]/[project-slug].figcraft" })
call_mcp_tool("figcraft", "inspect_document", {})
```

### Save Primary File
```json
call_mcp_tool("figcraft", "save_file", { "path": "projects/[project-slug]/[project-slug].figcraft" })
```

### Export Visual Previews
```json
call_mcp_tool("figcraft", "run_command", {
  "command": "file.exportLayers",
  "params": {
    "ids": ["artboard_id"],
    "path": "projects/[project-slug]/exports/preview.png",
    "format": "png",
    "scale": 2
  }
})
```
