# Data Import Templates

**Project:** Finance - Cash Customer Collection Automation
**Document:** Customer Data Migration Templates
**Version:** 1.0
**Date:** September 29, 2025

## Overview

This document provides templates and procedures for importing customer master data and initial transaction data into the Dataverse environment.

## Customer Master Data Import

### Excel Template Structure

#### Required Template: `Customer_Master_Import_Template.xlsx`

```excel
Column Structure (Row 1 - Headers):
A: Customer Code
B: Customer Name
C: Region
D: Customer Email 1
E: Customer Email 2
F: Customer Email 3
G: Customer Email 4
H: Sales Email 1
I: Sales Email 2
J: Sales Email 3
K: Sales Email 4
L: Sales Email 5
M: AR Backup Email 1
N: AR Backup Email 2
O: AR Backup Email 3
P: AR Backup Email 4
Q: Is Active
R: QR Code Available

Sample Data (Row 2):
A: 200120
B: ABC Company Limited
C: BK
D: finance@abc.com
E: accounting@abc.com
F:
G:
H: sales@nestle.com
I: sales.manager@nestle.com
J:
K:
L:
M: ar.team@nestle.com
N: ar.backup@nestle.com
O:
P:
Q: Yes
R: No
```

### Data Validation Rules

#### Customer Code Validation
```excel
Column A: Customer Code
- Format: Text
- Length: 6-7 digits
- Required: Yes
- Unique: Yes
- Validation: =AND(LEN(A2)>=6, LEN(A2)<=7, ISNUMBER(VALUE(A2)))
- Error Message: "Customer code must be 6-7 digits"
```

#### Customer Name Validation
```excel
Column B: Customer Name
- Format: Text
- Length: Maximum 255 characters
- Required: Yes
- Validation: =AND(LEN(B2)>0, LEN(B2)<=255)
- Error Message: "Customer name required, maximum 255 characters"
```

#### Region Validation
```excel
Column C: Region
- Format: Choice List
- Required: Yes
- Valid Values: NO, NE, CE, SO, BK, EA
- Validation: =OR(C2="NO", C2="NE", C2="CE", C2="SO", C2="BK", C2="EA")
- Error Message: "Region must be: NO, NE, CE, SO, BK, or EA"
```

#### Email Validation
```excel
Email Columns (D, E, F, G, H, I, J, K, L, M, N, O, P):
- Format: Email
- Required: D2, H2, M2 (at least one email per category)
- Validation: =OR(D2="", AND(ISERROR(FIND("@",D2))=FALSE, LEN(D2)<=100))
- Error Message: "Invalid email format or exceeds 100 characters"

Required Email Check:
- Customer Email 1 (D2): =D2<>""
- Sales Email 1 (H2): =H2<>""
- AR Backup Email 1 (M2): =M2<>""
```

#### Status Field Validation
```excel
Column Q: Is Active
- Format: Yes/No
- Required: Yes
- Valid Values: Yes, No, TRUE, FALSE, 1, 0
- Default: Yes
- Validation: =OR(Q2="Yes", Q2="No", Q2="TRUE", Q2="FALSE", Q2=1, Q2=0)

Column R: QR Code Available
- Format: Yes/No
- Required: Yes
- Valid Values: Yes, No, TRUE, FALSE, 1, 0
- Default: No
- Validation: =OR(R2="Yes", R2="No", R2="TRUE", R2="FALSE", R2=1, R2=0)
```

### Data Import Process

#### Step 1: Prepare Data File
```yaml
File Preparation:
1. Save Excel file as: Customer_Master_Import_[YYYYMMDD].xlsx
2. Verify all required fields populated
3. Run data validation checks
4. Remove any duplicate customer codes
5. Backup original data source
```

#### Step 2: Dataverse Import Wizard
```yaml
Navigate to: https://make.powerapps.com > Data > Get data > Import data

Import Configuration:
├── Data source: Excel workbook
├── Upload file: Customer_Master_Import_[YYYYMMDD].xlsx
├── Table: Choose existing table: nc_customers
├── Mapping method: Map columns automatically
└── Advanced settings: Skip duplicates based on Customer Code
```

