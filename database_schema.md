# Database Schema Documentation

**Project:** Finance - Cash Customer Collection Automation
**Platform:** Microsoft Dataverse
**Schema Version:** 1.0
**Last Updated:** September 30, 2025

---

## ⚠️ IMPORTANT: Field Name Notice

**This document uses CONCEPTUAL/PLACEHOLDER field names (`nc_` prefix) for planning purposes.**

**For ACTUAL production field names used in Power Apps code, see:**
- **[FIELD_NAME_REFERENCE.md](FIELD_NAME_REFERENCE.md)** ← Use this for code generation
- **Exported YAML**: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`

**Production uses `cr7bb_` prefix, not `nc_` prefix shown below.**

---

## Schema Overview

This schema implements **Option 2: Database-driven** approach for customer data maintenance in Dataverse, replacing the Excel-based system with a robust, real-time database solution.

## Core Tables

### 1. Customer Master Data (`nc_customers`)

**Purpose:** Central repository for all cash customer information, replacing Excel-based customer master data.

| Field Name | Data Type | Required | Description |
|------------|-----------|----------|-------------|
| `nc_customerid` | Primary Key | Yes | Auto-generated unique identifier |
| `nc_customercode` | Text(20) | Yes | SAP customer code (e.g., "200120") |
| `nc_customername` | Text(255) | Yes | Full customer name |
| `nc_region` | Choice | Yes | Customer region (NO, SO, NE, CE, etc.) |
| `nc_customeremail1` | Email | Yes | Primary customer email |
| `nc_customeremail2` | Email | No | Secondary customer email |
| `nc_customeremail3` | Email | No | Tertiary customer email |
| `nc_customeremail4` | Email | No | Quaternary customer email |
| `nc_salesemail1` | Email | Yes | Primary sales contact (CC'd) |
| `nc_salesemail2` | Email | No | Secondary sales contact |
| `nc_salesemail3` | Email | No | Tertiary sales contact |
| `nc_salesemail4` | Email | No | Quaternary sales contact |
| `nc_salesemail5` | Email | No | Fifth sales contact |
| `nc_arbackupemail1` | Email | Yes | Primary AR backup (Owner) |
| `nc_arbackupemail2` | Email | No | Secondary AR backup |
| `nc_arbackupemail3` | Email | No | Tertiary AR backup |
| `nc_arbackupemail4` | Email | No | Quaternary AR backup |
| `nc_isactive` | Yes/No | Yes | Customer active status |
| `nc_qrcodeavailable` | Yes/No | Yes | QR code file exists |
| `nc_lastmodified` | DateTime | Yes | Last update timestamp |
| `nc_modifiedby` | Lookup(User) | Yes | User who last modified |

**Business Rules:**
- `nc_customercode` must be unique
- At least one customer email required (`nc_customeremail1`)
- At least one sales email required (`nc_salesemail1`)
- At least one AR backup email required (`nc_arbackupemail1`)
- Default `nc_isactive` = true
- Default `nc_qrcodeavailable` = false

### 2. Daily Transaction Data (`nc_transactions`)

**Purpose:** Stores daily SAP extracts with transaction line items and processing status.

| Field Name | Data Type | Required | Description |
|------------|-----------|----------|-------------|
| `nc_transactionid` | Primary Key | Yes | Auto-generated unique identifier |
| `nc_customer` | Lookup(nc_customers) | Yes | Reference to customer record |
| `nc_recordtype` | Choice | Yes | Transaction, Summary, Header |
| `nc_documentnumber` | Text(50) | No* | SAP document number (required for Transaction type) |
| `nc_assignment` | Text(100) | No | SAP assignment field |
| `nc_documenttype` | Text(10) | No | Original SAP document type (DG, DR, DZ, etc.) |
| `nc_documentdate` | Date | No* | Document creation date (required for Transaction type) |
| `nc_netduedate` | Date | No* | Payment due date (required for Transaction type) |
| `nc_arrearsdays` | Whole Number | No | Original SAP arrears calculation |
| `nc_amountlocalcurrency` | Currency | Yes | Transaction/summary amount (+ or -) |
| `nc_textfield` | Text(500) | No | SAP text field (for exclusion keywords) |
| `nc_reference` | Text(100) | No | Reference information |
| `nc_transactiontype` | Choice | No* | CN (Credit Note) or DN (Debit Note) - calculated for transactions |
| `nc_isexcluded` | Yes/No | Yes | Marked for exclusion |
| `nc_excludereason` | Text(100) | No | Exclusion keyword found |
| `nc_daycount` | Whole Number | No* | Notification day count (required for transactions) |
| `nc_processdate` | Date | Yes | Date of SAP extract |
| `nc_processbatch` | Text(50) | Yes | Unique batch identifier for each file import |
| `nc_rownumber` | Whole Number | Yes | Original CSV row number for debugging |
| `nc_isprocessed` | Yes/No | Yes | Included in email processing |
| `nc_emailsent` | Yes/No | Yes | Email sent for this transaction |
| `nc_parentcustomeramount` | Currency | No | Customer total from summary row (for validation) |

**Record Type Choices:**
- **Transaction**: Individual SAP transaction line items
- **Summary**: Customer total rows (empty document fields)
- **Header**: CSV header row (for audit trail)

**Business Rules:**
- `nc_recordtype` determines field requirements (* = required for Transaction type only)
- `nc_transactiontype` calculated from `nc_amountlocalcurrency` for transactions (negative = CN, positive = DN)
- `nc_isexcluded` = true if text field contains exclusion keywords (Transaction type only)
- `nc_daycount` uses `nc_arrearsdays` for new transactions, historical tracking for existing
- `nc_processbatch` format: "YYYYMMDD_HHMMSS_filename" for unique identification
- Default `nc_isprocessed` = false
- Default `nc_emailsent` = false
- Summary records used for data validation but not email processing

**Exclusion Keywords:**
- "Paid"
- "Partial Payment"
- "รักษาตลาด" (Market Protection)
- "Bill credit 30 days"

### 3. Email Processing Log (`nc_emaillog`)

**Purpose:** Complete audit trail of all email communications sent to customers.

| Field Name | Data Type | Required | Description |
|------------|-----------|----------|-------------|
| `nc_emaillogid` | Primary Key | Yes | Auto-generated unique identifier |
| `nc_customer` | Lookup(nc_customers) | Yes | Customer who received email |
| `nc_processdate` | Date | Yes | Date of processing run |
| `nc_emailsubject` | Text(500) | Yes | Email subject line |
| `nc_emailtemplate` | Choice | Yes | Template used (A, B, C, D) |
| `nc_maxdaycount` | Whole Number | Yes | Highest day count in email |
| `nc_totalamount` | Currency | Yes | Total amount owed |
| `nc_transactioncount` | Whole Number | Yes | Number of transactions included |
| `nc_recipientemails` | Text(1000) | Yes | All recipient email addresses |
| `nc_ccemails` | Text(1000) | Yes | All CC email addresses |
| `nc_sentdatetime` | DateTime | Yes | Email sent timestamp |
| `nc_sentstatus` | Choice | Yes | Success, Failed, Pending |
| `nc_errormessage` | Text(500) | No | Error details if failed |
| `nc_qrcodeincluded` | Yes/No | Yes | QR code attached |

**Email Template Choices:**
- **Template A**: Day 1-2 (Standard)
- **Template B**: Day 3 (Cash discount warning)
- **Template C**: Day 4+ (Late fees apply)
- **Template D**: MI documents present

### 4. System Processing Log (`nc_processlog`)

**Purpose:** Track daily automation runs and system performance.

| Field Name | Data Type | Required | Description |
|------------|-----------|----------|-------------|
| `nc_processlogid` | Primary Key | Yes | Auto-generated unique identifier |
| `nc_processdate` | Date | Yes | Processing date |
| `nc_starttime` | DateTime | Yes | Process start time |
| `nc_endtime` | DateTime | No | Process completion time |
| `nc_status` | Choice | Yes | Running, Completed, Failed |
| `nc_totalcustomers` | Whole Number | Yes | Customers processed |
| `nc_emailssent` | Whole Number | Yes | Emails successfully sent |
| `nc_emailsfailed` | Whole Number | Yes | Emails failed |
| `nc_transactionsprocessed` | Whole Number | Yes | Total transactions processed |
| `nc_transactionsexcluded` | Whole Number | Yes | Transactions excluded |
| `nc_errormessages` | Text(2000) | No | Processing errors |
| `nc_sapfilename` | Text(255) | Yes | Source SAP file name |
| `nc_processedby` | Text(255) | Yes | Processing user/system |

**Processing Status Choices:**
- **Running**: Process in progress
- **Completed**: Successfully finished
- **Failed**: Process encountered errors

## Relationships

```
nc_customers (1) ←→ (N) nc_transactions
nc_customers (1) ←→ (N) nc_emaillog
nc_processlog (1) ←→ (N) nc_emaillog
```

## Security Model

### Security Roles

1. **AR Administrator**
   - Full CRUD on all tables
   - Can manage customer data and view all reports

2. **AR User**
   - Read/Write on `nc_customers`
   - Read-only on `nc_emaillog` and `nc_processlog`
   - Cannot delete transaction data

3. **System Service**
   - Write access to `nc_transactions`, `nc_emaillog`, `nc_processlog`
   - Read access to `nc_customers`

### Field-Level Security

- Email fields: AR team only
- System processing fields: Service account only
- Customer modification tracking: Audit enabled

## Data Validation Rules

### Customer Master Validation

**Implementation**: Configure via Dataverse Business Rules or Power Fx formulas

```powershell
# Business Rule: Customer Email Required
# Navigate to: Tables > nc_customers > Business rules > + Add business rule
Condition: IsBlank(nc_customeremail1)
Action: Show error message "At least one customer email is required"

