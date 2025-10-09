# Switch Back to Excel Table Approach

## Why Switch Back?
- CSV parsing changes column names (removes spaces)
- Requires updating 30+ references throughout the flow
- Excel table keeps original column names intact
- All existing `item()?['Document Number']` references will work as-is

---

## Steps to Switch

### Part 1: Create Table in Excel File (One-Time Setup)

**Option A: Modify Current SAP File**
1. Go to SharePoint: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
2. Navigate to: `/Shared Documents/Cash Customer Collection/01-Daily-SAP-Data/Current/`
3. Open the Excel file (e.g., `Cash_Line_items_as of 7.10.2025.xlsx`)
4. Click on cell **A1** (the "Account" header)
5. Press **Ctrl + Shift + End** to select all data (or select manually to last row/column)
6. Press **Ctrl + T** (or go to Insert → Table)
7. Check "My table has headers" ✅
8. Click **OK**
9. The table will be created with name "Table1"
10. **Important:** Click on the table, go to **Table Design** tab
11. In the **Table Name** field (top left), change "Table1" to: `SAPData`
12. Press Enter
13. **Save** the file (Ctrl + S)

**Option B: Create Template for SAP Team**
1. Create new Excel file with same column structure
2. Add headers: Account, Document Number, Assignment, Document Type, etc.
3. Add one sample data row
4. Convert to table (Ctrl + T)
5. Name it `SAPData`
6. Delete the sample row
7. Save as template
8. Share with SAP export team to use going forward

---

### Part 2: Update the Flow

**Step 1: Delete CSV Actions**
1. Open flow in edit mode
2. Delete these 3 actions:
   - **Get_SAP_file_content**
   - **Create_CSV_table**
   - **Parse_CSV**

**Step 2: Add Excel Table Action**
1. Click **+** button between "Set_varProcessLogID" and "Apply_to_each_row"
2. Search for: `excel list rows table`
3. Select **"List rows present in a table"** from Excel Online (Business)

**Step 3: Configure the Action**

**Location:** SharePoint

**Document Library:**
- Click dropdown
- Select site: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
- Select library: `Shared Documents`

**File:**
- Click the field
- Switch to **Expression** tab (fx icon)
- Paste this:
```
first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']
```
- Click **OK**

**Table:** Type: `SAPData`

**Step 4: Rename Action**
- Click **⋯** → **Rename**
- Name: `List_rows_in_table`

**Step 5: Update "Apply_to_each_row"**
1. Click on "Apply_to_each_row" to expand
2. Click in the "Select an output from previous steps" field
3. Delete current content
4. Select **value** from "List_rows_in_table" action
   - Or use expression: `outputs('List_rows_in_table')?['body/value']`

**Step 6: Revert Column Name Changes**

If you already changed column references to CSV format (DocumentNumber, NetDueDate, etc.), you need to change them back:

**Using Code View:**
1. Click **⋯** → **Peek code**
2. Use Find & Replace (Ctrl+H) to reverse the changes:
   - Find: `'DocumentNumber'` → Replace: `'Document Number'`
   - Find: `'DocumentType'` → Replace: `'Document Type'`
   - Find: `'DocumentDate'` → Replace: `'Document Date'`
   - Find: `'NetDueDate'` → Replace: `'Net Due Date'`
   - Find: `'ArrearsByNetDueDate'` → Replace: `'Arrears by Net Due Date'`
   - Find: `'AmountInLocalCurrency'` → Replace: `'Amount in Local Currency'`
3. Click outside code view
4. **Save**

**Step 7: Fix Lookup Field Syntax**

In the "Create_transaction" action, make sure you have:
```json
"item/cr7bb_customer": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}"
```

NOT:
```json
"item/cr7bb_Customer@odata.bind": "..."
```

**Step 8: Verify item() vs items() Function**

Change all references from `item()` to `items('Apply_to_each_row')`:

**Using Code View (Find & Replace):**
- Find: `item()?['`
- Replace: `items('Apply_to_each_row')?['`
- Click **Replace All**

