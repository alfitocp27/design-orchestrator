# Requirements Map: [Project Name]

> **Project Identifier**: `[project-slug]`  
> **Source PRD / Spec**: `[references/PRD.md | External Path | N/A (From Scratch)]`  
> **Document Version**: `[v1.0.0 | Date]`  
> **Last Synchronized**: [YYYY-MM-DD HH:MM:SS]  
> **Functional Source of Truth**: PRD / Specification  
> **Visual & UX Source of Truth**: `projects/[project-slug]/DESIGN.md`

---

## 1. System Overview & Core Objectives
- **System Goal**: [High-level objective extracted from PRD]
- **Target Modules**: [Module 1, Module 2, Module 3]
- **Key Business Constraints**: [e.g., SLA, compliance, data residency, offline support]

---

## 2. User Roles & Permission Matrix
| Role Name | Access Level | Primary Tasks & Capabilities | Viewport Context |
|---|---|---|---|
| **Admin / Manager** | Full / Approval | Review submissions, approve/reject, configure rules | Desktop (high density) |
| **Operator / Staff** | Contributor | Submit requests, track status, view personal history | Desktop / Mobile |
| **Viewer / Auditor** | Read-Only | Inspect audit trails, export compliance reports | Desktop |

---

## 3. Functional Requirements to Design Mapping

*Maps every functional requirement from the PRD to corresponding screens, components, and interaction states.*

| Req ID | PRD Source / Story | Business Rule & Workflow Logic | Mapped Screen(s) | Mapped Component(s) | Design Implementation Notes | Status |
|---|---|---|---|---|---|---|
| `REQ-001` | Section 3.1 / US-01 | Users can filter pending items by department & date | `Desktop_Overview_Populated` | `FilterBar`, `SelectDropdown` | Preserves active filter state; auto-submits on select | `Mapped` |
| `REQ-002` | Section 3.2 / US-04 | Dual-action approval (Approve / Reject with reason) | `Desktop_Overview_Populated`, `Detail_Modal` | `Button[Primary]`, `Button[Destructive]` | Rejection requires modal with mandatory reason textarea | `Mapped` |
| `REQ-003` | Section 4.0 / US-09 | Zero-data state when no items require review | `Desktop_Overview_Empty` | `EmptyStateCard` | Explicit recovery action: "Reset filters" or "Check history" | `Mapped` |

---

## 4. Undetermined Visual & UX Decisions (Consultation Register)

*Lists requirements or UX behaviors NOT specified in the PRD that require user consultation before canvas work.*

| Item ID | Domain / Scope | Ambiguity / Undetermined Aspect | Proposed Options | User Decision | Status |
|---|---|---|---|---|---|
| `DEC-001` | Data Density | Table row density preference | Option A: Compact (48px) vs Option B: Comfortable (64px) | [Pending User Input] | `OPEN` |
| `DEC-002` | Mobile Navigation | Bottom navigation vs Drawer | Option A: Bottom Bar (4 items) vs Option B: Hamburger Drawer | [Pending User Input] | `OPEN` |

---

## 5. PRD vs Design Conflict Log

> [!CAUTION]
> **Zero Silent Mutation Rule**: If a design or UX pattern conflicts with a functional rule in the PRD, the agent MUST NOT silently alter the PRD or override it. Log the conflict below and await user resolution.

| Conflict ID | PRD Requirement | Conflicting Design Proposal | Impact Analysis | User Resolution / Direction | Status |
|---|---|---|---|---|---|
| `CONF-001` | PRD specifies single-step reject | Modal dialog with reason input proposed | Adds friction but satisfies audit compliance | [Pending User Decision] | `OPEN` |

---

## 6. Traceability Verification Checklist
- [ ] Every user story in the PRD is mapped to at least one screen frame or state.
- [ ] All mandatory data fields have matching inputs or table column containers.
- [ ] Role-based visibility rules are reflected in component variant specifications.
- [ ] No functional questions were asked to the user that were already answered in the PRD.
- [ ] All open visual and UX ambiguities are resolved in Section 4.
