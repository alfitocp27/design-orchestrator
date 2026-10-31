# Design Orchestrator 2.1: Workflow Payloads & Tool Invocations

> **Design Orchestrator 2.1 Technical Runbook**  
> Complete execution payloads, commands, and verification procedures across all 9 stages, integrating FigCraft MCP, UI/UX Pro Max, Impeccable, Anti-Slop, CodebaseMemoryMCP, and the professional UI Kit architectural standards.

---

## Stage 1: Discovery & Scoping (Dual Discovery Modes)

### 1. Project Routing & Context Loading
1. Check `PROJECT_REGISTRY.md` for project status and location.
2. **If New Project**:
   - Copy `projects/_template/` to `projects/<project-slug>/`.
   - Register entry in `PROJECT_REGISTRY.md`.
   - Initialize `PROJECT.md`, `REQUIREMENTS_MAP.md`, `AGENTS.md`, `DESIGN.md`, `SCREENS.md`, and `SESSION_HANDOFF.md`.
3. **If Continuing Existing Project**:
   - Agent **must read the 5 mandatory files** before any canvas operations:
     1. `projects/<project-slug>/PROJECT.md`
     2. `projects/<project-slug>/REQUIREMENTS_MAP.md` (if present)
     3. `projects/<project-slug>/DESIGN.md`
     4. `projects/<project-slug>/SCREENS.md`
     5. `projects/<project-slug>/SESSION_HANDOFF.md`

### 2. Dual Discovery Modes

#### Mode 1: From Scratch (No PRD)
- Default Anti-Slop mode to `DURING` automatically.
- Pacing constraint: **Maximum 1–2 questions per turn**.
- Consultative framing: Accompany every option with a concise explanation, highlight **1 primary recommendation** (`(Rekomendasi Utama)`), and state operational/UX reasoning.
- Staging Priority:
  1. *Core System Needs & Problem Space* (primary operational modules, core workflows, pain points).
  2. *Target Users & Roles* (personas, technical fluency, operational environment).
  3. *Information Architecture & Surface Mode* (density, table structures, overview vs detail).
  *(Never ask for visual styling or palettes prematurely).*

#### Mode 2: PRD-Driven Design (Specification Provided)
- **Step 1 - Read-Only Document Ingestion**: Ingest all relevant PRDs, user stories, specs, or implementation plans from `references/PRD.md` or external paths.
- **Step 2 - Domain Knowledge Extraction**:
  - System goal & business context.
  - Modules & workflows.
  - User roles & permission matrix.
  - Screen requirements and mandatory data fields.
- **Step 3 - Zero Redundant Questions**: Do not ask the user questions already answered in the PRD.
- **Step 4 - Isolate Open Visual/UX Decisions**: Extract only unresolved decisions (e.g. data density, navigation pattern, mobile priority).
- **Step 5 - Targeted User Interview**: Ask only about the open decisions from Step 4.
- **Step 6 - Requirements Mapping**: Populate `projects/<project-slug>/REQUIREMENTS_MAP.md` linking requirements to screen frames and components.
- **Step 7 - Conflict Reporting**: If any visual proposal conflicts with a PRD business rule, log in `REQUIREMENTS_MAP.md` and await user resolution. Never modify the PRD silently.

---

## Stage 2: Codebase & Schema Analysis (CodebaseMemoryMCP)

Only execute when a relevant codebase is available.

### 1. Discover Projects
```json
{
  "ServerName": "codebase-memory-mcp",
  "ToolName": "list_projects",
  "Arguments": {}
}
```

### 2. Targeted Architecture & Token Query
Query existing token architectures, database status enums, or UI components:
```json
{
  "ServerName": "codebase-memory-mcp",
  "ToolName": "search_graph",
  "Arguments": {
    "project": "<project-name>",
    "query": "status workflow schema approval"
  }
}
```

---

## Stage 3: Visual Reference Research (Mobbin, browser-use, UI/UX Pro Max)

Before constructing tokens or canvases, curate **3 to 5 verified real-world benchmark references**.

