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
├── client docs/                    # Client proposals and requirements
├── Meeting Transcription/          # Stakeholder meeting records
├── Powerapp components-DO-NOT-EDIT/ # Exported Power Apps component definitions (READ-ONLY)
├── Powerapp screens-DO-NOT-EDIT/   # Exported screen definitions (READ-ONLY)
├── Powerapp solution Export/       # Solution package exports
├── templates/                      # Documentation and Power Apps templates
├── .cursor/rules/                  # Development rules and conventions
├── database_schema.md             # Dataverse schema documentation
├── development_plan.md            # 25-day development timeline
├── project_summary.md             # Complete project overview
└── task_assignment_matrix.md      # Team responsibilities
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

This project primarily uses a **Model-Driven Power App** (AR Control Center) with supplementary Canvas App components. Key development guidelines:

### Application Architecture Priority
1. **Primary**: Model-Driven App with Dataverse tables, forms, and views
2. **Secondary**: Canvas App components for custom business logic where needed
3. **Integration**: Power Automate flows for automation and data processing

### Critical File Policy
**NEVER edit Power Apps YAML files directly!** Files in `Powerapp components-DO-NOT-EDIT/` and `Powerapp screens-DO-NOT-EDIT/` are read-only exports. Always provide code snippets for manual implementation in Power Apps Studio.

### Model-Driven Development Focus
- **Tables**: Use Dataverse native tables (nc_customers, nc_transactions, etc.)
- **Forms**: Configure main/quick create forms for data entry
- **Views**: Create system/personal views for data analysis
- **Sitemaps**: Organize navigation around AR workflow
- **Business Rules**: Implement validation at the table level

### Canvas Component Guidelines (When Used)
- Component names must be globally unique using functional prefixes:
```yaml
# Model-Driven friendly naming
- ARDashboard_MainContainer
- CustomerMgmt_EmailForm
- TransactionList_FilterPanel
```

### Control Properties (Canvas Components)
- **TextInput Controls**: Use `.Value` property, not `.Text`
- **Power Fx Formulas**: ALL expressions must start with `=` symbol
- **Dataverse Integration**: Use Dataverse connector, not SharePoint lists

## Development Commands

Since this is a Power Platform project, traditional CLI commands don't apply. However, for project management:

### Documentation Commands
```powershell
# View project overview
Get-Content project_summary.md

# View development timeline
Get-Content development_plan.md

# Check database schema
Get-Content database_schema.md
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
- **Selected Option**: Database-driven using Dataverse tables (see `database_schema.md`)
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