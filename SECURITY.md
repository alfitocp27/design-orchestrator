# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.1.x   | :white_check_mark: |
| < 2.1   | :x:                |

---

## Reporting a Vulnerability

Security and privacy are core priorities for Design Orchestrator. If you discover a security vulnerability, credential exposure, or unintended privacy leak:

1. **Do NOT open a public GitHub issue.**
2. Report the vulnerability privately via GitHub's [Private Vulnerability Reporting](https://github.com/alfitocp27/design-orchestrator/security/advisories/new) or directly contact the repository maintainers.
3. Include details of the vulnerability, step-by-step reproduction instructions, and affected components or scripts.
4. Maintainers will review the report within 48 hours and coordinate a coordinated disclosure and patch release.

---

## Secret & Credential Policy

- Design Orchestrator never requires hardcoded secrets or API keys in repository files.
- All authentication is performed through official channels (e.g. GitHub CLI, Git Credential Manager, Antigravity Plugin Manager).
- Any accidental push of credentials or personal secrets will be revoked immediately and purged from Git history.