### 1. Tool Connection & Availability Verification
Verify available tools before executing calls:
- Query `call_mcp_tool("mobbin_mobbin", "search_screens", ...)` if available.
- Check `browser-use` CLI availability for Behance, Dribbble, or public UX galleries.
- Query `UI/UX Pro Max` in-memory:
```bash
python .agents/skills/ui-ux-pro-max/scripts/search.py "enterprise operational table" --design-system --json
```

### 2. URL Verification & Privacy Guardrail
- **Never hallucinate URLs.** Cite verified URLs or explicit tool references.
- **NEVER** transmit confidential PRD text, client company names, internal schemas, or PII into external queries. Generalize to neutral industry terms.

---

## Stage 4: Creative Direction & Concept Sign-Off

Synthesize findings into **2 to 3 genuinely differentiated visual concepts**:
1. **Concept Matrix**: Detail color palette, typography pairing, iconography style, layout density, surface depth model, and functional PRD alignment.
2. **Clear Primary Recommendation**: Highlight the direction that best satisfies user workflow throughput and Impeccable surface mode, stating explicit trade-offs.
3. **Concept Blending**: Allow user to blend aspects across concepts.
4. **🛑 CONCEPT APPROVAL GATE (Hard Stop)**:
   - Present concepts to the user in chat.
   - Wait for explicit user approval before touching the FigCraft canvas.

---

## Stage 5: Native Design System Construction (FigCraft MCP)

*In accordance with the Design System First principle, create foundations, 3-tier tokens, central vector icon library, atomic items, and reusable component sets inside the primary document BEFORE designing any screens.*

### 1. Explicit Open & Identity Verification
```json
{
  "ServerName": "figcraft",
  "ToolName": "open_file",
  "Arguments": {
    "path": "projects/<project-slug>/<project-slug>.figcraft"
  }
}
```
Verify via `figcraft/inspect_document` that document path and name match `<project-slug>`.

### 2. Clear Document Partitioning
Ensure pages or structured canvas sections exist:
- `01_Foundations`: Design tokens, specimen boards (Typography, Colors, Shadows), Central Vector Icon Library.
- `02_Components`: Atomic items and component sets organized into dedicated family artboards.
- `03_Patterns`: Composite assemblies (forms, modals, data tables, navigation shells, `Instances_Showcase`).
- `04_Screens`: Application viewports composed 100% of linked instances from approved components and patterns.
- *(Optional)*: `00_Cover` (1600 × 900 px presentation frame) and `00_Guidelines` (system overview and principles).

### 3. Constructing Foundations (3-Tier Tokens & Central Icon Library)
1. **3-Tier Variables Engine**:
   - Create Collections:
     ```json
     call_mcp_tool("figcraft", "run_command", {
       "command": "variable.createCollection",
       "params": { "name": "Primitives", "modes": ["Mode 1"] }
     })
     call_mcp_tool("figcraft", "run_command", {
       "command": "variable.createCollection",
       "params": { "name": "Tokens", "modes": ["Light"] }
     })
     call_mcp_tool("figcraft", "run_command", {
       "command": "variable.createCollection",
       "params": { "name": "ComponentTokens", "modes": ["Light"] }
     })
     ```
   - Register primitives (`Spacing/0..6`, `Color/Brand/50..900`, `Color/Neutral/50..900`).
   - Register semantic aliases (`text-primary`, `surface-card`, `border-subtle`, `radius-md`).
   - Register component token aliases (`btn-primary-bg`, `card-bg`, `table-row-hover`).
   - Updating Tier 1 primitives cascades automatically across semantic and component aliases to linked instances.
   - If native variable persistence is unsupported in the current session, fall back gracefully to **FigCraft Styles** (`style.create`, `style.apply`) and deterministic token tables in `DESIGN.md`.
2. **Foundations Specimen Boards on Canvas**:
   - `Typography_Specimen`: Font scale specimens (`H1`–`H5`, `S1`–`S2`, `B1`–`B4`, `C1`–`C3`, Button scale) with px sizes and sample text.
   - `Palette_Specimen`: Swatch cards showing hex, token name, and contrast compliance.
   - `Shadow_Specimen`: Dual-elevation cards demonstrating ambient blur + key directional shadows.
