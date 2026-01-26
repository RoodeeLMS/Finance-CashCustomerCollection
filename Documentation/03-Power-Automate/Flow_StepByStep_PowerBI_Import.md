# Step-by-Step: Daily SAP Import with Power BI + WorkingDayCalendar

**Date**: January 13, 2026
**Purpose**: Replace Excel-based import with Power BI DAX query and calculate arrear days using WorkingDayCalendar
**Prerequisites**:
- Power BI POC confirmed working
- WorkingDayCalendar table populated with 2025-2026 data

---

## Overview

**Current Flow (Phase 1)**:
```
Excel File → Parse → Create Transactions → cr7bb_daycount = SAP's calendar days
```

**New Flow (Phase 2)**:
```
Power BI DAX → Parse JSON → Create Transactions → cr7bb_daycount = Working days
```

---

## Architecture Changes

| Component | Phase 1 (Current) | Phase 2 (New) |
|-----------|-------------------|---------------|
| **Data Source** | Excel file from SharePoint | Power BI DAX query |
| **Arrear Days** | SAP's `ArrearsByNetDueDate` (calendar) | `TodayWDN - DueDateWDN` (working) |
| **Exclusion Logic** | Power Automate checks ItemText | **Pre-filtered in Power BI** |
| **File Management** | Rename to `_Processed` | Not needed |
| **Refresh Frequency** | Once daily (file upload) | Real-time from SAP |

---

## Step 1: Open the Flow

1. Go to **make.powerautomate.com**
2. Navigate to **Solutions** → **THFinanceCashCollection**
3. Find: `[THFinanceCashCollection] Daily SAP Transaction Import`
4. Click **Edit**

---

## Step 2: Add Variable - varTodayWDN

**Location**: After existing `Initialize variable` actions

1. Click **+** after the last Initialize variable
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varTodayWDN
   Type: Integer
   Value: 0
   ```
4. Rename action to: `Initialize_varTodayWDN`

---

## Step 3: Get Today's Working Day Number

**Location**: After variable initialization, before data retrieval

1. Click **+** after `Initialize_varTodayWDN`
2. Search and select **List rows** (Dataverse)
3. Configure:
   ```
   Table name: WorkingDayCalendars
   Filter rows: cr7bb_name eq '@{formatDateTime(utcNow(), 'yyyy-MM-dd')}'
   Row count: 1
   ```
4. Rename action to: `Get_Today_WDN`

---

## Step 4: Set Today's WDN Variable

**Location**: After `Get_Today_WDN`

1. Click **+** after `Get_Today_WDN`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varTodayWDN
   Value: @{coalesce(first(outputs('Get_Today_WDN')?['body/value'])?['cr7bb_workingdaynumber'], 0)}
   ```
4. Rename action to: `Set_varTodayWDN`

> **Note**: `coalesce` returns 0 if today is a non-working day (weekend/holiday).

---

## Step 5: Replace Excel Actions with Power BI Query

**Location**: Remove or disable all Excel-related actions

### 5a. Remove/Disable These Actions:
- `Get file content` (SharePoint - Excel file)
- `Run script` (Office Scripts - Parse Excel)
- `Parse JSON` (Excel output)
- Any file path/name references

### 5b. Add Power BI Action:

1. Click **+** after `Set_varTodayWDN`
2. Search for: `Power BI`
3. Select: **Run a query against a dataset**
4. Configure:

| Field | Value |
|-------|-------|
| **Workspace** | `[ICR] IT Finance & Legal` |
| **Dataset** | `Finance Customer Line Item For ...` (select from dropdown) |
| **Query Text** | See DAX query below |

5. Rename action to: `Get_Transactions_From_PowerBI`

### 5c. DAX Query:

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS(
        'CCC: Customer Line Item',
        "CustomerCode", [KUNNR],
        "DocumentNumber", [BELNR],
        "DocumentType", [BLART],
        "DocumentDate", [BLDAT],
        "NetDueDate", [NETDT],
        "Amount", [S_DMBTR],
        "ItemText", [SGTXT],
        "Reference", [XBLNR],
        "IsActiveCustomer", [IsActiveCustomer]
    ),
    AND(
        NOT(ISBLANK([CustomerCode])),
        [IsActiveCustomer] = TRUE
    )
)
```

> **Filter Logic:**
> - `IsActiveCustomer = TRUE` - Only customers linked to Dataverse active customer list
> - `NOT(ISBLANK([CustomerCode]))` - Must have valid customer code
> - **Note**: Power BI data already shows only outstanding items (cleared items are removed from source)

---

## Step 6: Create Process Log

**Location**: After `Get_Transactions_From_PowerBI`

1. Click **+** after Power BI action
2. Search and select **Add a new row** (Dataverse)
3. Configure:
   ```
   Table name: ProcessLogs
   cr7bb_processdate: @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
   cr7bb_status: In Progress (676180001)
   cr7bb_starttime: @{utcNow()}
   cr7bb_processtype: DailySync
   cr7bb_transactionsprocessed: 0
   cr7bb_transactionsexcluded: 0
   cr7bb_emailsfailed: 0
   ```
4. Rename action to: `Create_Process_Log`

---

## Step 7: Store Process Log ID

**Location**: After `Create_Process_Log`

1. Click **+** after `Create_Process_Log`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varProcessLogID
   Value: @{outputs('Create_Process_Log')?['body/cr7bb_processlogid']}
   ```
