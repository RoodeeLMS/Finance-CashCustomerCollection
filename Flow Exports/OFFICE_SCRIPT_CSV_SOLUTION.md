# Office Script Solution for Excel to JSON Conversion

## Overview
Since "Create CSV table" can't convert Excel binary to array, we'll use an Office Script to read the Excel worksheet and return JSON array directly.

---

## Part 1: Create the Office Script

### Step 1: Open Excel Online Script Editor
1. Go to https://www.office.com/launch/excel
2. Click **Automate** tab in the ribbon
3. Click **New Script**

### Step 2: Paste This Script

**Script Name:** `ConvertWorksheetToJSON`

```typescript
function main(workbook: ExcelScript.Workbook): object[] {
  // Get the first worksheet (or specify by name)
  const sheet = workbook.getWorksheet("Data");

  // Get the used range (all data)
  const usedRange = sheet.getUsedRange();

  if (!usedRange) {
    return [];
  }

  // Get all values as 2D array
  const values = usedRange.getValues();

  if (values.length === 0) {
    return [];
  }

  // First row contains headers
  const headers = values[0];

  // Convert rows to JSON objects
  const jsonArray: object[] = [];

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    const rowObject: any = {};

    for (let j = 0; j < headers.length; j++) {
      const header = headers[j].toString();
      const value = row[j];

      // Remove spaces from header names for consistency
      const cleanHeader = header.replace(/\s+/g, '');
      rowObject[cleanHeader] = value !== null && value !== undefined ? value.toString() : '';
    }

    jsonArray.push(rowObject);
  }

  return jsonArray;
}
```

### Step 3: Save the Script
1. Click **Save script** button
2. The script is now available to use in Power Automate

**Important:** This script:
- Reads the "Data" worksheet
- Removes spaces from column headers (so "Document Number" becomes "DocumentNumber")
- Returns an array of JSON objects
- Handles null/undefined values

---

## Part 2: Update the Flow

### Delete Old Actions

Delete these actions:
- **Create_CSV_table** (the one causing the error)
- **Parse_CSV** (if you have it)

### Add "Run script" Action

**Step 1: Add Action**
1. Click **+** after "Get_SAP_file_content"
2. Search for: `excel run script`
3. Select **"Run script"** from Excel Online (Business)

**Step 2: Configure**

**Location:** SharePoint

**Document Library:**
- Site: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
- Library: `Shared Documents`

**File:**
- Switch to **Expression** (fx)
- Paste: `first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']`
- Click OK

**Script:**
- Select: `ConvertWorksheetToJSON`

**Step 3: Rename**
- Name: `Run_script_ConvertToJSON`

---

## Part 3: Update Apply_to_each Loop

### Update the foreach Source

**In the "Apply_to_each_row" action:**

**Old (if using Parse_CSV):**
```
@body('Parse_CSV')
```

**New:**
```
@body('Run_script_ConvertToJSON')?['result']
```

**Or in code view:**
```json
"Apply_to_each_row": {
  "type": "Foreach",
  "foreach": "@body('Run_script_ConvertToJSON')?['result']",
  "actions": { ... }
}
```

---

## Part 4: Update All Column References

Since the Office Script **removes spaces** from column names, update all references:

### In Create_transaction Action

Use column names **WITHOUT spaces:**

```json
{
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "entityName": "cr7bb_thfinancecashcollectiontransactions",
      "item/cr7bb_customer": "@{first(outputs('List_customer')?['body/value'])?['cr7bb_thfinancecashcollectioncustomerid']}",
      "item/cr7bb_recordtype": 676180000,
      "item/cr7bb_documentnumber": "@{items('Apply_to_each_row')?['DocumentNumber']}",
      "item/cr7bb_assignment": "@{items('Apply_to_each_row')?['Assignment']}",
      "item/cr7bb_documenttype": "@{items('Apply_to_each_row')?['DocumentType']}",
      "item/cr7bb_documentdate": "@{items('Apply_to_each_row')?['DocumentDate']}",
      "item/cr7bb_netduedate": "@{items('Apply_to_each_row')?['NetDueDate']}",
      "item/cr7bb_arrearsdays": "@{int(coalesce(items('Apply_to_each_row')?['ArrearsByNetDueDate'], 0))}",
      "item/cr7bb_amountlocalcurrency": "@{outputs('Compose_ParsedAmount')}",
      "item/cr7bb_textfield": "@{items('Apply_to_each_row')?['Text']}",
      "item/cr7bb_referenceinformation": "@{items('Apply_to_each_row')?['Reference']}",
      "item/cr7bb_transactiontype": "@{outputs('Compose_TransactionType')}",
      "item/cr7bb_isexcluded": "@{outputs('Compose_isExcluded')}",
      "item/cr7bb_excludereason": "@{if(outputs('Compose_isExcluded'), 'Keyword found in text field', null)}",
      "item/cr7bb_daycount": "@{int(coalesce(items('Apply_to_each_row')?['ArrearsByNetDueDate'], 0))}",
      "item/cr7bb_transactionprocessdate": "@{variables('varProcessDate')}",
      "item/cr7bb_processbatch": "@{variables('varBatchID')}",
      "item/cr7bb_rownumber": "@{variables('varRowCounter')}",
      "item/cr7bb_isprocessed": false,
      "item/cr7bb_emailsent": false
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps",
      "connection": "shared_commondataserviceforapps",
      "operationId": "CreateRecord"
    }
  },
  "runAfter": {
    "Compose_TransactionType": ["Succeeded"]
  }
}
```

