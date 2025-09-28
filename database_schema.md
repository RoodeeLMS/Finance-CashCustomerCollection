# Database Schema Documentation

**Project:** Finance - Cash Customer Collection Automation
**Platform:** Microsoft Dataverse
**Schema Version:** 1.0
**Last Updated:** September 29, 2025

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
| `nc_documentnumber` | Text(50) | Yes | SAP document number (unique per day) |
| `nc_assignment` | Text(100) | No | SAP assignment field |
| `nc_documentdate` | Date | Yes | Document creation date |
| `nc_netduedate` | Date | Yes | Payment due date |
| `nc_amountlocalcurrency` | Currency | Yes | Transaction amount (+ or -) |
| `nc_textfield` | Text(500) | No | SAP text field (for exclusion keywords) |
| `nc_reference` | Text(100) | No | Reference information |
| `nc_transactiontype` | Choice | Yes | CN (Credit Note) or DN (Debit Note) |
| `nc_isexcluded` | Yes/No | Yes | Marked for exclusion |
| `nc_excludereason` | Text(100) | No | Exclusion keyword found |
| `nc_daycount` | Whole Number | Yes | Notification day count |
| `nc_processdate` | Date | Yes | Date of SAP extract |
| `nc_isprocessed` | Yes/No | Yes | Included in email processing |
| `nc_emailsent` | Yes/No | Yes | Email sent for this transaction |

**Business Rules:**
- `nc_transactiontype` calculated from `nc_amountlocalcurrency` (negative = CN, positive = DN)
- `nc_isexcluded` = true if text field contains exclusion keywords
- `nc_daycount` calculated based on previous day's file comparison
- Default `nc_isprocessed` = false
- Default `nc_emailsent` = false

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

```javascript
// At least one customer email required
nc_customeremail1 != null

// At least one sales email required
nc_salesemail1 != null

// At least one AR backup email required
nc_arbackupemail1 != null

// Customer code format validation
nc_customercode matches "^[0-9]{6,7}$"
```

### Transaction Processing Validation

```javascript
// Document number required
nc_documentnumber != null && nc_documentnumber != ""

// Amount cannot be zero
nc_amountlocalcurrency != 0

// Process date cannot be future
nc_processdate <= Today()
```

## Indexes for Performance

```sql
-- Customer lookup optimization
CREATE INDEX IX_nc_customers_customercode ON nc_customers(nc_customercode)

-- Transaction processing optimization
CREATE INDEX IX_nc_transactions_processdate ON nc_transactions(nc_processdate)
CREATE INDEX IX_nc_transactions_customer_date ON nc_transactions(nc_customer, nc_documentdate)

-- Email audit optimization
CREATE INDEX IX_nc_emaillog_processdate ON nc_emaillog(nc_processdate)
CREATE INDEX IX_nc_emaillog_customer ON nc_emaillog(nc_customer)
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

**Schema Status:** Ready for Implementation
**Next Step:** Dataverse environment configuration
**Dependencies:** Customer data migration, QR code folder access
