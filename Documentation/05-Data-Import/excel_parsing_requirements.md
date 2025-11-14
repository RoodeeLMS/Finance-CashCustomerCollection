# Excel Parsing Requirements

**Project:** Finance - Cash Customer Collection Automation
**Document:** Excel Data Ingestion Specifications
**Version:** 1.1
**Date:** September 29, 2025

## Overview

This document defines the parsing requirements for daily SAP Excel files containing cash customer line items. The parsing logic must handle three distinct row types and transform data for Dataverse storage.

## Source File Format

### File Naming Convention
```
Pattern: Cash_Line_items_as of DD.MM.YYYY.xlsx
Example: Cash_Line_items_as of 29.9.2025.xlsx
Location: SharePoint/OneDrive designated folder
Format: Excel Workbook (.xlsx)
Worksheet: First sheet (Sheet1) or named table
```

### Excel Structure
```
| A      | B              | C          | D             | E            | F           | G                     | H                       | I    | J         |
|--------|----------------|------------|---------------|--------------|-------------|----------------------|-------------------------|------|-----------|
| Account| Document Number| Assignment | Document Type | Document Date| Net Due Date| Arrears by Net Due Date| Amount in Local Currency| Text | Reference |
| 198609 | 9974698958     | 9974698958 | DG            | 9/26/2025    | 9/26/2025   | 3                    | -30213.31               |      | PR_GR...  |
| 198609 |                |            |               |              |             |                      | -73618.74               |      |           |
```

## Row Type Classification

### 1. Header Row (Row 1)
**Characteristics:**
- Always first row
- Contains column names
- Must be preserved for audit trail

**Processing:**
- Store as `nc_recordtype = "Header"`
- Map to `nc_textfield` for column validation
- Set `nc_rownumber = 1`

### 2. Transaction Rows
**Characteristics:**
- Document Number is populated
- Contains individual SAP transactions
- All date fields populated

**Required Fields:**
- Account (Customer Code)
- Document Number
- Document Date
- Net Due Date
- Amount in Local Currency

**Processing:**
- Store as `nc_recordtype = "Transaction"`
- Validate all required fields present
- Apply business logic transformations

### 3. Summary Rows
**Characteristics:**
- Document Number is empty/null
- Account is populated
- Amount represents customer total
- All other transaction fields empty

**Processing:**
- Store as `nc_recordtype = "Summary"`
- Use for data validation only
- Do not include in email processing

## Data Transformation Rules

### Customer Code Mapping
```javascript
// Input: Account field (e.g., "198609")
// Output: Lookup to nc_customers table
// Validation: Must exist in customer master data
```

### Amount Parsing
```javascript
// Excel number format (no quotes or commas needed):
// -30213.31 (negative number)
// 54785.49 (positive number)
// 566513.98 (positive number)

// Power Automate transformation:
// Excel handles number formatting automatically
float(item()?['Amount in Local Currency'])

// Note: Excel stores numbers as actual numeric values,
// not text strings, so no string parsing required
```

### Date Conversion
```javascript
// Excel date format: Excel serial number or formatted date
// Examples: 9/26/2025 (Excel date), 45563 (Excel serial)
// Output: ISO date format YYYY-MM-DD

// Power Automate expressions:
// Method 1: If Excel shows formatted dates
formatDateTime(item()?['Document Date'], 'yyyy-MM-dd')

// Method 2: If Excel shows serial numbers
formatDateTime(addDays('1900-01-01', sub(int(item()?['Document Date']), 2)), 'yyyy-MM-dd')

// Note: Power Automate Excel connector typically handles
// date conversion automatically when using "List rows"
```

### Document Type Mapping
```javascript
// SAP Document Type → Transaction Type
DG → CN (Credit Note)
DR → DN (Debit Note)
DZ → Special (Manual review)
Other → Other (Manual review)
```

### Exclusion Keyword Detection
```javascript
// Keywords (case-insensitive):
keywords = ["Paid", "Partial Payment", "รักษาตลาด", "exclude", "Bill credit 30 days"]

// Detection logic:
isExcluded = false
excludeReason = ""

for each keyword in keywords:
    if contains(toLower(textField), toLower(keyword)):
        isExcluded = true
        excludeReason = keyword
        break
```

## Validation Requirements

### Row-Level Validation

#### Transaction Rows
```javascript
// Required field validation
if (recordType == "Transaction") {
    errors = []

    if (isEmpty(documentNumber))
        errors.add("Document Number required")

    if (isEmpty(documentDate))
        errors.add("Document Date required")

    if (isEmpty(netDueDate))
        errors.add("Net Due Date required")

    if (amount == 0)
        errors.add("Amount cannot be zero")

    if (!customerExists(account))
        errors.add("Customer not found: " + account)
}
```

