# Changelog

All notable changes to **Design Orchestrator** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.2.0-dev] - 2026-10-31

### Added
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
- **Directory Canonicalization**: Harmonized skill paths across `AGENTS.md`, `README.md`, and documentation to `.agents/skills/design-orchestrator/`.

### Changed
- **Accurate Upstream Manifest**: Corrected upstream URLs and prerequisites in `orchestrator.manifest.json` and `docs/setup-guide.md` for `impeccable` (`pbakaus/impeccable`), `ui-ux-pro-max` (`nextlevelbuilder/ui-ux-pro-max-skill`), `figcraft`, and `codebase-memory-mcp`.
- **UI/UX Pro Max Verification**: Integrated dynamic Python 3 execution check against `scripts/search.py` in both `bootstrap.ps1` and `doctor.ps1`.

---

## [2.1.0] - 2026-10-31

### Added
- **Open-Source Public Architecture**: Initial standalone open-source release of Design Orchestrator 2.1 on GitHub (`alfitocp27/design-orchestrator`).
- **Declarative Manifest (`orchestrator.manifest.json`)**: Machine-readable configuration for Core and Full modes, external dependency management, and tool capabilities.
- **Portable Windows PowerShell Suite**:
  - `scripts/bootstrap.ps1`: Dynamic environment detection, Core/Full installation, idempotent configuration, and backup restoration.
  - `scripts/doctor.ps1`: Diagnostic health check for OS, PowerShell, Git, Antigravity 2.0 paths, and companion dependencies.
  - `scripts/uninstall.ps1`: Safe rollback and uninstallation script.
  - `scripts/test-runner.ps1`: Unified test runner for offline and integration suites.
- **Offline Mock Test Suite (`tests/offline/`)**: Mocks and fixtures for FigCraft MCP and CodebaseMemoryMCP allowing zero-dependency testing.
- **GitHub Actions CI (`.github/workflows/ci.yml`)**: Automated PowerShell script validation, manifest schema checks, and offline test execution on Windows runner.
- **Developer & Cross-PC Documentation**: `docs/setup-guide.md`, `docs/cross-pc-workflow.md`, `HANDOFF.md`, and clean project templates in `templates/project/`.

### Changed
- Decoupled meta-orchestrator from proprietary local workspace paths.
- Replaced machine-specific references with dynamic user environment variables.
- Standardized project template blueprints under `templates/project/`.
- Sanitized sample domain references to generic enterprise terminology.

### Security
- Comprehensive security and provenance audit: verified zero hardcoded tokens, passwords, personal Windows user paths, or unlicensed third-party assets.