3. **Central Vector Icon Library (Zero Emojis)**:
   - Create crisp vector paths (`vector.create`) with standard $20 \times 20\text{px}$ or $24 \times 24\text{px}$ bounds.
   - **Crucial**: Set `props: { fill: "none" }` on both the icon container frame (`frame.create`) and the vector path (`vector.create`) to prevent FigCraft's default white frame fill and grey polygon fill from creating opaque blocks inside buttons.
   - Convert icons into individual master components (`component.create {name: "Icon/<name>"}`).

### 4. Constructing Atomic Components (`02_Components`)
1. **Atomic Decomposition (Item $\rightarrow$ Group $\rightarrow$ Pattern)**:
   - Construct atomic items first: `Button`, `Input`, `Checkbox`, `Radio`, `Toggle`, `Avatar`, `Badge/Status`, `Nav/Item`, `List/Left_Item`, `List/Right_Item`.
   - Assemble composite molecules: `Button Group (Group)`, `Navbar Bottom (Group)`, `Context Menu (5 Rows)`, `List Row (5 Rows)` using linked instances (`instance.create`) of atomic items.
2. **Native Component & Variant Construction**:
   - Never use plain frames as components.
   - Build state frames with explicit auto-layout (`layout: "horizontal"` or `"vertical"`, `padding`, `gap`, `cornerRadius`, `fill`).
   - Convert to components and combine into component sets:
     ```json
     call_mcp_tool("figcraft", "run_command", {
       "command": "component.createMultiple",
       "params": { "ids": [var1_id, var2_id, var3_id, var4_id] }
     })
     call_mcp_tool("figcraft", "run_command", {
       "command": "component.combineVariants",
       "params": { "ids": [var1_id, var2_id, var3_id, var4_id] }
     })
     ```
3. **Properties & Nested Icons**:
   - Embed linked instances of icon masters into buttons and inputs.
   - Add boolean properties for icon toggles (`component.addProperty {name: "Icon Left", type: "boolean"}`).
4. **Component Family Artboards with Title Cards**:
   - Organize artboards by component family (adaptive to product scope, not rigidly capped).
   - Place a standardized Title Header card matching the artboard width at the top of each artboard ($\ge 24\text{px}$ clearance above purple `COMPONENT_SET` bounding boxes).

### 5. Executing the 8-Point Component Stress Testing Protocol
Execute and log on canvas:
1. **Master-to-Instance Propagation**: Modify master radius/fill $\rightarrow$ verify linked instance reflects change $\rightarrow$ revert.
2. **Instance Overrides Isolation**: Change text on instance $\rightarrow$ verify master and peers untouched.
3. **Variant Switching**: `instance.setProperties` to Hover/Active $\rightarrow$ verify visual switch.
4. **Nested Icon Inheritance & Swapping**: Verify child icon stroke matches host state colors; verify `instance.swap`.
5. **Extreme Content Stress**: Inject long text, short text, empty text $\rightarrow$ verify auto-layout does not break.
6. **Permutation Stress**: Swap units (`Kg`, `Rp`, `%`) and delta indicators $\rightarrow$ verify layout alignment.
7. **Sizing Constraints & Overflow**: Test in narrow vs wide parent containers.
8. **Save & Reload Persistence**: Save file, reopen, execute `component.list` $\rightarrow$ verify 100% components and instances remain connected.

---

## Stage 6: Design System Visual QA 2.0 & Approval Gate

1. **Two-Tier Quality Separation**:
   - **Tier 1 (Technical Verification)**: Deterministic validation of node types (`COMPONENT`, `INSTANCE`), auto-layout properties, 3-tier variable bindings, and save/reload persistence. Passing Tier 1 indicates structural validity only (`STATUS: TECHNICAL_RUNTIME_PASS`).
   - **Tier 2 (Visual & Craft Quality)**: Perceptual evaluation of WCAG 2.2 contrast, typography scale rhythm, spatial breathing room, and character (`STATUS: READY_FOR_CONTROLLED_PILOT`). Tier 1 PASS never implies Tier 2 approval; premium quality requires end-to-end evaluation in live pilot projects.