# Business Rule: Sales Email Required
Condition: IsBlank(nc_salesemail1)
Action: Show error message "At least one sales email is required"

# Business Rule: AR Backup Email Required
Condition: IsBlank(nc_arbackupemail1)
Action: Show error message "At least one AR backup email is required"

# Column Validation: Customer Code Format
# Navigate to: Tables > nc_customers > Columns > nc_customercode > Advanced options
Format Validation: IsMatch(Self.Value, "^[0-9]{6,7}$")
Error Message: "Customer code must be 6-7 digits"
```

### Transaction Processing Validation

**Implementation**: Configure via Dataverse Business Rules and Power Fx formulas

```powershell
# Business Rule: Transaction Fields Required
# Navigate to: Tables > nc_transactions > Business rules > + Add business rule
Condition: nc_recordtype = "Transaction"
Actions:
  - Set nc_documentnumber as required
  - Set nc_documentdate as required
  - Set nc_netduedate as required
  - Set nc_daycount as required

# Column Validation: Amount Not Zero
# Navigate to: Tables > nc_transactions > Columns > nc_amountlocalcurrency
Validation: Self.Value <> 0
Error Message: "Amount cannot be zero"

# Column Validation: Process Date Not Future
# Navigate to: Tables > nc_transactions > Columns > nc_processdate
Validation: Self.Value <= Today()
Error Message: "Process date cannot be in the future"

