# Table Creation Scripts

**Project:** Finance - Cash Customer Collection Automation
**Document:** Dataverse Table Creation Scripts
**Version:** 1.0
**Date:** September 29, 2025

## Overview

This document provides detailed scripts and configurations for creating all Dataverse tables, columns, and relationships in the Power Platform maker portal.

## Navigation Reference

```
Base URL: https://make.powerapps.com
Path: Home > [Select Environment] > Tables > + New table
```

## Table 1: Customer Master Data (`nc_customers`)

### Basic Table Setup
```yaml
Navigate to: Tables > + New table

Table Properties:
  Display name: "Customers"
  Plural name: "Customers"
  Schema name: "nc_customer"
  Description: "Central repository for cash customer information"

Primary Column Configuration:
  Display name: "Customer Name"
  Schema name: "nc_name"
  Data type: "Text"
  Maximum length: 255
  Required: Yes

Advanced Properties:
  Ownership: Organization
  Enable attachments: No
  Enable notes: No
  Enable activities: No
  Appear in search results: Yes
  Enable duplicate detection: Yes
  Enable change tracking: Yes
  Enable audit: Yes
```

### Column Definitions

#### Customer Identification
```yaml
Column: nc_customercode
  Display name: "Customer Code"
  Data type: Text
  Format: Text
  Maximum length: 20
  Required: Yes
  Unique: Yes
  Description: "SAP customer code (6-7 digits)"

Column: nc_customername
  Display name: "Customer Name"
  Data type: Text
  Format: Text
  Maximum length: 255
  Required: Yes
  Description: "Full legal customer name"

Column: nc_region
  Display name: "Region"
  Data type: Choice
  Required: Yes
  Description: "Customer geographical region"

  Choice Options:
    - Label: "Northern", Value: "NO"
    - Label: "Northeastern", Value: "NE"
    - Label: "Central", Value: "CE"
    - Label: "Southern", Value: "SO"
    - Label: "Bangkok", Value: "BK"
    - Label: "Eastern", Value: "EA"
  Default: "BK"
```

#### Customer Email Addresses
```yaml
Column: nc_customeremail1
  Display name: "Customer Email 1"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: Yes
  Description: "Primary customer email address"

Column: nc_customeremail2
  Display name: "Customer Email 2"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Secondary customer email address"

Column: nc_customeremail3
  Display name: "Customer Email 3"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Tertiary customer email address"

Column: nc_customeremail4
  Display name: "Customer Email 4"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Quaternary customer email address"
```

#### Sales Team Email Addresses
```yaml
Column: nc_salesemail1
  Display name: "Sales Email 1"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: Yes
  Description: "Primary sales contact email (CC'd on collections)"

Column: nc_salesemail2
  Display name: "Sales Email 2"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Secondary sales contact email"

Column: nc_salesemail3
  Display name: "Sales Email 3"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Tertiary sales contact email"

Column: nc_salesemail4
  Display name: "Sales Email 4"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Quaternary sales contact email"

Column: nc_salesemail5
  Display name: "Sales Email 5"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Fifth sales contact email"
```

#### AR Backup Email Addresses
```yaml
Column: nc_arbackupemail1
  Display name: "AR Backup Email 1"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: Yes
  Description: "Primary AR backup email (email owner)"

Column: nc_arbackupemail2
  Display name: "AR Backup Email 2"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Secondary AR backup email"

Column: nc_arbackupemail3
  Display name: "AR Backup Email 3"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Tertiary AR backup email"

Column: nc_arbackupemail4
  Display name: "AR Backup Email 4"
  Data type: Text
  Format: Email
  Maximum length: 100
  Required: No
  Description: "Quaternary AR backup email"
```

#### Status and Control Fields
```yaml
Column: nc_isactive
  Display name: "Is Active"
  Data type: Yes/No
  Required: Yes
  Default value: Yes
  Description: "Customer active status for email processing"

Column: nc_qrcodeavailable
  Display name: "QR Code Available"
  Data type: Yes/No
  Required: Yes
  Default value: No
  Description: "QR code file exists in SharePoint folder"
```

