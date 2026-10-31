# Design Orchestrator: Fresh Machine Setup Guide

This guide walks through setting up **Design Orchestrator 2.1** on a fresh Windows 11 PC with Antigravity 2.0.

---

## 1. Prerequisites

Before starting, ensure your Windows 11 PC has:
- **PowerShell 5.1+** (Built-in on Windows 11).
- **Git for Windows**:
  ```powershell
  winget install --id Git.Git -e --source winget
  ```
- **Google Antigravity 2.0** installed.
- *(Optional for Full Mode)*:
  - **Node.js / npx** (for Anti-Slop companion):
    ```powershell
    winget install --id OpenJS.NodeJS -e --source winget
    ```
  - **Python 3.10+** (if running custom design intelligence scripts):
    ```powershell
    winget install --id Python.Python.3.11 -e --source winget
    ```
  - **GitHub CLI (`gh`)**:
    ```powershell
    winget install --id GitHub.cli -e --source winget
    ```

---

## 2. Cloning the Repository

Open Windows Terminal (PowerShell) and navigate to your preferred workspace folder:

```powershell
cd "$HOME\Projects"   # or any folder you prefer
git clone https://github.com/alfitocp27/design-orchestrator.git
cd design-orchestrator
```

---

## 3. Running Bootstrap

### Option A: Core Mode (Recommended First Run)
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
- It asks before configuring external skills or changing global settings.
- It safely backs up any existing configuration files with a `.bak` timestamp.

---

## 4. Validating with Doctor

Always run `doctor.ps1` to verify system health and configuration:

```powershell
.\scripts\doctor.ps1
```

The doctor output will display:
- `[PASS]` for verified components.
- `[WARN]` or `[SKIP]` for optional companions not installed in Core Mode.
- `[FAIL]` for any critical missing requirement.

---

## 5. Running the Test Suite

Run the offline mock tests to verify that skill definitions, manifests, and scripts are working properly:

```powershell
.\scripts\test-runner.ps1
```

---

## 6. Starting a Design Session in Antigravity

Open Antigravity 2.0 in the `design-orchestrator` directory (or use this repository as your workspace):
- Antigravity will discover `AGENTS.md` and `.agents/skills/design-orchestrator/SKILL.md`.
- Read `HANDOFF.md` for open tasks and recent milestones.
- To create a new design project:
  1. Copy `templates/project/` to `projects/<your-project-slug>/`.
  2. Register your project in `PROJECT_REGISTRY.md`.
  3. Start designing with Design Orchestrator!
