# Field Name Reference Guide

## ⚠️ CRITICAL: Production Field Names

This document contains the **ACTUAL field names used in production**. These differ from `database_schema.md` which uses placeholder names.

**Always use this reference when generating Power Apps code.**

---

## Customer Table: `[THFinanceCashCollection]Customers`

### Solution Publisher Prefix: `cr7bb_`

### Primary Key
- `cr7bb_customerid` (GUID)

### Basic Information
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Customer Code | `cr7bb_customercode` | Text(20) | Yes |
| Customer Name | `cr7bb_customername` | Text(255) | Yes |
| Region | `nc_region` | Choice | Yes |

**⚠️ Special Note on Region:**
- **Logical name**: `nc_region` (different publisher prefix than other fields)
- **Display name** (for Patch operations): `Region`
- **Items source**: `Choices('Region Choice')`
- **Note**: This field uses `nc_` prefix, NOT `cr7bb_` like other fields

### Customer Email Addresses
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Customer Email 1 | `cr7bb_customeremail1` | Email | Yes |
| Customer Email 2 | `cr7bb_customeremail2` | Email | No |
| Customer Email 3 | `cr7bb_customeremail3` | Email | No |
| Customer Email 4 | `cr7bb_customeremail4` | Email | No |

### Sales Team Email Addresses
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Sales Email 1 | `cr7bb_salesemail1` | Email | Yes |
| Sales Email 2 | `cr7bb_salesemail2` | Email | No |
| Sales Email 3 | `cr7bb_salesemail3` | Email | No |
| Sales Email 4 | `cr7bb_salesemail4` | Email | No |
| Sales Email 5 | `cr7bb_salesemail5` | Email | No |

### AR Backup Email Addresses
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| AR Backup Email 1 | `cr7bb_arbackupemail1` | Email | Yes |
| AR Backup Email 2 | `cr7bb_arbackupemail2` | Email | No |
| AR Backup Email 3 | `cr7bb_arbackupemail3` | Email | No |
| AR Backup Email 4 | `cr7bb_arbackupemail4` | Email | No |

---

## Transaction Table: `[THFinanceCashCollection]Transactions`

### Solution Publisher Prefix: `cr7bb_`

### Primary Key
- `cr7bb_transactionid` (GUID)

### Basic Transaction Information
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Customer | `cr7bb_customer` | Lookup | Yes |
| Record Type | `cr7bb_recordtype` | Choice | Yes |
| Document Number | `cr7bb_documentnumber` | Text(50) | Conditional* |
| Assignment | `cr7bb_assignment` | Text(100) | No |
| Document Type | `cr7bb_documenttype` | Text(10) | No |
| Document Date | `cr7bb_documentdate` | Date | Conditional* |
| Net Due Date | `cr7bb_netduedate` | Date | Conditional* |
| Arrears Days | `cr7bb_arrearsdays` | Whole Number | No |
| Amount | `cr7bb_amountlocalcurrency` | Currency | Yes |
| Text | `cr7bb_textfield` | Text(500) | No |
| Reference | `cr7bb_reference` | Text(100) | No |

### Processing Fields
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Transaction Type | `cr7bb_transactiontype` | Choice | Conditional* |
| Is Excluded | `cr7bb_isexcluded` | Yes/No | Yes |
| Exclude Reason | `cr7bb_excludereason` | Text(100) | No |
| Day Count | `cr7bb_daycount` | Whole Number | Conditional* |
| Transaction Process Date | `cr7bb_transactionprocessdate` | Date | Yes |
| Process Batch | `cr7bb_processbatch` | Text(50) | Yes |
| Row Number | `cr7bb_rownumber` | Whole Number | Yes |
| Is Processed | `cr7bb_isprocessed` | Yes/No | Yes |
| Email Sent | `cr7bb_emailsent` | Yes/No | Yes |
| Parent Amount | `cr7bb_parentcustomeramount` | Currency | No |

**⚠️ Choice Fields and Their Global Choice Names:**
- **Record Type** (`cr7bb_recordtype`): Use `Choices('Record Type Choice')`
  - Transaction (676180000), Summary (676180001), Header (676180002)
- **Transaction Type** (`cr7bb_transactiontype`): Use `Choices('Transaction Type Choice')`
  - CN - Credit Note (676180000), DN - Debit Note (676180001)

**Note**: * = Required for Transaction record type only

---

## Email Log Table: `[THFinanceCashCollection]Emaillogs`

### Solution Publisher Prefix: `cr7bb_`

### Primary Key
- `cr7bb_thfinancecashcollectionemaillogid` (GUID)

