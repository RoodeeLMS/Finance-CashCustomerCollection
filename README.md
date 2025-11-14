# Finance Cash Customer Collection System

**Nestlé Thailand - Automated AR Collections Email System**

[![Power Platform](https://img.shields.io/badge/Power%20Platform-Dataverse-blue)](https://powerplatform.microsoft.com/)
[![Status](https://img.shields.io/badge/Status-Ready%20for%20Import-brightgreen)]()
[![Solution Version](https://img.shields.io/badge/Solution-v1.0.0.5-blue)]()
[![Last Updated](https://img.shields.io/badge/Updated-Nov%2014%202025-informational)]()

## 🎯 Project Overview

An automated customer collection email system that transforms Nestlé's daily Accounts Receivable (AR) collections process from manual email composition to an intelligent, automated system.

**Impact**: Reduces daily email composition time from **2-3 hours to 15 minutes** while ensuring **100% adherence to business rules**.

### Platform Components
- **Microsoft Dataverse** - Central data repository
- **Power Automate** - Collections engine and SAP data import
- **Canvas App** - AR Control Center (monitoring & manual operations)
- **SharePoint** - QR code storage and file sharing
- **Office 365** - Email delivery and contacts

### Key Features
- ✅ Daily SAP data import and validation
- ✅ Intelligent FIFO calculation (CN/DN matching)
- ✅ Automated email template selection (Day 1-2, Day 3, Day 4+)
- ✅ Real-time process monitoring dashboard
- ✅ Manual override and customer management
- ✅ Comprehensive audit trail

---

## 🚀 Quick Start

### For Deployment
1. **Download**: `THFinanceCashCollection_1_0_0_5.zip` from `Powerapp solution Export/`
2. **Import**: Follow steps in [Powerapp solution Export/IMPORT_INSTRUCTIONS.md](Powerapp%20solution%20Export/IMPORT_INSTRUCTIONS.md)
3. **Configure**:
   - Update email recipients (SharePoint paths, AR team emails)
   - Set environment variables
   - Create test customer records
4. **Test**: Run sample transactions through the flows
5. **Deploy**: Enable scheduled triggers and activate Canvas App

### For Development
1. **Canvas Screens**: Work in `Screen Development/ACTIVE/` (gitignored)
2. **Quick Check**: Use `/quick-check "Screen Development/ACTIVE/scnMyScreen.yaml"`
3. **Review**: Use `/review-powerapp-screen` when ready
4. **Export**: Use Power Apps Studio → Export to `Powerapp screens-DO-NOT-EDIT/`

---

## 📚 Documentation

### Quick Start
- **[Project Summary](Documentation/01-Project-Overview/project_summary.md)** - Complete project overview
- **[Development Plan](Documentation/01-Project-Overview/development_plan.md)** - 25-day implementation timeline
- **[Database Schema](Documentation/02-Database-Schema/database_schema.md)** - Dataverse tables and relationships
- **[Field Name Reference](Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md)** - ⭐ **PRIMARY SOURCE** for field names

### By Topic

#### 📊 Project Planning
- [Project Summary](Documentation/01-Project-Overview/project_summary.md) - Complete overview
- [Development Plan](Documentation/01-Project-Overview/development_plan.md) - Implementation timeline
- [Task Assignment Matrix](Documentation/01-Project-Overview/task_assignment_matrix.md) - Team responsibilities
- [Project Status](Documentation/01-Project-Overview/PROJECT_STATUS.md) - Current progress

#### 🗄️ Database & Schema
- [Database Schema](Documentation/02-Database-Schema/database_schema.md) - Complete Dataverse schema
- [Field Name Reference](Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md) - ⭐ **PRIMARY SOURCE** (cr7bb_ prefix)
- [Schema Analysis](Documentation/02-Database-Schema/CURRENT_SCHEMA_ANALYSIS.md) - Current state analysis
- [Dataverse Setup Guide](Documentation/02-Database-Schema/dataverse_setup_guide.md) - Environment setup
- [Table Creation Scripts](Documentation/02-Database-Schema/table_creation_scripts.md) - SQL-like scripts
- [Security Configuration](Documentation/02-Database-Schema/security_configuration.md) - Role-based access

#### ⚡ Power Automate
- [Collections Email Engine](Documentation/03-Power-Automate/PowerAutomate_Collections_Email_Engine.md) - Core automation logic
- [SAP Data Import Flow](Documentation/03-Power-Automate/PowerAutomate_SAP_Data_Import_Flow.md) - Daily import process
- [Deployment Guide](Documentation/03-Power-Automate/PowerAutomate_Deployment_Guide.md) - Flow deployment
- [Flow Setup Instructions](Documentation/03-Power-Automate/PowerAutomate_Flow_Setup_Instructions.md) - Configuration
- [Flow Modifications Guide](Documentation/03-Power-Automate/PowerAutomate_Flow_Modifications_Guide.md) - How to modify
- [Flow Editing Status](Documentation/03-Power-Automate/FLOW_EDITING_STATUS.md) - Current state
- [Skeleton Flows Creation](Documentation/03-Power-Automate/SKELETON_FLOWS_CREATION_GUIDE.md) - Template guide

#### 📱 Canvas App
- [Screen Development Guide](Documentation/04-Canvas-App/SCREEN_DEVELOPMENT_GUIDE.md) - How to create screens
- [Redesigned Screens](Documentation/04-Canvas-App/REDESIGNED_SCREENS.md) - Screen architecture
- [Transaction Screen Guide](Documentation/04-Canvas-App/TRANSACTION_SCREEN_GUIDE.md) - Transaction management
- [Customer Page Test Checklist](Documentation/04-Canvas-App/customer_page_test_checklist.md) - Testing guide
- [Customer Validation Results](Documentation/04-Canvas-App/customer_validation_results.md) - Validation status

#### 📥 Data Import
- [Data Import Templates](Documentation/05-Data-Import/data_import_templates.md) - Excel templates
- [Excel Parsing Requirements](Documentation/05-Data-Import/excel_parsing_requirements.md) - SAP format specs
- [Manual SAP Upload Notes](Documentation/05-Data-Import/MANUAL_SAP_UPLOAD_NOTES.md) - Manual upload process

#### 📋 Requirements
- [Requirements Validation](Documentation/06-Requirements/REQUIREMENTS_VALIDATION.md) - Business rules validation
- [Recommended Approach](Documentation/06-Requirements/RECOMMENDED_APPROACH.md) - Architecture decisions
- [Simplified Role System](Documentation/06-Requirements/SIMPLIFIED_ROLE_SYSTEM.md) - Access control design

#### 🤖 AI Assistant Rules
- [AI Assistant Rules Summary](Documentation/07-AI-Assistant-Rules/AI_ASSISTANT_RULES_SUMMARY.md) - Development rules for AI

---

## 🏗️ Repository Structure

```
Finance-CashCustomerCollection/
├── Documentation/                 # 📚 All project documentation (organized)
│   ├── 01-Project-Overview/      # Project summary, timeline, status
│   ├── 02-Database-Schema/       # Dataverse schema and field references
│   ├── 03-Power-Automate/        # Flow documentation and guides
│   ├── 04-Canvas-App/            # Screen development guides
│   ├── 05-Data-Import/           # Excel parsing and import templates
│   ├── 06-Requirements/          # Requirements validation and approach
│   └── 07-AI-Assistant-Rules/    # AI assistant development rules
│
├── Screen Development/           # 🎨 Canvas App screen development
│   ├── ACTIVE/                   # Work-in-progress screens (gitignored)
│   └── READY/                    # Reviewed, production-ready screens
│
├── Powerapp screens-DO-NOT-EDIT/ # 📤 Exported screens from Power Apps Studio (READ-ONLY)
├── Powerapp components-DO-NOT-EDIT/ # 📤 Exported components (READ-ONLY)
├── Powerapp solution Export/     # 📦 Solution package exports
│
├── client docs/                  # 📄 Client proposals and requirements
├── Meeting Transcription/        # 🗣️ Stakeholder meeting records
├── templates/                    # 📝 Documentation and Power Apps templates
│
├── CLAUDE.md                     # 🤖 Claude Code project instructions
└── README.md                     # 📖 This file
```

---

## 🚀 Getting Started

### For Developers

1. **Read Core Documentation**
   - Start with [Project Summary](Documentation/01-Project-Overview/project_summary.md)
   - Understand [Database Schema](Documentation/02-Database-Schema/database_schema.md)
   - Review [Field Name Reference](Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md)

2. **Development Environment**
   - Access Microsoft Power Platform development environment
   - Review [Dataverse Setup Guide](Documentation/02-Database-Schema/dataverse_setup_guide.md)
   - Configure connections (Dataverse, SharePoint, Office 365)

3. **Canvas App Development**
   - Read [Screen Development Guide](Documentation/04-Canvas-App/SCREEN_DEVELOPMENT_GUIDE.md)
   - Work in `Screen Development/ACTIVE/` folder
   - Use `/quick-check` for syntax validation
   - Move to `READY/` folder after review

4. **Power Automate Development**
   - Review [Collections Email Engine](Documentation/03-Power-Automate/PowerAutomate_Collections_Email_Engine.md)
   - Follow [Flow Setup Instructions](Documentation/03-Power-Automate/PowerAutomate_Flow_Setup_Instructions.md)
   - Test in development environment first

### For AI Assistants

- **Read [CLAUDE.md](CLAUDE.md)** - Complete development guidelines
- **Read [AI Assistant Rules](Documentation/07-AI-Assistant-Rules/AI_ASSISTANT_RULES_SUMMARY.md)** - Project-specific rules
- **Always verify field names** from [Field Name Reference](Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md)
- **Use `cr7bb_` prefix** for all Dataverse fields (NOT `nc_`)

---

## 🔑 Core Business Logic

### Exclusion Logic
Skip customers with text fields containing:
- "Paid"
- "Partial Payment"
- "รักษาตลาด" (Market maintenance)
- "Bill credit 30 days"

### FIFO Processing
1. **CN (Credit Notes)**: Negative amounts, sorted by document date (FIFO)
2. **DN (Debit Notes)**: Positive amounts, sorted by document date (FIFO)
3. Apply CN against DN using FIFO until customer owes money
4. Send notification when balance > 0

### Day Counting System
- **Day 1-2**: Standard payment reminder (Template A)
- **Day 3**: Warning about cash discount eligibility (Template B)
- **Day 4+**: Notice of additional MI (late fees) charges (Template C)
- **MI Documents**: Special explanation template (Template D)

---

## 📊 Project Status

**Current Phase**: Development (Week 3/5)

**Completed**:
- ✅ Dataverse schema design and implementation
- ✅ Power Automate SAP import flow
- ✅ Canvas App dashboard screen
- ✅ Email template system

**In Progress**:
- 🚧 Collections email engine (FIFO logic)
- 🚧 Customer management screens
- 🚧 Transaction monitoring

**Upcoming**:
- ⏳ User Acceptance Testing (UAT)
- ⏳ Production deployment
- ⏳ User training

See [Project Status](Documentation/01-Project-Overview/PROJECT_STATUS.md) for detailed progress.

---

## 🛠️ Development Workflow

### Canvas App Screens
```bash
# 1. Create/edit in ACTIVE folder
Screen Development/ACTIVE/scnMyScreen.yaml

# 2. Quick validation during development
/quick-check "Screen Development/ACTIVE/scnMyScreen.yaml"

# 3. Full review when ready
/review-powerapp-screen "Screen Development/ACTIVE/scnMyScreen.yaml"

# 4. Fix all issues

# 5. Move to READY folder
mv "Screen Development/ACTIVE/scnMyScreen.yaml" "Screen Development/READY/"

# 6. Import to Power Apps Studio manually

# 7. Export from Power Apps Studio to production folder
# (Auto-exports to Powerapp screens-DO-NOT-EDIT/)
```

### Power Automate Flows
1. Develop in browser-based Power Automate designer
2. Test thoroughly in development environment
3. Export solution package
4. Deploy to production via solution import

---

## 🎯 Success Metrics

**Operational Efficiency**:
- ✅ Reduce daily email composition from **2-3 hours to 15 minutes**
- ✅ Eliminate manual calculation errors
- ✅ 100% adherence to business rules

**System Performance**:
- 🎯 99%+ successful daily execution
- 🎯 Complete daily run within 30 minutes
- 🎯 Handle 50% customer growth without modification

**User Satisfaction**:
- 🎯 AR team can focus on exception handling (not routine tasks)
- 🎯 Audit trail for all sent emails
- 🎯 Real-time visibility into collections process

---

## 👥 Team

**Development Team**:
- Project Lead: [Name]
- Power Platform Developer: [Name]
- Database Administrator: [Name]
- Business Analyst: [Name]

**Stakeholders**:
- AR Team Lead
- Finance Manager
- IT Support Team

See [Task Assignment Matrix](Documentation/01-Project-Overview/task_assignment_matrix.md) for detailed responsibilities.

---

## 📞 Support

**Issues**: Create issue in repository issue tracker
**Questions**: Contact project lead or development team
**Documentation Updates**: Submit pull request with changes

---

## 📝 License

Internal Nestlé project - All rights reserved.

---

**Last Updated**: 2025-01-13
**Version**: 1.0.0
**Status**: In Development
