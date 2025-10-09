# Fix: Excel Table Issue - SAP Import Flow

## Problem
The SAP files are automatically generated from SAP as **raw worksheet data** (not Excel Tables), but the flow uses "List rows present in a table" which requires Excel Table format.

**Current action that fails:**
```json
{
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "01B47NF3BEUMVG4ZZQNBDZFRXT2ZRQNNPG",
      "table": "{778FFA65-BF8B-432D-8C1E-2B933455CD27}"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "GetItems"
    }
  }
}
```

## Solution Options

### Option 1: Use Excel Online Script (Recommended)
Add an action BEFORE the "List rows" action to convert the worksheet to a table programmatically.

**New action: "Run script"**
```json
{
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@outputs('Get_file_metadata')?['body/Id']",
      "script": "ConvertToTable"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "RunScript"
    }
  },
  "runAfter": {
    "Get_file_metadata": ["Succeeded"]
  }
}
```

**Office Script to create (in Excel Online):**
```typescript
function main(workbook: ExcelScript.Workbook) {
  // Get the first worksheet
  const sheet = workbook.getWorksheets()[0];

  // Get the used range
  const usedRange = sheet.getUsedRange();

  // Check if table already exists
  const tables = sheet.getTables();
  if (tables.length > 0) {
    return { tableName: tables[0].getName() };
  }

  // Create table from used range
  const table = sheet.addTable(usedRange, true);
  table.setName("SAPData");

  return { tableName: "SAPData" };
}
```

**Then update "List rows present in a table":**
```json
{
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@outputs('Get_file_metadata')?['body/Id']",
      "table": "SAPData"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "GetItems"
    }
  },
  "runAfter": {
    "Run_script": ["Succeeded"]
  }
}
```

### Option 2: Use "Get worksheet" action (Alternative)
Replace "List rows present in a table" with worksheet-based actions.

**Not recommended** because Excel connector worksheet actions are deprecated.

### Option 3: Parse CSV instead
If SAP can export as CSV instead of Excel, use "Parse CSV" action.

**Requires:** SAP export format change from .xlsx to .csv

## Recommended Approach

**Use Option 1 (Office Script)** because:
- ✅ Handles raw SAP exports automatically
- ✅ Works with dynamic files
- ✅ No manual intervention needed
- ✅ Table is created fresh each time

**Steps to implement:**
1. Open Excel Online (https://www.office.com/launch/excel)
2. Go to Automate → New Script
3. Paste the TypeScript code above
4. Save as "ConvertToTable"
5. Add "Run script" action in the flow (before "List rows")
6. Update "List rows" to use `"table": "SAPData"`

## Notes
- Office Scripts require **Microsoft 365 Business Standard** or higher license
- Script runs on the Excel file in SharePoint automatically
- Creates table with name "SAPData" if it doesn't exist
- Returns existing table name if already exists

---
**Created:** 2025-01-08
**Issue:** SAP exports are raw worksheets, not Excel Tables
**Status:** Pending implementation