### Email Log Fields
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Customer | `cr7bb_customer` | Lookup | Yes |
| Process Date | `cr7bb_processdate` | DateTime | Yes |
| Email Subject | `cr7bb_emailsubject` | Text(500) | Yes |
| Email Body Preview | `cr7bb_emailbodypreview` | Multiline Text | Yes |
| Total Amount | `cr7bb_totalamount` | Currency | Yes |
| Approval Status | `cr7bb_approvalstatus` | Choice | Yes |
| Send Status | `cr7bb_sendstatus` | Choice | Yes |
| Sent Date Time | `cr7bb_sentdatetime` | DateTime | No |
| Recipient Emails | `cr7bb_recipientemails` | Text | Yes |
| CC Emails | `cr7bb_ccemails` | Text | Yes |
| Max Day Count | `cr7bb_maxdaycount` | Whole Number | Yes |
| Email Template | `cr7bb_emailtemplate` | Text | Yes |
| QR Code Included | `cr7bb_qrcodeincluded` | Yes/No | Yes |
| Error Message | `cr7bb_errormessage` | Text | No |

**⚠️ Choice Fields and Values:**

**Approval Status** (`cr7bb_approvalstatus`):
| Value | Label | Numeric |
|-------|-------|---------|
| `ApprovalStatusChoice.Pending` | Pending | 676180000 |
| `ApprovalStatusChoice.Approved` | Approved | 676180001 |
| `ApprovalStatusChoice.Rejected` | Rejected | 676180002 |

**Send Status** (`cr7bb_sendstatus`):
| Value | Label | Numeric |
|-------|-------|---------|
| `'Send Status Choice'.Success` | Success | 676180000 |
| `'Send Status Choice'.Failed` | Failed | 676180001 |
| `'Send Status Choice'.Pending` | Pending | 676180002 |

**⚠️ Important Flow Behavior:**
- Email Engine creates EmailLogs with **ApprovalStatus = Approved** (auto-approved)
- Email Engine creates EmailLogs with **SendStatus = Pending** (waiting for send)
- Email Sending Flow updates **SendStatus** to Success/Failed after send attempt

**⚠️ CRITICAL - EmailLog Process Date is DateTime:**
```yaml
# ❌ WRONG - Causes "Incompatible types for comparison" warning (DateTime vs Text)
Filter('[THFinanceCashCollection]Emaillogs', cr7bb_processdate = Text(Today(), "yyyy-mm-dd"))

# ✅ CORRECT - Use DateTime range comparison (delegable)
Filter('[THFinanceCashCollection]Emaillogs',
    cr7bb_processdate >= Today() && cr7bb_processdate < DateAdd(Today(), 1, TimeUnit.Days))

# ✅ CORRECT - With variable
Filter('[THFinanceCashCollection]Emaillogs',
    cr7bb_processdate >= _selectedDate && cr7bb_processdate < DateAdd(_selectedDate, 1, TimeUnit.Days))
```

**⚠️ DIFFERENT TYPES - Same Field Name, Different Tables:**
| Table | Field | Type | Comparison Pattern |
|-------|-------|------|-------------------|
| EmailLogs | `cr7bb_processdate` | **DateTime** | `>= _date && < DateAdd(_date, 1, Days)` |
| ProcessLogs | `cr7bb_processdate` | **Text** | `= Text(_date, "yyyy-mm-dd")` |

**Note:** This is different from **ProcessLog.cr7bb_processdate** which is TEXT type!

**⚠️ Lookup Field Access Pattern:**
```yaml
ThisItem.Customer.'[THFinanceCashCollection]Customer'  # To get GUID for lookup
```

---

## Process Log Table: `[THFinanceCashCollection]Process Logs`

### Solution Publisher Prefix: `cr7bb_`

### Primary Key
- `cr7bb_thfinancecashcollectionprocesslogid` (GUID)

### Process Log Fields
| Display Name | Field Name | Type | Required |
|--------------|------------|------|----------|
| Process Date | `cr7bb_processdate` | **Text (Primary Name)** | Yes |
| Start Time | `cr7bb_starttime` | DateTime | Yes |
| End Time | `cr7bb_endtime` | DateTime | No |
| Status | `cr7bb_status` | Choice | Yes |
| Process Type | `cr7bb_processtype` | Text (50) | No |
| Summary | `cr7bb_summary` | Multiline Text (2000) | No |
| Transactions Processed | `cr7bb_transactionsprocessed` | Whole Number | Yes |
| Transactions Excluded | `cr7bb_transactionsexcluded` | Whole Number | Yes |
| Emails Failed | `cr7bb_emailsfailed` | Whole Number | Yes |

**Status Choice Values** (`'Status Choice'`):
| Value | Label | Numeric |
|-------|-------|---------|
| `'Status Choice'.Running` | Running | 676180000 |
| `'Status Choice'.Completed` | Completed | 676180001 |
| `'Status Choice'.Failed` | Failed | 676180002 |
| `'Status Choice'.'Completed with errors'` | Completed with errors | 676180003 |

**⚠️ CRITICAL - Use Choice Comparison, NOT String:**
```yaml
# ❌ WRONG - Causes "Incompatible types for comparison" warning
If(_processLog.cr7bb_status = "Completed", ...)

# ✅ CORRECT - Use choice reference
If(_processLog.cr7bb_status = 'Status Choice'.Completed, ...)
```

