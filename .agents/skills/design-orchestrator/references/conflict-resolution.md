# Design Orchestrator 2.0: Tool Harmonization & Precedence Matrix

> **Design Orchestrator 2.0 Reference**  
> Resolving tensions, overlaps, and precedence rules among Anti-Slop, Impeccable, UI/UX Pro Max, FigCraft MCP, and CodebaseMemoryMCP.

---

## 1. Tool Responsibility Matrix

Each skill and tool in Design Orchestrator has an explicit, non-overlapping mandate:

| Skill / MCP | Core Responsibility | Input Trigger | Primary Deliverables | Strict Boundary |
|---|---|---|---|---|
| **Anti-Slop** | **Quality Guardrail**<br>(Filter, not beautifier) | Always active (Default `DURING`) | Hard gates (R-02 no em-dash, R-25 contrast, R-03 mobile, R-17/38 truth in data, R-26 affordances). Purpose-Gate checks. | **Does NOT dictate aesthetic style**. Must NOT force designs to be flat or border-first. Rejects technique without purpose, not technique itself. |
| **Impeccable** | **Visual Direction & Craft Evaluator** | Stage 1 (Surface Mode) & Stage 6/8 (Craft Audit) | Surface mode briefs (`Operate`, `Persuade`, `Read`, `Experience`), visual hierarchy, tactile depth, typography scale, whitespace balance. | Guides craft floor and visual delight; does NOT execute canvas commands directly. |
| **UI/UX Pro Max** | **Design Intelligence & Benchmark Engine** | Stage 3 (Research) & Stage 4 (Concepts) | Curated font pairings, color palette scales, domain tokens, and benchmark heuristics via `search.py --design-system --json`. | Provides design reference data; does NOT generate standalone `.md` files in workspace root. |
| **CodebaseMemoryMCP** | **Schema & Business Logic Authority** | Stage 2 (Codebase Analysis) | Database schemas, status enums, permission matrices, and workflow steps from existing repository graphs. | Governs functional truth; does NOT dictate visual styling. |
| **FigCraft MCP** | **Native Canvas Execution & Geometry Engine** | Stage 5 (Design System) through Stage 9 | Native components (`component.create`), component sets, linked instances, auto-layout, screenshot exports, geometry audits. | Executes canvas commands; requires explicit document targeting (`open_file`). |

---

## 2. Resolving Key Tensions & Potential Conflicts

### Tension A: Anti-Slop Guardrails vs. Impeccable Visual Boldness

| Conflict Scenario | Anti-Slop Stance | Impeccable Stance | Orchestrator 2.0 Resolution |
|---|---|---|---|
| **Gradients & Shadows** | Bans generic blue-to-purple AI gradients and floating unanchored cards. | Recommends rich color accents, tactile elevation, and visual depth. | **Purpose-Gating**: Gradients and micro-elevation are ALLOWED and ENCOURAGED when they establish hierarchy or reflect authentic brand identity. They FAIL only if added blindly as generic decoration without documented purpose in `DESIGN.md`. Anti-Slop must never force a sterile, flat-grey default. |
| **Border-First vs. Tonal Surfaces** | Recommends structural boundaries to delineate data containers. | Recommends subtle tonal layering and diffused micro-elevation to prevent visual fatigue. | **Proportional Borders**: Borders must NOT be overly heavy or dark on every element. Use soft structural borders (`#E2E8F0` or `#E5E7EB`) layered with micro-elevation (`0 1px 2px rgba(0,0,0,0.05)`). Do not outline every element with dark slate borders. |
| **Pill Badges & Status Tints** | Forbids arbitrary capsule badges containing "AI Powered", "Beta", "Fast". | Recommends clear status triage tags. | **Semantic Badges**: Badges are permitted exclusively for real semantic states (Pending, Approved, Warning, Critical) with WCAG AA compliant text and subtle background fills. |

---

### Tension B: UI/UX Pro Max Output vs. Project Isolation

- **Issue**: UI/UX Pro Max CLI `--persist` generates `design-system/<project>/MASTER.md` in the workspace root or local directory.
- **Resolution**: Use UI/UX Pro Max **strictly in-memory** (`--json` flag). Ingest token data and font pairings directly into the unified project document `projects/<project-slug>/DESIGN.md`. Never create stray design system files in the root directory.

---

### Tension C: PRD Functional Truth vs. Visual Direction (DESIGN.md)

| Artifact | Authority Level | Scope | Rule |
|---|---|---|---|
| **PRD / User Stories / Spec** | Functional Source of Truth | Business rules, user roles, permission matrices, workflow logic, mandatory data fields. | Agent must NEVER silently rewrite, delete, or bypass PRD constraints. |
| **`DESIGN.md`** | Visual & UX Source of Truth | Visual hierarchy, color tokens, typography scales, spacing grid, elevation profiles, component variant states. | Must not contradict PRD business rules without explicit user sign-off. |

- **Conflict Protocol**: If a visual technique or layout collides with a functional PRD rule:
  1. Immediately log the conflict in `projects/<project-slug>/REQUIREMENTS_MAP.md` under Section 5.
  2. Flag the trade-off explicitly in chat.
  3. Await the user's decision before touching the canvas. Never unilaterally modify the PRD.

---

## 3. Impact-Based Defect Classification for Visual QA 2.0

When reporting defects across the 4 Dimensions, categorize findings strictly by **actual user impact**:

1. **P1 - Critical / Blocker (Functional, Severe Accessibility, or Architectural)**:
   - Functional failure: Broken navigation or dead controls without declared destinations.
   - Severe accessibility violation: Contrast ratio $< 3.0:1$ on text, illegible font $< 11\text{px}$, or mobile touch target $< 44\text{px}$.
   - Severe data truncation or clipping that obscures critical business/decision data.
   - Architectural failure: Plain frames falsely claiming to be reusable components.
   - Component breaking or collapsing under dynamic content stress testing.
2. **P2 - Major / Usability & Semantic Degradation**:
   - Table column misalignment $\Delta x > 2\text{px}$.
   - Contrast between $3.0:1$ and $4.5:1$ on normal text (WCAG AA violation).
   - Severe color clashing that creates cognitive confusion or breaks semantic recognition (e.g. status cyan on primary green button).
   - Visible overlap of labels with component borders ($< 24\text{px}$ clearance).
   - State collision (empty state mixed into populated table).
   - Dead unanchored whitespace $> 100\text{px}$.
3. **P3 - Minor / Polish & Refinement**:
   - Subtle optical alignment adjustments ($\Delta x \le 1\text{px}$).
   - Micro-spacing rhythm adjustments (e.g. 12px vs 16px).
   - Subtle border tone or micro-elevation tuning.
   - Stylistic preferences that do NOT impair legibility, comprehension, or usability.  
   *(Aesthetic nuances must NEVER be classified as P1 or block delivery).*

