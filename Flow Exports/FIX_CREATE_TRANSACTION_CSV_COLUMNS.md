# Fix: Update Create Transaction to Use CSV Column Names

## Problem
CSV parsing removes spaces from column headers, so:
- `Document Number` becomes `DocumentNumber`
- `Net Due Date` becomes `NetDueDate`
- etc.

But the flow references still use the old names with spaces.

## Solution
Update all column references in the flow to match CSV output (no spaces).

---

## Changes Required

### In "Check_if_Summary_Row" Action

**Find:**
```json
"@empty(item()?['Document Number'])"
```

**Replace with:**
```json
"@empty(item()?['DocumentNumber'])"
```

### In "Compose_Summary" Action

**Find:**
```json
"account": "@{item()?['Account']}",
"amount": "@{item()?['Amount in Local Currency']}"
```

**Replace with:**
```json
"account": "@{item()?['Account']}",
"amount": "@{item()?['AmountInLocalCurrency']}"
```

### In "List_customer" Action

**Find:**
```json
"$filter": "cr7bb_customercode eq '@{item()?['Account']}'"
```

**Keep as is** (Account has no space, already correct)

### In "Compose_isExcluded" Action

**Find:**
```json
"@or(contains(toLower(coalesce(item()?['Text'], '')), 'paid'), ...)"
```

**Keep as is** (Text has no space, already correct)

### In "Compose_ParsedAmount" Action

**Find:**
```json
"@float(replace(replace(string(item()?['Amount in Local Currency']), ',', ''), '\"', ''))"
```

**Replace with:**
```json
"@float(replace(replace(string(item()?['AmountInLocalCurrency']), ',', ''), '\"', ''))"
```

### In "Create_transaction" Action

**Find and replace ALL these field references:**

| Old (with spaces) | New (no spaces) |
|-------------------|-----------------|
| `item()?['Document Number']` | `item()?['DocumentNumber']` |
| `item()?['Assignment']` | `item()?['Assignment']` ✅ (no change) |
| `item()?['Document Type']` | `item()?['DocumentType']` |
| `item()?['Document Date']` | `item()?['DocumentDate']` |
| `item()?['Net Due Date']` | `item()?['NetDueDate']` |
| `item()?['Arrears by Net Due Date']` | `item()?['ArrearsByNetDueDate']` |
| `item()?['Text']` | `item()?['Text']` ✅ (no change) |
| `item()?['Reference']` | `item()?['Reference']` ✅ (no change) |

**Complete Updated Create_transaction Action:**

```json
"Create_transaction": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "entityName": "cr7bb_thfinancecashcollectiontransactions",
      "item/cr7bb_customer": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}",
      "item/cr7bb_recordtype": "Transaction",
      "item/cr7bb_documentnumber": "@{item()?['DocumentNumber']}",
      "item/cr7bb_assignment": "@{item()?['Assignment']}",
      "item/cr7bb_documenttype": "@{item()?['DocumentType']}",
      "item/cr7bb_documentdate": "@{item()?['DocumentDate']}",
      "item/cr7bb_netduedate": "@{item()?['NetDueDate']}",
      "item/cr7bb_arrearsdays": "@{int(coalesce(item()?['ArrearsByNetDueDate'], 0))}",
      "item/cr7bb_amountlocalcurrency": "@{outputs('Compose_ParsedAmount')}",
      "item/cr7bb_textfield": "@{item()?['Text']}",
      "item/cr7bb_reference": "@{item()?['Reference']}",
      "item/cr7bb_transactiontype": "@{outputs('Compose_TransactionType')}",
      "item/cr7bb_isexcluded": "@{outputs('Compose_isExcluded')}",
      "item/cr7bb_excludereason": "@{if(outputs('Compose_isExcluded'), 'Keyword found in text field', null)}",
      "item/cr7bb_daycount": "@{int(coalesce(item()?['ArrearsByNetDueDate'], 0))}",
      "item/cr7bb_processdate": "@{variables('varProcessDate')}",
      "item/cr7bb_processbatch": "@{variables('varBatchID')}",
      "item/cr7bb_rownumber": "@{variables('varRowCounter')}",
      "item/cr7bb_isprocessed": false,
      "item/cr7bb_emailsent": false
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps",
      "operationId": "CreateRecord",
      "connectionName": "shared_commondataserviceforapps"
    }
  },
  "runAfter": {
    "Compose_TransactionType": ["Succeeded"]
  }
}
```

### In "Append_customer_not_found_error" Action

**Find:**
```json
"value": "Row @{variables('varRowCounter')}: Customer @{item()?['Account']} not found"
```

**Keep as is** (Account has no space, already correct)

---

## How to Apply These Changes

### Using Flow Designer (Easiest)

**For each action:**

1. Click on the action to expand it
2. Click in the field that has the old reference
3. Delete the current expression
4. Click **Expression** tab
5. Paste the new expression (without spaces)
6. Click **OK**

**Example - Updating Document Number field:**
1. Click on "Create_transaction" action
2. Find the **cr7bb_documentnumber** field
3. Current value: `@{item()?['Document Number']}`
4. Click the field → Delete
5. Click Expression tab
6. Paste: `item()?['DocumentNumber']`
7. Click OK

Repeat for all fields listed above.

### Using Code View (Faster)

1. Click **⋯** → **Peek code**
2. Use Find & Replace (Ctrl+H):
   - Find: `item()?['Document Number']`
   - Replace: `item()?['DocumentNumber']`
   - Click **Replace All**
3. Repeat for each column name with spaces:
   - `'Document Type'` → `'DocumentType'`
   - `'Document Date'` → `'DocumentDate'`
   - `'Net Due Date'` → `'NetDueDate'`
   - `'Arrears by Net Due Date'` → `'ArrearsByNetDueDate'`
   - `'Amount in Local Currency'` → `'AmountInLocalCurrency'`
4. Click outside code view to close
5. Click **Save**

---

## Complete Find & Replace List

Use these in order (Ctrl+H in code view):

1. `'Document Number'` → `'DocumentNumber'`
2. `'Document Type'` → `'DocumentType'`
3. `'Document Date'` → `'DocumentDate'`
4. `'Net Due Date'` → `'NetDueDate'`
5. `'Arrears by Net Due Date'` → `'ArrearsByNetDueDate'`
6. `'Amount in Local Currency'` → `'AmountInLocalCurrency'`

**Note:** Keep the single quotes `'` around the column names!

---

## Verification

After making changes, verify in code view that you see:
- ✅ `item()?['DocumentNumber']` (not 'Document Number')
- ✅ `item()?['NetDueDate']` (not 'Net Due Date')
- ✅ `item()?['AmountInLocalCurrency']` (not 'Amount in Local Currency')

---

## Test After Update

1. Save the flow
2. Click **Test** → **Manually** → **Run flow**
3. Check the run history
4. **Create_transaction** action should now succeed
5. Verify transactions created in Dataverse

---

**Created:** 2025-01-08
**Error:** 'Document Number' is required
**Root Cause:** CSV removes spaces from column headers
**Fix:** Update all item() references to use names without spaces
**Time to Fix:** 5 minutes (code view) or 15 minutes (designer)
