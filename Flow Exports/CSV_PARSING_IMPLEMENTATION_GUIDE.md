# CSV Parsing Implementation Guide - SAP Import Flow

## Overview
This guide shows how to replace the Excel Table reading with CSV parsing to handle raw SAP worksheet exports.

---

## Problem Summary
- SAP exports raw Excel worksheet data (not formatted as Excel Tables)
- "List rows present in a table" action requires table format
- "List rows present in a worksheet" action is deprecated and unavailable

## Solution
Replace Excel connector with SharePoint file content retrieval + CSV parsing.

---

## Implementation Methods

### Method 1: Using Flow Designer (Easiest - Recommended)

**Step 1: Open Flow in Edit Mode**
1. Go to https://make.powerautomate.com
2. Click **Solutions** → **THFinanceCashCollection**
3. Open flow: **[THFinanceCashCollection] Daily SAP Transaction Import**
4. Click **Edit**

**Step 2: Delete the Old Action**
1. Scroll down to find **"List rows present in a table"** action
   - It's between "Set_varProcessLogID" and "Apply to each"
2. Click **⋯** (three dots) on the action
3. Select **Delete**
4. Confirm deletion

**Step 3: Add "Get file content" Action**
1. Click the **+** button between "Set_varProcessLogID" and "Apply to each"
2. Select **Add an action**
3. Search for: `sharepoint get file content`
4. Select **"Get file content"** from SharePoint connector

**Configure the action:**
- **Site Address:** Select `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
- **File Identifier:** Click in the field, then:
  1. Click **Expression** tab
  2. Paste: `first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']`
  3. Click **OK**

**Rename the action (recommended):**
- Click **⋯** → **Rename**
- Name it: `Get_SAP_file_content`

**Step 4: Add "Create CSV table" Action**
1. Click the **+** button below "Get_SAP_file_content"
2. Select **Add an action**
3. Search for: `create csv table`
4. Select **"Create CSV table"** from Data Operations

**Configure the action:**
- **From:** Click in the field
  1. Click **Dynamic content** tab
  2. Search for "File Content"
  3. Select **File Content** from "Get_SAP_file_content" action

**Rename the action (recommended):**
- Click **⋯** → **Rename**
- Name it: `Create_CSV_table`

**Step 5: Add "Parse JSON" Action**
1. Click the **+** button below "Create_CSV_table"
2. Select **Add an action**
3. Search for: `parse json`
4. Select **"Parse JSON"** from Data Operations

**Configure the action:**

**Content:** Click in the field
1. Click **Dynamic content** tab
2. Search for "Output"
3. Select **Output** from "Create_CSV_table" action

**Schema:** Click **"Generate from sample"** button and paste this JSON sample:
```json
[
  {
    "Account": "198609",
    "Document Number": "9974712914",
    "Assignment": "9974712914",
    "Document Type": "DR",
    "Document Date": "10/7/2025",
    "Net Due Date": "10/8/2025",
    "Arrears by Net Due Date": "-1",
    "Amount in Local Currency": "550,940.60",
    "Currency": "THB",
    "Text": "",
    "Reference": "SFA93603806"
  }
]
```

Click **Done**

**Rename the action (recommended):**
- Click **⋯** → **Rename**
- Name it: `Parse_CSV`

**Step 6: Update "Apply to each" Action**
1. Click on the **"Apply to each"** action to expand it
2. Click in the **"Select an output from previous steps"** field
3. Delete the current content
4. Click **Dynamic content** tab
5. Search for "Body"
6. Select **Body** from "Parse_CSV" action
   - Make sure you select from "Parse_CSV", not from other actions

**Step 7: Save the Flow**
1. Click **Save** button at the top
2. Wait for "Your flow is ready" message

**Step 8: Test the Flow**
1. Click **Test** button
2. Select **Manually**
3. Click **Test**
4. Click **Run flow**
5. Click **Done**
6. Monitor the execution

---

### Method 2: Manual Update via Code View (Faster)

**Step 1: Open Flow in Edit Mode**
1. Go to https://make.powerautomate.com
2. Click **Solutions** → **THFinanceCashCollection**
3. Open flow: **[THFinanceCashCollection] Daily SAP Transaction Import**
4. Click **Edit**

**Step 2: Access Code View**
1. Click **⋯** (three dots in top-right)
2. Select **Peek code**

**Step 3: Find and Delete Old Action**
Search for this block and DELETE it:
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
},
```

**Step 4: Add Three New Actions**
Paste these THREE actions where you deleted the old one:

```json
"Get_SAP_file_content": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "dataset": "https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions",
      "id": "@{first(outputs('Get_files_(properties_only)')?['body/value'])?['{Identifier}']}"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline",
      "operationId": "GetFileContent",
      "connectionName": "shared_sharepointonline"
    }
  },
  "runAfter": {
    "Set_varProcessLogID": ["Succeeded"]
  }
},
"Create_CSV_table": {
  "type": "Table",
  "inputs": {
    "from": "@body('Get_SAP_file_content')",
    "format": "CSV"
  },
  "runAfter": {
    "Get_SAP_file_content": ["Succeeded"]
  }
},
"Parse_CSV": {
  "type": "ParseJson",
  "inputs": {
    "content": "@body('Create_CSV_table')",
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
    "Create_CSV_table": ["Succeeded"]
  }
},
```

**Step 5: Update Apply_to_each Loop**
Find this line:
```json
"foreach": "@outputs('List_rows_present_in_a_table')?['body/value']",
```

Change to:
```json
"foreach": "@body('Parse_CSV')",
```

**Step 6: Update Apply_to_each RunAfter**
Find:
```json
"runAfter": {
  "List_rows_present_in_a_table": ["Succeeded"]
}
```

Change to:
```json
"runAfter": {
  "Parse_CSV": ["Succeeded"]
}
```

**Step 7: Save**
1. Click outside the code view panel to close
2. Click **Save** button
3. Wait for "Your flow is ready" confirmation

---

## What Changed - Technical Details

### Old Approach
```
Set_varProcessLogID
    ↓
