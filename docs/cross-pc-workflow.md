# Cross-PC Development Workflow

This document outlines the workflow for developing and using **Design Orchestrator 2.1** across multiple Windows 11 computers (e.g. Office PC and Home PC) using Antigravity 2.0.

---

## 1. Principles of Portability

To ensure smooth synchronization without merge conflicts or broken paths:
1. **Dynamic Paths Only**: Never commit files containing absolute paths like `C:\Users\username\...`. Always use `$PSScriptRoot`, relative paths, or environment variables (`$env:LOCALAPPDATA`, `$env:USERPROFILE`).
2. **Configuration Separation**: Machine-specific configuration (like local MCP endpoints or auth tokens) belongs in `.env` (gitignored) or Antigravity's local settings, never in committed repository files.
3. **Session Handoff Protocol**: Before switching machines, update `HANDOFF.md` with what was completed, any known defects, and what to do next.

---

## 2. Daily Workflow: Switching from Office to Home

### Step 1: Ending Session on Office PC
Before leaving your office PC:
1. Verify tests pass:
   ```powershell
   .\scripts\test-runner.ps1
   ```
2. Update `HANDOFF.md` with:
   - Current version / milestone.
   - Touched files.
   - Next task to tackle on Home PC.
3. Commit and push:
   ```powershell
   git status
   git add .
   git commit -m "chore(handoff): sync progress before home switch"
   git push origin main
   ```

### Step 2: Resuming Session on Home PC
On your home PC:
1. Pull the latest changes:
   ```powershell
   git pull origin main
   ```
2. Run `doctor.ps1` to ensure environment readiness:
   ```powershell
   .\scripts\doctor.ps1
   ```
3. Open Antigravity 2.0.
4. Read `HANDOFF.md` to pick up exactly where you left off.

---

## 3. Resolving Divergent State

If you accidentally made edits on both PCs without pulling first:
```powershell
git fetch origin
git status
git merge origin/main
```
Resolve any markdown conflicts in `HANDOFF.md` or templates, run `.\scripts\test-runner.ps1`, and push back to `main`.