2. **The 4-Dimensional VQA 2.0 Inspection**:
   - **Dimensi 1: Technical Integrity** (Auto-layout explicit, locked columns $\Delta x \le 1\text{px}$, native component integrity, variable bindings).
   - **Dimensi 2: Visual Quality & Craft** (WCAG 2.2 contrast $\ge 4.5:1$, zero color clashes, micro-elevation, minimum text $\ge 13\text{px}$, variant label clearance $\ge 24\text{px}$).
   - **Dimensi 3: UX & Semantic Quality** (Populated vs empty state separation, domain realism `[SIMULASI]`, stress testing passed, Zero Critical Data Loss text policy).
   - **Dimensi 4: Creative Quality & Character** (Anti-monotony, distinct personality, alignment with approved concept, no generic AI slop).
3. **Figma Import Fidelity Check**:
   - If using elements from an imported reference, verify that visual rendering matches design intent and no import artifacts (e.g. broken font weights, missing fills) exist.
4. **Export Visual Artifacts**:
   - Export unselected previews of all component and pattern artboards to `projects/<project-slug>/exports/`.
5. **Save Primary Canvas**:
   `figcraft/save_file(path: "projects/<project-slug>/<project-slug>.figcraft")`

### 🛑 DESIGN SYSTEM APPROVAL GATE (Mandatory Hard Stop)
- **DO NOT proceed to Stage 7 (`04_Screens`) under any circumstances.**
- Update `SESSION_HANDOFF.md` with status `PENDING_USER_APPROVAL`.
- Present the artboard screenshots, token architecture, and stress test results to the user.
- **STOP and wait for explicit user approval before touching application screens.**

---

## Stage 7: Application Screen Execution (Post-Approval Only)

*Executes ONLY after explicit user sign-off on the Design System.*

1. **Strict Reusability Mandate (Instances vs Frames)**:
   - All repeating controls, atoms, molecules, and operational patterns in `04_Screens` MUST be instantiated from `02_Components` or `03_Patterns` via `instance.create`.
   - Structural screen shells, viewports, grid columns, main body wrappers, and sidebar layout frames MUST be native Frames with Auto Layout (`node.create {type: "frame", props: {layout: "vertical" | "horizontal"}}`). Banned: wrapping whole viewports into rigid component instances.
2. **Text Overflow & Zero Critical Data Loss Policy**:
   - Ensure critical data (financial figures, KPI metrics, approval status, employee identities, alert messages) is never obscured or lost via ellipsis truncation.
   - Use multi-line text wrapping (`textAutoResize: "height"`, `wrap: true`), adaptive flex sizing (`sizingH: "hug"` or responsive flex), or secondary expansion drawers/modals. Truncation (`textAutoResize: "truncate"`) is restricted exclusively to non-critical secondary text.
3. **Locked Column Data Grids**:
   - Ensure table headers and table rows share exact column widths:
     $$\Delta x = |x(C_{i, R_j}) - x(C_{i, \text{header}})| \le 1\text{px}$$
4. **State Separation**:
   - Build Populated State, Empty State, and responsive breakpoints (Desktop 1440 × 900, Mobile 390 × 844) as separate top-level frames in `04_Screens`.

---

## Stage 8: Screen Visual QA 2.0 & Remediation

- Execute the 4 Dimensions on all screen frames.
- Re-export unselected screenshots to `projects/<project-slug>/exports/`.
- If any defect is found: remediate within a maximum of 3 targeted iterations.
- If defects remain after 3 iterations: report honestly as `NEEDS REVIEW` or `FAIL`. Never claim false `PASS`.

---

## Stage 9: Delivery, Continuity & Registry Update

1. Save canvas: `figcraft/save_file(path: "projects/<project-slug>/<project-slug>.figcraft")`.
2. Update `projects/<project-slug>/SCREENS.md` with node IDs, viewports, and states.
3. Update `projects/<project-slug>/SESSION_HANDOFF.md` with complete defect register and next steps.
4. Update `projects/<project-slug>/REQUIREMENTS_MAP.md` if PRD-driven.
5. Update `PROJECT_REGISTRY.md` with delivery milestone.
6. Deliver final report with screenshot links and evidence tables.