#### Step 3: Column Mapping
```yaml
Excel Column → Dataverse Field Mapping:

Customer Code → nc_customercode
Customer Name → nc_customername (Primary Name Column)
Region → nc_region
Customer Email 1 → nc_customeremail1
Customer Email 2 → nc_customeremail2
Customer Email 3 → nc_customeremail3
Customer Email 4 → nc_customeremail4
Sales Email 1 → nc_salesemail1
Sales Email 2 → nc_salesemail2
Sales Email 3 → nc_salesemail3
Sales Email 4 → nc_salesemail4
Sales Email 5 → nc_salesemail5
AR Backup Email 1 → nc_arbackupemail1
AR Backup Email 2 → nc_arbackupemail2
AR Backup Email 3 → nc_arbackupemail3
AR Backup Email 4 → nc_arbackupemail4
Is Active → nc_isactive
QR Code Available → nc_qrcodeavailable
```

#### Step 4: Data Transformation Rules
```yaml
During Import Processing:

Text Fields:
├── Trim whitespace from all text fields
├── Convert customer code to uppercase
├── Standardize email formats (lowercase)
└── Remove special characters from names

Choice Fields:
├── Region: Convert to standard values (BK, NO, NE, etc.)
├── Yes/No fields: Convert TRUE/FALSE, 1/0 to Yes/No
└── Handle empty choice fields as null

Email Fields:
├── Validate email format during import
├── Skip invalid email addresses (log warning)
├── Ensure at least one email per required category
└── Convert to lowercase for consistency
```

## QR Code Validation Import

### QR Code Availability Template

#### Template: `QR_Code_Validation_Template.xlsx`

```excel
Column Structure:
A: Customer Code
B: Customer Name
C: QR Code File Name
D: File Exists
E: File Size (KB)
F: Last Modified Date
G: Validation Status

Sample Data:
A: 200120
B: ABC Company Limited
C: 200120_QR.png
D: Yes
E: 15.7
F: 2025-09-29
G: Valid
```

### QR Code Validation Process
```yaml
Validation Steps:
1. Check SharePoint QR Code folder
2. Match customer code to QR file naming convention
3. Verify file accessibility and size
4. Update nc_qrcodeavailable flag in customer records
5. Generate report of missing QR codes
```

## Historical Transaction Import (Optional)

### Transaction History Template

#### Template: `Transaction_History_Import_Template.xlsx`

```excel
Column Structure:
A: Customer Code
B: Document Number
C: Document Type
D: Document Date
E: Net Due Date
F: Amount
G: Text
H: Reference
I: Record Type
J: Process Date

Sample Data:
A: 200120
B: 9974698958
C: DR
D: 2025-09-26
E: 2025-09-27
F: 30213.31
G:
H: CMI2509000000507
I: Transaction
J: 2025-09-29
```

## Power Automate Import Flow

### Automated Customer Import Flow

#### Flow Name: "Customer Master Data Import"

```yaml
Trigger: Manual trigger or SharePoint file detection

Flow Steps:
1. Detect Excel file in designated SharePoint folder
2. Parse Excel data using "List rows present in a table"
3. For each row:
   a. Validate required fields
   b. Check for existing customer (by customer code)
   c. Create or update customer record
   d. Log import results
4. Send completion email with import summary
5. Move processed file to archive folder
```

#### Flow Implementation Details

```javascript
// Customer lookup by code
customers('nc_customercode eq \'' + item()?['Customer Code'] + '\'')

// Create customer record
{
  "nc_customercode": item()?['Customer Code'],
  "nc_customername": item()?['Customer Name'],
  "nc_region": item()?['Region'],
  "nc_customeremail1": item()?['Customer Email 1'],
  "nc_customeremail2": item()?['Customer Email 2'],
  "nc_customeremail3": item()?['Customer Email 3'],
  "nc_customeremail4": item()?['Customer Email 4'],
  "nc_salesemail1": item()?['Sales Email 1'],
  "nc_salesemail2": item()?['Sales Email 2'],
  "nc_salesemail3": item()?['Sales Email 3'],
  "nc_salesemail4": item()?['Sales Email 4'],
  "nc_salesemail5": item()?['Sales Email 5'],
  "nc_arbackupemail1": item()?['AR Backup Email 1'],
  "nc_arbackupemail2": item()?['AR Backup Email 2'],
  "nc_arbackupemail3": item()?['AR Backup Email 3'],
  "nc_arbackupemail4": item()?['AR Backup Email 4'],
  "nc_isactive": if(equals(item()?['Is Active'], 'Yes'), true, false),
  "nc_qrcodeavailable": if(equals(item()?['QR Code Available'], 'Yes'), true, false)
}

// Email validation function
and(contains(item()?['Customer Email 1'], '@'), greater(length(item()?['Customer Email 1']), 5))

// Duplicate check logic
if(empty(outputs('Get_Customer')?['body/value']), 'Create', 'Update')
```

