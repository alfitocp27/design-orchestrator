# [Project Name] - Design System & Direction

> **Unified Single Source of Truth**: 3-tier design tokens, native variables, creative direction, color harmony rules, atomic component architecture, Central Vector Icon Library, Anti-Slop Purpose-Gate records, 8-point stress test log, and Visual Quality Assurance (VQA 2.0) 4-dimensional verification engine.

---

## 1. Product Context & Surface Mode

- **Product Name**: [Project Name]
- **Target Audience**: [Primary user personas, operational context, and technical environment]
- **Surface Mode**: `Operate` <!-- Operate (high-density/dashboards) | Persuade (marketing) | Read (docs) | Experience (interactive) -->
- **Core Workflow**: [Primary action/flow the user performs]
- **Domain Source**: [Codebase, business rules, or domain schemas]
- **Data Integrity**: [Tag simulated data clearly with `[SIMULASI]`]

---

## 2. Brand Identity & Creative Direction

- **Personality**: [e.g., High-trust, analytical, calm, structured, precise]
- **Visual Mood**: [e.g., Clean slate backdrop, crisp white card surfaces, subtle borders, high-contrast typography, purposeful status accents]
- **Anti-Reference**: [What to deliberately avoid: generic purple AI gradients, floating unanchored cards, fake stats, decorative pills without semantic state, mixing populated and empty states]

---

## 3. Visual Reference Research (Benchmark & Heuristics)

*Curated 3 to 5 verified real-world UI/UX benchmarks analyzed for craft floor, column density, interaction affordances, and UX patterns. Zero proprietary PRD or company PII sent to external tools.*

| Ref ID | Source / Platform | Screen / Pattern Type | Reference URL / Identifier | Analyzed Aspects & Strengths | Translation to Project Tokens & UX |
|---|---|---|---|---|---|
| `REF-01` | Mobbin / Web | Enterprise Data Grid & Triage | `https://mobbin.com/...` | High density, locked columns, status pills | Adopted 44px row height and subtle status badge fills |
| `REF-02` | UI/UX Pro Max | Palette & Typography Pairing | In-memory search (`Operate` style) | High contrast slate/blue, tabular figures | Adopted `#1E40AF` primary action and `Inter` font scale |
| `REF-03` | Behance / Web | Modern Command Center | `https://behance.net/...` | Tonal surface layering, subtle elevation | Applied micro-shadows to card containers |

---

## 4. Visual Consultation Concepts & Concept Sign-Off

*2 to 3 differentiated visual directions evaluated before canvas design system construction. Must include one clear recommended direction.*

### Concept Options Matrix
| Dimension | Concept 1 (Recommended): Technical Precision | Concept 2: Modern Editorial Clean | Concept 3: High-Density Swiss |
|---|---|---|---|
| **Palette / Mood** | Slate cool backdrop (`#F8FAFC`), crisp white cards, royal blue primary (`#1E40AF`) | Neutral warm canvas (`#FAF9F5`), ivory cards, emerald accent (`#059669`) | Light gray (`#F3F4F6`), high-contrast dark navy primary (`#0F172A`) |
| **Typography** | Inter / Plus Jakarta Sans: crisp geometric sans, clear tabular numerals | Instrument Sans / Outfit: contemporary editorial sans | Roboto / System UI: utilitarian, compact scanability |
| **Iconography** | 20 × 20 px SVG, 1.5px clean outline (Zero Emojis) | 20 × 20 px SVG, 1.75px rounded outline (Zero Emojis) | 18 × 18 px SVG, 2.0px crisp sharp outline (Zero Emojis) |
| **Density & Grid** | 8px grid, compact-comfortable padding | 8px grid, spacious padding, generous whitespace | 4px/8px grid, ultra-compact high information density |
| **Elevation** | Subtle dual micro-shadows (`0 1px 2px rgba(...)`) | Soft diffused shadows, floating surface cards | 1px structural borders (`#E5E7EB`), flat elevation |
| **PRD Alignment Rationale** | Highest operational scanability for high-volume review workflows; balances speed and clarity | Friendly and contemporary, but lower data density | Maximum data throughput, but potentially higher cognitive fatigue |

