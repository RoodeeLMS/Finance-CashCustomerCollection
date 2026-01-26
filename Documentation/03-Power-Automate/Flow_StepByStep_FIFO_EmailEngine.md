# Step-by-Step: FIFO CN Application & AR Notification

**Date**: January 14, 2026
**Flow Name**: `[THFinance] Daily Collections Email Engine`
**Purpose**: Apply CN to DN using FIFO with STOP logic, send customer emails, send AR summary
**Key Changes**: Correct FIFO STOP logic + AR notification for ArrearDays ≥ 3

---

## Critical Business Rules

### 1. FIFO CN Application - STOP (Not Skip)

**Client Clarification (2026-01-14):**
> When applying CN in FIFO order, if the next CN would make total CN exceed total DN, **STOP completely**. Do NOT skip to check the next CN.

**Example:**
| CN | Amount | Running Total | DN Total | Action |
|----|--------|---------------|----------|--------|
| CN1 | -3,000 | -3,000 | 10,000 | ✅ Apply (3,000 < 10,000) |
| CN2 | -5,000 | -8,000 | 10,000 | ✅ Apply (8,000 < 10,000) |
| CN3 | -4,000 | -12,000 | 10,000 | ❌ **STOP** (12,000 > 10,000) |

**Result:** Applied CNs = CN1 + CN2 = -8,000. Remaining DN = 10,000 - 8,000 = **2,000 THB**

### 2. AR Notification for Overdue ≥ 3 Days

**Client Clarification (2026-01-14):**
> If any transaction has ArrearDays ≥ 3 (positive = overdue), send a summary notification to AR team.

**Method Selected:** Option 2 - Separate summary email at end of daily flow
- NOT CC on each customer email
- ONE summary email with all affected customers

---

## Prerequisites

1. **WorkingDayCalendar table** populated (for ArrearDays calculation)
2. **Transactions table** with today's imported data
3. **Customers table** with email addresses
4. **QR Codes** in SharePoint (optional)

---

## Flow Variables

### Initialize at Start

```
varProcessDate          String    @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
varTodayWDN             Integer   0
varEmailsSent           Integer   0
varEmailsFailed         Integer   0
varCustomersProcessed   Integer   0
varARAlertCustomers     Array     []    ⭐ NEW - Customers with ArrearDays ≥ 3
varErrorMessages        Array     []
```

### Per-Customer Variables

```
varAppliedCNTotal       Float     0     ⭐ Running total of applied CNs
varAppliedCNs           Array     []    ⭐ List of applied CN records
varRemainingDN          Float     0     ⭐ DN total after CN application
varMaxArrearDays        Integer   0
varHasOverdueAlert      Boolean   false ⭐ Flag for AR notification
```

---

## Step-by-Step Implementation

### Step 1: Flow Trigger & Initialization

**Action 1**: Manual trigger or Recurrence
```
Trigger: Manually trigger a flow
  OR
Trigger: Recurrence
  Frequency: Day
  At: 8:30 AM
  Time Zone: SE Asia Standard Time
```

---

### Step 2: Initialize Variables

**Add these variables** (click + New step for each):

**Variable 1: varProcessDate**
```
Name: varProcessDate
Type: String
Value: @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
```

**Variable 2: varTodayWDN**
```
Name: varTodayWDN
Type: Integer
Value: 0
```

**Variable 3: varEmailsSent**
```
Name: varEmailsSent
Type: Integer
Value: 0
```

**Variable 4: varEmailsFailed**
```
Name: varEmailsFailed
Type: Integer
Value: 0
```

**Variable 5: varCustomersProcessed**
```
Name: varCustomersProcessed
Type: Integer
Value: 0
```

**Variable 6: varARAlertCustomers** ⭐ NEW
```
Name: varARAlertCustomers
Type: Array
Value: []
```
> This collects customers with overdue transactions (ArrearDays ≥ 3) for AR summary

**Variable 7: varErrorMessages**
```
Name: varErrorMessages
Type: Array
Value: []
```