## Data Quality Checks

### Pre-Import Validation

#### Validation Checklist
```yaml
File Structure:
├── ✓ Correct column headers
├── ✓ Required columns present
├── ✓ Data types match expectations
├── ✓ No completely empty rows
└── ✓ File size reasonable (<10MB)

Data Quality:
├── ✓ Customer codes unique
├── ✓ Required emails populated
├── ✓ Valid email formats
├── ✓ Region codes valid
├── ✓ No special characters in critical fields
└── ✓ Customer names not truncated
```

### Post-Import Validation

#### Validation Queries
```sql
-- Check for missing required emails
SELECT nc_customercode, nc_customername
FROM nc_customers
WHERE nc_customeremail1 IS NULL
   OR nc_salesemail1 IS NULL
   OR nc_arbackupemail1 IS NULL

-- Check for invalid email formats
SELECT nc_customercode, nc_customeremail1
FROM nc_customers
WHERE nc_customeremail1 NOT LIKE '%@%'
   OR LEN(nc_customeremail1) < 5

-- Check for duplicate customer codes
SELECT nc_customercode, COUNT(*) as DuplicateCount
FROM nc_customers
GROUP BY nc_customercode
HAVING COUNT(*) > 1

-- Verify region distribution
SELECT nc_region, COUNT(*) as CustomerCount
FROM nc_customers
GROUP BY nc_region
ORDER BY CustomerCount DESC
```

## Error Handling and Logging

### Import Error Types

#### Critical Errors (Stop Import)
```yaml
Error Scenarios:
├── Missing required field (Customer Code, Name)
├── Invalid customer code format
├── Duplicate customer code in import file
├── Missing all required email categories
└── File corruption or access issues

Resolution Actions:
├── Stop import process
├── Generate detailed error report
├── Notify system administrator
├── Provide corrected template
└── Schedule retry after data correction
```

#### Warning Errors (Continue Import)
```yaml
Warning Scenarios:
├── Missing optional email addresses
├── QR code file not found
├── Invalid region code (use default)
├── Email format warnings
└── Name field truncation

Resolution Actions:
├── Log warning with row details
├── Apply default values where appropriate
├── Continue with import
├── Generate warning report
└── Schedule data cleanup task
```

### Import Logging

#### Log Structure
```json
{
  "importBatchId": "20250929_143000_CustomerImport",
  "fileName": "Customer_Master_Import_20250929.xlsx",
  "startTime": "2025-09-29T14:30:00Z",
  "endTime": "2025-09-29T14:35:00Z",
  "status": "Completed",
  "totalRows": 85,
  "successfulImports": 82,
  "errors": 0,
  "warnings": 3,
  "summary": {
    "newCustomers": 75,
    "updatedCustomers": 7,
    "skippedRows": 3
  },
  "warningDetails": [
    {
      "row": 15,
      "customerCode": "200125",
      "issue": "Missing QR code file",
      "resolution": "Set QR Available to false"
    }
  ]
}
```

## Import Schedule and Maintenance

### Regular Import Schedule
```yaml
Customer Data Updates:
├── Full refresh: Monthly (1st weekend)
├── Incremental updates: Weekly (Sunday 6 AM)
├── Emergency updates: As needed
└── QR code validation: Weekly (Monday 7 AM)

Archive Strategy:
├── Keep import files: 12 months
├── Archive old versions: Yearly
├── Backup before major imports
└── Document all changes
```

### Data Maintenance Tasks

#### Weekly Tasks
```yaml
Maintenance Checklist:
├── Verify customer email deliverability
├── Update QR code availability flags
├── Check for inactive customers
├── Validate new email addresses
└── Review import logs for patterns
```

#### Monthly Tasks
```yaml
Comprehensive Review:
├── Customer data quality audit
├── Email address cleanup
├── Regional distribution analysis
├── QR code file management
└── Archive old import files
```

---

**Template Status:** Ready for Use
**Estimated Import Time:** 30-60 minutes for 100 customers
**Dependencies:** Dataverse tables created, SharePoint access configured