### Visual Concept Sign-Off (Hard Gate)
- **Selected Concept**: `Concept 1 (Technical Precision)` <!-- Concept 1 | Concept 2 | Concept 3 | Custom Blended -->
- **User Approval Date**: [YYYY-MM-DD]
- **User Customization Notes**: [e.g., Use Concept 1 colors with Concept 3 ultra-compact table density]
- **Approval Status**: `APPROVED` <!-- PENDING | APPROVED -->

---

## 5. 3-Tier Design Tokens & Native Variables Architecture

### 5.1 Tier 1: Primitives (Foundational Scales)
| Primitive Token | Value | Type | Collection Name | Description |
|---|---|---|---|---|
| `Spacing/0` .. `6` | `0px`, `4px`, `8px`, `12px`, `16px`, `20px`, `24px` | Number | `Primitives` | Base spacing scale |
| `Radius/none` .. `xl` | `0px`, `4px`, `6px`, `8px`, `12px`, `9999px` | Number | `Primitives` | Corner radius scale |
| `Color/Brand/50`..`900` | Hex scale (`#EFF6FF` s.d. `#1E3A8A`) | Color | `Primitives` | Raw brand palette scale |
| `Color/Slate/50`..`900` | Hex scale (`#F8FAFC` s.d. `#0F172A`) | Color | `Primitives` | Raw neutral slate scale |
| `Color/Emerald/50`..`900`| Hex scale (`#ECFDF5` s.d. `#064E3B`) | Color | `Primitives` | Raw success palette scale |
| `Color/Crimson/50`..`900`| Hex scale (`#FEF2F2` s.d. `#7F1D1D`) | Color | `Primitives` | Raw danger palette scale |

---

### 5.2 Tier 2: Semantic Tokens (Aliases & WCAG 2.2 Verification)
| Semantic Token Name | Primitive Alias / Value | Semantic Role | Contrast on `#FFFFFF` / Surface | WCAG Compliance |
|---|---|---|---|---|
| `color/background` | `Color/Slate/50` (`#F8FAFC`) | Canvas root background | N/A | Base Canvas |
| `color/surface` | `#FFFFFF` | Card, table, panel surfaces | N/A | Base Surface |
| `color/surface-subtle` | `Color/Slate/100` (`#F1F5F9`) | Table headers, muted panels | N/A | Sub-surface |
| `color/primary` | `Color/Brand/600` (`#[Hex]`) | Primary brand CTAs & active states | $\ge 4.5:1$ | WCAG AA / AAA |
| `color/primary-hover` | `Color/Brand/700` (`#[Hex]`) | Hover state for primary buttons | $\ge 4.5:1$ | WCAG AA |
| `color/text-primary` | `Color/Slate/900` (`#[Hex]`) | Headings, titles, high-priority text | $\ge 7.0:1$ | WCAG AAA |
| `color/text-secondary`| `Color/Slate/600` (`#[Hex]`) | Descriptions, body content | $\ge 4.5:1$ | WCAG AA |
| `color/text-muted` | `Color/Slate/400` (`#[Hex]`) | Secondary labels, captions, metadata | $\ge 4.5:1$ | WCAG AA |
| `color/border` | `Color/Slate/200` (`#[Hex]`) | Card borders, dividers, grid lines | Structural boundary | Structural (1px) |
| `status/success-bg` | `Color/Emerald/50` (`#[Hex]`)| Success pill background | N/A | Pill Base |
| `status/success-text`| `Color/Emerald/700`(`#[Hex]`)| Success pill text | $\ge 4.5:1$ on bg | WCAG AA |
| `status/progress-bg` | `Color/Blue/50` (`#[Hex]`)   | In-progress pill background | N/A | Pill Base |
| `status/progress-text`|`Color/Blue/700` (`#[Hex]`)  | In-progress pill text | $\ge 4.5:1$ on bg | WCAG AA |
| `status/warning-bg` | `Color/Amber/50` (`#[Hex]`)  | Warning pill background | N/A | Pill Base |
| `status/warning-text`| `Color/Amber/800` (`#[Hex]`) | Warning pill text | $\ge 4.5:1$ on bg | WCAG AA |
| `status/danger-bg`  | `Color/Crimson/50` (`#[Hex]`)| Danger pill background | N/A | Pill Base |
| `status/danger-text` | `Color/Crimson/700`(`#[Hex]`)| Danger pill text | $\ge 4.5:1$ on bg | WCAG AA |

---