## Table 2: Transaction Data (`nc_transactions`)

### Basic Table Setup
```yaml
Navigate to: Tables > + New table

Table Properties:
  Display name: "Transactions"
  Plural name: "Transactions"
  Schema name: "nc_transaction"
  Description: "Daily SAP transaction line items and processing status"

Primary Column Configuration:
  Display name: "Document Number"
  Schema name: "nc_name"
  Data type: "Text"
  Maximum length: 50
  Required: No

Advanced Properties:
  Ownership: Organization
  Enable attachments: No
  Enable notes: Yes
  Enable activities: No
  Appear in search results: Yes
  Enable duplicate detection: Yes
  Enable change tracking: Yes
  Enable audit: Yes
```

### Column Definitions

#### Core Transaction Fields
```yaml
Column: nc_customer
  Display name: "Customer"
  Data type: Lookup
  Related table: nc_customers
  Required: Yes
  Description: "Reference to customer record"

Column: nc_recordtype
  Display name: "Record Type"
  Data type: Choice
  Required: Yes
  Description: "Type of record in transaction file"

  Choice Options:
    - Label: "Transaction", Value: "Transaction"
    - Label: "Summary", Value: "Summary"
    - Label: "Header", Value: "Header"
  Default: "Transaction"

Column: nc_documentnumber
  Display name: "Document Number"
  Data type: Text
  Format: Text
  Maximum length: 50
  Required: No
  Description: "SAP document number (required for Transaction type)"

Column: nc_assignment
  Display name: "Assignment"
  Data type: Text
  Format: Text
  Maximum length: 100
  Required: No
  Description: "SAP assignment field"

Column: nc_documenttype
  Display name: "Document Type"
  Data type: Text
  Format: Text
  Maximum length: 10
  Required: No
  Description: "Original SAP document type (DG, DR, DZ, etc.)"
```

#### Date and Amount Fields
```yaml
Column: nc_documentdate
  Display name: "Document Date"
  Data type: Date and Time
  Format: Date only
  Required: No
  Description: "Document creation date (required for Transaction type)"

Column: nc_netduedate
  Display name: "Net Due Date"
  Data type: Date and Time
  Format: Date only
  Required: No
  Description: "Payment due date (required for Transaction type)"

Column: nc_arrearsdays
  Display name: "Arrears Days"
  Data type: Whole Number
  Minimum value: 0
  Maximum value: 999
  Required: No
  Description: "Original SAP arrears calculation"

Column: nc_amountlocalcurrency
  Display name: "Amount (Local Currency)"
  Data type: Currency
  Precision: 2
  Required: Yes
  Description: "Transaction/summary amount (+ or -)"
```

#### Text and Reference Fields
```yaml
Column: nc_textfield
  Display name: "Text"
  Data type: Multiple Lines of Text
  Maximum length: 500
  Required: No
  Description: "SAP text field (for exclusion keywords)"

Column: nc_reference
  Display name: "Reference"
  Data type: Text
  Format: Text
  Maximum length: 100
  Required: No
  Description: "Reference information"

Column: nc_transactiontype
  Display name: "Transaction Type"
  Data type: Choice
  Required: No
  Description: "CN (Credit Note) or DN (Debit Note) - calculated for transactions"

  Choice Options:
    - Label: "Credit Note", Value: "CN"
    - Label: "Debit Note", Value: "DN"
    - Label: "Other", Value: "Other"
```

