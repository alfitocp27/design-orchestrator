# AGENTS.md — Design Orchestrator Repository Rules

> Instructions and boundaries for AI Coding Agents (Antigravity, Claude Code, Codex, Cursor) collaborating on the `design-orchestrator` repository.

---

## 1. Scope & Repository Identity

This repository hosts **Design Orchestrator 2.1**, an open-source meta-skill and architecture framework for interface and product design in Antigravity 2.0.

- **Primary Goal**: Maintain, test, and distribute the meta-orchestrator skill, project blueprint templates, installer scripts, and offline validation test suites.
- **Portability**: All code, scripts, and documentation must remain strictly machine-independent. Never hardcode Windows usernames, drive letters, or machine-specific absolute paths.
- **Licensing & Clean Provenance**: Original code is licensed under the MIT License. Never vendor third-party datasets, fonts, or code into this repository without explicit distribution rights. Use `orchestrator.manifest.json` for external dependencies.
- **No Secrets**: Never commit API keys, personal email addresses, private corporate domain references, or credentials.

---

## 2. Modes of Operation

1. **Core Mode**:
   - Zero external tool requirement.
   - Operates with mock test fixtures and offline schema validation.
   - When a capability requires FigCraft MCP or external skills, agents must explicitly report it as `UNAVAILABLE` rather than claiming it passed.
2. **Full Mode**:
   - Production mode integrating FigCraft MCP, Anti-Slop, UI/UX Pro Max, and CodebaseMemoryMCP.
   - Real runtime verification required for all canvas assertions.

---

## 3. Directory Conventions

- `skills/design-orchestrator/`: The core meta-skill definition (`SKILL.md`) and technical references.
- `templates/`: Blueprint templates for project scaffolding (`templates/project/` and `templates/PROJECT_REGISTRY.md.template`).
- `scripts/`: Cross-PC PowerShell scripts (`bootstrap.ps1`, `doctor.ps1`, `uninstall.ps1`, `test-runner.ps1`).
- `tests/`: Divided into `tests/offline/` (zero dependencies, mocked) and `tests/integration/` (requires live MCP).
- `docs/`: Comprehensive guides for setup, cross-PC workflows, and architecture.

---

## 4. Development & Contribution Guardrails

- Before submitting code or documentation changes, always execute `scripts/test-runner.ps1` to ensure offline tests pass.
- Run `scripts/doctor.ps1` to verify local environment health.
- All PowerShell scripts must be idempotent and support non-destructive reruns.
- Maintain documentation integrity: update `CHANGELOG.md` and `HANDOFF.md` when completing milestones.
