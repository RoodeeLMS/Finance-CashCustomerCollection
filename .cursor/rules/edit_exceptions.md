# .cursor Edit Policy Exceptions

## General Policy Reminder
**CRITICAL: NEVER edit Power Apps YAML files directly!** (e.g., in `Powerapp components-DO-NOT-EDIT/` or `Powerapp screens-DO-NOT-EDIT/`). These are read-only exports. Always provide snippets for manual implementation in Power Apps Studio.

## Allowed Direct Edits
AI assistants (e.g., Grok, Claude) **MAY** directly create or edit files in these folders for documentation, rules, and planning purposes:

### 1. `.grok/` Folder
- **Purpose**: AI-generated artifacts, issue trackers, fix snippets, and temporary files.
- **Allowed Actions**:
  - Create new Markdown/JSON/TXT files (e.g., `issues_and_fixes.md`, `claude_responses.md`).
  - Edit existing files for updates (e.g., append Claude fixes to issues file).
  - Examples: Issue summaries, Power Automate flow outlines, schema corrections.
- **Restrictions**:
  - No executable code (e.g., no .ps1 scripts that run flows).
  - Keep files <10KB; use snippets for large content.
  - Always confirm with user before major changes.

### 2. `.cursor/rules/` Folder
- **Purpose**: Workspace-specific development rules, conventions, and AI guidelines.
- **Allowed Actions**:
  - Create new rule files (e.g., `finance-rules.md`, `edit_policy.md`).
  - Edit existing rules for updates (e.g., add exceptions, refine Power Fx guidelines).
  - Examples: Dataverse validation rules, Power Automate best practices, error checklists.
- **Restrictions**:
  - Maintain Markdown format; no breaking syntax.
  - Reference project docs (e.g., link to CLAUDE.md).
  - Version changes with headers (e.g., "## Version 1.1 - Added Edit Exceptions").

## Implementation Guidelines
- **Tool Usage**: Use `run_terminal_cmd` for PowerShell-based creates/edits (e.g., `New-Item`, `Set-Content`, `Add-Content`).
- **Verification**: After edits, confirm paths/output and suggest git add/commit.
- **User Confirmation**: For any edit, provide a summary and ask for approval if non-trivial.
- **Backup**: Before edits, note: "This is a doc-only change; originals safe."

## Enforcement
- AI must check this policy before any `edit_file` or `run_terminal_cmd` for file mods.
- If unsure, provide snippet instead of direct edit.
- Update this file as needed (self-referential: edits here are allowed).

**Last Updated**: September 29, 2025
**Status**: Active - Allows targeted edits in `.grok` and `.cursor/rules/` for efficiency.