**Step 9: Save and Test**
1. Click **Save**
2. Click **Test** → **Manually**
3. Click **Run flow**
4. Monitor execution

---

## Expected Flow Structure After Changes

```
Set_varProcessLogID
    ↓
List_rows_in_table (Excel connector with dynamic file + table "SAPData")
    ↓
Apply_to_each_row (loops through outputs('List_rows_in_table')?['body/value'])
    ↓
    Create_transaction (uses items('Apply_to_each_row')?['Document Number'], etc.)
```

---

## Complete Create_transaction Action (Corrected)

```json
{
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "entityName": "cr7bb_thfinancecashcollectiontransactions",
      "item/cr7bb_customer": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}",
      "item/cr7bb_recordtype": 676180000,
      "item/cr7bb_documentnumber": "@{items('Apply_to_each_row')?['Document Number']}",
      "item/cr7bb_assignment": "@{items('Apply_to_each_row')?['Assignment']}",
      "item/cr7bb_documenttype": "@{items('Apply_to_each_row')?['Document Type']}",
      "item/cr7bb_documentdate": "@{items('Apply_to_each_row')?['Document Date']}",
      "item/cr7bb_netduedate": "@{items('Apply_to_each_row')?['Net Due Date']}",
      "item/cr7bb_arrearsdays": "@{int(coalesce(items('Apply_to_each_row')?['Arrears by Net Due Date'], 0))}",
      "item/cr7bb_amountlocalcurrency": "@{outputs('Compose_ParsedAmount')}",
      "item/cr7bb_textfield": "@{items('Apply_to_each_row')?['Text']}",
      "item/cr7bb_referenceinformation": "@{items('Apply_to_each_row')?['Reference']}",
      "item/cr7bb_transactiontype": "@{outputs('Compose_TransactionType')}",
      "item/cr7bb_isexcluded": "@{outputs('Compose_isExcluded')}",
      "item/cr7bb_excludereason": "@{if(outputs('Compose_isExcluded'), 'Keyword found in text field', null)}",
      "item/cr7bb_daycount": "@{int(coalesce(items('Apply_to_each_row')?['Arrears by Net Due Date'], 0))}",
      "item/cr7bb_transactionprocessdate": "@{variables('varProcessDate')}",
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
    "Compose_TransactionType": [
      "Succeeded"
    ]
  }
}
```

**Note:** Column names have spaces (e.g., `'Document Number'`, not `'DocumentNumber'`)

---

## Verification Checklist

- ✅ Excel file has table named "SAPData"
- ✅ Table includes all data rows with headers
- ✅ Three CSV actions deleted
- ✅ One Excel "List rows in table" action added
- ✅ File parameter uses dynamic expression
- ✅ Table parameter = "SAPData"
- ✅ Apply_to_each references outputs('List_rows_in_table')
- ✅ All column names have spaces (original format)
- ✅ All references use items('Apply_to_each_row')
- ✅ Lookup field uses item/cr7bb_customer (lowercase)
- ✅ Flow saves without errors

---

## Troubleshooting

### Error: "Table 'SAPData' not found"
**Fix:** Open the Excel file and verify:
1. Data is formatted as a table (has filter dropdown arrows in headers)
2. Table name is exactly "SAPData" (case-sensitive)
3. Table Design tab shows the correct name

### Error: "File could not be found"
**Fix:** Verify the expression in File parameter:
```
first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']
```

### Error: "The property 'Document Number' does not exist"
**Fix:** You still have CSV column names (without spaces). Revert them using Find & Replace.

---

## Benefits of Excel Table Approach

| Feature | CSV Parsing | Excel Table |
|---------|-------------|-------------|
| Column Names | Changed (no spaces) | Original (with spaces) |
| Setup Complexity | Multiple actions | One action |
| Code Changes | 30+ references | None needed |
| Reliability | Medium | High |
| Maintenance | Complex | Simple |

---

**Created:** 2025-01-08
**Purpose:** Switch from CSV parsing back to Excel table reading
**Reason:** CSV removes spaces from column names, causing extensive code changes
**Time:** 10-15 minutes
