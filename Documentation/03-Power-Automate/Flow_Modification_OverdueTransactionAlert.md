# Flow Modification: Transaction-Level Overdue Alert

## Summary

**Change**: Replace customer-level overdue alert with transaction-level details

**Columns needed** (10):
Customer Name, Account, Reference, Assignment, Doc Number, Doc Type, Doc Date, Arrear, Amount, Text

---

## Steps

### Step 1: Open the Flow
1. Go to [make.powerautomate.com](https://make.powerautomate.com)
2. **Solutions** → **TH Finance Cash Collection** → **Daily Collections Email Engine** → **Edit**

### Step 2: Update List_Transactions
1. Find **List_Transactions** action
2. Add to **Select columns**: `,cr7bb_reference,cr7bb_assignment,cr7bb_text`

### Step 3: Add Variable
1. After last **Initialize variable**, add new one:
   - Name: `varOverdueTransactions`
   - Type: **Array**
   - Value: `[]`

### Step 4: Modify Check_AR_Alert (Inside Yes Branch)

**Current structure:**
- Check_AR_Alert condition: `Compose_Max_DayCount >= 3`
- Inside Yes: `Append_AR_Alert_Customer` (appends customer summary)

**Changes:**
1. Find **Check_AR_Alert** → expand **If yes** branch
2. Delete **Append_AR_Alert_Customer** action
3. Add **Filter array**:
   - From: `@outputs('Sort_DN_FIFO')`
   - Condition (advanced): `@greaterOrEquals(item()?['cr7bb_daycount'], 3)`
   - Rename to: `Filter_Overdue_Trans`
4. Add **Apply to each** after filter:
   - Select output: `@body('Filter_Overdue_Trans')`
   - Rename to: `Loop_Overdue_Trans`
5. Inside loop, add **Append to array variable**:
   - Name: `varOverdueTransactions`
   - Value: see JSON below

### Step 5: Update AR Alert Section (After Customer Loop)

**Location**: Find `Check_Has_AR_Alerts` condition (runs after `Apply_to_each_Customer`)

**Current structure:**
- `Check_Has_AR_Alerts`: checks `length(varARAlertCustomers) > 0`
- `Apply_to_each_AR_Alert`: loops through `varARAlertCustomers`
- `Append_Table_Row`: appends HTML `<tr>` to `varTableRows`
- `Compose_AR_Alert_Body`: builds full HTML with 5-column table

**Changes:**

1. **Update Check_Has_AR_Alerts condition**:
   - Change from: `length(variables('varARAlertCustomers'))`
   - Change to: `length(variables('varOverdueTransactions'))`

2. **Update Apply_to_each_AR_Alert**:
   - Change foreach from: `@variables('varARAlertCustomers')`
   - Change to: `@variables('varOverdueTransactions')`

3. **Update Append_Table_Row** (inside the loop):
   - Replace value with new 10-column row (see HTML Row Template below)

4. **Update Compose_AR_Alert_Body**:
   - Replace table headers with 10 columns (see HTML Body Template below)

### Step 6: Update Email Subject
Find `Send_AR_Alert_Email` action, change Subject to:
```
⚠️ [THFinance] Overdue Alert - @{length(variables('varOverdueTransactions'))} Transactions ≥ 3 Days - @{variables('varProcessDate')}
```

### Step 7: Save and Test

---

## Append Value JSON

```json
{
  "CustomerName": "@{outputs('Get_Customer')?['body/cr7bb_customername']}",
  "Account": "@{outputs('Get_Customer')?['body/cr7bb_customercode']}",
  "Reference": "@{items('Loop_Overdue_Trans')?['cr7bb_reference']}",
  "Assignment": "@{items('Loop_Overdue_Trans')?['cr7bb_assignment']}",
  "DocNumber": "@{items('Loop_Overdue_Trans')?['cr7bb_documentnumber']}",
  "DocType": "@{items('Loop_Overdue_Trans')?['cr7bb_documenttype']}",
  "DocDate": "@{items('Loop_Overdue_Trans')?['cr7bb_documentdate']}",
  "Arrear": "@{items('Loop_Overdue_Trans')?['cr7bb_daycount']}",
  "Amount": "@{items('Loop_Overdue_Trans')?['cr7bb_amountlocalcurrency']}",
  "Text": "@{items('Loop_Overdue_Trans')?['cr7bb_text']}"
}
```

---

## HTML Row Template (for Append_Table_Row)

```html
<tr>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['CustomerName']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['Account']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['Reference']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['Assignment']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['DocNumber']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['DocType']}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['DocDate']}</td>
  <td style="border:1px solid #ddd;padding:8px;text-align:right;">@{items('Apply_to_each_AR_Alert')?['Arrear']}</td>
  <td style="border:1px solid #ddd;padding:8px;text-align:right;">@{formatNumber(float(items('Apply_to_each_AR_Alert')?['Amount']),'N2')}</td>
  <td style="border:1px solid #ddd;padding:8px;">@{items('Apply_to_each_AR_Alert')?['Text']}</td>
</tr>
```

---

## HTML Body Template (for Compose_AR_Alert_Body)

```html
<html>
<body style="font-family:Arial,sans-serif;">
<h2 style="color:#0065A1;">⚠️ Overdue Transaction Alert</h2>
<p>The following <strong>@{length(variables('varOverdueTransactions'))}</strong> transactions have been overdue for 3+ days:</p>
<table style="border-collapse:collapse;width:100%;">
  <tr style="background-color:#0065A1;color:white;">
    <th style="border:1px solid #ddd;padding:8px;">Customer Name</th>
    <th style="border:1px solid #ddd;padding:8px;">Account</th>
    <th style="border:1px solid #ddd;padding:8px;">Reference</th>
    <th style="border:1px solid #ddd;padding:8px;">Assignment</th>
    <th style="border:1px solid #ddd;padding:8px;">Doc Number</th>
    <th style="border:1px solid #ddd;padding:8px;">Doc Type</th>
    <th style="border:1px solid #ddd;padding:8px;">Doc Date</th>
    <th style="border:1px solid #ddd;padding:8px;">Arrear</th>
    <th style="border:1px solid #ddd;padding:8px;">Amount</th>
    <th style="border:1px solid #ddd;padding:8px;">Text</th>
  </tr>
  @{variables('varTableRows')}
</table>
<p style="margin-top:20px;color:#666;">Generated: @{variables('varProcessDate')}</p>
</body>
</html>
```

---

## Quick Reference

| Step | Action | What to Change |
|------|--------|----------------|
| 2 | List_Transactions | Add 3 columns to Select |
| 3 | Initialize variable | Add `varOverdueTransactions` array |
| 4 | Check_AR_Alert → Yes | Replace Append with Filter + Loop |
| 5 | Check_Has_AR_Alerts | Change to `varOverdueTransactions` |
| 5 | Apply_to_each_AR_Alert | Change foreach source |
| 5 | Append_Table_Row | Replace with 10-column row |
| 5 | Compose_AR_Alert_Body | Replace with 10-column table |
| 6 | Send_AR_Alert_Email | Update subject line |

---

**Created**: 2026-01-23