---

### Step 3: Get Today's WDN

**Action**: List rows (Dataverse)
```
Table name: WorkingDayCalendars
Filter rows: cr7bb_name eq '@{variables('varProcessDate')}'
Row count: 1
```
Rename to: `Get_Today_WDN`

**Action**: Set variable
```
Name: varTodayWDN
Value: @{coalesce(first(outputs('Get_Today_WDN')?['body/value'])?['cr7bb_workingdaynumber'], 0)}
```

---

### Step 4: Get All Today's Transactions

**Action**: List rows (Dataverse)
```
Table name: [THFinanceCashCollection]Transactions
Filter rows: cr7bb_processdate eq '@{variables('varProcessDate')}' and cr7bb_emailsent eq false
Row count: 5000
```
Rename to: `Get_All_Transactions`

---

### Step 5: Get Unique Customer IDs

**Action**: Select (Data Operations)
```
From: @{outputs('Get_All_Transactions')?['body/value']}
Map: @{item()?['_cr7bb_customer_value']}
```
Rename to: `Extract_Customer_IDs`

**Action**: Compose
```
Inputs: @{union(body('Extract_Customer_IDs'), body('Extract_Customer_IDs'))}
```
Rename to: `Unique_Customer_IDs`
> union() with itself removes duplicates

---

### Step 6: Main Customer Loop

**Action**: Apply to each
```
Select an output: @{outputs('Unique_Customer_IDs')}
```
Rename to: `For_Each_Customer`

**Settings**: Concurrency Control = 1 (sequential for accurate counting)

---

## Inside Customer Loop (Steps 7-18)

### Step 7: Get Customer Details

**Action**: Get a row by ID (Dataverse)
```
Table name: [THFinanceCashCollection]Customers
Row ID: @{items('For_Each_Customer')}
```
Rename to: `Get_Customer`

---

### Step 8: Get Customer's Transactions

**Action**: Filter array
```
From: @{outputs('Get_All_Transactions')?['body/value']}
Condition: @{equals(item()?['_cr7bb_customer_value'], items('For_Each_Customer'))}
```
Rename to: `Customer_Transactions`

---

### Step 9: Filter Non-Excluded Transactions

**Action**: Filter array
```
From: @{body('Customer_Transactions')}
Condition: @{equals(item()?['cr7bb_isexcluded'], false)}
```
Rename to: `Active_Transactions`

**Action**: Condition
```
Condition: length(body('Active_Transactions')) is equal to 0
```

**If Yes (All Excluded):**
- Continue to next customer (no action needed)

**If No:** Continue with FIFO processing

---

### Step 10: Separate DN and CN

**Action**: Filter array (DN - Positive Amounts)
```
From: @{body('Active_Transactions')}
Condition: @{greater(float(item()?['cr7bb_amountlocalcurrency']), 0)}
```
Rename to: `DN_List`

**Action**: Filter array (CN - Negative Amounts)
```
From: @{body('Active_Transactions')}
Condition: @{less(float(item()?['cr7bb_amountlocalcurrency']), 0)}
```
Rename to: `CN_List`

---

### Step 11: Sort by Document Date (FIFO)

**Action**: Compose (Sort DN)
```
Inputs: @{sort(body('DN_List'), 'cr7bb_documentdate')}
```
Rename to: `DN_Sorted`

**Action**: Compose (Sort CN)
```
Inputs: @{sort(body('CN_List'), 'cr7bb_documentdate')}
```
Rename to: `CN_Sorted`

---

### Step 12: Calculate DN Total

**Action**: Compose
```
Inputs: @{if(
  equals(length(outputs('DN_Sorted')), 0),
  0,
  sum(outputs('DN_Sorted'), 'cr7bb_amountlocalcurrency')
)}
```
Rename to: `DN_Total`

**Action**: Condition
```
Condition: @{outputs('DN_Total')} is equal to 0
```

**If Yes (No DN):**
- Continue to next customer

---

