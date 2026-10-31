# Design Orchestrator: Fresh Machine Setup Guide

This guide walks through setting up **Design Orchestrator 2.1** on a fresh Windows 11 PC with Antigravity 2.0.

---

## 1. Prerequisites Matrix

Before starting, review what each mode requires:

| Component | Core Mode | Full Mode | Installation Method |
|---|---|---|---|
| **Windows 11** | Required | Required | Built-in OS |
| **PowerShell 5.1+** | Required | Required | Built-in (`powershell.exe`) |
| **Git for Windows** | Required | Required | `winget install --id Git.Git -e` |
| **Antigravity 2.0** | Recommended | Required | Official Antigravity installer |
| **Anti-Slop** | Not needed | Recommended | `npx antislop-ai --mode during` (or via `bootstrap.ps1 -Mode Full`) |
| **Node.js / npx** | Not needed | Recommended | `winget install --id OpenJS.NodeJS -e` |
| **Python 3.x** | Not needed | Optional (for UI/UX Pro Max) | `winget install --id Python.Python.3.12 -e` *(Note: Windows Store alias is not sufficient)* |
| **UI/UX Pro Max** | Not needed | Optional | `git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill .agents/skills/ui-ux-pro-max` |
| **Impeccable** | Not needed | Optional | `git clone https://github.com/pbakaus/impeccable .agents/skills/impeccable` |
| **FigCraft MCP** | Not needed (Simulated) | Required for Canvas | Install FigCraft desktop app or CLI; serves Stdio MCP |
| **CodebaseMemoryMCP** | Not needed | Optional | `https://github.com/DeusData/codebase-memory-mcp` |

---

## 2. Cloning the Repository

Open Windows Terminal (PowerShell) and navigate to your preferred workspace folder:

```powershell
cd "$HOME\Projects"   # Or any folder you prefer
git clone https://github.com/alfitocp27/design-orchestrator.git
cd design-orchestrator
```

---

## 3. Running Bootstrap

### Option A: Core Mode (Instant Zero-Dependency Setup)
Core Mode sets up the local meta-skill and project templates without requiring external plugins or MCP servers:

```powershell
.\scripts\bootstrap.ps1 -Mode Core
```

### Option B: Full Mode (Production Setup)
Full Mode checks your system for companion tools and guides you through setting them up:

```powershell
# Interactive Full Mode (prompts before installing external dependencies):
.\scripts\bootstrap.ps1 -Mode Full

# Automated Full Mode (automatically configures and clones supported companions):
.\scripts\bootstrap.ps1 -Mode Full -InstallCompanions
```

When run:
- It asks before installing external skills (e.g. Anti-Slop via npx, UI/UX Pro Max, Impeccable) or installs them automatically when `-InstallCompanions` or `-Force` is specified.
- It dynamically discovers FigCraft (`figcraft-cli.exe`), verifies stdio communication, and registers it safely in `~/.gemini/config/mcp_config.json` with an automatic timestamped backup.
- It registers `codebase-memory-mcp` with automatic timestamped backup and verifies live Stdio JSON-RPC handshake.
- It safely preserves any existing project configuration.

---

## 4. Validating with Doctor

Always run `doctor.ps1` to verify system health and configuration:

```powershell
.\scripts\doctor.ps1
```

### Understanding Doctor Lifecycle States:
- **`[NOT_INSTALLED]`**: Neither executable nor files exist on the machine.
- **`[DETECTED]`**: Prerequisites (e.g. Node or real Python 3.x) exist to install the component.
- **`[INSTALLED]`**: Component binary or skill files exist on disk.
- **`[CONFIGURED]`**: Registered in Antigravity (`~/.gemini/config/mcp_config.json` or `.agents/skills/`).
- **`[CONNECTED]`**: The MCP server or GUI application process is actively running.
- **`[VERIFIED]`**: Live communication handshake tested over Stdio JSON-RPC or full functional roundtrip passed.

---

## 5. Running the Test Suite

Run the offline mock tests to verify that skill definitions, manifests, and scripts are working properly:

```powershell
.\scripts\test-runner.ps1
```

To include live MCP checks:
```powershell
.\scripts\test-runner.ps1 -IncludeIntegration
```

---

## 6. Full Mode Integration & Companions Setup

If you want live FigCraft canvas manipulation, design intelligence, and codebase memory on your clean PC:

1. **Anti-Slop Guardrail**:
   ```powershell
   npx antislop-ai --mode during
   ```
   *Upstream: [miqdadbadjuber/anti-slop](https://github.com/miqdadbadjuber/anti-slop)*

2. **FigCraft MCP (Live Canvas Execution)**:
   - Install FigCraft (desktop app or CLI). FigCraft CLI installs at `%LOCALAPPDATA%\Programs\ArtCraft\FigCraft\figcraft-cli.exe`.
   - FigCraft serves MCP natively over Stdio using `figcraft-cli mcp` (both headless and attached to an active window).
   - Register in `~/.gemini/config/mcp_config.json`:
     ```json
     {
       "mcpServers": {
         "figcraft": {
           "command": "%LOCALAPPDATA%\\Programs\\ArtCraft\\FigCraft\\figcraft-cli.exe",
           "args": ["mcp"]
         }
       }
     }
     ```
     *(Or let `.\scripts\bootstrap.ps1 -Mode Full` register it with automatic configuration backup).*

3. **UI/UX Pro Max (Design Intelligence)**:
   - Ensure Python 3.x is installed: `winget install --id Python.Python.3.12 -e`.
   - Clone the skill:
     ```powershell
     git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill .agents\skills\ui-ux-pro-max
     ```

4. **Impeccable (Craft Floor & Visual Polish)**:
   - Upstream: [pbakaus/impeccable](https://github.com/pbakaus/impeccable).
   - Clone or copy into `.agents\skills\impeccable`.

5. **CodebaseMemoryMCP (Schema & Business Logic)**:
   - Upstream: [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp).
   - Register in `~/.gemini/config/mcp_config.json`.

---

## 7. Starting a Design Session in Antigravity

Open Antigravity 2.0 in the `design-orchestrator` directory (or use this repository as your workspace):
- Antigravity will discover `AGENTS.md` and `.agents/skills/design-orchestrator/SKILL.md`.
- Read `HANDOFF.md` for open tasks and recent milestones.
- To create a new design project:
  1. Copy `templates/project/` to `projects/<your-project-slug>/`.
  2. Register your project in `PROJECT_REGISTRY.md`.
  3. Start designing with Design Orchestrator!