### Update Other Actions Too

**Compose_ParsedAmount:**
```json
"inputs": "@float(replace(replace(string(items('Apply_to_each_row')?['AmountInLocalCurrency']), ',', ''), '\"', ''))"
```

**Check_if_Summary_Row:**
```json
"equals": [
  "@empty(items('Apply_to_each_row')?['DocumentNumber'])",
  "@true"
]
```

**Compose_isExcluded:**
```json
"inputs": "@or(contains(toLower(coalesce(items('Apply_to_each_row')?['Text'], '')), 'paid'), contains(toLower(coalesce(items('Apply_to_each_row')?['Text'], '')), 'partial payment'), contains(toLower(coalesce(items('Apply_to_each_row')?['Text'], '')), 'exclude'), contains(coalesce(items('Apply_to_each_row')?['Text'], ''), 'รักษาตลาด'), contains(toLower(coalesce(items('Apply_to_each_row')?['Text'], '')), 'bill credit 30 days'))"
```

**List_customer:**
```json
"$filter": "cr7bb_customercode eq '@{items('Apply_to_each_row')?['Account']}'"
```

---

## Complete Flow Structure

```
Get_files_(properties_only)
    ↓
Set_varFileName
    ↓
Create_Process_Log
    ↓
Set_varProcessLogID
    ↓
Get_SAP_file_content (SharePoint - get file binary)
    ↓
Run_script_ConvertToJSON (Office Script - convert to JSON array)
    ↓
Apply_to_each_row (foreach: @body('Run_script_ConvertToJSON')?['result'])
    ↓
    Create_transaction (uses DocumentNumber, NetDueDate, etc.)
```

---

## Complete JSON for Run Script Action

```json
"Run_script_ConvertToJSON": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@{first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']}",
      "script": "ConvertWorksheetToJSON"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "RunScript",
      "connectionName": "shared_excelonlinebusiness"
    }
  },
  "runAfter": {
    "Get_SAP_file_content": ["Succeeded"]
  }
}
```

**Wait - Issue!** The script needs the file to already be in SharePoint, but we're getting file content. Let me fix this...

**Actually, change the approach:**

Remove "Get_SAP_file_content" - the Run Script action can access the file directly!

### Corrected Run Script Action (Standalone)

```json
"Run_script_ConvertToJSON": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@{first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']}",
      "script": "ConvertWorksheetToJSON"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "RunScript",
      "connectionName": "shared_excelonlinebusiness"
    }
  },
  "runAfter": {
    "Set_varProcessLogID": ["Succeeded"]
  }
}
```

**Delete "Get_SAP_file_content"** - you don't need it anymore!

---

## Summary of Changes

### Delete:
- ❌ Get_SAP_file_content
- ❌ Create_CSV_table
- ❌ Parse_CSV (if exists)

### Add:
- ✅ Office Script in Excel Online: `ConvertWorksheetToJSON`
- ✅ Run script action in flow

### Update:
- ✅ Apply_to_each foreach: `@body('Run_script_ConvertToJSON')?['result']`
- ✅ All column references: Remove spaces (DocumentNumber, NetDueDate, etc.)

---

## Testing

1. Save the Office Script in Excel Online
2. Update the flow as described
3. Save the flow
4. Test with a real SAP file
5. Check that transactions are created correctly

---

## Troubleshooting

### Error: "Script 'ConvertWorksheetToJSON' not found"
**Fix:** Make sure you saved the script in Excel Online and it's available in your tenant

### Error: "Worksheet 'Data' not found"
**Fix:** Update the script to use the correct worksheet name (line 3 of the script)

### Error: "Cannot read property 'result'"
**Fix:** The script output path is `@body('Run_script_ConvertToJSON')` not `?['result']`. Try without `?['result']`

---

**Created:** 2025-01-08
**Purpose:** Use Office Scripts to convert Excel worksheet to JSON array
**Advantage:** No CSV conversion issues, handles any Excel file
**Requirement:** Microsoft 365 Business Standard or higher (for Office Scripts)