### Step 13: FIFO CN Application with STOP Logic ⭐ KEY CHANGE

This is the critical change. We need to loop through CNs and STOP when next CN would exceed DN.

**Initialize Per-Customer Variables:**

**Action**: Set variable
```
Name: varAppliedCNTotal
Value: 0
```

**Action**: Set variable
```
Name: varAppliedCNs
Value: []
```

**Action**: Set variable
```
Name: varRemainingDN
Value: @{outputs('DN_Total')}
```

---

### Step 14: Apply CNs with STOP Logic ⭐ FIFO STOP

**Action**: Apply to each
```
Select an output: @{outputs('CN_Sorted')}
```
Rename to: `Apply_CNs_FIFO`

**Settings**: Concurrency Control = 1 (must be sequential for FIFO)

**Inside Apply_CNs_FIFO:**

**Action**: Compose (Calculate if CN can be applied)
```
Inputs: @{add(
  abs(variables('varAppliedCNTotal')),
  abs(float(items('Apply_CNs_FIFO')?['cr7bb_amountlocalcurrency']))
)}
```
Rename to: `Potential_CN_Total`

**Action**: Condition
```
Condition: @{outputs('Potential_CN_Total')} is less than or equal to @{outputs('DN_Total')}
```

**If Yes (Can Apply This CN):**

**Action**: Set variable
```
Name: varAppliedCNTotal
Value: @{add(
  variables('varAppliedCNTotal'),
  float(items('Apply_CNs_FIFO')?['cr7bb_amountlocalcurrency'])
)}
```
> Note: CN amounts are negative, so this subtracts from running total

**Action**: Append to array variable
```
Name: varAppliedCNs
Value: @{items('Apply_CNs_FIFO')}
```

**If No (CN Would Exceed DN):**

⚠️ **CRITICAL**: We need to EXIT the loop here, not just skip.

**Option A - Using Do Until with Break Flag:**

Since Apply to Each doesn't support break, we need a different approach:

**Alternative: Use Do Until with Index**

Replace Steps 13-14 with this approach:

---

### Step 13-14 Alternative: FIFO with Do Until (Supports STOP)

**Action**: Initialize variable
```
Name: varCNIndex
Type: Integer
Value: 0
```

**Action**: Initialize variable
```
Name: varStopFIFO
Type: Boolean
Value: false
```

**Action**: Do until
```
Condition: @{or(
  greaterOrEquals(variables('varCNIndex'), length(outputs('CN_Sorted'))),
  variables('varStopFIFO')
)}
```
Rename to: `FIFO_CN_Loop`

**Settings**: Count = 1000, Timeout = PT1H

**Inside FIFO_CN_Loop:**

**Action**: Compose (Get Current CN)
```
Inputs: @{outputs('CN_Sorted')?[variables('varCNIndex')]}
```
Rename to: `Current_CN`

**Action**: Compose (Calculate Potential Total)
```
Inputs: @{add(
  abs(variables('varAppliedCNTotal')),
  abs(float(outputs('Current_CN')?['cr7bb_amountlocalcurrency']))
)}
```
Rename to: `Potential_CN_Total`

**Action**: Condition
```
Condition: @{outputs('Potential_CN_Total')} is less than or equal to @{outputs('DN_Total')}
```

**If Yes (Apply CN):**

**Action**: Set variable (Update Applied Total)
```
Name: varAppliedCNTotal
Value: @{add(
  variables('varAppliedCNTotal'),
  float(outputs('Current_CN')?['cr7bb_amountlocalcurrency'])
)}
```

**Action**: Append to array variable
```
Name: varAppliedCNs
Value: @{outputs('Current_CN')}
```

**Action**: Increment variable
```
Name: varCNIndex
Value: 1
```

**If No (STOP - CN Would Exceed):**

**Action**: Set variable ⭐ STOP SIGNAL
```
Name: varStopFIFO
Value: true
```

---

### Step 15: Calculate Remaining Amount

