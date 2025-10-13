# Manual SAP Upload Flow - Implementation Notes

**Status**: ⚠️ **REQUIRES SIGNIFICANT IMPLEMENTATION** (Large flow - 600+ lines)

**File**: `THFinanceCashCollectionManualSAPUpload-FBAB356C-96A7-F011-BBD2-002248572CF8.json`

---

## 📋 Overview

The Manual SAP Upload flow is essentially a **PowerApps-triggered version** of the SAP Import flow. It allows AR users to manually trigger SAP file processing from the Canvas App instead of waiting for the daily scheduled run.

---

## 🔄 Implementation Strategy

**Option 1: Duplicate SAP Import Flow** (Recommended)
- Copy the entire actions section from completed SAP Import flow
- Change trigger from Recurrence to PowerAppV2
- Add input parameter: `FilePath` (string)
- Replace file search logic with direct file path usage
- Add PowerApps response at the end

**Option 2: Reference SAP Import as Child Flow** (Cleaner but requires Premium)
- Create a child flow call to SAP Import
- Pass parameters to child flow
- Return response to PowerApps

---

## 📝 Required Changes from SAP Import

### 1. **Trigger Change**

**From** (SAP Import):
```json
"triggers": {
  "Recurrence": {
    "type": "Recurrence",
    "recurrence": {
      "frequency": "Day",
      "interval": 1,
      "timeZone": "SE Asia Standard Time",
      "startTime": "2025-10-13T00:00:00Z",
      "schedule": {
        "hours": ["8"],
        "minutes": [0]
      }
    }
  }
}
```

**To** (Manual SAP Upload):
```json
"triggers": {
  "manual": {
    "type": "Request",
    "kind": "PowerAppV2",
    "inputs": {
      "schema": {
        "type": "object",
        "properties": {
          "text": {
            "title": "FilePath",
            "type": "string",
            "description": "SharePoint file path to process",
            "x-ms-content-hint": "TEXT"
          }
        },
        "required": ["text"]
      }
    }
  }
}
```

### 2. **File Path Handling**

**Remove** from SAP Import:
- `Get_files_(properties_only)` action (searches for files)
- File modified date filter

**Add** to Manual SAP Upload:
- Accept `FilePath` parameter from PowerApps trigger
- Use provided path directly: `@triggerBody()['text']`

**Example**:
```json
"Initialize_varSourceFilePath": {
  "inputs": {
    "variables": [{
      "name": "varSourceFilePath",
      "type": "string",
      "value": "@triggerBody()['text']"
    }]
  }
}
```

### 3. **Get File Properties**

Instead of searching, get specific file:
```json
"Get_File_Properties": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "dataset": "https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions",
      "id": "@variables('varSourceFilePath')"
    },
    "host": {
      "connectionName": "shared_sharepointonline",
      "operationId": "GetFileMetadata",
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
    }
  }
}
```

### 4. **PowerApps Response**

**Add at end** (after all processing):
```json
"Respond_to_PowerApp": {
  "runAfter": {
    "Update_Process_Log": ["Succeeded", "Failed"]
  },
  "type": "Response",
  "kind": "PowerApp",
  "inputs": {
    "statusCode": 200,
    "body": {
      "status": "@if(greater(variables('varErrorCount'), 0), 'Failed', 'Success')",
      "message": "Processed @{variables('varTransactionCount')} transactions with @{variables('varErrorCount')} errors",
      "rowCount": "@variables('varTransactionCount')",
      "processLogID": "@variables('varProcessLogID')"
    },
    "schema": {
      "type": "object",
      "properties": {
        "status": {"type": "string"},
        "message": {"type": "string"},
        "rowCount": {"type": "integer"},
        "processLogID": {"type": "string"}
      }
    }
  }
}
```

---

## 📦 Actions to Copy from SAP Import

**Keep ALL of these actions** (with modifications noted above):

1. ✅ All variable initializations (varProcessDate, varBatchID, varFileName, etc.)
2. ✅ `Set_varSourceFilePath` (but use trigger input)
3. ✅ `Condition_Check_File_Already_Processed`
4. ✅ `Create_Process_Log`
5. ✅ `Set_varProcessLogID`
6. ✅ `List_rows_in_table` (Excel processing)
7. ✅ `Apply_to_each_row` (entire loop with all nested actions)
   - Transaction creation
   - FIFO logic
   - Exclusion rules
   - Error handling
8. ✅ `Copy_File_with_Processed_Suffix`
9. ✅ `Delete_Original_File`
10. ✅ `Update_Process_Log`
11. ✅ `Send_Summary_Email` (optional - may want to skip for manual runs)
12. ➕ **ADD**: `Respond_to_PowerApp` (new action)

---

## 🎯 Testing Checklist

After implementation:

- [ ] Flow accepts FilePath parameter from PowerApps
- [ ] Flow processes specified file (not search)
- [ ] All file tracking works (sourcefilename, sourcefilepath)
- [ ] Duplicate detection works (skips _Processed files)
- [ ] Transactions created with all fields
- [ ] File renamed after processing
- [ ] Process Log created and updated
- [ ] PowerApps receives response with status and counts
- [ ] Error handling returns errors to PowerApps

---

## 📊 Complexity Estimate

- **Lines of code**: ~650 lines (similar to SAP Import)
- **Time to implement**: 30-45 minutes (copy + modify)
- **Risk**: Low (duplicates tested SAP Import flow)

---

## 🚀 Quick Implementation Steps

1. Read entire SAP Import flow actions section (line 94-650)
2. Copy to Manual SAP Upload, replacing existing actions
3. Change trigger to PowerAppV2 with FilePath parameter
4. Replace `Get_files_(properties_only)` with `Get_File_Properties` using trigger input
5. Remove `Set_varFileName` action (get from file properties instead)
6. Add `Respond_to_PowerApp` action at end
7. Update connection references if needed
8. Test with sample file path from PowerApps

---

## ⚠️ Important Notes

- Manual SAP Upload does NOT skip the scheduled run - they are independent
- Both flows write to same tables (Transactions, Process Logs)
- Use `varProcessDate` to distinguish manual vs scheduled runs
- Consider adding "Manual" flag to Process Log for reporting
- Keep all business logic identical to SAP Import (FIFO, exclusions, etc.)

---

## 📚 Reference Files

- **Source flow**: [THFinanceCashCollectionDailySAPTransactionImport-*.json](file:///E:/NestlePowerApp/Finance-CashCustomerCollection/Powerapp%20solution%20Export/THFinanceCashCollection_1_0_0_4/Workflows/THFinanceCashCollectionDailySAPTransactionImport-CF8144D2-A3A3-F011-BBD2-002248572D93.json) (COMPLETED)
- **Target flow**: [THFinanceCashCollectionManualSAPUpload-*.json](file:///E:/NestlePowerApp/Finance-CashCustomerCollection/Powerapp%20solution%20Export/THFinanceCashCollection_1_0_0_4/Workflows/THFinanceCashCollectionManualSAPUpload-FBAB356C-96A7-F011-BBD2-002248572CF8.json) (NEEDS WORK)
- **Specification**: [FLOW_MODIFICATIONS_SPECIFICATION.md](file:///E:/NestlePowerApp/Finance-CashCustomerCollection/FLOW_MODIFICATIONS_SPECIFICATION.md) line 710-850
