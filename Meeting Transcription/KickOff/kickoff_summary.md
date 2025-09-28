# Finance Cash Customer Collection - Kickoff Meeting Summary

**Meeting Date:** September 19, 2025, 9:56:40 AM  
**Duration:** 60 minutes  
**Meeting Type:** Project Kickoff  

## Participants
- **Changsalak Alisara** (TH-Bangkok, Accounts Receivable) - Lead Presenter
- **Chamnong Nick** (TH-Bangkok, Information Technology) - Developer
- **Arayasomboon Chalitda** (TH-Bangkok, IT Finance & Legal)
- **Nawawitrattana Siri** (TH-Bangkok, Credit Management)
- **Nithijarernariya Russarin** (TH-Bangkok, Information Technology)
- **Panich Jarukit** (TH-Bangkok, Accounts Receivable)

## Project Overview

### Current State
- **Manual Process**: AR team manually sends daily outstanding balance notifications to cash customers via email
- **Daily Operations**: Process runs every morning, consuming significant time and prone to errors
- **Data Sources**: Two main Excel files are used - Customer Master Data and Daily SAP downloads

### Project Objective
Automate the daily collections email process to eliminate manual work, ensure consistency, and provide full audit trail capabilities.

## Data Architecture

### File #1: Customer Master Data (Excel)
**Maintained by:** AR team manually  
**Contents:**
- Customer Code
- Customer Name  
- Region
- Customer Email Address (primary, secondary, tertiary)
- Sales Email (CC'd in communications)
- AR Backup Email (account owner)

### File #2: Daily SAP Download (Excel)
**Source:** SAP system - customer line items  
**Frequency:** Daily download  
**Contents:**
- Account Name
- Document Number
- Assignment
- Document Date  
- Net Due Date
- Amount in Local Currency
- Text field (for exclusion markers)
- Reference

## Core Business Logic

### 1. Data Processing Flow
1. **Group transactions** by customer code/number from Excel File #2
2. **Text field scanning** - if "Exclude" keyword found, skip all line items for that customer
3. **Amount categorization**:
   - CN (Credit Notes) = Negative amounts
   - DN (Debit Notes) = Positive amounts
4. **FIFO sorting** by document date for both CN and DN

### 2. Business Rules for Sending Notifications

#### Rule 1: No DN Check
- If customer has no DN (debit notes), **don't send** notification
- Logic: No bills to pay = no notification needed

#### Rule 2: Balance Comparison
- **If Absolute CN < Absolute DN**: Proceed to Step 4 (send notification)
- **If Absolute CN > DN**: Apply FIFO to CN until CN < DN, then proceed to Step 4

### 3. Exclusion Logic
**"Exclude" keyword usage:**
- **Purpose**: Mark payments already received but not yet cleared in system
- **Examples**: "Paid", "Partial Payment", "รักษาตลาด" (Market Protection), "Bill credit 30 days"
- **System behavior**: Any line item with "Exclude" in text field is skipped entirely
- **Lifecycle**: Marked items will automatically disappear from next day's download once cleared in SAP

### 4. Day Counting System
**Purpose:** Track how many times a bill has been notified (for warning messages)

**Implementation:**
- Add "Day" column to Excel File #2
- **File Day-1**: Previous day's file
- **File Day 0**: Current day's file
- **Logic**: If document number exists in Day-1 file, increment day count by +1
- **New documents**: If not found in Day-1, assign Day = 0+1 = 1

**Warning System:**
- After **3 notifications**: Warning message that payment today won't qualify for cash discount (MI)

## Email Template Logic

### Template Selection Based on Day Count
1. **Template A**: Day 1 & 2 only
   - Standard format with QR code and bill payment info
2. **Template B**: Day 3
   - Includes warning: "If payment made today, no MI charge"
3. **Template C**: Day 4+
   - Includes note: "Additional MI charges will apply"
4. **Template D**: When MI documents present
   - Additional text: "MI amounts shown are late payment fees"

### Email Format Structure
**Subject Line:** `[Customer Code], [Customer Name], รายละเอียดบิลวันที่ [Date Range]`

**Date Logic:**
- If all bills same month: Show only day range (e.g., "29-30")
- If bills cross months: Show full date range
- Count only DN (positive amounts) for date range calculation

**Content Elements:**
- Customer-specific QR code for PromptPay
- Bill payment information (both PromptPay and bank transfer)
- Dynamic payment instructions based on day count
- Contact signature with regional AR representative details

## Payment Methods Integration

### PromptPay QR Codes
- **Source**: City Bank generated codes
- **Storage**: Folder with customer code as filename (e.g., "123456.jpg")
- **Fallback**: If QR code missing, email still sends but without QR image
- **Maintenance**: New customers require QR code generation

### Bill Payment Information
**Upper section (constant):** Company bank account details  
**Lower section (dynamic):** 999 + Customer Code format for reference

## Technical Implementation Considerations

### Data Management Options Discussed
**Option 1:** Continue Excel-based maintenance
- Pros: Familiar interface, easy AR team adoption
- Cons: Risk of data corruption, timing issues with daily updates

**Option 2:** Database-driven maintenance (Recommended by AR)
- Pros: Real-time updates, data integrity, validation capabilities
- Cons: Requires training, one-by-one entry for bulk changes

### Validation Requirements
**Mandatory fields for each customer:**
- At least one customer email
- At least one sales email  
- At least one AR backup email
- System should alert if any required field missing

### Email Sending Strategy
**Testing Phase:**
- Route emails to AR team initially for validation
- Manual review and approval before full automation
- Gradual rollout (2-3 weeks testing period)

**Production Phase:**
- Full automation after successful testing
- Maintain audit trail of all sent communications
- Error handling for missing data scenarios

## Data Volume & Performance

### Current Scale
- **Cash customers**: Approximately 100 customers
- **Daily transactions**: Estimated 100-1000 line items per day
- **Email volume**: ~100 emails daily
- **Growth projection**: Stable, no significant increase expected

### Storage Considerations
- Daily data accumulation concern for long-term storage
- Estimated annual volume: 100,000+ records
- Archive strategy to be determined for 5-10 year horizon

## Key Technical Decisions Made

### Document Identification
- **Primary key**: Document Number (unique, sequential)
- **Date sorting**: Document Date for FIFO logic
- **Amount determination**: Sign of amount field (positive/negative) rather than document type

### System Integration
- **Email permissions**: Developer needs SharePoint access and email sending rights
- **QR code access**: Existing folder structure to be shared
- **AR signature**: Dynamic contact info pulled from Office 365 directory

### Error Handling
- **Missing QR codes**: Continue processing without image
- **Invalid customer data**: Alert AR team for correction
- **System failures**: Maintain manual fallback capability

## Next Steps Committed

### Immediate Actions (Nick/Developer)
1. Create SharePoint folder for daily file sharing
2. Obtain sample files for development:
   - Customer master data (cleaned)
   - Daily SAP downloads (multiple days)
   - Email templates (PowerPoint/Word)
   - QR code folder access

### AR Team Actions
1. Clean and provide sample customer master data
2. Share existing email templates
3. Provide access to QR code repository
4. Define testing approach for validation phase

### Follow-up Schedule
- **Next meeting**: Bi-weekly check-ins
- **Development timeline**: TBD based on Nick's assessment
- **Testing phase**: 2-3 weeks before go-live

## Risk Mitigation

### Data Integrity
- Implement validation rules for required fields
- Error alerting for incomplete customer records
- Backup procedures for Excel-based data (if chosen)

### Communication Management
- Customer notification strategy for automation change
- AR contact information in email signatures
- Escalation procedures for system issues

### Business Continuity
- Manual process backup capability
- Gradual transition during testing phase
- Rollback procedures if automation fails

## Success Criteria

### Functional Requirements
- Accurate daily email generation based on business rules
- Proper exclusion handling for already-paid items
- Correct template selection based on notification count
- Complete audit trail of all communications

### Operational Benefits
- Eliminate daily manual email composition
- Ensure consistent application of business rules
- Reduce human error in amount calculations
- Provide scalable solution for future growth

---

**Meeting Status:** Successful kickoff with clear requirements defined  
**Next Milestone:** Sample data delivery and development environment setup  
**Project Sponsor:** Accounts Receivable Department  
**Technical Lead:** Nick Chamnong (IT)