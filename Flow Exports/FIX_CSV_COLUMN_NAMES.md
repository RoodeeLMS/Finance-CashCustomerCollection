# Fix: CSV Column Name Mismatch

## Error
```
Invalid parameter for 'Create transaction'. Error: 'Document Number' is required.
```

## Root Cause

When Excel is converted to CSV, **column headers with spaces get changed**:

**Excel Column:** `Document Number`
**CSV Column:** `DocumentNumber` (space removed) or `Document_Number` (underscore added)

The flow is looking for `item()?['Document Number']` but CSV parsing created `item()?['DocumentNumber']`.

---

## Solution: Update Parse JSON Schema

### Option 1: Update the Schema WITHOUT Spaces

**Change the Parse JSON schema to match CSV output:**

Open the **Parse_CSV** action and replace the schema with this:

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "Account": {"type": "string"},
      "DocumentNumber": {"type": "string"},
      "Assignment": {"type": "string"},
      "DocumentType": {"type": "string"},
      "DocumentDate": {"type": "string"},
      "NetDueDate": {"type": "string"},
      "ArrearsByNetDueDate": {"type": "string"},
      "AmountInLocalCurrency": {"type": "string"},
      "Currency": {"type": "string"},
      "Text": {"type": "string"},
      "Reference": {"type": "string"}
    }
  }
}
```

**Then update ALL references in the flow:**

This is **NOT RECOMMENDED** because you'd have to change 30+ references throughout the flow.

---

## Option 2: Use Excel Online Connector Instead (RECOMMENDED)

The CSV conversion is causing column name issues. Let's use **Excel Online connector with dynamic file reference** instead.

### Steps:

**1. Delete these 3 actions:**
   - Get_SAP_file_content
   - Create_CSV_table
   - Parse_CSV

**2. Add new Excel Online action:**

Action: **"List rows present in a table"**

**But first, you need to create the table in Excel:**

### Creating the Table in Excel (One-Time Setup)

**Option A: Modify the SAP Export File**
1. Open the current SAP export file in Excel Online (from SharePoint)
2. Click on cell A1 (the "Account" header)
3. Press **Ctrl + Shift + End** to select all data
4. Go to **Insert** → **Table** (or press Ctrl + T)
5. Check "My table has headers"
6. Click OK
7. The table name will default to "Table1"
8. **Important:** Right-click the table, select **Table Design** → **Table Name** field
9. Change name to: `SAPData`
10. Save the file

**Option B: Create a Template File**
1. Create a new Excel file with the same column structure
2. Add one sample row of data
3. Convert to table (Ctrl + T)
4. Name it `SAPData`
5. Delete the sample row (keep headers)
6. Save as template
7. Ask SAP team to use this template for exports

### Then Update the Flow

**Add "List rows present in a table" action:**

```json
"List_rows_in_table": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@{first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']}",
      "table": "SAPData"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "GetItems",
      "connectionName": "shared_excelonlinebusiness"
    }
  },
  "runAfter": {
    "Set_varProcessLogID": ["Succeeded"]
  }
}
```

**Update Apply_to_each:**
```json
"foreach": "@outputs('List_rows_in_table')?['body/value']"
```

---

## Option 3: Quick Debug - Check Actual Column Names

Before making changes, let's see what column names CSV is actually creating:

### Debug Steps:

1. In the flow run history, click on the **Parse_CSV** action
2. Look at the **Outputs** section
3. Expand the body array
4. Check the actual property names

**If they have spaces:** The schema is wrong
**If they have no spaces:** Update all references in the flow

**Example Output:**
```json
[
  {
    "Account": "198609",
    "DocumentNumber": "9974712914",  ← No space!
    ...
  }
]
```

---

## Recommended Path Forward

**Immediate Fix (15 minutes):**
1. Open the SAP Excel file in SharePoint
2. Convert the data range to a table named "SAPData"
3. Save
4. Replace the 3 CSV actions with 1 Excel "List rows present in a table" action
5. Test

**Long-term Fix (coordinate with SAP team):**
1. Create an Excel template with table pre-formatted
2. SAP team uses this template for exports
3. Flow works automatically without CSV conversion

---

## Summary

| Approach | Time | Difficulty | Reliability |
|----------|------|------------|-------------|
| Fix CSV schema | 5 min | Hard | Low (name mismatches) |
| Use Excel table | 15 min | Easy | High |
| Template with SAP | 30 min | Medium | Very High |

**Recommendation:** Use Excel table approach (Option 2)

---

**Created:** 2025-01-08
**Error:** Document Number is required
**Cause:** CSV column name conversion removes spaces
**Fix:** Use Excel table with fixed name instead of CSV parsing
