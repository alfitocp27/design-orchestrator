# Project Specification: [Project Name]

> **Project Identifier**: `[project-slug]`  
> **Status**: `draft` <!-- draft | in-progress | in-review | completed | archived -->  
> **Discovery Mode**: `PRD-Driven` <!-- From Scratch | PRD-Driven -->  
> **PRD Source / Version**: `[references/PRD.md | External Path | N/A]`  
> **Visual Consultation Status**: `pending` <!-- pending | concepts_presented | approved -->  
> **Design System Status**: `pending` <!-- pending | in-review | approved -->  
> **Surface Mode**: `Operate` <!-- Operate | Persuade | Read | Experience -->  
> **Created Date**: [YYYY-MM-DD]  
> **Last Active**: [YYYY-MM-DD]  
> **Lead Designer / Agent**: [Agent / Pair Lead]

---

## 1. Primary Design File & Document Architecture
- **Canvas File**: `projects/[project-slug]/[project-slug].figcraft`
- **Backup / History Folder**: `projects/[project-slug]/references/`
- **Screenshots & Exports**: `projects/[project-slug]/exports/`

### Document Partitioning (Foundations, Components, Patterns, Screens)
The primary `.figcraft` document is organized into structured sections (pages or canvas sections):
1. `01_Foundations`: 3-tier design tokens (Primitives, Semantic Tokens), native variables/styles, specimen boards (Typography, Colors, Dual Elevation), and Central Vector Icon Library (strict ban on emojis).
2. `02_Components`: Atomic master components and variant sets (`(Item)`) organized into dedicated component family artboards with standardized title cards.
3. `03_Patterns`: Composite assemblies (`(Group)`) and operational patterns (`Data_Tables`, `Modals`, `Instances_Showcase`) using linked instances.
4. `04_Screens`: Application frames (Desktop 1440 × 900, Mobile 390 × 844) composed 100% of linked instances created strictly AFTER design system approval.
*(Optional)*: `00_Cover` (presentation hero frame) and `00_Guidelines` (design principles and usage notes).

> [!IMPORTANT]
> **Design System First, Atomic Hierarchy & Fidelity Awareness**:
> 1. All design work for this project must live inside the single primary `.figcraft` document.
> 2. Foundations and Components must be built and approved by the user BEFORE application screens or dashboards are constructed.
> 3. Atomic progression: construct atomic `(Item)` components first, then assemble `(Group)` molecules using linked instances.
> 4. Emojis are strictly banned from UI designs; use consistent SVG vector icons from the Central Icon Library.
> 5. Treat external templates as architectural references; never assume visual fidelity from data structure alone.
> 6. When opening, agents must execute `figcraft/open_file(path: "projects/[project-slug]/[project-slug].figcraft")` and verify via `figcraft/inspect_document`. Never create stray design files.

---

## 2. Project Scope & Objectives
- **Product Overview**: [Brief description of what this product or module does]
- **Target Audience**: [Primary user personas, operational context, environment]
- **Core User Flow**:
  1. [Step 1: e.g., Land on dashboard overview]
  2. [Step 2: e.g., Filter pending items]
  3. [Step 3: e.g., Review item details and execute action]
  4. [Step 4: e.g., Receive immediate visual feedback / confirmation]

---

## 3. Viewports & Target Breakpoints
| Viewport | Dimensions | Frame Naming Convention | Minimum Tap/Target Size |
|---|---|---|---|
| **Desktop** | 1440 × 900 px | `Desktop_[ScreenName]_[State]` | $\ge 32\text{px}$ height |
| **Mobile** | 390 × 844 px | `Mobile_[ScreenName]_[State]` | $\ge 44 \times 44\text{px}$ touch target |
| **Tablet** *(Optional)* | 834 × 1194 px | `Tablet_[ScreenName]_[State]` | $\ge 40\text{px}$ height |

---

## 4. Required States
In accordance with the Design Orchestrator, states must be strictly separated into dedicated frames:
- [ ] **Populated State**: Realistically populated with domain data (explicitly tagged `[SIMULASI]` if simulated).
- [ ] **Empty State**: Dedicated frame demonstrating zero-data or filtered-to-empty state with helpful recovery actions.
- [ ] **Loading / Skeleton State** *(If required)*: Clear skeleton layout matching populated geometry.
- [ ] **Error / Edge Cases** *(If required)*: Connection drop, validation failure, or permission denied.

---

## 5. Domain & Codebase Integration
- **Codebase Memory Project**: `[None | Project-Name-In-CodebaseMemoryMCP]`
- **Domain Entities**: [Key entities, e.g., User, Request, Status, AuditLog]
- **Status Workflows**: [e.g., draft -> pending_review -> approved | rejected]

---

## 6. Project Boundary & Isolation Rules
1. **Directory Isolation**: All assets, screenshots, and documentation for this project remain strictly within `projects/[project-slug]/`.
2. **Never Cross Projects**: Do not import, modify, or reference files from other project folders (`projects/<other-project>/`).
3. **Session Continuity**: Every session must begin by reading `PROJECT.md`, `REQUIREMENTS_MAP.md` (if available), `DESIGN.md`, `SCREENS.md`, and `SESSION_HANDOFF.md`.
4. **Handoff Discipline**: Every session must conclude by updating `SCREENS.md`, `SESSION_HANDOFF.md`, and `REQUIREMENTS_MAP.md` (if scope changed).
