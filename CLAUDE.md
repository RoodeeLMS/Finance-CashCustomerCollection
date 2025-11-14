# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Microsoft Power Platform** solution for Nestlé's automated customer collection email system. The project automates the daily Accounts Receivable (AR) collections process, replacing manual email composition with an intelligent system that processes SAP data and sends personalized payment reminder emails to ~100 cash customers daily.

**Platform Components:**
- **Microsoft Dataverse**: Central data repository
- **Power Automate**: Core automation engine ("Collections Engine")
- **Model-Driven Power App**: AR Control Center
- **SharePoint**: File sharing and QR code storage
- **Office 365**: Email delivery and contact integration

## Development Environment

This is a **documentation and planning repository**. The actual Power Platform components are developed within the Microsoft Power Platform environment and exported here for version control.

**Key Points:**
- No traditional package.json or build tools
- Power Platform development occurs in browser-based editors
- This repository contains exported solutions, documentation, and project planning files
- YAML files in `Powerapp components-DO-NOT-EDIT/` are exported component definitions

## Project Structure

```
├── Documentation/
│   ├── 01-Project-Overview/       # Project summary, timeline, status
│   ├── 02-Database-Schema/        # Dataverse schema and field references
│   ├── 03-Power-Automate/         # Flow documentation and guides
│   ├── 04-Canvas-App/             # Screen development guides
│   ├── 05-Data-Import/            # Excel parsing and import templates
│   ├── 06-Requirements/           # Requirements validation and approach
│   └── 07-AI-Assistant-Rules/     # AI assistant development rules
├── client docs/                   # Client proposals and requirements
├── Meeting Transcription/         # Stakeholder meeting records
├── Powerapp components-DO-NOT-EDIT/ # Exported Power Apps component definitions (READ-ONLY)
├── Powerapp screens-DO-NOT-EDIT/  # Exported screen definitions (READ-ONLY)
├── Powerapp solution Export/      # Solution package exports
├── Screen Development/            # Active screen development workspace
│   ├── ACTIVE/                   # Work-in-progress screens (gitignored)
│   └── READY/                    # Reviewed, production-ready screens
├── templates/                     # Documentation and Power Apps templates
└── .cursor/rules/                 # Development rules and conventions
```

## Core Business Logic

The system implements complex business rules for payment reminder processing:

### Exclusion Logic
Skip customers with text fields containing: "Paid", "Partial Payment", "รักษาตลาด", "Bill credit 30 days"

### FIFO Processing
- **CN (Credit Notes)**: Negative amounts, sorted by document date (FIFO)
- **DN (Debit Notes)**: Positive amounts, sorted by document date (FIFO)
- Apply CN against DN using FIFO until customer owes money, then send notification

### Day Counting System
- Track notification frequency per bill
- **Day 1-2**: Standard template
- **Day 3**: Warning about cash discount eligibility
- **Day 4+**: Additional MI (late fees) charges

## Power Apps Development Rules

This project uses **Canvas App** for the AR Control Center. Follow Nestlé Power Apps universal standards.

### 📚 Universal Standards (ALWAYS READ)

**Location**: `~/.claude/powerapp-standards/`

This project follows **Nestlé Power Apps Universal Standards v1.4**. Before creating or editing screens, AI assistants MUST read:

1. **Core Standards** (Always Read):
   - `universal-powerapp-checklist.md` - Critical rules & common errors
   - `nestle-brand-standards.md` - Nestlé colors, fonts, layouts
   - `powerapp-control-reference.md` - Quick index (links-only navigation)

2. **Detailed References** (Read When Needed):
   - `modern-controls-complete-reference.md` - Modern controls (Button@0.0.45, Text@0.0.51)
   - `classic-controls-reference.md` - Classic controls (Icon@2.5.0, Gallery@2.15.0)
   - `powerapp-yaml-complete-guide.md` - YAML syntax & schema

3. **Data Source** (Project-Specific):
   - `dataverse-common-patterns.md` - Dataverse CRUD, syntax, relationships

4. **Development Guides** (Task-Specific):
   - `powerapp-naming-conventions.md` - Naming rules
   - `powerapp-common-errors.md` - Error troubleshooting
   - `gallery-patterns.md` - Gallery implementation patterns

### 🎯 Project-Specific Overrides

**Documentation Hierarchy**: Project docs override universal standards

**Project-Specific Files** (Read After Universal):
- `Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md` - **PRIMARY SOURCE** for field names (cr7bb_ prefix)
- `Documentation/07-AI-Assistant-Rules/AI_ASSISTANT_RULES_SUMMARY.md` - Project-specific rules & patterns
- `Documentation/04-Canvas-App/REDESIGNED_SCREENS.md` - Screen architecture & design decisions

### 🚀 Development Workflow

**Screen Lifecycle**:
1. **Create** in `templates/powerapps/` (working directory)
2. **Quick check** with `/quick-check <file>` during development (10-30 sec)
3. **Full review** with subagent or `/review-powerapp-screen` when ready (2-3 min)
4. **Fix** all critical + standards issues
5. **Import** to Power Apps Studio manually
6. **Export** from Power Apps Studio to `Powerapp screens-DO-NOT-EDIT/` (production reference)

**Daily Workflow**:
```
Edit in templates/powerapps/
→ Say "check scnMyScreen" (quick validation)
→ Fix errors, repeat
→ Say "review scnMyScreen" when ready
→ Import to Power Apps Studio
```

### ⚙️ Available Tools

**Subagent** (Auto-Activates):
- **`powerapp-screen-reviewer`** - Comprehensive review after you create/edit screens
  - Auto-invokes when significant changes made
  - Checks critical errors, standards, best practices
  - 2-3 min thorough analysis

