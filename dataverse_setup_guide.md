# Dataverse Environment Setup Guide

**Project:** Finance - Cash Customer Collection Automation
**Document:** Dataverse Environment Configuration
**Version:** 1.0
**Date:** September 29, 2025

## Overview

This guide provides step-by-step instructions for setting up the Microsoft Dataverse environment for the Nestlé Cash Customer Collection automation system.

## Prerequisites

### Required Licenses
- **Power Platform Premium** or **Power Apps per app license**
- **Dataverse for Teams** (minimum)
- **Office 365 Business Premium** (for SharePoint integration)

### Required Permissions
- **System Administrator** role in Power Platform admin center
- **SharePoint Site Collection Administrator** for document libraries
- **Exchange Administrator** for email integration

### Environment Requirements
- **Tenant**: Nestlé Office 365 tenant
- **Region**: Select appropriate region for data residency
- **Language**: English (or primary business language)
- **Currency**: Thai Baht (THB) - based on exclusion keywords

## Step 1: Create Dataverse Environment

### 1.1 Access Power Platform Admin Center
```
1. Navigate to: https://admin.powerplatform.microsoft.com
2. Sign in with System Administrator account
3. Select "Environments" from left navigation
4. Click "+ New" to create environment
```

### 1.2 Environment Configuration
```
Environment Settings:
├── Name: "Nestle Finance CashCollection Dev"
├── Type: "Sandbox" (for development)
├── Region: [Select appropriate region]
├── Language: English
├── Currency: Thai Baht (THB)
├── Security Group: [Optional - restrict access]
└── Dataverse: Yes (Add a Dataverse database)
```

### 1.3 Database Configuration
```
Database Settings:
├── Language: English
├── Currency: Thai Baht (THB)
├── Sample apps and data: No
├── Security group: [Match environment setting]
└── Enable Dynamics 365 apps: No (unless required)
```

## Step 2: Create Custom Tables

### 2.1 Customer Master Data Table (`nc_customers`)

```javascript
// Navigate to: https://make.powerapps.com
// Select your environment > Tables > + New table

Table Configuration:
├── Display name: "Customers"
├── Plural name: "Customers"
├── Name: "nc_customer"
├── Primary name column: "Customer Name"
├── Ownership: Organization
└── Enable attachments: No

Required Columns:
nc_customercode (Text, 20, Required, Unique)
nc_customername (Text, 255, Required)
nc_region (Choice, Required)
nc_customeremail1 (Email, Required)
nc_customeremail2 (Email)
nc_customeremail3 (Email)
nc_customeremail4 (Email)
nc_salesemail1 (Email, Required)
nc_salesemail2 (Email)
nc_salesemail3 (Email)
nc_salesemail4 (Email)
nc_salesemail5 (Email)
nc_arbackupemail1 (Email, Required)
nc_arbackupemail2 (Email)
nc_arbackupemail3 (Email)
nc_arbackupemail4 (Email)
nc_isactive (Yes/No, Required, Default: Yes)
nc_qrcodeavailable (Yes/No, Required, Default: No)
```

### 2.2 Transaction Data Table (`nc_transactions`)

```javascript
Table Configuration:
├── Display name: "Transactions"
├── Plural name: "Transactions"
├── Name: "nc_transaction"
├── Primary name column: "Document Number"
├── Ownership: Organization
└── Enable attachments: No

Required Columns:
nc_customer (Lookup to nc_customers, Required)
nc_recordtype (Choice: Transaction/Summary/Header, Required)
nc_documentnumber (Text, 50)
nc_assignment (Text, 100)
nc_documenttype (Text, 10)
nc_documentdate (Date Only)
nc_netduedate (Date Only)
nc_arrearsdays (Whole Number)
nc_amountlocalcurrency (Currency, Required)
nc_textfield (Text, 500)
nc_reference (Text, 100)
nc_transactiontype (Choice: CN/DN)
nc_isexcluded (Yes/No, Required, Default: No)
nc_excludereason (Text, 100)
nc_daycount (Whole Number)
nc_processdate (Date Only, Required)
nc_processbatch (Text, 50, Required)
nc_rownumber (Whole Number, Required)
nc_isprocessed (Yes/No, Required, Default: No)
nc_emailsent (Yes/No, Required, Default: No)
nc_parentcustomeramount (Currency)
```

### 2.3 Email Log Table (`nc_emaillog`)

```javascript
Table Configuration:
├── Display name: "Email Log"
├── Plural name: "Email Logs"
├── Name: "nc_emaillog"
├── Primary name column: "Email Subject"
├── Ownership: Organization
└── Enable attachments: Yes (for email copies)

Required Columns:
nc_customer (Lookup to nc_customers, Required)
nc_processdate (Date Only, Required)
nc_emailsubject (Text, 500, Required)
nc_emailtemplate (Choice: A/B/C/D, Required)
nc_maxdaycount (Whole Number, Required)
nc_totalamount (Currency, Required)
nc_transactioncount (Whole Number, Required)
nc_recipientemails (Multiple Lines of Text, 1000, Required)
nc_ccemails (Multiple Lines of Text, 1000, Required)
nc_sentdatetime (Date and Time, Required)
nc_sentstatus (Choice: Success/Failed/Pending, Required)
nc_errormessage (Text, 500)
nc_qrcodeincluded (Yes/No, Required, Default: No)
```