# Business Rule: Process Batch Required
Condition: IsBlank(nc_processbatch)
Action: Show error message "Process batch identifier is required for audit trail"
```

## Performance Optimization

**Dataverse Auto-Indexing**: Dataverse automatically creates indexes on lookup fields and primary keys. Manual SQL index creation is not supported.

### Dataverse Performance Best Practices

```powershell
# Lookup Field Optimization (Auto-indexed)
- nc_customer (lookup fields are automatically indexed)
- nc_processdate (date fields used in filtering)
- nc_customercode (marked as alternate key for fast lookups)

# Power Automate Query Optimization
- Use FetchXML for complex queries instead of OData
- Filter early in flows to reduce data transfer
- Use pagination for large result sets

# Alternate Key Configuration
# Navigate to: Tables > nc_customers > Keys > + Add key
Alternate Key: nc_customercode (for fast customer lookups)

# View Optimization
- Create indexed views for frequently accessed data combinations
- Use column filtering in Model-Driven app views
- Limit view columns to essential data only
```

### FetchXML Query Examples

```xml
<!-- Optimized customer transaction lookup -->
<fetch>
  <entity name="nc_transaction">
    <filter>
      <condition attribute="nc_customer" operator="eq" value="{customer_guid}" />
      <condition attribute="nc_processdate" operator="eq" value="2025-09-29" />
    </filter>
  </entity>
</fetch>

<!-- Optimized email log queries -->
<fetch>
  <entity name="nc_emaillog">
    <filter>
      <condition attribute="nc_processdate" operator="on-or-after" value="2025-09-01" />
    </filter>
    <order attribute="nc_sentdatetime" descending="true" />
  </entity>
