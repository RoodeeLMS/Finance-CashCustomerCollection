# Project Summary: Automated Customer Collection Email System

**Project Name:** Finance - Cash Customer Collection Automation  
**Client:** Nestlé (Thai) Ltd.  
**Developer:** Nick Chamnong, Vector Dynamics Co., Ltd  
**Project Type:** Microsoft Power Platform Solution  
**Last Updated:** September 26, 2025  

## Executive Summary

This project automates Nestlé's daily Accounts Receivable (AR) collections process, replacing manual email composition with an intelligent system that processes SAP data, applies complex business rules, and sends personalized payment reminder emails to approximately 100 cash customers daily.

The solution leverages **Microsoft Power Platform** with **Dataverse**, **Power Automate**, and a **Model-Driven Power App** to create a comprehensive automation engine with full audit capabilities.

**Project Value:**
- Eliminates daily manual email composition (saving 2-3 hours daily)
- Ensures consistent application of complex business rules
- Provides complete audit trail of all customer communications
- Scales to handle future growth without proportional resource increase

## Current State Analysis

### Manual Process Pain Points
- **Daily Time Investment**: 2-3 hours of manual email composition each morning
- **Error Prone**: Manual calculation of payment amounts with complex exclusion rules
- **Inconsistent**: Varying email formats and business rule application
- **No Audit Trail**: Limited tracking of customer communications
- **Scalability Issues**: Process time increases linearly with customer growth

### Data Sources
1. **Customer Master Data** (Excel)
   - ~100 cash customers
   - Contact information (primary, sales, AR backup emails)
   - Regional assignments
   - Manually maintained by AR team

2. **Daily SAP Extract** (Excel)
   - Customer transaction line items
   - Document numbers, dates, amounts
   - Text fields for exclusion markers
   - Downloaded fresh each morning

## Technical Architecture

### Platform Components
- **Microsoft Dataverse**: Central data repository
- **Power Automate**: Core automation engine ("Collections Engine")
- **Model-Driven Power App**: AR Control Center
- **SharePoint**: File sharing and QR code storage
- **Office 365**: Email delivery and contact integration

### Development Approach
**Total Effort:** 25 mandays (5 weeks)
- **Weeks 1-3 (15 days)**: Core development
- **Weeks 4-5 (10 days)**: UAT & Go-Live support

## Business Logic Requirements

### Core Processing Rules

#### 1. Exclusion Logic
```
IF text_field CONTAINS "Exclude" THEN
    Skip all line items for customer
ELSE
    Continue processing
```
**Exclusion Keywords:** "Paid", "Partial Payment", "รักษาตลาด", "Bill credit 30 days"

#### 2. Amount Categorization & FIFO Processing
```
CN (Credit Notes) = Negative amounts
DN (Debit Notes) = Positive amounts

SORT DN BY document_date ASC (FIFO)
SORT CN BY document_date ASC (FIFO)
```

#### 3. Send Decision Logic
```
IF customer.DN_count = 0 THEN
    Don't send (no bills to pay)
ELSE IF ABS(CN_total) < ABS(DN_total) THEN
    Send notification (customer owes money)
ELSE
    Apply FIFO to CN until CN < DN, then send
```

#### 4. Day Counting System
- Track notification frequency per bill
- **Day 1-2**: Standard template
- **Day 3**: Warning about cash discount eligibility  
- **Day 4+**: Additional MI (late fees) charges
- **MI Present**: Explanatory text about late payment fees

### Email Template Logic

#### Dynamic Template Selection
```python
if max_day_count <= 2:
    template = "Template_A"  # Standard
elif max_day_count == 3:
    template = "Template_B"  # Warning
elif max_day_count >= 4:
    template = "Template_C"  # Late fees
    
if contains_MI_documents:
    template = "Template_D"  # MI explanation
```

#### Subject Line Format
```
[Customer_Code], [Customer_Name], รายละเอียดบิลวันที่ [Date_Range]
```

#### Content Components
- Customer-specific QR code (PromptPay)
- Bill payment information (bank transfer)
- Dynamic payment instructions based on day count
- Regional AR representative contact signature

## Technical Implementation Details

### Data Management Strategy
**Decision Required:** Excel vs Database maintenance

**Option 1: Excel-based** (Current preference)
- Familiar to AR team
- Risk of data corruption
- Timing issues with daily updates

**Option 2: Database-driven** (AR team recommendation)
- Real-time updates
- Data validation capabilities
- Requires training, slower for bulk changes

### Integration Points

#### QR Code Management
- **Source**: City Bank generated codes
- **Storage**: SharePoint folder, filename = customer_code
- **Fallback**: Send email without QR if missing
- **Maintenance**: Manual addition for new customers

#### Payment Information
- **Upper section**: Company bank account (constant)
- **Lower section**: 999 + Customer_Code format

#### Contact Signatures
- **Dynamic lookup**: Office 365 directory integration
- **Fields**: Name, email, phone number
- **Regional mapping**: Based on customer region assignment