**Slash Commands** (Manual):
- **`/review-powerapp-screen <file>`** - Comprehensive review (2-3 min)
- **`/quick-check <file>`** - Fast syntax check (10-30 sec, critical only)
- **`/init-powerapp-project <name> <source>`** - Initialize new project

### 🎨 Nestlé Brand Compliance

**Colors** (from nestle-brand-standards.md):
- **Nestlé Blue**: RGBA(0, 101, 161, 1) - Primary buttons, headers
- **Nestlé Red**: RGBA(212, 41, 57, 1) - Warnings, alerts
- **Oak Brown**: RGBA(100, 81, 61, 1) - Secondary buttons

**Fonts**:
- **Primary**: Lato (with Weight property)
- **Secondary**: Segoe UI (system font)
- **Never use**: Font.'Lato Black' (use Font.Lato with Weight property)

**Typography**:
- Headers: Size 20-24, Weight.Bold
- Body: Size 14-16, Weight.Semibold or Regular
- Labels: Size 12-14

### ⚠️ Critical Rules (Project-Specific)

**Field Names**:
- **ALWAYS verify from FIELD_NAME_REFERENCE.md**
- All fields use `cr7bb_` prefix (NOT `nc_` from schema docs)
- Example: `cr7bb_customercode`, `cr7bb_customername`, `cr7bb_Region`

**Dataverse Tables**:
- `[THFinanceCashCollection]Customers` - Customer master data
- `[THFinanceCashCollection]Transactions` - Transaction line items
- `[THFinanceCashCollection]ProcessLogs` - Process execution logs (TEXT date type)
- `[THFinanceCashCollection]EmailLogs` - Email send logs

**Date Fields**:
- **ProcessLogs**: `cr7bb_processdate` is TEXT type (format: "yyyy-mm-dd")
- **EmailLogs**: `cr7bb_sentdatetime` is DateTime type

**Control Properties**:
- **TextInput**: Use `.Value` property, not `.Text`
- **Power Fx Formulas**: ALL expressions must start with `=` symbol
- **AutoLayout Containers**: MUST set LayoutMinHeight and LayoutMinWidth (dangerous defaults!)
- **Text Controls**: Always specify Width property (default 96px causes issues)

**PowerFx Field Naming Patterns**:
- **Dataverse Logical Names**: Use `cr7bb_` prefix (e.g., `cr7bb_customercode`, `cr7bb_Region`)
- **Dataverse Display Names**: Can omit prefix when referencing from record variables (e.g., `Region`, `CustomerCode`)
- Both work interchangeably: `_selectedCustomer.cr7bb_Region` = `_selectedCustomer.Region`
- **Best Practice**: Use Display Names for readability in formulas
- **Calculated Column Names** (AddColumns, ShowColumns): NO QUOTES on column name parameter
  - Correct: `AddColumns(table, TransactionTypeText, expression)`
  - Wrong: `AddColumns(table, "TransactionTypeText", expression)`
  - Column name is an identifier, not a string literal

## Development Commands

Since this is a Power Platform project, traditional CLI commands don't apply. However, for project management:

### Documentation Commands
```powershell
# View project overview
Get-Content Documentation/01-Project-Overview/project_summary.md

# View development timeline
Get-Content Documentation/01-Project-Overview/development_plan.md

# Check database schema
Get-Content Documentation/02-Database-Schema/database_schema.md
```

### Power Platform Development Workflow
1. **Environment Access**: Work in Microsoft Power Platform development environment
2. **Solution Export**: Export solutions to `Powerapp solution Export/` folder
3. **Component Export**: Export individual components to `Powerapp components-DO-NOT-EDIT/`
4. **Documentation**: Update schema and project docs as needed

## Key Integration Points

### Data Sources
- **Customer Master Data**: Excel file with ~100 cash customers
- **Daily SAP Extract**: Excel file with transaction line items
- **QR Codes**: SharePoint folder with PromptPay codes (filename = customer_code)

### Email Templates
Dynamic template selection based on day count:
- **Template A**: Days 1-2 (Standard)
- **Template B**: Day 3 (Warning)
- **Template C**: Day 4+ (Late fees)
- **Template D**: MI documents (MI explanation)

### Validation Requirements
```sql
REQUIRED FIELDS per customer:
- customer_email IS NOT NULL
- sales_email IS NOT NULL
- ar_backup_email IS NOT NULL
```

## Architecture Decisions

### Data Maintenance Strategy
**Status**: ✅ **RESOLVED** - Database-driven approach selected
- **Selected Option**: Database-driven using Dataverse tables (see `Documentation/02-Database-Schema/database_schema.md`)
- **Rationale**: Real-time updates, better audit trail, eliminates file corruption risks
- **Implementation**: Customer master data stored in `nc_customers` table with role-based access
- **Training Plan**: AR team will use Model-Driven app forms instead of Excel editing

### Error Handling
- Missing QR codes: Log warning, continue processing
- Invalid email formats: Error handling with alerts
- Missing required fields: Alert AR team

## Development Timeline

**Total Duration**: 25 business days (5 weeks)
- **Week 1**: Environment setup, data collection, architecture
- **Week 2**: Core business logic implementation
- **Week 3**: Email engine and template processing
- **Week 4**: Model-Driven App and testing
- **Week 5**: UAT and Go-Live support

## Success Metrics

**Operational Efficiency:**
- Reduce daily email composition from 2-3 hours to 15 minutes
- Eliminate manual calculation errors
- 100% adherence to business rules

**System Performance:**
- 99%+ successful daily execution
- Complete daily run within 30 minutes
- Handle 50% customer growth without modification