# Design Orchestrator Project Registry

> Central registry of all UI/UX design projects in this workspace.  
> Every project maintains its own isolated directory, design system (`DESIGN.md`), primary canvas file (`.figcraft`), and session history, while sharing workspace skills and MCP tools.

---

## 1. Project Registry

| Project Slug | Project Name | Directory Path | Primary Design File | Surface Mode | Discovery Mode | Project Status | Design System Status | Last Updated | Notes / Milestone |
|---|---|---|---|---|---|---|---|---|---|
| `_template` | Standard Project Template | `projects/_template/` | N/A (Scaffolding blueprint) | Varied | `Template` | `Template` | `Ready for Pilot` | YYYY-MM-DD | Baseline scaffolding (Design Orchestrator 2.1) |
| `<example-project>` | Example Dashboard | `projects/<example-project>/` | `projects/<example-project>/<example-project>.figcraft` | `Operate` | `From Scratch` | `In Progress` | `Pending Approval` | YYYY-MM-DD | Initial scaffolding |

---

## 2. Workspace Directory Architecture

```
workspace/
├── .agents/skills/                     # Shared workspace skills
│   └── design-orchestrator/            # Meta-orchestrator skill & references
├── projects/                           # All active design projects
│   ├── _template/                      # Standard template blueprint
│   │   ├── PROJECT.md                  # Project scope, personas, and target viewports
│   │   ├── REQUIREMENTS_MAP.md         # PRD-to-screen traceability & conflict log
│   │   ├── AGENTS.md                   # Project-level agent instructions & safety protocols
│   │   ├── DESIGN.md                   # Project design system, tokens, references, VQA log
│   │   ├── SESSION_HANDOFF.md          # Session continuity, open defects, next actions
│   │   ├── SCREENS.md                  # Catalog of frames, node IDs, responsive states
│   │   ├── exports/                    # Project-specific screenshots & exported PNGs
│   │   └── references/                 # Project-specific domain references, PRDs & assets
│   └── <project-slug>/                 # Independent project instance
│       ├── <project-slug>.figcraft     # Single primary FigCraft document for this project
│       ├── PROJECT.md
│       ├── REQUIREMENTS_MAP.md
│       ├── AGENTS.md
│       ├── DESIGN.md
│       ├── SESSION_HANDOFF.md
│       ├── SCREENS.md
│       ├── exports/
│       └── references/
├── archive/                            # Completed or retired projects
├── PROJECT_REGISTRY.md                 # Master project index & status registry
└── AGENTS.md                           # Master workspace agent routing & safety rules
```

---

## 3. Project Lifecycle States

- **Discovery**: Ingesting PRD or conducting progressive interview.
- **Visual Research**: Curating verified benchmarks (Mobbin, browser-use, UI/UX Pro Max).
- **Concept Sign-off**: Visual concepts presented; awaiting user approval (🛑 **Hard Gate**).
- **Design System First**: Engineering `01_Foundations`, `02_Components`, `03_Patterns` and running 8-Point Stress Test.
- **Design System Gate**: Design system VQA 2.0 passed; awaiting user approval (🛑 **Mandatory Hard Stop**).
- **Application Screens**: Viewports constructed in `04_Screens` using 100% linked instances.
- **Completed**: Final delivery verified, exported, and documented.
- **Archived**: Moved to `archive/` to prevent workspace clutter.