**Action**: Compose
```
Inputs: @{add(outputs('DN_Total'), variables('varAppliedCNTotal'))}
```
Rename to: `Remaining_Amount`

> Note: varAppliedCNTotal is negative, so add() effectively subtracts

**Action**: Condition (Check if customer owes money)
```
Condition: @{outputs('Remaining_Amount')} is greater than 0
```

**If No (No Amount Due):**
- Continue to next customer

---

### Step 16: Calculate Max Arrear Days & Check AR Alert ⭐ NEW

**Action**: Compose (Get Max Arrear from DN transactions)
```
Inputs: @{max(
  map(outputs('DN_Sorted'), int(item()?['cr7bb_daycount']))
)}
```
Rename to: `Max_Arrear_Days`

**Action**: Condition (Check for AR Alert)
```
Condition: @{outputs('Max_Arrear_Days')} is greater than or equal to 3
```
Rename to: `Check_AR_Alert`

**If Yes (Overdue ≥ 3 days):** ⭐ AR NOTIFICATION

**Action**: Append to array variable
```
Name: varARAlertCustomers
Value: {
  "CustomerCode": "@{outputs('Get_Customer')?['body/cr7bb_customercode']}",
  "CustomerName": "@{outputs('Get_Customer')?['body/cr7bb_customername']}",
  "MaxArrearDays": @{outputs('Max_Arrear_Days')},
  "RemainingAmount": @{outputs('Remaining_Amount')},
  "TransactionCount": @{length(outputs('DN_Sorted'))}
}
```

---

### Step 17: Select Email Template

**Action**: Compose
```
Inputs: @{if(
  contains(
    join(map(outputs('DN_Sorted'), item()?['cr7bb_documenttype']), ','),
    'MI'
  ),
  'Template_D',
  if(
    less(outputs('Max_Arrear_Days'), 3),
    'Template_A',
    if(
      equals(outputs('Max_Arrear_Days'), 3),
      'Template_B',
      'Template_C'
    )
  )
)}
```
Rename to: `Selected_Template`

| Template | Condition |
|----------|-----------|
| Template_A | Arrear < 3 (standard reminder) |
| Template_B | Arrear = 3 (cash discount warning) |
| Template_C | Arrear > 3 (late fee warning) |
| Template_D | MI document exists |

---

### Step 18: Build and Send Email

**(Existing email building logic - see PowerAutomate_Collections_Email_Engine.md)**

Key points:
- Build HTML table with DN transactions (not applied CNs)
- Show Remaining_Amount as total due
- Attach QR code if available
- Send to customer emails, CC to sales/AR

**After Send Email:**

**Action**: Increment variable
```
Name: varEmailsSent
Value: 1
```

**Action**: Increment variable
```
Name: varCustomersProcessed
Value: 1
```

---

## After Customer Loop (Step 19-20)

### Step 19: Send AR Summary Email ⭐ NEW

**Location**: AFTER the For_Each_Customer loop ends

**Action**: Condition
```
Condition: length(variables('varARAlertCustomers')) is greater than 0
```
Rename to: `Check_AR_Alert_Needed`

**If Yes (Has Overdue Customers):**

**Action**: Compose (Build AR Alert Table)
```
Inputs: @{join(
  map(
    variables('varARAlertCustomers'),
    concat(
      '<tr>',
      '<td>', item()?['CustomerCode'], '</td>',
      '<td>', item()?['CustomerName'], '</td>',
      '<td style="text-align:center;color:red;font-weight:bold;">', item()?['MaxArrearDays'], '</td>',
      '<td style="text-align:right;">', formatNumber(float(item()?['RemainingAmount']), 'N2'), '</td>',
      '<td style="text-align:center;">', item()?['TransactionCount'], '</td>',
      '</tr>'
    )
  ),
  ''
)}
```
Rename to: `AR_Alert_Table_Rows`