#### Processing Control Fields
```yaml
Column: nc_isexcluded
  Display name: "Is Excluded"
  Data type: Yes/No
  Required: Yes
  Default value: No
  Description: "Marked for exclusion from email processing"

Column: nc_excludereason
  Display name: "Exclude Reason"
  Data type: Text
  Format: Text
  Maximum length: 100
  Required: No
  Description: "Exclusion keyword found"

Column: nc_daycount
  Display name: "Day Count"
  Data type: Whole Number
  Minimum value: 0
  Maximum value: 999
  Required: No
  Description: "Notification day count (required for transactions)"

Column: nc_processdate
  Display name: "Process Date"
  Data type: Date and Time
  Format: Date only
  Required: Yes
  Description: "Date of SAP extract"

Column: nc_processbatch
  Display name: "Process Batch"
  Data type: Text
  Format: Text
  Maximum length: 50
  Required: Yes
  Description: "Unique batch identifier for each file import"

Column: nc_rownumber
  Display name: "Row Number"
  Data type: Whole Number
  Minimum value: 1
  Required: Yes
  Description: "Original Excel row number for debugging"

Column: nc_isprocessed
  Display name: "Is Processed"
  Data type: Yes/No
  Required: Yes
  Default value: No
  Description: "Included in email processing"

Column: nc_emailsent
  Display name: "Email Sent"
  Data type: Yes/No
  Required: Yes
  Default value: No
  Description: "Email sent for this transaction"

Column: nc_parentcustomeramount
  Display name: "Parent Customer Amount"
  Data type: Currency
  Precision: 2
  Required: No
  Description: "Customer total from summary row (for validation)"
```

## Table 3: Email Log (`nc_emaillog`)

### Basic Table Setup
```yaml
Navigate to: Tables > + New table

Table Properties:
  Display name: "Email Log"
  Plural name: "Email Logs"
  Schema name: "nc_emaillog"
  Description: "Complete audit trail of all email communications"

Primary Column Configuration:
  Display name: "Email Subject"
  Schema name: "nc_name"
  Data type: "Text"
  Maximum length: 500
  Required: Yes

Advanced Properties:
  Ownership: Organization
  Enable attachments: Yes
  Enable notes: Yes
  Enable activities: Yes
  Appear in search results: Yes
  Enable duplicate detection: No
  Enable change tracking: Yes
  Enable audit: Yes
```

### Column Definitions

#### Email Identification
```yaml
Column: nc_customer
  Display name: "Customer"
  Data type: Lookup
  Related table: nc_customers
  Required: Yes
  Description: "Customer who received email"

Column: nc_processdate
  Display name: "Process Date"
  Data type: Date and Time
  Format: Date only
  Required: Yes
  Description: "Date of processing run"

Column: nc_emailsubject
  Display name: "Email Subject"
  Data type: Text
  Format: Text
  Maximum length: 500
  Required: Yes
  Description: "Email subject line"

Column: nc_emailtemplate
  Display name: "Email Template"
  Data type: Choice
  Required: Yes
  Description: "Template used for email"

  Choice Options:
    - Label: "Template A (Day 1-2 Standard)", Value: "A"
    - Label: "Template B (Day 3 Warning)", Value: "B"
    - Label: "Template C (Day 4+ Late Fees)", Value: "C"
    - Label: "Template D (MI Documents)", Value: "D"
```

#### Email Content and Metrics
```yaml
Column: nc_maxdaycount
  Display name: "Max Day Count"
  Data type: Whole Number
  Minimum value: 0
  Maximum value: 999
  Required: Yes
  Description: "Highest day count in email"

Column: nc_totalamount
  Display name: "Total Amount"
  Data type: Currency
  Precision: 2
  Required: Yes
  Description: "Total amount owed included in email"

Column: nc_transactioncount
  Display name: "Transaction Count"
  Data type: Whole Number
  Minimum value: 1
  Required: Yes
  Description: "Number of transactions included in email"

Column: nc_recipientemails
  Display name: "Recipient Emails"
  Data type: Multiple Lines of Text
  Maximum length: 1000
  Required: Yes
  Description: "All recipient email addresses (semicolon separated)"

Column: nc_ccemails
  Display name: "CC Emails"
  Data type: Multiple Lines of Text
  Maximum length: 1000
  Required: Yes
  Description: "All CC email addresses (semicolon separated)"
```

