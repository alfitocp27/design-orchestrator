# Contributing to Design Orchestrator

Thank you for your interest in contributing to **Design Orchestrator**! We welcome bug fixes, documentation improvements, architectural proposals, and test expansions.

---

## 1. Code of Conduct & Principles

- **Evidence-Based Design**: We value reproducible evidence over assertions. Visual and geometric claims must be verifiable.
- **Respect for Privacy & Security**: Never commit internal enterprise names, proprietary data, API keys, or credentials.
- **Clean Provenance**: Only contribute code, documentation, and assets you own or that are compatible with the MIT License. Do not vendor external third-party packages or datasets without proper licensing.

---

## 2. Development Setup

1. Fork and clone the repository:
   ```powershell
   git clone https://github.com/alfitocp27/design-orchestrator.git
   cd design-orchestrator
   ```
2. Initialize your local development environment:
   ```powershell
   .\scripts\bootstrap.ps1 -Mode Core
   ```
3. Run the doctor diagnostic to ensure requirements are met:
   ```powershell
   .\scripts\doctor.ps1
   ```

---

## 3. Testing Requirements

All contributions must pass the offline test suite before being merged:

```powershell
.\scripts\test-runner.ps1
```

The test runner validates:
1. **Manifest Integrity**: `orchestrator.manifest.json` schema and dependency syntax.
2. **Skill Reference Integrity**: Internal markdown links in `skills/design-orchestrator/` resolve to valid files.
3. **Zero Secrets / Zero Hardcoded Paths**: No hardcoded local machine paths or secret tokens.
4. **Idempotent Bootstrapper**: `bootstrap.ps1` runs non-destructively in dry-run mode.

If you are modifying canvas or MCP integrations, write an offline mock test in `tests/offline/` using JSON fixtures before adding live integration tests.

---

## 4. Submitting a Pull Request

1. Create a feature branch:
   ```powershell
   git checkout -b feat/my-improvement
   ```
2. Make focused changes and commit with descriptive messages:
   ```powershell
   git commit -m "feat(templates): enhance responsive auto-layout in default card"
   ```
3. Ensure CI passes on GitHub Actions.
4. Submit your Pull Request against the `main` branch.
