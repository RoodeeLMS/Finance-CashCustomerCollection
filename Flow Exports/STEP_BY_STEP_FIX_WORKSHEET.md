# Step-by-Step: Fix SAP Import Flow to Read Worksheet "Data"

## Problem
Flow uses hardcoded file ID and tries to read Excel Table, but SAP exports raw worksheet data.

## Solution
Change the action to read from worksheet "Data" with dynamic file reference.

---

## Steps in Power Automate Flow Editor

### Step 1: Open the Flow
1. Go to https://make.powerautomate.com
2. Click **Solutions** in left menu
3. Open **THFinanceCashCollection** solution
4. Click on flow **"[THFinanceCashCollection] Daily SAP Transaction Import"**
5. Click **Edit** button

### Step 2: Find the Problem Action
1. Scroll down to find the action named **"List rows present in a table"**
2. It should be right after **"Set_varProcessLogID"** action
3. Click on the action to expand it

### Step 3: Delete the Old Action
1. Click the **⋯** (three dots) in the top-right corner of the action
2. Select **Delete**
3. Confirm deletion

### Step 4: Add New Action
1. Click the **+ (plus)** button where the old action was (between "Set_varProcessLogID" and "Apply_to_each_row")
2. Select **Add an action**
3. Search for: `excel list rows worksheet`
4. Select **"List rows present in a worksheet"** from Excel Online (Business) connector

### Step 5: Configure the New Action
Fill in the parameters:

**Location:** `SharePoint`

**Document Library:** Click dropdown and select:
- Site: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
- Library: `Shared Documents`

**File:** Click the folder icon, then switch to **"Custom value"** (lightning bolt icon)
- Paste this expression:
```
outputs('Get_file_metadata')?['body/{Identifier}']
```

**Table:** Type: `Data`

### Step 6: Rename the Action (Optional but Recommended)
1. Click the **⋯** (three dots) on the action
2. Select **Rename**
3. Name it: `List_rows_in_worksheet_Data`

### Step 7: Verify the "Apply to each" Loop
1. Click on the **"Apply_to_each_row"** action below
2. Check the **"Select an output from previous steps"** field
3. It should automatically update to reference the new action
4. If not, manually select: `value` from the new "List rows in worksheet Data" action

### Step 8: Save the Flow
1. Click **Save** button at the top
2. Wait for "Your flow is ready" message

### Step 9: Test the Flow
1. Make sure there's a SAP Excel file in: `/Shared Documents/Cash Customer Collection/01-Daily-SAP-Data/Current/`
2. Click **Test** button
3. Select **Manually**
4. Click **Test**
5. Click **Run flow**
6. Click **Done**
7. Wait for the flow to complete
8. Check for any errors

---

## Verification Checklist

After completing the steps, verify:

- ✅ Old "List rows present in a table" action is deleted
- ✅ New "List rows present in a worksheet" action exists
- ✅ File parameter uses dynamic expression (not hardcoded ID)
- ✅ Worksheet parameter = "Data"
- ✅ "Apply_to_each_row" references the new action
- ✅ Flow saves without errors
- ✅ Test run completes successfully

---

## If You Get Errors

### Error: "File not found"
**Fix:** Check the "Get_file_metadata" action runs before the new action
- The new action must have `"runAfter": { "Set_varProcessLogID": ["Succeeded"] }`

### Error: "Worksheet not found"
**Fix:** Verify the worksheet name is exactly "Data" (case-sensitive)
- Open the Excel file and check the worksheet tab name

### Error: "Column not found"
**Fix:** Verify the Excel file has headers in row 1 matching:
- Account, Document Number, Assignment, Document Type, etc.

---

## Alternative: Edit in Code View (Advanced)

If you prefer editing JSON directly:

### Step 1: Open Code View
1. In the flow editor, click **⋯** (top-right)
2. Select **Peek code**

### Step 2: Find the Action
Search for: `"List_rows_present_in_a_table"`

### Step 3: Replace the JSON
Replace this entire block:

**OLD:**
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

**NEW:**
```json
"List_rows_in_worksheet_Data": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "source": "groups/02ebed5f-6782-4117-8509-f2a24646f258",
      "drive": "b!-jBuElvcHUepxeIS8jlWyaETtSFBsJBGqCTRaDVYBTQs-l439a4iRbJ_XNJ0mnSo",
      "file": "@outputs('Get_file_metadata')?['body/{Identifier}']",
      "worksheet": "Data"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness",
      "operationId": "GetWorksheetRows",
      "connectionName": "shared_excelonlinebusiness"
    }
  },
  "runAfter": {
    "Set_varProcessLogID": ["Succeeded"]
  }
}
```

### Step 4: Update the Apply_to_each Reference
Find the "Apply_to_each_row" action and update:

**OLD:**
```json
"foreach": "@outputs('List_rows_present_in_a_table')?['body/value']"
```

**NEW:**
```json
"foreach": "@outputs('List_rows_in_worksheet_Data')?['body/value']"
```

### Step 5: Save
1. Click outside the code view to close
2. Click **Save**

---

## Summary of Changes

| What Changed | Old Value | New Value |
|--------------|-----------|-----------|
| Action Name | `List_rows_present_in_a_table` | `List_rows_in_worksheet_Data` |
| Operation | `GetItems` (table) | `GetWorksheetRows` (worksheet) |
| File Parameter | Hardcoded ID | Dynamic expression |
| Table/Worksheet | Table GUID | `"Data"` (worksheet name) |

---

**Created:** 2025-01-08
**Issue:** Flow reads wrong file and expects Excel Table format
**Fix:** Use worksheet reader with dynamic file reference
