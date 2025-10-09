# Fix: Parse SAP Excel File Without Table Format

## Problem
SAP exports raw worksheet data (not Excel Tables), but flow uses "List rows present in a table" which requires table format.

## Solution: Use SharePoint "Get file content" + Parse in Flow

Replace the hardcoded "List_rows_present_in_a_table" action with dynamic file reading.

---

## Step 1: Remove the Old Action

**Delete this action:**
```json
"List_rows_present_in_a_table": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "01B47NF3BEUMVG4ZZQNBDZFRXT2ZRQNNPG",
      "table": "{778FFA65-BF8B-432D-8C1E-2B933455CD27}"
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

---

## Step 2: Add "Get file content" Action

**Add this SharePoint action after "Get_file_metadata":**

```json
"Get_SAP_file_content": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline",
      "operationId": "GetFileContent",
      "connectionName": "shared_sharepointonline"
    },
    "parameters": {
      "dataset": "https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions",
      "id": "@outputs('Get_file_metadata')?['body/{Identifier}']"
    }
  },
  "runAfter": {
    "Set_varProcessLogID": ["Succeeded"]
  }
}
```

---

## Step 3: Add "Create CSV table" Action

Convert Excel binary to CSV format:

```json
"Convert_to_CSV": {
  "type": "Table",
  "inputs": {
    "from": "@body('Get_SAP_file_content')",
    "format": "CSV"
  },
  "runAfter": {
    "Get_SAP_file_content": ["Succeeded"]
  }
}
```

---

## Step 4: Add "Parse CSV" Action

Parse the CSV into array of objects:

```json
"Parse_CSV": {
  "type": "ParseJson",
  "inputs": {
    "content": "@body('Convert_to_CSV')",
    "schema": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "Account": {"type": "string"},
          "Document Number": {"type": "string"},
          "Assignment": {"type": "string"},
          "Document Type": {"type": "string"},
          "Document Date": {"type": "string"},
          "Net Due Date": {"type": "string"},
          "Arrears by Net Due Date": {"type": "string"},
          "Amount in Local Currency": {"type": "string"},
          "Currency": {"type": "string"},
          "Text": {"type": "string"},
          "Reference": {"type": "string"}
        }
      }
    }
  },
  "runAfter": {
    "Convert_to_CSV": ["Succeeded"]
  }
}
```

---

## Step 5: Update "Apply_to_each_row" Loop

Change the foreach source:

**Old:**
```json
"foreach": "@outputs('List_rows_present_in_a_table')?['body/value']"
```

**New:**
```json
"foreach": "@body('Parse_CSV')"
```

---

## Alternative: Simpler Approach Using Excel Connector Differently

Actually, there's an **easier way** - just fix the existing action to use the dynamic file:

### Keep "List_rows_present_in_a_table" but fix it:

```json
"List_rows_present_in_a_table": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@outputs('Get_file_metadata')?['body/{Identifier}']",
      "table": "{778FFA65-BF8B-432D-8C1E-2B933455CD27}"
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

**But you still need the table to exist in the Excel file.**

---

## Recommended: Ask SAP Export to Include Table Format

**Best long-term solution:**

Contact whoever manages the SAP export and ask them to format the data as an Excel Table before saving:

1. Select all data in Excel
2. Press Ctrl + T
3. Name the table "SAPData"
4. Save as template

Then in the flow, use:
```json
"table": "SAPData"
```

---

## Which Option to Choose?

| Option | Pros | Cons |
|--------|------|------|
| **CSV Parse** | Works with any format | More actions, slower |
| **Fix table ID** | Simple one-line fix | Still needs table format |
| **Change SAP export** | Best performance | Requires SAP team coordination |

**Recommendation:** Start with **CSV Parse** (Steps 1-5) to get it working now, then optimize later.

---

**Created:** 2025-01-08
**Status:** Ready to implement