### 2.4 Process Log Table (`nc_processlog`)

```javascript
Table Configuration:
├── Display name: "Process Log"
├── Plural name: "Process Logs"
├── Name: "nc_processlog"
├── Primary name column: "Process Date"
├── Ownership: Organization
└── Enable attachments: No

Required Columns:
nc_processdate (Date Only, Required)
nc_starttime (Date and Time, Required)
nc_endtime (Date and Time)
nc_status (Choice: Running/Completed/Failed, Required)
nc_totalcustomers (Whole Number, Required, Default: 0)
nc_emailssent (Whole Number, Required, Default: 0)
nc_emailsfailed (Whole Number, Required, Default: 0)
nc_transactionsprocessed (Whole Number, Required, Default: 0)
nc_transactionsexcluded (Whole Number, Required, Default: 0)
nc_errormessages (Multiple Lines of Text, 2000)
nc_sapfilename (Text, 255, Required)
nc_processedby (Text, 255, Required)
```

## Step 3: Configure Relationships

### 3.1 Create Table Relationships

```javascript
// Customer to Transactions (1:N)
Relationship Configuration:
├── Related table: nc_transactions
├── Lookup column: nc_customer
├── Relationship name: nc_customer_transactions
├── Lookup column display name: Customer
├── Lookup column name: nc_customer
└── Behavior: Referential (Restrict Delete)

// Customer to Email Log (1:N)
Relationship Configuration:
├── Related table: nc_emaillog
├── Lookup column: nc_customer
├── Relationship name: nc_customer_emaillog
├── Lookup column display name: Customer
├── Lookup column name: nc_customer
└── Behavior: Referential (Restrict Delete)

// Process Log to Email Log (1:N) - Optional
Relationship Configuration:
├── Related table: nc_emaillog
├── Lookup column: nc_processlog
├── Relationship name: nc_processlog_emaillog
├── Lookup column display name: Process Run
├── Lookup column name: nc_processlog
└── Behavior: Referential (Remove Link)
```

## Step 4: Configure Choice Values

### 4.1 Region Choice
```
Choice Values for nc_region:
├── NO (Northern)
├── NE (Northeastern)
├── CE (Central)
├── SO (Southern)
├── BK (Bangkok)
└── EA (Eastern)
```

### 4.2 Record Type Choice
```
Choice Values for nc_recordtype:
├── Transaction (Individual transaction line)
├── Summary (Customer total row)
└── Header (CSV header row)
```

### 4.3 Transaction Type Choice
```
Choice Values for nc_transactiontype:
├── CN (Credit Note)
├── DN (Debit Note)
└── Other (Manual review required)
```

### 4.4 Email Template Choice
```
Choice Values for nc_emailtemplate:
├── A (Day 1-2: Standard reminder)
├── B (Day 3: Cash discount warning)
├── C (Day 4+: Late fees apply)
└── D (MI documents: MI explanation)
```

### 4.5 Process Status Choice
```
Choice Values for nc_status:
├── Running (Process in progress)
├── Completed (Successfully finished)
└── Failed (Process encountered errors)
```

### 4.6 Email Status Choice
```
Choice Values for nc_sentstatus:
├── Success (Email sent successfully)
├── Failed (Email sending failed)
└── Pending (Email queued for sending)
```

## Step 5: Configure Business Rules

### 5.1 Customer Validation Rules

```javascript
// Rule: Require at least one customer email
Business Rule Configuration:
├── Name: "Customer Email Required"
├── Entity: nc_customers
├── Scope: Entity
├── Condition: nc_customeremail1 is empty
├── Action: Show error message
└── Message: "At least one customer email is required"

// Rule: Require at least one sales email
Business Rule Configuration:
├── Name: "Sales Email Required"
├── Entity: nc_customers
├── Scope: Entity
├── Condition: nc_salesemail1 is empty
├── Action: Show error message
└── Message: "At least one sales email is required"

// Rule: Require at least one AR backup email
Business Rule Configuration:
├── Name: "AR Backup Email Required"
├── Entity: nc_customers
├── Scope: Entity
├── Condition: nc_arbackupemail1 is empty
├── Action: Show error message
└── Message: "At least one AR backup email is required"
```

### 5.2 Transaction Validation Rules

```javascript
// Rule: Document fields required for Transaction type
Business Rule Configuration:
├── Name: "Transaction Fields Required"
├── Entity: nc_transactions
├── Scope: Entity
├── Condition: nc_recordtype equals "Transaction"
├── Actions:
│   ├── Set nc_documentnumber as required
│   ├── Set nc_documentdate as required
│   ├── Set nc_netduedate as required
│   └── Set nc_daycount as required
└── Message: "Document details required for transaction records"
```

## Step 6: Configure Security Roles

### 6.1 Create Custom Security Roles

