# Dynamic Creative Direction & Archetype Engine

> **Design Orchestrator 2.2 Reference**  
> Comprehensive runbook for conducting domain intelligence, multi-source design research, formulating structurally distinct visual concepts across 10 mandatory dimensions, evaluating trade-offs, and enforcing the Concept Approval Gate.

---

## 1. Escaping Generic AI Slop & The "Sterile Default" Trap

AI coding agents typically fail interface design in one of two predictable extremes:
1. **The AI Slop Extreme**: Purple-to-blue decorative mesh gradients, glowing card borders (`box-shadow: 0 0 20px #8b5cf6`), unanchored floating boxes, generic capsule pills on every corner, skeleton loaders masquerading as real layouts, and generic Lucide icons scattered without domain semantics.
2. **The Sterile Default Extreme**: Flat grey-on-white boxes, heavy dark borders (`1px solid #334155`), lack of spatial rhythm, tiny 10px monospace text everywhere, and zero brand personality or human warmth.

**The Solution**: The **Dynamic Creative Direction Engine** replaces rigid preset templates with adaptive design synthesis: **Intentional Depth, Distinct Typography, Purposeful Color Harmony, Domain Spatial Structure, and Rigorous Contrast Validation**.

```
+---------------------------------------------------------------------------------------------------+
| DYNAMIC CREATIVE DIRECTION SYNTHESIS                                                              |
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|   [STAGE 1: DOMAIN INTELLIGENCE]           [STAGE 2: MULTI-SOURCE RESEARCH]                       |
|   * Product Typology & Workflow            * UI/UX Pro Max (192 Palettes, 74 Fonts, 25 Charts)    |
|   * User Persona & Environment             * Impeccable (Surface Modes: Operate, Persuade, Read)  |
|   * Information Complexity & Density       * Anti-Slop (Rules R-01 to R-40 Purpose Gate)          |
|   * Brand & WCAG Accessibility             * NeedMCP (Optional Cloud Benchmark: getStyle)        |
|                     |                                        |                                    |
|                     +-------------------+--------------------+                                    |
|                                         |                                                         |
|                                         v                                                         |
|                     [STAGE 3: 2-3 DIVERGENT CONCEPTS (10 DIMENSIONS)]                             |
|                     1. Identity & Rationale         6. Surface & Radii                            |
|                     2. Curated Benchmarks           7. Iconography                                |
|                     3. Typography Pairing           8. Data Visualization                         |
|                     4. Color Palette & WCAG         9. Accessibility (AA/AAA)                     |
|                     5. Layout & Spatial Grid       10. UX Trade-Offs                              |
|                                         |                                                         |
|                                         v                                                         |
|                     [STAGE 4: DUAL-TRACK EVALUATION]                                              |
|                     * Deterministic Check (WCAG Math, Field Completeness, Divergence)             |
|                     * Subjective Craft Review (Visual Hierarchy, Brand Fit, Scannability)         |
|                                         |                                                         |
|                                         v                                                         |
|                     [STAGE 5: 🛑 CONCEPT APPROVAL GATE (User Sign-Off)]                            |
|                     * No style locking (selectStyle) before approval                              |
|                     * Generates DESIGN.md -> Native FigCraft Design System                        |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Tahap 1: Product & Domain Intelligence Framework

Never select a palette, layout, or typography pairing based on a single keyword in the user brief (e.g., choosing "blue dashboard" just because the word "analytics" appeared). The agent must systematically analyze the seven core dimensions of product context:

### 2.1 The Seven Domain Intelligence Facets

1. **Product Typology & Purpose**:
   - What fundamental problem is the interface solving? (e.g., Real-time Industrial SCADA, High-frequency Trading Desk, Adaptive Learning LMS, Audio Mastering Workstation, Medical Diagnostics, B2B Logistics Dispatch).
2. **Target User Persona & Mental Model**:
   - Who uses this screen daily? (e.g., Fatigue-prone night-shift dispatchers, busy teachers grading 150 exams, precision audio engineers, senior enterprise executives viewing high-level summaries).
3. **Operational Environment & Lighting**:
   - Where is the screen used? (e.g., Low-light control room requiring dark high-contrast mode, bright sunlight mobile field tablets, multi-monitor desk setup, clean corporate office).
4. **Information Complexity & Cognitive Load**:
   - How dense is the raw data? (e.g., High-density tabular telemetry with 20+ columns vs. low-density educational storytelling with linear progression).
5. **User Visual & Cultural Preferences**:
   - What emotional tone is appropriate? (e.g., Utilitarian, precision-engineered, authoritative, warm and inviting, playfully encouraging, minimalist editorial).
6. **Brand Constraints & Accessibility Baseline**:
   - Are there corporate brand colors that must be integrated? All color pairings must meet WCAG 2.2 AA ($4.5:1$ for normal body text, $3.0:1$ for large text and UI components).
7. **Data Visualization & Real-Time Needs**:
   - Does the screen require time-series line charts, distribution histograms, multi-state status badges, anomalous alert overlays, or live gauges?

---

## 3. Tahap 2: Multi-Source Design Research

The agent synthesizes design intelligence from multiple coordinated authorities. No single tool or database is treated as the sole dictator.

```
+-------------------------------------------------------------------------------------------------------+
| MULTI-SOURCE COORDINATION MATRIX                                                                      |
+----------------------+---------------------------+----------------------------------------------------+
| Source Tool          | Primary Intelligence      | Execution Protocol                                 |
+----------------------+---------------------------+----------------------------------------------------+
| **UI/UX Pro Max**    | 192 Curated Palettes      | Query via Python:                                  |
|                      | 74 Typography Pairings    | `python search.py "<domain>" --domain color --json`|
|                      | 79 UI Styles & 25 Charts  | `python search.py "<domain>" --domain typography`  |
|                      | 119 UX Guidelines         | `python search.py "<data_type>" --domain chart`    |
+----------------------+---------------------------+----------------------------------------------------+
| **Impeccable**       | Surface Modes:            | Audit cognitive density and surface hierarchy:     |
|                      | - *Operate* (High Density)| Compact $32-40\text{px}$ controls for data tools;  |
|                      | - *Persuade* (Brand/Hero) | Spacious $48-56\text{px}$ for conversion/welcome;  |
|                      | - *Read* (Editorial/Doc)  | $65-75$ character line length for education/docs.  |
+----------------------+---------------------------+----------------------------------------------------+
| **Anti-Slop**        | Negative Constraint Guard | Apply Rules R-01 to R-40:                          |
|                      | (Purposeless Aesthetic)   | Ban AI glow, purple gradient clichés, unanchored   |
|                      |                           | cards, and meaningless decorative pills.           |
+----------------------+---------------------------+----------------------------------------------------+
| **NeedMCP (Opt)**    | Secondary External Bench  | Status `UNVERIFIED_RUNTIME` unless key configured: |
|                      | (Web Theme Catalog)       | Read-only `getStyle(slug)` for exploration;        |
|                      |                           | `selectStyle` prohibited prior to sign-off.        |
+----------------------+---------------------------+----------------------------------------------------+
```

---

## 4. Tahap 3: Dynamic Creative Direction & The 10 Dimensions

### 4.1 Archetypes as Dynamic Starting Seeds, Never Rigid Handcuffs
Older orchestrators forced every project into one of 5 rigid static archetypes. Design Orchestrator 2.2 treats archetype archetypes (e.g., *Technical Precision*, *Humanist Editorial*, *Industrial High-Contrast*, *Modern Spatial Minimal*) purely as **dynamic starting seeds**.

The agent adapts the seeds to the specific brief by varying density, typography classification, elevation models, and spatial composition.

### 4.2 The 10 Mandatory Dimensions per Concept

Every concept presented to the user must detail each of the following 10 dimensions:

1. **Design Identity & Rationale**:
   - The thematic concept name, core design philosophy, and specific justification for why this direction fits the user persona and domain workflows.
2. **Relevant Visual Benchmarks / Precedents**:
   - Real-world production references or curated benchmarks solving comparable operational workflows (e.g., Linear, Bloomberg Terminal, Ableton Live, Coursera, Grafana).
3. **Typography Direction**:
   - Specific font families for Headings, Body, and Tabular/Data, including weights, scale ratio (e.g. Major Second $1.125$ for dense vs. Perfect Fourth $1.333$ for editorial), line heights, and tracking.
4. **Color Direction & WCAG Ratios**:
   - Exact hex tokens for Canvas Base, Card Surface, Primary Brand/Action, Secondary Neutral, Structural Border, Text Primary, Text Secondary, and Semantic Statuses (Success, Warning, Destructive, Info).
   - Documented WCAG 2.2 contrast ratios for Text Primary vs. Canvas/Card (must be $\ge 4.5:1$).
5. **Layout Composition & Spatial Grid**:
   - Column grid structure (e.g., 12-column responsive, asymmetrical 3-pane workbench, single-column focused reading shell), margin/gutter scales, and primary visual focal points.
6. **Surface Treatment & Elevation**:
   - Layering model: Border-first (crisp 1px borders, 0px shadow) vs. Ambient-elevation (subtle diffuse shadows, rounded corners) vs. Flat-recessed (contrasting background tiles).
   - Border radius scale (e.g. Sharp $2-4\text{px}$ vs Standard $6-8\text{px}$ vs Rounded $12-16\text{px}$).
7. **Iconography & Visual Accents**:
   - Stroke weight ($1.5\text{px}$ vs $2.0\text{px}$), outline vs duotone, corner styling matching typography geometry.
8. **Data Visualization Direction (if applicable)**:
   - Primary chart types (Line with confidence band, anomaly markers, bar/histogram, gauge), data color ramps with categorical distinctness, tooltip and hover behaviors.
9. **Accessibility Considerations**:
   - Explicit WCAG 2.2 AA compliance notes, high-contrast focus rings ($2\text{px}$ solid with $2\text{px}$ offset), reduced-motion guidelines, and readability under target lighting.
10. **UX Trade-Offs & Strategic Suitability**:
    - Honest assessment of strengths, weaknesses, and potential drawbacks (e.g., "Maximizes data throughput on wide monitors but requires horizontal scrolling on smaller viewports").

---

## 5. Tahap 4: Concept Evaluation & Synthesis Matrix

### 5.1 Enforcing Structural & Visual Divergence
The 2–3 concepts must exhibit **true structural divergence**, not cosmetic variations:
- **Divergence Check 1 (Typography)**: Concepts must not all use identical font categories (e.g., if Concept 1 uses Geometric Sans + Mono, Concept 2 should explore Humanist Sans or Neo-Grotesque, and Concept 3 may explore Modern Technical or Editorial Serif).
- **Divergence Check 2 (Spatial Density)**: Concepts should offer contrasting information density levels (e.g., Compact Operate vs. Balanced Comfortable).
- **Divergence Check 3 (Surface Philosophy)**: Concepts must differ in elevation strategy (e.g., High-contrast crisp border-first vs. Soft tonal layering).

### 5.2 Strict Separation: Deterministic QA vs. Subjective Craft Review
- **Deterministic QA (Automated)**:
  - Contrast math validation $(L1 + 0.05)/(L2 + 0.05) \ge 4.5:1$.
  - Mandatory 10-dimension completeness check.
  - Absence of prohibited AI-slop keywords (e.g. gratuitous glowing borders).
- **Subjective Craft Review (Human / Agent Advisory)**:
  - Visual hierarchy, brand resonance, emotional appropriateness, user delight.
  - **Rule**: Never assign arbitrary pseudo-mathematical scores (e.g., "Aesthetic Score: 94/100"). State qualitative observations, strengths, and trade-offs.

---

## 6. Tahap 5: Concept Approval Gate & DESIGN.md Generation

```
+---------------------------------------------------------------------------------------------------+
| 🛑 CONCEPT APPROVAL GATE PROTOCOL                                                                 |
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|   1. Present 2-3 Concepts in chat with comparative matrix and 1 clear recommendation.             |
|   2. Await explicit user response (Option A, Option B, or hybrid blend).                          |
|   3. DO NOT call NeedMCP `selectStyle` or write canvas components before user approval.           |
|   4. Upon approval, generate `design-system/<slug>/DESIGN.md` capturing the chosen direction.     |
|   5. Transition to Stage 5 (Native FigCraft Component Engineering).                               |
+---------------------------------------------------------------------------------------------------+
```

### 6.1 Native FigCraft Translation Rules
Never assume web CSS or HTML specifications translate automatically into Figma/FigCraft without adaptation:
- Web `display: flex` $\rightarrow$ FigCraft `FRAME` with Auto Layout (`layoutMode: "HORIZONTAL"` or `"VERTICAL"`).
- Web CSS class `.btn` $\rightarrow$ Master `COMPONENT` in `02_Components` page.
- Repeating buttons in screen $\rightarrow$ Linked `INSTANCE` with `instance.create { component: masterId }`.
- Viewports and layout boundaries $\rightarrow$ Structural `FRAME` (never an instance).