</fetch>
```

## Data Migration Strategy

### Phase 1: Customer Master Data Import
1. Import CSV data into `nc_customers` table
2. Map CSV columns to Dataverse fields
3. Validate email formats and required fields
4. Set default values for new fields

### Phase 2: QR Code Validation
1. Check QR code availability for each customer
2. Update `nc_qrcodeavailable` flag
3. Generate missing QR codes if needed

### Phase 3: Historical Data (Optional)
1. Import recent transaction history if available
2. Establish baseline for day counting system

## Maintenance Procedures

### Daily Operations
- SAP file import to `nc_transactions`
- Email processing and logging
- Performance monitoring via `nc_processlog`

### Weekly Tasks
- Customer data validation
- Failed email retry processing
- System performance review

### Monthly Tasks
- Data archival for old transactions
- QR code validation
- Security audit review

---

## Power Automate Excel Ingestion Flow

### Flow Architecture: "Daily SAP Data Import"

**Trigger:** Scheduled (Daily at 8:00 AM) or Manual

**Flow Steps:**

#### 1. File Detection & Validation
```
├── Get files from SharePoint/OneDrive folder
├── Filter: *.xlsx files modified in last 24 hours
├── Validate: File name pattern "Cash_Line_items_as of DD.MM.YYYY.xlsx"
└── Log: File found/not found status
```

#### 2. Pre-Processing Setup
```
├── Generate batch ID: format("YYYYMMDD_HHMMSS_{0}", filename)
├── Create process log entry (nc_processlog)
├── Set variables:
│   ├── ProcessDate = utcNow()
│   ├── RowCounter = 0
│   └── ErrorCount = 0
```

#### 3. Excel Parsing & Row Processing
```
├── List rows present in Excel table (range A:J)
├── For each row in Excel worksheet:
│   ├── Increment RowCounter
│   ├── Determine record type:
│   │   ├── If row = 1: recordtype = "Header"
│   │   ├── If "Document Number" cell empty: recordtype = "Summary"
│   │   └── Else: recordtype = "Transaction"
│   │
│   ├── Customer Lookup:
│   │   ├── Query nc_customers by nc_customercode = Account
│   │   ├── If not found: Log error, skip row
│   │   └── Get customer GUID
│   │
│   ├── Data Transformation:
│   │   ├── Parse amount: handle Excel number formatting
│   │   ├── Convert dates: Excel date serial to standard format
│   │   ├── Map DocumentType → TransactionType (DG=CN, DR=DN)
│   │   ├── Calculate daycount from ArrearsbyNetDueDate
│   │   └── Check exclusion keywords in Text field
│   │
│   └── Create nc_transactions record
```

#### 4. Data Validation & Cross-Checks
```
├── For each customer processed:
│   ├── Sum transaction amounts by customer
│   ├── Compare with summary row amount
│   ├── If mismatch: Log validation error
│   └── Update nc_transactions.nc_parentcustomeramount
│
├── Check for duplicate document numbers in batch
├── Validate required email addresses exist
└── Mark invalid records as excluded
```

#### 5. Historical Day Count Processing
```
├── Query yesterday's transactions for same customers
├── For each customer:
│   ├── Compare document numbers
│   ├── If document exists in previous day:
│   │   └── Increment daycount = previous_daycount + 1
│   ├── If new document:
│   │   └── Use arrears days from CSV
│   └── Update nc_daycount field
```

#### 6. Error Handling & Logging
```
├── Catch parsing errors:
│   ├── Log to nc_processlog.nc_errormessages
│   ├── Continue processing remaining rows
│   └── Set overall status = "Completed with errors"
│
├── Update process log:
│   ├── nc_endtime = utcNow()
│   ├── nc_totalcustomers = distinct customer count
│   ├── nc_transactionsprocessed = transaction records created
│   ├── nc_transactionsexcluded = excluded records
│   └── nc_status = "Completed"/"Failed"
│
└── Send notification email if errors > 0
```

### Flow Variables & Expressions

**Key Power Automate Expressions:**

```javascript
// Generate batch ID
formatDateTime(utcNow(), 'yyyyMMdd_HHmmss')

// Parse Excel number values (handles negative numbers automatically)
float(item()?['Amount in Local Currency'])

// Excel date conversion (from Excel serial number)
formatDateTime(addDays('1900-01-01', sub(int(item()?['Document Date']), 2)), 'yyyy-MM-dd')

// Record type determination for Excel
if(empty(item()?['Document Number']), 'Summary', 'Transaction')

// Transaction type mapping
switch(item()?['Document Type'], 'DG', 'CN', 'DR', 'DN', 'Other')

// Exclusion keyword check
or(contains(item()?['Text'], 'Paid'), contains(item()?['Text'], 'Partial Payment'), contains(item()?['Text'], 'รักษาตลาด'), contains(item()?['Text'], 'exclude'))

// Excel worksheet reference
// Use "List rows present in a table" action with table range A:J
```

### Error Scenarios & Handling

| Error Type | Handling Strategy |
|------------|-------------------|
| File not found | Log warning, skip processing |
| Invalid Excel format | Log error, stop processing |
| Excel file locked/in use | Retry 3 times, then log error |
| Customer not found | Log error, skip row, continue |
| Duplicate document | Log warning, update existing |
| Amount parsing error | Log error, set amount = 0, continue |
| Date format error | Log error, use processdate, continue |
| Excel table not found | Log error, try range-based parsing |
| Validation mismatch | Log warning, continue processing |

### Performance Considerations

- **Batch Processing**: Process 100 rows at a time
- **Parallel Processing**: Customer lookups in parallel where possible
- **Indexing**: Ensure indexes on customercode and documentnumber
- **Memory Management**: Clear variables after each customer group

### Integration Points

```
SharePoint Folder → Power Automate → Dataverse
     ↓                    ↓              ↓
SAP Excel File  →    Excel Parsing →  nc_transactions
QR Code Folder  →    Validation    →  nc_processlog
Email Templates →    Error Handling →  nc_emaillog
```

---

**Schema Status:** Ready for Implementation
**Next Step:** Power Automate flow development, Dataverse environment configuration
**Dependencies:** Customer data migration, SharePoint folder access, QR code folder access
