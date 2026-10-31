# Design Orchestrator Session Handoff & Cross-PC State

> **Document Purpose**: Single source of truth for cross-session and cross-PC state handoff in Antigravity 2.0.  
> Update this file before ending work on one PC so you or any collaborator can immediately resume on another PC.

---

## 1. Current Project State

- **Current Version**: `v2.1.1` (Clean-Install Verification & Bootstrap Hardening)
- **Repository**: `https://github.com/alfitocp27/design-orchestrator.git`
- **Active Branch**: `feat/clean-install-verification`
- **Readiness Status**: `TECHNICAL_RUNTIME_PASS / CLEAN_INSTALL_VERIFIED`
- **Last Sync**: 2026-10-31

---

## 2. Clean-Install Verification & Milestones (2026-10-31)

1. **Clean Installation & Environment Audit**:
   - Performed clean-install verification on Windows 11 with fresh Antigravity 2.0.
   - Core Mode verified 100% offline with zero external dependencies.
   - All 5 offline tests (`test-manifest.ps1`, `test-mock-orchestration.ps1`, `test-no-secrets.ps1`, `test-skill-integrity.ps1`, `test-templates.ps1`) pass.
   - Integration test `test-figcraft-live.ps1` upgraded and passes with real Stdio JSON-RPC communication proof.

2. **Full Mode Dependencies Audit & Discovery**:
   - **FigCraft MCP**: Status `[INSTALLED]`, `[CONNECTED]`, `[VERIFIED]`.
     - Binary detected dynamically at `%LOCALAPPDATA%\Programs\ArtCraft\FigCraft\figcraft-cli.exe`.
     - Stdio MCP server (`figcraft-cli mcp`) tested with live JSON-RPC `initialize` and `tools/list` handshake. Verified 19 native tools.
   - **Anti-Slop**: Status `[DETECTED]`. Node.js / npx `v24.22.1` available; ready for installation via `npx antislop-ai --mode during`.
   - **UI/UX Pro Max**: Status `[NOT_INSTALLED]`. Requires real Python 3.x (Windows Store alias stub detected). Upstream: `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill`.
   - **Impeccable**: Status `[NOT_INSTALLED]`. Optional craft floor skill. Upstream: `https://github.com/pbakaus/impeccable`.
   - **CodebaseMemoryMCP**: Status `[NOT_INSTALLED]`. Optional schema authority. Upstream: `https://github.com/DeusData/codebase-memory-mcp`.

3. **Portable Bootstrap & Diagnostics Hardening**:
   - Fixed Windows 11 App Execution Alias bug in `doctor.ps1` where `Get-Command python` falsely claimed Python was detected.
   - Implemented dynamic FigCraft CLI path resolution across standard Windows installation directories.
   - Added real Stdio MCP JSON-RPC protocol handshake verification into `doctor.ps1`, `bootstrap.ps1`, and `tests/integration/test-figcraft-live.ps1`.
   - Added `Backup-And-Register-McpServer` in `bootstrap.ps1` to guarantee zero unbacked Antigravity configuration modifications.
   - Corrected canonical directory references in `AGENTS.md` and `README.md` to `.agents/skills/design-orchestrator/`.

---

## 3. Immediate Next Steps on Fresh / Home PC

1. **Clone repository**:
   ```powershell
   git clone https://github.com/alfitocp27/design-orchestrator.git
   cd design-orchestrator
   ```
2. **Run bootstrapper**:
   ```powershell
   # Core Mode (Zero external tools):
   .\scripts\bootstrap.ps1 -Mode Core

   # Or Full Production Mode (Audits and configures companions):
   .\scripts\bootstrap.ps1 -Mode Full
   ```
3. **Run doctor diagnostic**:
   ```powershell
   .\scripts\doctor.ps1
   ```
4. **Run test suite**:
   ```powershell
   .\scripts\test-runner.ps1 -IncludeIntegration
   ```

---

## 4. Known Considerations & Future Backlog

- **Python 3.x Prerequisite**: To enable UI/UX Pro Max on a clean Windows 11 PC, install official Python (`winget install --id Python.Python.3.12 -e`) to bypass the Windows Store alias.
- **Antigravity MCP Registration**: Once approved by the user, register FigCraft in `~/.gemini/config/mcp_config.json` using `bootstrap.ps1 -Mode Full -Force` (with automatic backup).