#### Summary Rows
```javascript
// Summary row validation
if (recordType == "Summary") {
    if (isEmpty(account))
        errors.add("Customer code required in summary")

    if (amount == 0)
        errors.add("Summary amount cannot be zero")
}
```

### Customer-Level Validation
```javascript
// After processing all rows for a customer
customerTransactionSum = sum(transactions where account = customerCode)
customerSummaryAmount = summaryRow.amount

if (abs(customerTransactionSum - customerSummaryAmount) > 0.01) {
    logWarning("Amount mismatch for customer " + customerCode +
               ": Transactions=" + customerTransactionSum +
               ", Summary=" + customerSummaryAmount)
}
```

### File-Level Validation
```javascript
// Check for duplicate document numbers within file
duplicates = transactions.groupBy(documentNumber).filter(count > 1)
if (duplicates.length > 0) {
    logWarning("Duplicate documents found: " + duplicates.join(", "))
}

// Verify summary rows exist for all customers
customersWithTransactions = distinct(transactions.account)
customersWithSummary = distinct(summaryRows.account)
missing = customersWithTransactions.except(customersWithSummary)
if (missing.length > 0) {
    logError("Missing summary rows for: " + missing.join(", "))
}
```

## Error Handling Strategy

### Recoverable Errors
**Continue processing, log warning:**
- Amount parsing errors → Set amount = 0
- Date format errors → Use process date
- Customer not found → Skip row
- Text encoding issues → Log original value
- Validation mismatches → Continue with warning

### Non-Recoverable Errors
**Stop processing, log error:**
- File not found
- Invalid Excel format (.xlsx required)
- Excel file corrupted or locked
- No rows found
- Header row missing
- Worksheet/table not accessible
- Critical system errors

### Error Logging Format
```json
{
    "batchId": "20250929_080000_Cash_Line_items_as of 29.9.2025.xlsx",
    "rowNumber": 15,
    "errorType": "ValidationError",
    "errorMessage": "Customer not found: 999999",
    "inputData": {
        "account": "999999",
        "documentNumber": "9974698958",
        "amount": -30213.31
    },
    "timestamp": "2025-09-29T08:05:23Z"
}
```

## Performance Optimization

### Batch Processing
- Process rows in chunks of 100
- Commit to database every 500 rows
- Use bulk operations where possible

### Memory Management
```javascript
// Clear variables after each customer group
foreach customerGroup in customers {
    processCustomerTransactions(customerGroup)
    clearVariables(customerGroup)
}
```

### Lookup Optimization
```javascript
// Pre-load customer lookup table
customerMap = loadAllCustomers() // Load once at start

// Use in-memory lookup instead of database queries
customer = customerMap.get(accountCode)
```

## Data Quality Checks

### Pre-Import Validation
1. File size reasonable (< 10MB)
2. Valid Excel format (.xlsx)
3. File not password protected
4. Worksheet accessible
5. Row count matches expected range (10-10,000 rows)
6. Header row structure valid
7. No completely empty rows

### Post-Import Validation
1. All customers have summary rows
2. Transaction counts match expectations
3. Amount totals are reasonable
4. No orphaned transactions
5. Date ranges are logical

### Daily Reconciliation
```sql
-- Validate daily totals
SELECT
    nc_customer,
    SUM(CASE WHEN nc_recordtype = 'Transaction' THEN nc_amountlocalcurrency ELSE 0 END) as TransactionTotal,
    MAX(CASE WHEN nc_recordtype = 'Summary' THEN nc_amountlocalcurrency ELSE 0 END) as SummaryAmount,
    ABS(TransactionTotal - SummaryAmount) as Variance
FROM nc_transactions
WHERE nc_processdate = TODAY()
GROUP BY nc_customer
HAVING Variance > 0.01
```

## Integration Points

### Power Automate Flow Integration
```
Excel File → List Rows → Transform Data → Validate → Store in Dataverse
    ↓            ↓           ↓            ↓           ↓
File Check   Row Type    Field Mapping  Business   nc_transactions
Detection    Classification            Rules      nc_processlog
```

### Excel-Specific Power Automate Actions
- **Get files (preview)**: Detect Excel files in SharePoint
- **List rows present in a table**: Read Excel data as structured table
- **List rows present in a worksheet**: Read Excel data by range (A:J)
- **Get file content**: Retrieve Excel file for processing

### Dataverse Integration
- Use Dataverse bulk operations
- Handle concurrent access
- Maintain referential integrity
- Log all operations

### Error Notification
- Email AR team on critical errors
- Dashboard alerts for warnings
- Daily processing summary

---

**Document Status:** Complete
**Implementation Ready:** Yes
**Dependencies:** Customer master data loaded, Dataverse environment configured