**Process Type Values (Text):**
- `DailySync` - Daily transaction sync from Power BI
- `WorkingDayGeneration` - Initial/regenerate WorkingDayCalendar
- `WorkingDayRecalc` - Recalculate after holiday change
- `EmailSend` - Email sending process

**⚠️ CRITICAL - Process Date is TEXT, not Date:**
```yaml
# ❌ WRONG - Causes type mismatch error
Filter('[THFinanceCashCollection]Process Logs', cr7bb_processdate = Today())

# ✅ CORRECT - Convert Today() to text format
Filter('[THFinanceCashCollection]Process Logs', cr7bb_processdate = Text(Today(), "yyyy-mm-dd"))
```

---

## Usage Examples

### Table Control - FieldName Property
```yaml
Children:
  - CustomerCode:
      Control: TableDataField@1.5.0
      Properties:
        FieldDisplayName: ="Customer Code"
        FieldName: ="cr7bb_customercode"  # Use display name with prefix
        FieldType: ="s"

  - Region:
      Control: TableDataField@1.5.0
      Properties:
        FieldDisplayName: ="Region"
        FieldName: ="nc_region"  # Different prefix than other fields
        FieldType: ="l"
```

### Filter/Sort Operations
```yaml
Items: |-
  =Sort(
    '[THFinanceCashCollection]Customers',
    cr7bb_customercode,  # Use display name
    SortOrder.Ascending
  )
```

### ComboBox for Choice Fields
```yaml
CustomerFormRegion:
  Control: ComboBox@0.0.51
  Properties:
    # Reference the choice definition directly
    Items: =Choices('Region Choice')

    # Default selection with LookUp
    DefaultSelectedItems: |-
      =If(
          IsBlank(currentSelectedCustomer.Region),
          Blank(),
          LookUp(
              Choices('Region Choice'),
              Value = currentSelectedCustomer.Region
          )
      )
```

### Patch Operations (Create/Update)
```yaml
OnSelect: |-
  =Patch(
    '[THFinanceCashCollection]Customers',
    currentSelectedCustomer,
    {
      cr7bb_customercode: CustomerFormCustomerCode.UpdatedValue,
      cr7bb_customername: CustomerFormCustomerName.UpdatedValue,
      Region: CustomerFormRegion.Selected.Value,  # Logical name, no prefix
      cr7bb_customeremail1: CustomerFormCustomerEmail1.UpdatedValue,
      cr7bb_salesemail1: CustomerFormSalesEmail1.UpdatedValue,
      cr7bb_arbackupemail1: CustomerFormARBackupEmail1.UpdatedValue
    }
  )
```

### Component Value Binding
```yaml
CustomerFormCustomerCode:
  Control: CanvasComponent
  ComponentName: cmpEditableText
  Properties:
    TitleText: ="Customer Code"
    Value: =currentSelectedCustomer.cr7bb_customercode  # Display name
    isRequired: =true
```

---

## Verification Checklist

Before writing any Power Apps code:
- [ ] Check this document for actual field names
- [ ] Verify in exported YAML: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
- [ ] Use `cr7bb_` prefix for all standard fields
- [ ] Use logical name (no prefix) for choice fields in Patch
- [ ] Use display name for choice fields in Table FieldName
- [ ] Double-check capitalization (e.g., `Region` vs `region`)

---

## ⚠️ Lookup Field Comparison Pattern

When comparing Dataverse lookup fields in Filter operations, you must dereference to the table GUID.

**❌ WRONG** (comparing lookup objects directly):
```yaml
Filter(
    '[THFinanceCashCollection]Transactions',
    Customer = _selectedEmail.Customer
)
# Error: Incompatible types for comparison
```

**✅ CORRECT** (dereference to table GUID):
```yaml
Filter(
    '[THFinanceCashCollection]Transactions',
    Customer.'[THFinanceCashCollection]Customer' = _selectedEmail.Customer.'[THFinanceCashCollection]Customer'
)
```

**Pattern**: `LookupField.'[SolutionPrefix]TableName'`

**Examples**:
- `Customer.'[THFinanceCashCollection]Customer'` - Customer lookup
- `Transaction.'[THFinanceCashCollection]Transaction'` - Transaction lookup

**Key Points**:
- Both sides of comparison must use same dereference syntax
- Table name is singular (matches Dataverse logical name)
- This returns the GUID for comparison

---

## Common Mistakes to Avoid

❌ **WRONG** (using incorrect field names):
```yaml
FieldName: ="nc_customercode"
cr7bb_region: CustomerFormRegion.Selected
```

✅ **CORRECT** (using actual production names):
```yaml
FieldName: ="cr7bb_customercode"
Region: CustomerFormRegion.Selected.Value  # Region uses nc_region logical name
```

---

## Update History

- **2025-09-30**: Initial creation based on actual production exports
- **2025-09-30**: Added EmailLog and Process Log table field references
- **Source**: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`, `customizations.xml`

**Last Verified**: September 30, 2025
**Status**: Production-accurate field names