### Validation Requirements
```sql
REQUIRED FIELDS per customer:
- customer_email IS NOT NULL
- sales_email IS NOT NULL  
- ar_backup_email IS NOT NULL

VALIDATION TRIGGERS:
- Missing required fields → Alert AR team
- Invalid email format → Error handling
- Missing QR code → Log warning, continue processing
```

## Development Phases

### Phase 1: Platform Setup (5 days)
- Dataverse model design and implementation
- Security roles and business rules configuration
- Table relationships establishment

### Phase 2: Core Engine Development (5 days)
- Power Automate "Collections Engine" flow
- Excel file ingestion and processing
- Business logic implementation (exclusions, FIFO, day counting)
- Email template generation and sending

### Phase 3: Control Center (5 days)
- Model-Driven App development
- Dashboard for monitoring daily runs
- Customer data management interface
- Manual payment logging capability

### Phase 4: Testing & Go-Live (10 days)
- User Acceptance Testing support
- Production deployment
- Training delivery
- Performance monitoring

## Risk Mitigation Strategies

### Data Integrity
- **Implementation**: Validation rules for all required fields
- **Monitoring**: Alert system for incomplete customer records
- **Backup**: Manual process fallback capability

### Business Continuity
- **Testing**: Gradual rollout with AR team validation
- **Fallback**: Maintain manual process during transition
- **Support**: Real-time monitoring during first weeks

### Change Management
- **Training**: Comprehensive AR team onboarding
- **Documentation**: Process guides and troubleshooting
- **Support**: Dedicated support during transition period

## Success Metrics

### Operational Efficiency
- **Time Savings**: Reduce daily email composition from 2-3 hours to 15 minutes
- **Error Reduction**: Eliminate manual calculation errors
- **Consistency**: 100% adherence to business rules

### System Performance
- **Reliability**: 99%+ successful daily execution
- **Processing Time**: Complete daily run within 30 minutes
- **Scalability**: Handle 50% customer growth without modification

### Business Impact
- **Audit Compliance**: Complete trail of all customer communications
- **Cash Flow**: Consistent payment reminder delivery
- **Resource Allocation**: Free AR staff for higher-value activities

## Project Deliverables

### Core Components
1. **Dataverse Database**
   - Customer master data tables
   - Transaction processing tables
   - Audit and logging tables

2. **Power Automate Flows**
   - Daily collections engine
   - Error handling and notifications
   - Audit trail maintenance

3. **Model-Driven Power App**
   - AR Control Center dashboard
   - Customer data management
   - Manual payment interface

### Supporting Materials
4. **Documentation Package**
   - User guides and training materials
   - Administrative procedures
   - Troubleshooting guides

5. **Testing Framework**
   - UAT test cases and scenarios
   - Performance benchmarks
   - Rollback procedures

## File Structure Overview

```
Project Root/
├── client docs/
│   └── Automated Customer Collection Email Power App.md (Proposal)
├── database_schema.md (Schema documentation)
├── Meeting Transcription/
│   ├── KickOff/ (Sept 19, 2025 - Requirements gathering)
│   ├── Brief1/ (Initial briefing)
│   └── Update1/ (Progress updates)
├── Powerapp components-DO-NOT-EDIT/
│   ├── cmpEditableText.yaml (Reusable text input component)
│   └── NavigationMenu.yaml (Navigation component)
├── Powerapp screens-DO-NOT-EDIT/ (Screen definitions)
├── Powerapp solution Export/ (Solution packages)
└── templates/
    ├── docs/ (Documentation templates)
    └── powerapps/ (Power Apps templates)
```

## Next Steps

### Immediate Actions (Week 1)
1. **Development Environment Setup**
   - ✅ SharePoint site creation and permissions (COMPLETED by Nick)
   - 🔄 Dataverse environment provisioning (IN PROGRESS - Nick with client team)
   - Power Platform licensing verification

2. **Sample Data Collection** (CLIENT TEAM responsibility)
   - Customer master data (cleaned/anonymized) - **Pending from AR team**
   - Multiple days of SAP extract samples - **Pending from AR team**
   - QR code folder access - **Pending from AR team**
   - Email template examples - **Pending from AR team**

3. **Technical Architecture Finalization**
   - Data maintenance strategy decision (Excel vs Database) - **Joint decision needed**
   - Integration approach confirmation - **Nick's responsibility**
   - Testing environment setup - **Nick's responsibility**

### Weekly Milestones
- **Week 1**: Environment setup, sample data integration
- **Week 2**: Core business logic implementation
- **Week 3**: Email generation and UI development
- **Week 4**: User acceptance testing
- **Week 5**: Production deployment and support

## Contact Information

**Technical Lead:** Nick Chamnong (Information Technology)  
**Business Sponsor:** Changsalak Alisara (Accounts Receivable)  
**Project Stakeholders:**
- Arayasomboon Chalitda (IT Finance & Legal)
- Nawawitrattana Siri (Credit Management)
- Panich Jarukit (Accounts Receivable)

**Meeting Schedule:** Bi-weekly progress reviews  
**Escalation Path:** IT Finance → Credit Management → Accounts Receivable  

---

**Document Version:** 1.0  
**Last Review:** Kickoff Meeting (September 19, 2025)  
**Next Review:** Development Sprint 1 Completion