#### Delivery Status
```yaml
Column: nc_sentdatetime
  Display name: "Sent Date Time"
  Data type: Date and Time
  Format: Date and time
  Required: Yes
  Description: "Email sent timestamp"

Column: nc_sentstatus
  Display name: "Send Status"
  Data type: Choice
  Required: Yes
  Description: "Email delivery status"

  Choice Options:
    - Label: "Success", Value: "Success"
    - Label: "Failed", Value: "Failed"
    - Label: "Pending", Value: "Pending"
  Default: "Pending"

Column: nc_errormessage
  Display name: "Error Message"
  Data type: Text
  Format: Text
  Maximum length: 500
  Required: No
  Description: "Error details if email failed"

Column: nc_qrcodeincluded
  Display name: "QR Code Included"
  Data type: Yes/No
  Required: Yes
  Default value: No
  Description: "QR code attached to email"
```

## Table 4: Process Log (`nc_processlog`)

### Basic Table Setup
```yaml
Navigate to: Tables > + New table

Table Properties:
  Display name: "Process Log"
  Plural name: "Process Logs"
  Schema name: "nc_processlog"
  Description: "Track daily automation runs and system performance"

Primary Column Configuration:
  Display name: "Process Date"
  Schema name: "nc_name"
  Data type: "Date and Time"
  Format: "Date only"
  Required: Yes

Advanced Properties:
  Ownership: Organization
  Enable attachments: Yes
  Enable notes: Yes
  Enable activities: No
  Appear in search results: Yes
  Enable duplicate detection: Yes
  Enable change tracking: Yes
  Enable audit: Yes
```

### Column Definitions

#### Process Identification
```yaml
Column: nc_processdate
  Display name: "Process Date"
  Data type: Date and Time
  Format: Date only
  Required: Yes
  Description: "Processing date"

Column: nc_starttime
  Display name: "Start Time"
  Data type: Date and Time
  Format: Date and time
  Required: Yes
  Description: "Process start time"

Column: nc_endtime
  Display name: "End Time"
  Data type: Date and Time
  Format: Date and time
  Required: No
  Description: "Process completion time"

Column: nc_status
  Display name: "Status"
  Data type: Choice
  Required: Yes
  Description: "Processing status"

  Choice Options:
    - Label: "Running", Value: "Running"
    - Label: "Completed", Value: "Completed"
    - Label: "Failed", Value: "Failed"
  Default: "Running"
```

#### Process Metrics
```yaml
Column: nc_totalcustomers
  Display name: "Total Customers"
  Data type: Whole Number
  Minimum value: 0
  Required: Yes
  Default value: 0
  Description: "Customers processed in this run"

Column: nc_emailssent
  Display name: "Emails Sent"
  Data type: Whole Number
  Minimum value: 0
  Required: Yes
  Default value: 0
  Description: "Emails successfully sent"

Column: nc_emailsfailed
  Display name: "Emails Failed"
  Data type: Whole Number
  Minimum value: 0
  Required: Yes
  Default value: 0
  Description: "Emails that failed to send"

Column: nc_transactionsprocessed
  Display name: "Transactions Processed"
  Data type: Whole Number
  Minimum value: 0
  Required: Yes
  Default value: 0
  Description: "Total transactions processed"

Column: nc_transactionsexcluded
  Display name: "Transactions Excluded"
  Data type: Whole Number
  Minimum value: 0
  Required: Yes
  Default value: 0
  Description: "Transactions excluded from processing"
```

#### Error and File Information
```yaml
Column: nc_errormessages
  Display name: "Error Messages"
  Data type: Multiple Lines of Text
  Maximum length: 2000
  Required: No
  Description: "Processing errors and warnings"

Column: nc_sapfilename
  Display name: "SAP File Name"
  Data type: Text
  Format: Text
  Maximum length: 255
  Required: Yes
  Description: "Source SAP Excel file name"

Column: nc_processedby
  Display name: "Processed By"
  Data type: Text
  Format: Text
  Maximum length: 255
  Required: Yes
  Description: "Processing user or system account"
```

## Table Relationships