4. Rename action to: `Set_varProcessLogID`

---

## Step 8: Apply to Each Transaction

**Location**: After `Set_varProcessLogID`

1. Click **+** after `Set_varProcessLogID`
2. Search and select **Apply to each**
3. Configure:
   ```
   Select an output from previous steps: @{outputs('Get_Transactions_From_PowerBI')?['body/firstTableRows']}
   ```
4. Rename action to: `Apply_to_each_Transaction`

---

## Step 9: Inside Loop - Get DueDate's WDN

**Location**: Inside `Apply_to_each_Transaction`

1. Expand `Apply_to_each_Transaction`
2. Click **+** (Add an action)
3. Search and select **List rows** (Dataverse)
4. Configure:
   ```
   Table name: WorkingDayCalendars
   Filter rows: cr7bb_name eq '@{formatDateTime(items('Apply_to_each_Transaction')?['[NetDueDate]'], 'yyyy-MM-dd')}'
   Row count: 1
   ```
5. Rename action to: `Get_DueDate_WDN`

---

## Step 10: Inside Loop - Calculate Arrear Days

**Location**: Inside loop, after `Get_DueDate_WDN`

1. Click **+** after `Get_DueDate_WDN`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{sub(
     variables('varTodayWDN'),
     coalesce(
       first(outputs('Get_DueDate_WDN')?['body/value'])?['cr7bb_workingdaynumber'],
       0
     )
   )}
   ```
4. Rename action to: `Calculated_ArrearDays`

> **Note**: All dates have WDN values. Non-working days inherit the **NEXT** working day's WDN, so calculations work correctly for any due date (no null checks needed).

---

## Step 11: Inside Loop - Determine Transaction Type

**Location**: Inside loop, after `Calculated_ArrearDays`

1. Click **+** after `Calculated_ArrearDays`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{if(
     less(float(items('Apply_to_each_Transaction')?['Amount']), 0),
     'CN',
     'DN'
   )}
   ```
4. Rename action to: `Compose_TransactionType`

---

## Step 12: Inside Loop - Create Transaction

**Location**: Inside loop, after `Compose_TransactionType`

> **Note**: Exclusion logic (Paid, Partial Payment, รักษาตลาด, Bill credit 30 days) is **pre-filtered in Power BI**. No need to check in Power Automate.

1. Click **+** after `Compose_TransactionType`
2. Search and select **Add a new row** (Dataverse)
3. Configure:

```
Table name: Transactions

Fields:
- cr7bb_customercode: @{items('Apply_to_each_Transaction')?['CustomerCode']}
- cr7bb_Customer (lookup): cr7bb_thfinancecashcollectioncustomers(cr7bb_customercode='@{items('Apply_to_each_Transaction')?['CustomerCode']}')
- cr7bb_documentnumber: @{items('Apply_to_each_Transaction')?['DocumentNumber']}
- cr7bb_documenttype: @{items('Apply_to_each_Transaction')?['DocumentType']}
- cr7bb_documentdate: @{items('Apply_to_each_Transaction')?['DocumentDate']}
- cr7bb_netduedate: @{items('Apply_to_each_Transaction')?['NetDueDate']}
- cr7bb_amountlocalcurrency: @{float(items('Apply_to_each_Transaction')?['Amount'])}
- cr7bb_textfield: @{items('Apply_to_each_Transaction')?['ItemText']}
- cr7bb_referenceinformation: @{items('Apply_to_each_Transaction')?['Reference']}
- cr7bb_transactiontype: @{outputs('Compose_TransactionType')}
- cr7bb_daycount: @{outputs('Calculated_ArrearDays')}
- cr7bb_arrearsdays: @{outputs('Calculated_ArrearDays')}
- cr7bb_processbatch: @{variables('varProcessLogID')}
- cr7bb_transactionprocessdate: @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
- cr7bb_isexcluded: false
- cr7bb_isprocessed: false
- cr7bb_emailsent: false
```

