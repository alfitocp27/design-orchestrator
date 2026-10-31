# Changelog

All notable changes to **Design Orchestrator** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.2.0-dev] - 2026-10-31

### Added
- **Final Visual Quality Remediation & VQA 2.0 Engine Upgrades**:
  - Collapsed Text Height & Line-Height Integrity Check: Added deterministic detection for sub-pixel collapsed text ($H < 0.75 \times \text{fontSize} \times \text{lineCount}$) and invalid unitless `lineHeight` floats ($0 < \text{lineHeight} < 3.0$) in `scripts/verify-canvas.ps1`. Explains and catches the FigCraft MCP quirk where unitless values were treated as literal sub-pixel heights.
  - Sibling Visual Collision & 2D Bounding-Box Overlap Math: Implemented 2D bounding-box intersection auditing between non-absolute siblings in `scripts/verify-canvas.ps1`, reporting P1 blockers with exact coordinates and overlap measurements.
  - Synthetic Defect Regression Fixtures: Added `tests/fixtures/canvas/synthetic-text-overlap-defect.json` and `tests/fixtures/canvas/synthetic-text-overlap-fixed.json`; expanded `tests/offline/test-verify-canvas.ps1` from 6 to 8 test cases asserting 100% detection of typography collapse and sibling collisions with zero false PASS.
  - Responsive Viewport Testing Harness: Added `scripts/test_viewports.py` verifying multi-viewport behavior on 1440x900 (baseline), 1280x800, and 1024x768 viewports on active FigCraft canvas with unselected screenshot evidence.
  - Dual-Mode FigCraft Architecture: Added explicit support for `ATTACHED` (port 7979 live desktop GUI) and `HEADLESS` (isolated stdio background process) execution modes in `scripts/figcraft_engine.py`, verified with `tests/integration/test-live-attached-canvas.ps1`.
- **Execution Engine Reliability & Context Optimization (Sprint 4)**:
  - Idempotent FigCraft Execution: Enhanced `scripts/figcraft_engine.py` with `get_or_create_collection`, `get_or_create_variable`, `get_or_create_frame`, `get_or_create_component`, and `get_or_create_instance` preventing duplicate collections, variables, frames, and master components on consecutive runs.
  - Active Document Safety: Added `ensure_target_document` enforcing document isolation and preventing accidental mutations on active user files.
  - Context Footprint & Progressive Disclosure: Streamlined `SKILL.md` (45.4% line reduction, 40.4% word reduction, saving ~1,209 tokens per invocation) with a clear Progressive Disclosure Reference Map routing agents to specialized runbooks; streamlined `references/workflow-details.md` (12.9% line reduction).
  - Added reproducible context measurer `scripts/measure-context.ps1`.
  - Reliability & Regression Test Suite: Added `tests/integration/test-engine-reliability.ps1` executing 8 comprehensive reliability tests (double-run idempotency, master-instance mutation inheritance, responsive viewport auto layout, state resumption, controlled MCP error trapping, save/reload persistence, Core Mode offline independence, and zero false PASS on NOT_VERIFIABLE).
  - End-to-End Pilot Preparation: Added synthetic benchmark brief `tests/fixtures/pilot/synthetic-pilot-brief.json` and standard operating procedure `docs/end-to-end-pilot-protocol.md` for post-Sprint 4 pilot execution.
- **Native Design System Engine & 8-Point Stress Testing Harness (Sprint 3)**:
  - Built `scripts/figcraft_engine.py`: Direct Stdio JSON-RPC client for FigCraft MCP executing the 7 core native design system recipes (3-tier variable token hierarchy, central vector icon library, atomic master components, variant sets with `combineVariants`, linked instances with override isolation, adaptive auto-layout with `sizingH: hug|fill`, and composite UI patterns).
  - Built `scripts/build-native-design-system.ps1`: Automated harness that initializes native design systems, executes the 8-point component stress testing protocol, and links to canvas QA.
  - Added live integration test `tests/integration/test-native-design-system-live.ps1` to test runner.
  - Integrated 8-Point Component Stress Testing Protocol (Master propagation, text override isolation, variant switching, icon inheritance, content expansion stress, permutation stress, sizing constraints, and save/reload persistence).
- **Dynamic Creative Direction Engine (Sprint 2)**:
  - Replaced 5 rigid static archetypes with dynamic archetype seeds synthesized from 7 product intelligence facets and multi-source research (UI/UX Pro Max, Impeccable, Anti-Slop, NeedMCP).
  - Enforced 10 mandatory dimensions per concept: Identity & Rationale, Benchmarks, Typography, Color & WCAG, Layout & Grid, Surface & Elevation, Iconography, Data Visualization, Accessibility, and UX Trade-offs.
  - Implemented `scripts/evaluate-creative-direction.ps1` for automated deterministic validation of concept structure, field completeness, divergence, and WCAG 2.2 contrast math.
  - Added 4 synthetic domain fixtures in `tests/fixtures/creative-direction/` (Enterprise Operations, EdTech, Industrial SCADA, Creative Audio Mastering).
  - Added `tests/offline/test-creative-direction.ps1` regression test with Zero False PASS verification.
