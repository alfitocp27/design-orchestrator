# Changelog

All notable changes to **Design Orchestrator** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.1.1] - 2026-10-31

### Fixed
- **Windows 11 Python Detection**: Eliminated false-positive `DETECTED` status caused by the Microsoft Store `python.exe` App Execution Alias; `doctor.ps1` and `bootstrap.ps1` now verify actual execution output and exit codes.
- **Dynamic FigCraft Discovery**: Expanded detection to scan standard user locations (`%LOCALAPPDATA%\Programs\ArtCraft\FigCraft`, `%ProgramFiles%`, and PATH), recognizing installed desktop app and CLI.
- **Real MCP Communication Handshake**: Upgraded `test-figcraft-live.ps1`, `doctor.ps1`, and `bootstrap.ps1` to test live JSON-RPC Stdio initialization (`serverInfo`, `tools/list`) with FigCraft MCP, proving actual protocol communication.
- **Safe Antigravity MCP Registration**: Added `Backup-And-Register-McpServer` helper in `bootstrap.ps1` ensuring existing `~/.gemini/config/mcp_config.json` is safely backed up before any write operations.
- **Directory Canonicalization**: Harmonized skill paths across `AGENTS.md`, `README.md`, and documentation to `.agents/skills/design-orchestrator/`.

### Changed
- **Accurate Upstream Manifest**: Corrected upstream URLs and prerequisites in `orchestrator.manifest.json` and `docs/setup-guide.md` for `impeccable` (`pbakaus/impeccable`), `ui-ux-pro-max` (`nextlevelbuilder/ui-ux-pro-max-skill`), `figcraft`, and `codebase-memory-mcp`.

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
