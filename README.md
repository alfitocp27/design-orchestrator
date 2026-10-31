# Design Orchestrator 2.1

[![CI](https://github.com/alfitocp27/design-orchestrator/actions/workflows/ci.yml/badge.svg)](https://github.com/alfitocp27/design-orchestrator/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Antigravity](https://img.shields.io/badge/Antigravity-2.0-purple.svg)](https://github.com/alfitocp27/design-orchestrator)
[![Platform: Windows 11](https://img.shields.io/badge/Platform-Windows%2011-0078D4.svg)](https://github.com/alfitocp27/design-orchestrator)

**Design Orchestrator 2.1** is an open-source, portable meta-skill and architectural framework for end-to-end interface and product design in [Google Antigravity 2.0](https://github.com/alfitocp27/design-orchestrator).

It bridges consultative discovery, visual reference intelligence, creative direction, native FigCraft execution, atomic component hierarchies, 3-tier design token engines, and the **4-Dimensional Visual Quality Assurance (VQA) 2.0** verification system.

---

## 🌟 Key Highlights in v2.1

- **Evidence-Based QA & Zero False PASS**: Math bounding boxes ($\Delta x = 0$) alone are not visual proof. Verification requires multi-dimensional visual checks, clean screenshots, and the 8-Point Stress Test.
- **Native Reusable Components vs Page Layout Shells**: Atomic UI controls (`(Item)` $\rightarrow$ `(Group)` $\rightarrow$ `(Pattern)`) use native linked instances. Page viewports use native frames with auto-layout.
- **Domain-Driven Artboard Architecture**: Adaptive artboards with standardized Title Header cards.
- **3-Tier Design Tokens**: Primitives $\rightarrow$ Semantic Tokens $\rightarrow$ Component Tokens with native variable bindings and markdown fallbacks.
- **Dual Discovery Modes**: Mode 1 (Progressive consultative interview with 1-2 questions per turn) & Mode 2 (PRD-driven functional truth and traceability mapping).
- **Zero Critical Data Loss**: Text overflow handling never truncates or obscures operational metrics, KPI figures, status badges, or employee names.
- **🛑 Two Mandatory Hard Stops**: Concept Approval Gate (Stage 4) and Design System Approval Gate (Stage 6). Never builds screens before explicit user sign-off.

---

## 🚀 Core vs. Full Mode

Design Orchestrator is designed to be **100% portable** across multiple Windows 11 machines.

| Feature | Core Mode (Default) | Full Mode (Production) |
|---|---|---|
| **External Dependencies** | **Zero** (100% offline) | FigCraft MCP, Anti-Slop, UI/UX Pro Max |
| **Prerequisites** | PowerShell 5.1+ & Git | PowerShell 5.1+, Git, Antigravity 2.0, FigCraft MCP |
| **Project Templates** | ✅ Included (`templates/project/`) | ✅ Included (`templates/project/`) |
| **Meta-Skill & References** | ✅ Included (`skills/design-orchestrator/`) | ✅ Included (`skills/design-orchestrator/`) |
| **Test Suite** | ✅ Offline mocks & fixture tests | ✅ Offline mocks + Live MCP integration |
| **Canvas Execution** | ⚠️ Simulated via offline mocks | ✅ Real-time FigCraft canvas manipulation |
| **Anti-Slop Guardrail** | ⚠️ Manual reference guidelines | ✅ Automated rule checks (`npx antislop-ai`) |

---

## 📦 Quickstart (Windows 11)

### 1. Clone the Repository
```powershell
git clone https://github.com/alfitocp27/design-orchestrator.git
cd design-orchestrator
```

### 2. Run the Portable Bootstrapper
Run PowerShell as your standard user:
```powershell
# To install in lightweight Core Mode (recommended first):
.\scripts\bootstrap.ps1 -Mode Core

# Or to install in Full Production Mode:
.\scripts\bootstrap.ps1 -Mode Full
```

The bootstrapper automatically detects your environment paths dynamically (never hardcoding usernames), sets up the skill directory, configures project blueprints, and offers guided installation for optional companions.

### 3. Verify Environment Health
Run the doctor diagnostic script:
```powershell
.\scripts\doctor.ps1
```

### 4. Run the Test Suite
```powershell
.\scripts\test-runner.ps1
```

---

## 🔄 Cross-PC Development (Office & Home)

To develop seamlessly across multiple PCs without losing project state:

1. **Commit and Push from your current PC**:
   ```powershell
   git status
   git add .
   git commit -m "feat: your milestone description"
   git push origin main
   ```
2. **Pull and Validate on your second PC (Home)**:
   ```powershell
   git pull origin main
   .\scripts\doctor.ps1
   ```
3. Open a new Antigravity session in the repository root. Antigravity will automatically load `AGENTS.md` and `.agents/skills/design-orchestrator/SKILL.md`. Check `HANDOFF.md` for current session priorities.

For full cross-PC details, see [docs/cross-pc-workflow.md](docs/cross-pc-workflow.md).

---

## 📂 Repository Architecture

```
design-orchestrator/
├── .github/workflows/          # GitHub Actions CI for linting, syntax, and offline tests
├── .agents/skills/             # Installed skills directory for Antigravity discovery
│   └── design-orchestrator/    # Unified Meta-Skill v2.1
│       ├── SKILL.md            # Master meta-skill definition & orchestration matrix
│       └── references/         # In-depth architectural runbooks & specifications
├── templates/                  # Reusable project scaffolding blueprints
│   ├── project/                # Baseline files for newly created design projects
│   └── PROJECT_REGISTRY.md.template
├── scripts/                    # Portable PowerShell automation suite
│   ├── bootstrap.ps1           # Environment detection & idempotent installer
│   ├── doctor.ps1              # System health & dependency diagnostic checker
│   ├── uninstall.ps1           # Clean uninstaller and configuration revert
│   └── test-runner.ps1         # Unified test suite runner
├── tests/                      # Testing framework
│   ├── mocks/                  # Offline JSON fixtures for FigCraft & CodebaseMemory
│   ├── offline/                # Zero-dependency validation tests
│   └── integration/            # Live MCP integration tests
├── docs/                       # Technical guides
│   ├── setup-guide.md          # Fresh machine onboarding guide
│   └── cross-pc-workflow.md    # Multi-machine synchronization runbook
├── orchestrator.manifest.json  # Declarative dependency & capability manifest
├── AGENTS.md                   # Machine-readable instructions for AI agents
├── README.md                   # Public project overview & quickstart
├── LICENSE                     # MIT License
├── CONTRIBUTING.md             # Contribution & testing standards
├── SECURITY.md                 # Security & credential policies
├── CHANGELOG.md                # Release history
└── HANDOFF.md                  # Current session state & next steps
```

---

## 🛡️ License & Third-Party Notice

Design Orchestrator original code, documentation, and templates are licensed under the [MIT License](LICENSE).

Third-party companions (`anti-slop`, `ui-ux-pro-max`, `impeccable`, `figcraft`, `codebase-memory-mcp`) are external integrations managed via `orchestrator.manifest.json` and are subject to their respective licenses. This repository does not vendor unauthorized third-party datasets or copyrighted assets.

---

## 🤝 Contributing

Contributions are welcome! Please ensure all offline mock tests pass before submitting a pull request:
```powershell
.\scripts\test-runner.ps1
```
See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.