List_rows_present_in_a_table (Excel connector - requires table format)
    ↓
Apply_to_each_row
```

### New Approach
```
Set_varProcessLogID
    ↓
Get_SAP_file_content (SharePoint connector - gets file binary)
    ↓
Create_CSV_table (Native action - converts Excel to CSV)
    ↓
Parse_CSV (Native action - parses CSV to JSON array)
    ↓
Apply_to_each_row
```

---

## Action Details

### 1. Get_SAP_file_content
- **Type**: SharePoint connector - GetFileContent
- **Purpose**: Retrieve the Excel file as binary content
- **Dynamic Reference**: Uses output from "Get_files_(properties_only)" action
- **Returns**: Binary file content

### 2. Create_CSV_table
- **Type**: Native "Table" action
- **Purpose**: Convert Excel binary to CSV format
- **Input**: Binary from Get_SAP_file_content
- **Format**: CSV
- **Returns**: CSV string

### 3. Parse_CSV
- **Type**: Native "Parse JSON" action
- **Purpose**: Convert CSV string to array of JSON objects
- **Schema**: Matches SAP export columns exactly
- **Returns**: Array of row objects with column properties

---

## Testing the Updated Flow

### Pre-Test Checklist
- ✅ Updated JSON saved successfully
- ✅ No syntax errors in code view
- ✅ SAP Excel file exists in SharePoint folder
- ✅ File modified within last 24 hours

### Test Steps
1. Click **Test** button in flow editor
2. Select **Manually**
3. Click **Test**
4. Click **Run flow**
5. Click **Done**
6. Monitor the run history

### Expected Results
✅ **Get_SAP_file_content**: Should retrieve file binary successfully
✅ **Create_CSV_table**: Should convert to CSV format
✅ **Parse_CSV**: Should parse into array of objects
✅ **Apply_to_each_row**: Should loop through all rows
✅ **Transactions created**: Should match row count in Excel

### Common Errors and Fixes

#### Error: "The template language expression 'body('Create_CSV_table')' cannot be evaluated"
**Cause**: Excel file is not being converted to CSV properly
**Fix**: Ensure the Excel file has data in the "Data" worksheet with headers in row 1

#### Error: "Invalid type. Expected Array but got String"
**Cause**: CSV parsing returned string instead of array
**Fix**: Check the Parse_CSV schema matches the CSV structure

#### Error: "The action 'Get_SAP_file_content' failed. The file could not be found"
**Cause**: File path or identifier is incorrect
**Fix**: Verify the "Get_files_(properties_only)" action returns a file

---

## Verification Checklist

After implementation, verify:

- ✅ Old "List_rows_present_in_a_table" action removed
- ✅ Three new actions added (Get file, Create CSV, Parse CSV)
- ✅ Apply_to_each foreach references `@body('Parse_CSV')`
- ✅ Apply_to_each runAfter references `Parse_CSV`
- ✅ Flow saves without errors
- ✅ Test run completes successfully
- ✅ Transactions created in Dataverse
- ✅ Process log updated correctly

---

## Benefits of CSV Parsing Approach

| Feature | Old Approach | New Approach |
|---------|-------------|--------------|
| **SAP Compatibility** | ❌ Requires table format | ✅ Works with raw exports |
| **File Reference** | ❌ Hardcoded file ID | ✅ Dynamic from SharePoint |
| **Maintenance** | ❌ Manual table creation | ✅ Zero maintenance |
| **Flexibility** | ❌ Only Excel tables | ✅ Any Excel format |
| **Reliability** | ❌ Breaks if table removed | ✅ Always works |

---

## Rollback Instructions

If you need to revert to the old approach:

1. Keep the backup export from Step 1
2. Import the backup solution
3. OR manually restore the "List_rows_present_in_a_table" action from backup

**Note**: The old approach will still have the hardcoded file ID issue, so you'd need to fix that separately.

---

## Next Steps After Implementation

1. ✅ Test with real SAP export file
2. ✅ Verify all transactions imported correctly
3. ✅ Check Process Log for completion status
4. ✅ Verify email summary sent
5. ✅ Run Email Engine flow to process transactions
6. Update the other flow fixes:
   - Apply lookup field syntax fix (DATAVERSE_FIELD_FIXES.md)
   - Apply runAfter dependency fix (FIX_RUNAFTER_DEPENDENCIES.md)

---

**Created:** 2025-01-08
**Issue:** Excel Table format requirement blocking SAP import
**Solution:** CSV parsing with dynamic file reference
**Status:** Ready to implement