### Create Relationships
```yaml
Navigate to: Tables > [Select Table] > Relationships > + Add relationship

Relationship 1: Customer to Transactions (1:N)
  Type: One-to-many
  Related table: nc_transactions
  Current table lookup column: nc_customer
  Related table lookup column: Customer
  Relationship name: nc_customer_nc_transactions
  Lookup column display name: Customer
  Lookup column name: nc_customer
  Behavior type: Referential
  Delete action: Restrict

Relationship 2: Customer to Email Log (1:N)
  Type: One-to-many
  Related table: nc_emaillog
  Current table lookup column: nc_customer
  Related table lookup column: Customer
  Relationship name: nc_customer_nc_emaillog
  Lookup column display name: Customer
  Lookup column name: nc_customer
  Behavior type: Referential
  Delete action: Restrict

Relationship 3: Process Log to Email Log (1:N) - Optional
  Type: One-to-many
  Related table: nc_emaillog
  Current table lookup column: nc_processlog
  Related table lookup column: Process Run
  Relationship name: nc_processlog_nc_emaillog
  Lookup column display name: Process Run
  Lookup column name: nc_processlog
  Behavior type: Referential
  Delete action: Remove Link
```

## Business Rules Configuration

### Navigate to Business Rules
```yaml
Path: Tables > [Select Table] > Business rules > + Add business rule
```

### Rule 1: Customer Email Required
```yaml
Table: nc_customers
Rule Name: "Customer Email Required"
Description: "At least one customer email must be provided"

Conditions:
  Condition 1: nc_customeremail1 Does not contain data

Actions:
  Action 1: Show error message
  Message: "At least one customer email address is required"

Business Rule Scope: Entity
Activate: Yes
```

### Rule 2: Sales Email Required
```yaml
Table: nc_customers
Rule Name: "Sales Email Required"
Description: "At least one sales email must be provided"

Conditions:
  Condition 1: nc_salesemail1 Does not contain data

Actions:
  Action 1: Show error message
  Message: "At least one sales email address is required"

Business Rule Scope: Entity
Activate: Yes
```

### Rule 3: AR Backup Email Required
```yaml
Table: nc_customers
Rule Name: "AR Backup Email Required"
Description: "At least one AR backup email must be provided"

Conditions:
  Condition 1: nc_arbackupemail1 Does not contain data

Actions:
  Action 1: Show error message
  Message: "At least one AR backup email address is required"

Business Rule Scope: Entity
Activate: Yes
```

### Rule 4: Transaction Fields Required
```yaml
Table: nc_transactions
Rule Name: "Transaction Fields Required"
Description: "Document fields required for Transaction record type"

Conditions:
  Condition 1: nc_recordtype Equals Transaction

Actions:
  Action 1: Set field requirement
    Field: nc_documentnumber
    Required: Yes
  Action 2: Set field requirement
    Field: nc_documentdate
    Required: Yes
  Action 3: Set field requirement
    Field: nc_netduedate
    Required: Yes
  Action 4: Set field requirement
    Field: nc_daycount
    Required: Yes

Business Rule Scope: Entity
Activate: Yes
```

## Creation Checklist

### Pre-Creation Checklist
- [ ] Dataverse environment created
- [ ] Security roles configured
- [ ] Solution created with proper publisher
- [ ] Backup strategy in place

### Table Creation Order
1. [ ] Create nc_customers table (no dependencies)
2. [ ] Create nc_processlog table (no dependencies)
3. [ ] Create nc_transactions table (depends on nc_customers)
4. [ ] Create nc_emaillog table (depends on nc_customers, nc_processlog)

### Post-Creation Checklist
- [ ] All relationships created and tested
- [ ] Business rules activated and tested
- [ ] Security roles assigned correct permissions
- [ ] Test records created successfully
- [ ] All tables added to solution
- [ ] Solution exported for backup

---

**Script Status:** Ready for Implementation
**Estimated Time:** 3-4 hours for complete table creation
**Dependencies:** Dataverse environment, proper security roles