#### AR Administrator Role
```powershell
# Navigate to: Advanced Settings > Settings > Security > Security Roles
# Create new role: "NC AR Administrator"

Entity Permissions:
├── nc_customers: Create, Read, Write, Delete, Append, Append To, Assign, Share
├── nc_transactions: Create, Read, Write, Delete, Append, Append To
├── nc_emaillog: Read, Write, Delete
├── nc_processlog: Read, Write, Delete
├── User: Read (for audit fields)
└── Team: Read (for assignments)

Tab Permissions:
├── Core Records: Full access
├── Business Management: Read access
├── Service Management: No access
├── Customization: Full access (for AR Admins only)
└── Privacy Related Privileges: As needed
```

#### AR User Role
```powershell
# Create new role: "NC AR User"

Entity Permissions:
├── nc_customers: Read, Write, Append, Append To
├── nc_transactions: Read (no modification)
├── nc_emaillog: Read (view sent emails)
├── nc_processlog: Read (view processing status)
└── User: Read (basic)

Business Process Permissions:
├── Email processing: Read only
├── Customer maintenance: Full access
└── Reporting: Read access
```

#### System Service Role
```powershell
# Create new role: "NC System Service"

Entity Permissions:
├── nc_customers: Read, Append To
├── nc_transactions: Create, Read, Write, Append, Append To
├── nc_emaillog: Create, Read, Write, Append, Append To
├── nc_processlog: Create, Read, Write, Append, Append To
└── User: Read (for created by fields)

Special Permissions:
├── Bulk operations: Full access
├── System jobs: Read, Write
└── Data import/export: Full access
```

### 6.2 Assign Security Roles
```
User Assignments:
├── AR Team Members → "NC AR User" role
├── AR Managers → "NC AR Administrator" role
├── Power Automate Service → "NC System Service" role
└── System Administrators → "System Administrator" role
```

## Step 7: Create Solution

### 7.1 Create Managed Solution

```javascript
// Navigate to: Solutions > + New solution

Solution Configuration:
├── Display name: "Nestle Cash Collection"
├── Name: "NestleCashCollection"
├── Publisher: [Create new publisher]
├── Version: 1.0.0.0
└── Description: "Automated customer collection email system"

Publisher Configuration:
├── Display name: "Nestle Finance"
├── Name: "nestle"
├── Prefix: "nc"
└── Choice value prefix: 10000
```

### 7.2 Add Components to Solution

```
Add to Solution:
├── Tables:
│   ├── nc_customers
│   ├── nc_transactions
│   ├── nc_emaillog
│   └── nc_processlog
├── Security Roles:
│   ├── NC AR Administrator
│   ├── NC AR User
│   └── NC System Service
├── Business Rules:
│   ├── Customer Email Required
│   ├── Sales Email Required
│   ├── AR Backup Email Required
│   └── Transaction Fields Required
└── Relationships:
    ├── Customer-Transactions
    ├── Customer-EmailLog
    └── ProcessLog-EmailLog
```

## Step 8: Test Environment Setup

### 8.1 Create Test Data

```javascript
// Test Customer Record
Customer Test Data:
├── nc_customercode: "TEST001"
├── nc_customername: "Test Customer Ltd"
├── nc_region: "BK"
├── nc_customeremail1: "test@customer.com"
├── nc_salesemail1: "sales@nestle.com"
├── nc_arbackupemail1: "ar@nestle.com"
├── nc_isactive: Yes
└── nc_qrcodeavailable: No
```

### 8.2 Verify Permissions

```
Test Cases:
├── AR User can create/edit customers: ✓
├── AR User cannot delete transactions: ✓
├── System Service can bulk import: ✓
├── Email log records are created: ✓
└── Business rules are enforced: ✓
```

## Step 9: Environment Settings

### 9.1 Configure Data Loss Prevention (DLP)
```
DLP Policy Configuration:
├── Name: "Nestle Finance DLP"
├── Scope: Environment specific
├── Business data connectors:
│   ├── Dataverse
│   ├── SharePoint
│   ├── Office 365 Outlook
│   └── Excel Online
├── Non-business data connectors:
│   └── [Restrict all others]
└── Blocked connectors: [Social media, external file services]
```

### 9.2 Configure Environment Variables
```
Environment Variables:
├── SharePoint Site URL: [Customer collection site]
├── QR Code Folder Path: [SharePoint QR code library]
├── Email Template Library: [SharePoint template location]
├── Default AR Email: [Fallback email address]
└── Processing Schedule: [Daily at 8:00 AM]
```

## Next Steps

### Immediate Actions:
1. ✅ Create Dataverse environment
2. ✅ Configure security roles
3. ✅ Create custom tables
4. ✅ Set up relationships and business rules
5. ✅ Create managed solution

### Follow-up Tasks:
1. 🔄 **Customer data migration**
2. 🔄 **Power Automate flow development**
3. 🔄 **SharePoint folder configuration**
4. 🔄 **Email template setup**
5. 🔄 **QR code validation**

---

**Setup Status:** Ready for Implementation
**Estimated Time:** 2-3 hours for complete setup
**Dependencies:** Power Platform premium licenses, tenant admin access