**Action**: Send an email (V2)
```
To: ar-team@nestle.com
Subject: ⚠️ [THFinance] Overdue Alert - @{length(variables('varARAlertCustomers'))} Customers with Arrear ≥ 3 Days - @{variables('varProcessDate')}
Body: |
  <html>
  <body style="font-family: Arial, sans-serif;">
    <h2 style="color: #D83B01;">⚠️ Daily Overdue Alert</h2>

    <p>The following <strong>@{length(variables('varARAlertCustomers'))}</strong> customer(s) have transactions overdue by <strong>3 or more working days</strong>:</p>

    <table border="1" cellpadding="8" style="border-collapse: collapse; width: 100%;">
      <tr style="background-color: #D83B01; color: white;">
        <th>Customer Code</th>
        <th>Customer Name</th>
        <th>Max Arrear Days</th>
        <th>Amount Due (THB)</th>
        <th>Transactions</th>
      </tr>
      @{outputs('AR_Alert_Table_Rows')}
    </table>

    <p style="margin-top: 20px;">
      <strong>Action Required:</strong> Please follow up with these customers regarding their overdue payments.
    </p>

    <p style="color: #666; font-size: 12px;">
      Process Date: @{variables('varProcessDate')}<br/>
      Generated by: [THFinance] Daily Collections Email Engine
    </p>
  </body>
  </html>
Importance: High
```
Rename to: `Send_AR_Alert_Email`

---

### Step 20: Final Summary Log

**Action**: Send an email (V2)
```
To: ar-team@nestle.com
Subject: ✅ [THFinance] Daily Email Summary - @{variables('varProcessDate')} - @{variables('varEmailsSent')} Sent
Body: |
  <h2>Daily Collections Email Summary</h2>

  <ul>
    <li><strong>Process Date:</strong> @{variables('varProcessDate')}</li>
    <li><strong>Customers Processed:</strong> @{variables('varCustomersProcessed')}</li>
    <li><strong>Emails Sent:</strong> @{variables('varEmailsSent')}</li>
    <li><strong>Emails Failed:</strong> @{variables('varEmailsFailed')}</li>
    <li><strong>AR Alerts:</strong> @{length(variables('varARAlertCustomers'))} customers with Arrear ≥ 3 days</li>
  </ul>

  @{if(
    greater(length(variables('varErrorMessages')), 0),
    concat(
      '<h3>⚠️ Errors:</h3><ul>',
      join(map(variables('varErrorMessages'), concat('<li>', item(), '</li>')), ''),
      '</ul>'
    ),
    ''
  )}
```

---

## Complete Flow Structure

```
[Trigger: Manual or Scheduled]
  │
  ├── Initialize Variables (7 variables)
  │     - varProcessDate, varTodayWDN, varEmailsSent, varEmailsFailed
  │     - varCustomersProcessed, varARAlertCustomers ⭐, varErrorMessages
  │
  ├── Get_Today_WDN
  ├── Get_All_Transactions
  ├── Extract_Customer_IDs → Unique_Customer_IDs
  │
  ├── ════ For_Each_Customer ════
  │   │
  │   ├── Get_Customer (details)
  │   ├── Customer_Transactions (filter)
  │   ├── Active_Transactions (non-excluded)
  │   │
  │   ├── Condition: All excluded?
  │   │   └── Yes: Skip customer
  │   │
  │   ├── DN_List, CN_List (separate by amount sign)
  │   ├── DN_Sorted, CN_Sorted (FIFO by document date)
  │   │
  │   ├── DN_Total (sum)
  │   ├── Condition: DN_Total = 0?
  │   │   └── Yes: Skip customer
  │   │
  │   ├── Initialize FIFO variables
  │   │     - varAppliedCNTotal = 0
  │   │     - varAppliedCNs = []
  │   │     - varCNIndex = 0
  │   │     - varStopFIFO = false
  │   │
  │   ├── ════ FIFO_CN_Loop (Do Until) ════  ⭐ STOP LOGIC
  │   │   │
  │   │   ├── Current_CN = CN_Sorted[varCNIndex]
  │   │   ├── Potential_CN_Total = |applied| + |current CN|
  │   │   │
  │   │   ├── Condition: Potential ≤ DN_Total?
  │   │   │   ├── Yes: Apply CN
  │   │   │   │     - Update varAppliedCNTotal
  │   │   │   │     - Append to varAppliedCNs
  │   │   │   │     - Increment varCNIndex
  │   │   │   │
  │   │   │   └── No: STOP ⭐
  │   │   │         - Set varStopFIFO = true
  │   │   │
  │   │   └── Loop exits when: index >= CN count OR stopFIFO = true
  │   │
  │   ├── Remaining_Amount = DN_Total + varAppliedCNTotal
  │   │
  │   ├── Condition: Remaining_Amount > 0?
  │   │   └── No: Skip customer (CN covered all DN)
  │   │
  │   ├── Max_Arrear_Days (from DN transactions)
  │   │
  │   ├── Condition: Max_Arrear_Days ≥ 3?  ⭐ AR ALERT
  │   │   └── Yes: Append to varARAlertCustomers
  │   │
  │   ├── Selected_Template (A/B/C/D)
  │   ├── Build Email (HTML with DN table)
  │   ├── Send Email to Customer
  │   └── Increment counters
  │
  ├── ════ After Loop ════
  │
  ├── Condition: varARAlertCustomers not empty?  ⭐ AR SUMMARY
  │   └── Yes: Send_AR_Alert_Email (summary to AR team)
  │
  └── Send Final Summary Log
```