> **Note**: The `cr7bb_Customer` lookup uses **OData bind with alternate key** syntax:
> - This requires `cr7bb_customercode` to be set as an **alternate key** on the Customers table
> - No separate lookup action needed - Dataverse resolves the customer automatically
> - If customercode doesn't exist, the row creation will fail (handle with error handling)

4. Rename action to: `Create_Transaction`

---

## Step 13: After Loop - Update Process Log Status

**Location**: After `Apply_to_each_Transaction`

1. Click **+** after the Apply to each
2. Search and select **Update a row** (Dataverse)
3. Configure:
   ```
   Table name: ProcessLogs
   Row ID: @{variables('varProcessLogID')}
   cr7bb_status: Completed (676180002)
   cr7bb_endtime: @{utcNow()}
   cr7bb_transactionsprocessed: @{length(outputs('Get_Transactions_From_PowerBI')?['body/firstTableRows'])}
   cr7bb_summary: Imported @{length(outputs('Get_Transactions_From_PowerBI')?['body/firstTableRows'])} transactions from Power BI
   ```
4. Rename action to: `Update_Process_Log_Complete`

---

## Step 14: Add Error Handling (Optional but Recommended)

**Location**: Configure run after for `Update_Process_Log_Complete`

1. Click **...** on `Update_Process_Log_Complete`
2. Select **Configure run after**
3. Check: ✅ is successful, ✅ has failed
4. Add a **Condition** to check for failure:
   ```
   Condition: result('Apply_to_each_Transaction') contains 'Failed'
   ```
5. If yes: Update Process Log with status = Failed

---

## Step 15: Save and Test

1. Click **Save**
2. Click **Test** → **Manually**
3. Verify:
   - `varTodayWDN` is set correctly
   - Power BI returns data
   - Transactions created with correct `cr7bb_daycount` (working days)

---

## Flow Diagram (New Architecture)

```
[Trigger: 8:00 AM Daily]
        │
        ▼
[Initialize Variables]
  + varTodayWDN = 0
  + varProcessLogID = ""
        │
        ▼
[Get Today's WDN] ← WorkingDayCalendar
  Query: WHERE nc_name = today
        │
        ▼
[Set varTodayWDN]
        │
        ▼
[Run DAX Query] ← Power BI Dataset  ★ NEW
  Returns: CustomerCode, DocumentNumber, Amount, NetDueDate, etc.
        │
        ▼
[Create Process Log]
        │
        ▼
[Set varProcessLogID]
        │
        ▼
[Apply to Each Transaction]
        │
        ├──► [Get_DueDate_WDN] ← WorkingDayCalendar
        │      Query: WHERE nc_name = NetDueDate
        │
        ├──► [Calculated_ArrearDays]
        │      = varTodayWDN - DueDateWDN
        │
        ├──► [Compose_TransactionType]
        │      CN if Amount < 0, else DN
        │
        └──► [Create_Transaction]
               cr7bb_daycount = Calculated_ArrearDays
               cr7bb_Customer = OData bind by customercode
               (Exclusion pre-filtered in Power BI)
        │
        ▼
[Update Process Log → Complete]
```

---

## Removed Components (No Longer Needed)

| Component | Reason |
|-----------|--------|
| SharePoint Get file content | Power BI replaces file-based import |
| Office Script Run script | No Excel parsing needed |
| Parse JSON (Excel output) | Power BI returns JSON directly |
| File rename to `_Processed` | No file management needed |
| File not found error handling | No file to check |

---

## Field Mapping: Power BI → Dataverse