### 5.3 Tier 3: Component Tokens (Native Collection: `ComponentTokens`)

*Component tokens alias Tier 2 Semantic Tokens. Updating a Tier 1 Primitive automatically cascades through Semantic Tokens down to Component Tokens, Master Components, and all multi-page Linked Instances.*

| Component Token | Semantic Token Mapping | Applied Component & Slot |
|---|---|---|
| `btn-primary-bg` | `color/primary` | `Button/Primary` background fill |
| `btn-primary-text` | `#FFFFFF` | `Button/Primary` text & icon stroke |
| `input-border-default` | `color/border` | `Input/Text` stroke |
| `input-border-focus` | `color/primary` | `Input/Text` focus stroke & ring |
| `table-header-bg` | `color/surface-subtle` | `Table/Row (Header)` fill |
| `table-row-hover-bg` | `Color/Slate/50` | `Table/Row` hover state fill |

---

### 5.4 Typography Scale & Specimen Specs
- **Font Family**: Max 2 font families (1 Sans for UI, 1 Mono for data tables/numbers).
- **Legibility Floor**: Minimum body text $13\text{px}$, minimum micro/caption $11\text{px}$.
- **Typographic Scale**:
  - `H1 (Headline 1)`: 48px / SemiBold (600) / Line Height 58px — Hero & Page Titles
  - `H2 (Headline 2)`: 40px / SemiBold (600) / Line Height 48px — Section Banner
  - `H3 (Headline 3)`: 32px / SemiBold (600) / Line Height 38px — Modal & Drawer Headers
  - `H4 (Headline 4)`: 28px / SemiBold (600) / Line Height 34px — Card Headlines
  - `H5 (Headline 5)`: 24px / SemiBold (600) / Line Height 28px — Subsection / Artboard Titles
  - `S1 (Subtitle 1)`: 18px / SemiBold (600) / Line Height 28px — Lead paragraphs
  - `S2 (Subtitle 2)`: 16px / SemiBold (600) / Line Height 24px — Card Subtitles
  - `B1 (Body 1)`: 16px / Regular (400) / Line Height 24px — Primary reading body
  - `B2 (Body 2 Medium)`: 16px / Medium (500) / Line Height 24px — Emphasized body text
  - `B3 (Body 3)`: 14px / Regular (400) / Line Height 20px — Standard UI & data table cells
  - `B4 (Body 4 Medium)`: 14px / Medium (500) / Line Height 20px — Emphasized table data
  - `C1 (Caption 1)`: 12px / Regular (400) / Line Height 16px — Timestamps & metadata
  - `C2 (Caption 2 Medium)`: 12px / Medium (500) / Line Height 16px — Status pill text & badges
  - `C3 (Micro Caption)`: 10px / Medium (500) / Line Height 14px — Micro telemetry labels
  - `Button Scale`: Giant (18px/lh:24), Large (16px/lh:20), Medium (14px/lh:16), Small (12px/lh:16), Tiny (10px/lh:12).

---

### 5.5 Elevation & Dual Drop Shadow Specimen
- `elevation/subtle (100)`: Dual Layer:
  - Ambient: `0 1px 2px rgba(15, 23, 42, 0.04)`
  - Direct: `0 1px 1px rgba(15, 23, 42, 0.02)` — Cards, sidebars, tables.
- `elevation/lifted (300)`: Dual Layer:
  - Ambient: `0 4px 6px -1px rgba(15, 23, 42, 0.07)`
  - Direct: `0 2px 4px -2px rgba(15, 23, 42, 0.05)` — Hovered cards, context menus.
- `elevation/overlay (500)`: Dual Layer:
  - Ambient: `0 10px 25px -5px rgba(15, 23, 42, 0.10)`
  - Direct: `0 6px 14px -6px rgba(15, 23, 42, 0.12)` — Dropdowns, modals, action sheets.
- `focus/ring`: Solid accent halo `0 0 0 3px rgba(30, 64, 175, 0.25)`.

---

## 6. Central Vector Icon Library Registry (Zero Emojis)

All icons reside in `01_Foundations` / Central Icon Library drawn as native vector paths (`vector.create`) with standard $20 \times 20\text{px}$ or $24 \times 24\text{px}$ bounds:

| Icon Name | Category | Node ID | Master Component ID | Bounding Box | Stroke / Fill |
|---|---|---|---|---|---|
| `arrow-left` | Navigation | `[id]` | `[id]` | 24 × 24 px | 1.5px stroke, none |
| `arrow-right`| Navigation | `[id]` | `[id]` | 24 × 24 px | 1.5px stroke, none |
| `search` | Actions | `[id]` | `[id]` | 20 × 20 px | 1.5px stroke, none |
| `filter` | Actions | `[id]` | `[id]` | 20 × 20 px | 1.5px stroke, none |
| `check` | Feedback | `[id]` | `[id]` | 20 × 20 px | 2.0px stroke, none |
| `alert-circle`| Feedback| `[id]` | `[id]` | 20 × 20 px | 1.5px stroke, none |

---

## 7. Atomic Component Hierarchy (Item $\rightarrow$ Group $\rightarrow$ Pattern)

| Component Level | Component Set Name | Node ID | Sub-Items / Linked Instances Composed | Variants & Properties |
|---|---|---|---|---|
| **Atom / Item** | `Button` | `[id]` | None (embeds nested `Icon` master) | `Size=Giant..Tiny`, `State=Default/Hover/Focus/Disabled`, `Style=Filled/Outline/Clear`, `Icon Left` (bool), `Icon Right` (bool) |
| **Atom / Item** | `Nav/Item` | `[id]` | None (embeds nested `Icon` master) | `State=Selected/Inactive`, `Style=Line/Pill` |
| **Atom / Item** | `List/Left_Item` | `[id]` | Embeds `Avatar` or `Icon` | `Content=Avatar+Text/Icon+Text` |
| **Atom / Item** | `List/Right_Item`| `[id]` | Embeds `Badge` or `Icon` | `Content=Text+Icon/Badge+Icon` |
| **Molecule / Group**| `Button Group (Group)` | `[id]` | Composes 2–5 linked instances of `Button Group (Item)` | `Amount=2..5`, `Size=Giant..Medium` |
| **Molecule / Group**| `Navbar Bottom (Group)` | `[id]` | Composes 3–5 linked instances of `Nav/Item` | `Amount=3..5`, `Style=Line/Pill` |
| **Molecule / Group**| `List Row (5 Rows)` | `[id]` | Composes 5 linked instances of `List/Left_Item` + `List/Right_Item` | `State=Default` |
| **Organism / Pattern**| `Card/KPI_Deck` | `[id]` | Composes `Badge/Status` + metrics + trend indicators | `Props: title, value, delta, unit` |
| **Organism / Pattern**| `Table/Data_Grid` | `[id]` | Composes `Table/Row` (Header, Default, Alert) with locked columns | `Columns: 6, RowHeight: 44px` |
| **Organism / Pattern**| `Pop-Up Modal` | `[id]` | Composes `Card` + `TopBar` + linked `Button` instances | `Layout=Vertical/Horizontal Buttons` |

---

## 8. Figma Import Fidelity Log & Runtime Verification

*Tracks verified native capabilities and documented fallbacks when importing or benchmarking external files.*

| Feature / Tooling | Verified Status | Observed Behavior in FigCraft | Fallback Protocol |
|---|---|---|---|
| **Auto Layout** | `VERIFIED` | 93.4%+ frames import with full `layout.mode`, padding, and gap preservation. | Set explicitly via `node.set {props: {layout}}` if missing. |
| **Variable Collections** | `VERIFIED / PARTIAL` | Collections & aliases import; root types serialize inside modes dictionary. | Bind via `variable.bind`. Fallback to `styles` and `DESIGN.md` tables if binding fails. |
| **Component Sets** | `VERIFIED` | Purple dashed bounding boxes and variant names import cleanly. | Maintain variant naming (`Property=Value`) for all variant sets. |
| **Boolean Properties** | `VERIFIED` | Component boolean properties import and control nested layer visibility. | Add explicit boolean properties via `component.addProperty`. |
| **Instance Swapping** | `VERIFIED` | `instance.swap` replaces nested icon components cleanly. | Use `instance.swap {ids, component}` to change icon types. |

---

## 9. Mandatory 8-Point Component Stress Testing Protocol

Before submitting the design system for user approval, execute and record this 8-point live canvas test:

| Test Item | Target Component & Node ID | Action Executed | Observed Result | Verdict |
|---|---|---|---|---|
| **1. Master-to-Instance Propagation** | `Card/KPI` (`#ID`) | Modified `cornerRadius` on Master $\rightarrow$ inspected Instance | Instance updated automatically $\rightarrow$ reverted | `PASS` |
| **2. Instance Overrides Isolation** | `Button/Primary` (`#ID`) | Overrode text label & prop on Instance | Master & peer instances untouched | `PASS` |
| **3. Variant Switching** | `Badge/Status` (`#ID`) | Switched variant via `instance.setProperties` | Visual styling updated without detaching | `PASS` |
| **4. Nested Icon Inheritance & Swap** | `Button` with nested `Icon` | Updated nested icon Master stroke; swapped icon via `instance.swap` | Cascaded to all composite instances; swap clean | `PASS` |
| **5. Extreme Content Stress** | `Table/Row` & `Button` | Injected long string, short string, empty string | Auto-layout adapted, zero clipping | `PASS` |
| **6. Permutation Stress** | `Card/KPI` (`#ID`) | Swapped units (`Kg`, `Rp`, `%`) and deltas (+/-) | Metrics & labels aligned cleanly | `PASS` |
| **7. Sizing & Overflow Stress** | `Input` / `Badge` in narrow box | Tested narrow container; applied Zero Critical Data Loss policy (multi-line wrapping / adaptive flex before truncation) | Sizing hug/fill preserved padding, no critical data clipped | `PASS` |
| **8. Save & Reload Persistence** | Entire Canvas | `save_file` $\rightarrow$ `open_file` $\rightarrow$ `component.list` | 100% components & linked instances intact | `PASS` |

---

## 10. Anti-Slop Purpose-Gate Register

*Every decorative, stylized, or visual technique MUST justify its functional purpose below (Anti-Slop Hard Gate).*

| Visual Technique | Element / Component | Purpose & Hierarchy Rationale |
|---|---|---|
| **Status Tint Pill** | Status indicators (`Badge/Status`) | Instant visual triage of pending vs approved items without reading text |
| **Subtle Border (1px)** | Table & card containers | Clear structural boundary between canvas background and data container |
| **Primary Fill Button** | Main approval action | Unmistakable primary CTA dominance over secondary / destructive actions |
| **Dual Micro-Elevation** | Card containers | Provides tactile lift and separation from base canvas without floating unanchored |

---

## 11. Design System User Approval Sign-Off (Mandatory Hard Gate)

> [!CRITICAL]
> **Design System First Protocol**: Application screens and dashboards in `04_Screens` must NOT be generated until the sign-off below is marked `APPROVED` by the user.

- **Review Date**: [YYYY-MM-DD]
- **Design System Preview Ref**: `exports/design_system_preview.png`
- **Approval Status**: `PENDING_USER_APPROVAL` <!-- PENDING_USER_APPROVAL | APPROVED -->
- **User Feedback / Notes**: [User review notes]

---

## 12. Visual Quality Assurance (VQA 2.0) 4-Dimensional Audit Log

### The 4-Dimensional Quality Audit Checklist
- [ ] **Dimensi 1: Technical Integrity**: Parent auto-layout explicit, locked table columns ($\Delta x \le 1\text{px}$), native components verified (`component.list`), save & reload persistent.
- [ ] **Dimensi 2: Visual Quality & Craft**: WCAG 2.2 contrast verified ($\ge 4.5:1$), zero color clashing (no cyan on green), micro-elevation applied, minimum body text $\ge 13\text{px}$, variant label clearance $\ge 24\text{px}$, clean unselected screenshots.
- [ ] **Dimensi 3: UX & Semantic Quality**: Populated vs empty states strictly separated, domain realism verified with `[SIMULASI]` tags, 8-Point Stress Testing passed, Zero Critical Data Loss policy enforced (wrapping & adaptive sizing prior to any ellipsis).
- [ ] **Dimensi 4: Creative Quality & Character**: Distinct product personality (avoids generic AI template look), faithful to approved Stage 4 concept, purposeful visual innovation.

### Audit Run History
| Audit Date | Inspector | Screenshot Reference | P1/P2 Defect Count | Quality Gate Verdict |
|---|---|---|---|---|
| [YYYY-MM-DD] | [Agent ID] | `exports/[artboard]_[timestamp].png` | 0 | `PASS` / `NEEDS REVIEW` / `FAIL` |