---

## Testing Scenarios

### Test 1: FIFO STOP Logic
**Setup:**
- DN Total: 10,000 THB
- CN1: -3,000 (Date: Jan 1)
- CN2: -5,000 (Date: Jan 2)
- CN3: -4,000 (Date: Jan 3)

**Expected:**
- CN1 applied (running: 3,000)
- CN2 applied (running: 8,000)
- CN3 **STOPPED** (8,000 + 4,000 = 12,000 > 10,000)
- Remaining: 10,000 - 8,000 = **2,000 THB**

### Test 2: AR Alert Triggered
**Setup:**
- Customer with DN where Max ArrearDays = 5

**Expected:**
- Customer included in varARAlertCustomers
- AR summary email sent at end of flow

### Test 3: No AR Alert
**Setup:**
- Customer with DN where Max ArrearDays = 2

**Expected:**
- Customer NOT in varARAlertCustomers
- AR summary email NOT sent (or sent with 0 customers)

### Test 4: CN Equals DN Exactly
**Setup:**
- DN Total: 10,000
- CN1: -10,000

**Expected:**
- CN1 applied (10,000 = 10,000)
- Remaining: 0
- Customer skipped (no amount due)

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Loop doesn't stop | varStopFIFO not set | Check condition is `<=` not `<` |
| Wrong CN applied | Not sorted FIFO | Verify sort by cr7bb_documentdate ASC |
| AR alert missing | Condition wrong | Check `>=` not `>` for ArrearDays ≥ 3 |
| Email not sent | Remaining ≤ 0 | Verify FIFO calculation |

---

## Key Expressions Reference

### FIFO Stop Condition
```
@{lessOrEquals(
  add(abs(variables('varAppliedCNTotal')), abs(float(outputs('Current_CN')?['cr7bb_amountlocalcurrency']))),
  outputs('DN_Total')
)}
```

### Remaining Amount After FIFO
```
@{add(outputs('DN_Total'), variables('varAppliedCNTotal'))}
```
> varAppliedCNTotal is negative, so add() subtracts

### Max Arrear Days from DN
```
@{max(map(outputs('DN_Sorted'), int(item()?['cr7bb_daycount'])))}
```

### AR Alert Check
```
@{greaterOrEquals(outputs('Max_Arrear_Days'), 3)}
```

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-14 | Initial step-by-step guide |
| 2026-01-14 | Added FIFO STOP logic (Do Until with break flag) |
| 2026-01-14 | Added AR notification for ArrearDays ≥ 3 |
| 2026-01-14 | Added AR summary email at end of flow |