| Power BI Column | Dataverse Field | Type |
|-----------------|-----------------|------|
| `CustomerCode` (KUNNR) | `cr7bb_customercode` | Text |
| `CustomerCode` (KUNNR) | `cr7bb_Customer` | Lookup (via OData bind) |
| `DocumentNumber` (BELNR) | `cr7bb_documentnumber` | Text |
| `DocumentType` (BLART) | `cr7bb_documenttype` | Text |
| `DocumentDate` (BLDAT) | `cr7bb_documentdate` | Date |
| `NetDueDate` (NETDT) | `cr7bb_netduedate` | Date |
| `Amount` (S_DMBTR) | `cr7bb_amountlocalcurrency` | Decimal |
| `ItemText` (SGTXT) | `cr7bb_textfield` | Text |
| `Reference` (XBLNR) | `cr7bb_referenceinformation` | Text |
| *(Calculated)* | `cr7bb_daycount` | Integer |
| *(Calculated)* | `cr7bb_arrearsdays` | Integer |
| *(Calculated)* | `cr7bb_transactiontype` | Text |
| *(ProcessLog ID)* | `cr7bb_processbatch` | Text |
| *(Today's date)* | `cr7bb_transactionprocessdate` | Date |

---

## Verification Checklist

After running the flow, verify in Dataverse:

| Check | Expected |
|-------|----------|
| Process Log created | Status = Completed, ProcessType = "DailySync" |
| Transaction count matches | Power BI row count = Dataverse transaction count |
| Customer linked | Transaction's cr7bb_Customer field populated (click to see Customer record) |
| DayCount = 0 | Transaction with DueDate = Today |
| DayCount = 1 | Transaction with DueDate = Yesterday (working day) |
| DayCount = 1 (not 3) | Transaction with DueDate = Friday (if today is Monday) |
| TransactionType | CN for negative amounts, DN for positive |
| No excluded items | Power BI pre-filters (paid, partial payment, etc.) |

---

## Troubleshooting

### Error: "Dataset not found"
- Verify workspace access: `[ICR] IT Finance & Legal`
- Check dataset name spelling
- Try selecting from dropdown instead of typing

### Error: "Query failed"
- Table name might be different in Power BI
- Try `INFO.TABLES()` query first to see available tables
- Check column names match

### Error: "The template language expression cannot be evaluated"
- Action name mismatch
- Verify exact action names in `outputs('...')` references

### Error: "Invalid type. Expected Integer but got Null"
- WDN lookup returned no record (date not in WorkingDayCalendar)
- Solution: Use `coalesce(..., 0)` as fallback
- Note: With single-pass buffered generation, all dates have WDN (non-working days inherit NEXT working day's WDN)

### Performance: Flow is slow
- ~500 transactions with individual WDN lookups
- Accept latency (recommended for daily batch)
- Alternative: Pre-fetch all WDN into array (complex)

### Power BI returns no data
- Check if dataset is refreshed
- Verify DAX query in Power BI Desktop first
- Check filter conditions

### Error: "Resource not found" on Create_Transaction
- CustomerCode from Power BI doesn't exist in Customers table
- The OData bind alternate key lookup failed
- Solution: Ensure Customer master data is synced before transaction import
- Check for leading zeros: SAP KUNNR may have leading zeros stripped

---

## Comparison: Excel vs Power BI

| Aspect | Excel (Phase 1) | Power BI (Phase 2) |
|--------|-----------------|-------------------|
| **Data Freshness** | File uploaded daily | Real-time from SAP |
| **Setup Complexity** | SharePoint + Office Script | Premium connector |
| **Maintenance** | File management, naming | DAX query only |
| **Error Handling** | File not found, corrupt | Connection/query errors |
| **Scalability** | File size limits | Large datasets OK |
| **Cost** | Standard connectors | Power BI Premium required |

---

## Next Steps After Implementation

1. **Test with production data** - Run flow and verify all transactions imported correctly
2. **Compare arrear days** - Spot-check: Working days should be fewer than calendar days
3. **Monitor for errors** - Check Process Log for failures
4. **Update Collections Engine** - Ensure it reads new `cr7bb_daycount` values
5. **Decommission Excel import** - Turn off old scheduled import (if separate flow)

---

**Status**: Ready for implementation

---

## Quick Reference: Expression Snippets

### Get Today as yyyy-MM-dd:
```
@{formatDateTime(utcNow(), 'yyyy-MM-dd')}
```

### Get WDN from WorkingDayCalendar result:
```
@{coalesce(first(outputs('Get_Today_WDN')?['body/value'])?['cr7bb_workingdaynumber'], 0)}
```

### Calculate Arrear Days:
```
@{sub(variables('varTodayWDN'), coalesce(first(outputs('Get_DueDate_WDN')?['body/value'])?['cr7bb_workingdaynumber'], 0))}
```

### Check if Amount is negative (CN):
```
@{if(less(float(items('Apply_to_each_Transaction')?['Amount']), 0), 'CN', 'DN')}
```

### Get Power BI rows:
```
@{outputs('Get_Transactions_From_PowerBI')?['body/firstTableRows']}
```

### Get row count:
```
@{length(outputs('Get_Transactions_From_PowerBI')?['body/firstTableRows'])}
```

### Link Customer via OData bind (alternate key):
```
cr7bb_thfinancecashcollectioncustomers(cr7bb_customercode='@{items('Apply_to_each_Transaction')?['CustomerCode']}')
```
> **Note**: Requires `cr7bb_customercode` to be defined as alternate key on Customers table