- **Repository Hygiene & Automated QA Foundation (Sprint 1)**:
  - Mojibake remediation across documentation and reference runbooks; added `tests/offline/test-encoding-hygiene.ps1`.
  - Built 6 synthetic FigCraft document fixtures in `tests/fixtures/synthetic/`.
  - Implemented `scripts/verify-canvas.ps1` automated canvas geometry, column alignment ($\Delta x$), boundary overflow, and WCAG contrast verifier with JSON/Markdown reporting.
  - Added `tests/offline/test-verify-canvas.ps1`.
- **Optional NeedMCP Integration Candidate**:
  - Registered NeedMCP under `integrations/needmcp/` with manifest `needmcp.manifest.json` and guide `README.md`.
  - Enforced anti-style-locking policy (`getStyle` for exploration; `selectStyle` strictly gated post-approval) and recorded status as `UNVERIFIED_RUNTIME`.

### Fixed
- **Artefacta Screen Visual Quality Remediation**:
  - Eliminated text collisions in `Artifact_Dossier_Title` and `Plate_Caption` by replacing unitless `lineHeight` floats with `"lineHeight": "Auto"`, restoring full 34px and 13px line metrics.
  - Restructured `Archival_Plate_Card` into an isolated `Plate_Media_Container` frame (`clip: True`) and a framed `Plate_Caption_Box` with discrete title and subtitle layers, eliminating text collisions and supporting clean media replacement.
  - Standardized all synthetic sensor and mesh telemetry to explicit `[SIMULATED]` and `[DEMO]` annotations, upholding data integrity.
- **FigCraft MCP Command Verification**: Audited runtime commands and replaced unverified commands (`node.delete`, `node.duplicate`) with verified commands (`edit.delete`, `edit.duplicate`) in documentation and engine.
- **Canvas QA & Contrast Precision**: Enhanced `scripts/verify-canvas.ps1` with parent container fill traversal for native FigCraft text nodes lacking inline background properties.
- **WCAG Dual Hex Reporting**: Updated `scripts/evaluate-creative-direction.ps1` to calculate and report both foreground and background hex values for text contrast checks on canvas and card surfaces.
- **Antigravity Configuration Path Inconsistency**: Standardized Antigravity 2.0 configuration reference strictly to `~/.gemini/config/mcp_config.json`, documenting upstream CLI naming differences.

---

## [2.1.1] - 2026-10-31

### Added
- **CodebaseMemoryMCP Integration**: Added live Stdio JSON-RPC integration test (`tests/integration/test-codebase-memory-live.ps1`), dynamic registration in `bootstrap.ps1`, and doctor verification in `doctor.ps1`.
- **Companion Skills Governance**: Added `.agents/skills/{ui-ux-pro-max,impeccable,antislop,anti-slop}` to `.gitignore` ensuring third-party companion tools can be cloned locally for Antigravity discovery without vendoring them into the core repository.
- **Automated Companion Skill Installer**: Added automated installation/cloning of upstream companion skills (`anti-slop`, `ui-ux-pro-max`, `impeccable`) via `-InstallCompanions` switch or interactive prompt in `bootstrap.ps1`.

### Fixed
- **Windows 11 Python Detection**: Eliminated false-positive `DETECTED` status caused by the Microsoft Store `python.exe` App Execution Alias; `doctor.ps1` and `bootstrap.ps1` now scan dynamic user directories (`%LOCALAPPDATA%\Programs\Python\Python3*`, PATH) and verify real execution exit codes.
- **Dynamic FigCraft Discovery**: Expanded detection to scan standard user locations (`%LOCALAPPDATA%\Programs\ArtCraft\FigCraft`, `%ProgramFiles%`, and PATH), recognizing installed desktop app and CLI.
- **Real MCP Communication Handshake**: Upgraded `test-figcraft-live.ps1`, `doctor.ps1`, and `bootstrap.ps1` to test live JSON-RPC Stdio initialization (`serverInfo`, `tools/list`) with FigCraft MCP, proving actual protocol communication.
- **Safe Antigravity MCP Registration**: Added `Backup-And-Register-McpServer` helper in `bootstrap.ps1` ensuring existing `~/.gemini/config/mcp_config.json` is safely backed up with timestamp before any write operations.
- **Secret Scanner Hardening**: Upgraded `test-no-secrets.ps1` to prefer git-tracked files (`git ls-files`) and ignore companion directories, preventing false-positive secret alarms from external test fixtures.
