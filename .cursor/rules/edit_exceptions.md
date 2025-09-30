# .cursor Edit Policy Exceptions

## General Edit Policy

### Restricted Folders (DO-NOT-EDIT)
**CRITICAL: NEVER edit files in folders containing "DO-NOT-EDIT" in their name!**

Restricted folders:
- `Powerapp components-DO-NOT-EDIT/` - Power Apps component exports
- `Powerapp screens-DO-NOT-EDIT/` - Power Apps screen exports
- Any folder with `DO-NOT-EDIT` suffix

These are read-only exports. Always provide snippets for manual implementation in Power Apps Studio.

### Editable Files and Folders
**AI assistants MAY directly edit all other files** including:
- Documentation files (*.md)
- Configuration files (*.json, *.yaml in root or config folders)
- Project planning files
- Database schema documentation
- All files in `.cursor/rules/` and `.grok/` folders
- Any file NOT in a `DO-NOT-EDIT` folder

## Proactive Editing Guidelines

AI assistants **MAY** proactively edit files to:
- Fix documentation inconsistencies
- Update schema references
- Correct field name mismatches
- Improve project structure
- Add clarifications to existing docs

### Special Folders for AI Work

#### 1. `.grok/` Folder
- **Purpose**: AI-generated artifacts, issue trackers, fix snippets, and temporary files.
- **Allowed Actions**:
  - Create new Markdown/JSON/TXT files (e.g., `issues_and_fixes.md`, `claude_responses.md`).
  - Edit existing files for updates (e.g., append Claude fixes to issues file).
  - Examples: Issue summaries, Power Automate flow outlines, schema corrections.
- **Restrictions**:
  - No executable code (e.g., no .ps1 scripts that run flows).
  - Keep files <10KB; use snippets for large content.

#### 2. `.cursor/rules/` Folder
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
- **Verification**: After edits, verify changes and document what was updated
- **User Notification**: Inform user of documentation updates made
- **Version Control**: Changes should be committed with clear descriptions

## Enforcement Rules

**DO NOT EDIT if:**
- File is in a folder with `DO-NOT-EDIT` suffix
- File is a Power Apps YAML export (`.yaml` in restricted folders)
- File is a binary/compiled artifact

**SAFE TO EDIT:**
- All documentation files (`.md`)
- Configuration files (`.json`, `.yaml` NOT in DO-NOT-EDIT folders)
- Project planning and tracking files
- Schema documentation
- Rule files in `.cursor/rules/`
- Working files in `.grok/`
- Any file in root or standard project folders

**When in doubt**: Check if folder name contains `DO-NOT-EDIT`. If yes, provide snippet instead of direct edit.

---

**Last Updated**: September 30, 2025
**Status**: Active - Edit freely except DO-NOT-EDIT folders
**Policy Change**: Expanded from folder-specific to project-wide (excluding DO-NOT-EDIT folders)
