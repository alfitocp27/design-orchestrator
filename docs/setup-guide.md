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
| **Anti-Slop** | Not needed | Recommended | Automated by `bootstrap.ps1 -Mode Full` (`npx antislop-ai`) |
| **Node.js / npx** | Not needed | Recommended | `winget install --id OpenJS.NodeJS -e` |
| **UI/UX Pro Max** | Not needed | Optional | Manual clone into `.agents/skills/ui-ux-pro-max` |
| **FigCraft MCP** | Not needed (Simulated) | Required for Canvas | Manual install of FigCraft desktop app |
| **CodebaseMemoryMCP** | Not needed | Optional | Manual install of codebase-memory-mcp |

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
.\scripts\bootstrap.ps1 -Mode Full
```

When prompted:
- It asks before installing external skills (e.g. Anti-Slop via npx).
- It clearly reports desktop applications (like FigCraft) that require manual installation, without falsely claiming to install them.
- It safely preserves any existing project configuration.

---

## 4. Validating with Doctor

Always run `doctor.ps1` to verify system health and configuration:

```powershell
.\scripts\doctor.ps1
```

### Understanding Doctor Lifecycle States:
- **`[NOT_INSTALLED]`**: Neither executable nor files exist on the machine.
- **`[DETECTED]`**: Prerequisites (e.g. Node or Python) exist to install the component.
- **`[INSTALLED]`**: Component binary or skill files exist on disk.
- **`[CONFIGURED]`**: Schema, settings, or manifest are registered in Antigravity.
- **`[CONNECTED]`**: The MCP server or application process is actively running in the background.
- **`[VERIFIED]`**: Full functional test or roundtrip passed.

> [!NOTE]
> Having an MCP schema on disk shows `[CONFIGURED]`. Real canvas operations require `[CONNECTED]`, meaning the FigCraft desktop application process must be running.

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

## 6. Manual Setup Steps for Full Mode Companions

If you want live FigCraft canvas manipulation and codebase memory on your home PC:

1. **Anti-Slop Guardrail**:
   ```powershell
   npx antislop-ai --mode during
   ```
2. **FigCraft Desktop App (for Live Canvas Execution)**:
   - Install the FigCraft desktop app.
   - Launch FigCraft on your PC before starting a design session in Antigravity.
   - When FigCraft is running, `doctor.ps1` will report `MCP Server | FigCraft MCP | [CONNECTED]`.
3. **UI/UX Pro Max (Design Intelligence)**:
   - Clone the skill into `.agents/skills/ui-ux-pro-max` or link your existing installation.

---

## 7. Starting a Design Session in Antigravity

Open Antigravity 2.0 in the `design-orchestrator` directory (or use this repository as your workspace):
- Antigravity will discover `AGENTS.md` and `.agents/skills/design-orchestrator/SKILL.md`.
- Read `HANDOFF.md` for open tasks and recent milestones.
- To create a new design project:
  1. Copy `templates/project/` to `projects/<your-project-slug>/`.
  2. Register your project in `PROJECT_REGISTRY.md`.
  3. Start designing with Design Orchestrator!
