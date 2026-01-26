# Step-by-Step: QR Code Availability Check Flow

**Date**: January 26, 2026
**Flow Names**:
- `[THFinance] Check QR Availability` - Main flow (child)
- `[THFinance] CheckQRAvailability(PowerApps)` - PowerApps wrapper (parent)

**Purpose**: Scan all customers and update `cr7bb_qrcodeavailable` field based on QR file existence in SharePoint
**Trigger**: Called from Power Apps via wrapper flow

---

## Architecture

```
Power Apps (scnCustomer)
    │
    └─── '[THFinance]CheckQRAvailability(PowerApps)'.Run()
              │
              └─── [THFinance] Check QR Availability (Child Flow)
                        │
                        └─── Response to Power Apps
```

---

## Overview

This flow checks if QR code files exist in SharePoint for each customer and updates their `cr7bb_qrcodeavailable` field accordingly.

**QR File Location**: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions/Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/`

**File Naming Convention**: `{CustomerCode}.jpg` (e.g., `12345678.jpg`)

---

## Flow Structure

```
[Manually trigger a flow] OR [Recurrence]
  │
  ├── Initialize varUpdatedCount (Integer = 0)
  ├── Initialize varNotFoundCount (Integer = 0)
  │
  ├── List_All_Customers (Dataverse)
  │
  ├── Apply to each Customer
  │   │
  │   ├── Get_QR_File (SharePoint - Get file metadata by path)
  │   │   Path: /Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/{CustomerCode}.jpg
  │   │
  │   ├── Condition: File exists? (based on action success/failure)
  │   │   │
  │   │   ├── Yes: Update Customer (cr7bb_qrcodeavailable = true)
  │   │   │        Increment varUpdatedCount
  │   │   │
  │   │   └── No: Update Customer (cr7bb_qrcodeavailable = false)
  │   │           Increment varNotFoundCount
  │
  └── Log Completion (Process Log)
```

---

## Step-by-Step Implementation

### Step 1: Create Flow

1. Go to **make.powerautomate.com**
2. Click **+ Create** → **Instant cloud flow**
3. Name: `[THFinance] Check QR Availability`
4. Trigger: **Manually trigger a flow**
5. Click **Create**

---

### Step 2: Initialize Variables

**Variable 1: varUpdatedCount**
```
Name: varUpdatedCount
Type: Integer
Value: 0
```

**Variable 2: varNotFoundCount**
```
Name: varNotFoundCount
Type: Integer
Value: 0
```

---

### Step 3: List All Customers

**Action**: List rows (Dataverse)
```
Table name: [THFinanceCashCollection]Customers
Select columns: cr7bb_thfinancecashcollectioncustomerid,cr7bb_customercode,cr7bb_qrcodeavailable
```
Rename to: `List_All_Customers`

---

### Step 4: Apply to Each Customer

**Action**: Apply to each
```
Select an output: @{outputs('List_All_Customers')?['body/value']}
```

**Settings** (click ... → Settings):
- Concurrency Control: **On**
- Degree of Parallelism: **20** (for faster processing)

---

### Step 5: Inside Loop - Check File Exists

**Action**: Get file metadata using path (SharePoint)
```
Site Address: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions
File Path: /Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/@{items('Apply_to_each')?['cr7bb_customercode']}.jpg
```
Rename to: `Get_QR_File`

**Configure run after** (click ... → Configure run after):
- Check: ✅ is successful
- Check: ✅ has failed

> This allows the flow to continue whether the file exists or not.

---

### Step 6: Inside Loop - Condition

**Action**: Condition
```
Condition: @{outputs('Get_QR_File')?['statusCode']} is equal to 200
```

**Alternative** (if statusCode not available):
```
Condition: @{not(empty(outputs('Get_QR_File')?['body/Id']))} is equal to true
```

---

### Step 7: If Yes (File Exists)

**7A. Update Customer Record**
```
Table name: [THFinanceCashCollection]Customers
Row ID: @{items('Apply_to_each')?['cr7bb_thfinancecashcollectioncustomerid']}
QR Code Available: Yes
```
Rename to: `Update_Customer_QR_True`

**7B. Increment Counter**
```
Name: varUpdatedCount
Value: 1
```

---

### Step 8: If No (File Not Found)

**8A. Update Customer Record**
```
Table name: [THFinanceCashCollection]Customers
Row ID: @{items('Apply_to_each')?['cr7bb_thfinancecashcollectioncustomerid']}
QR Code Available: No
```
Rename to: `Update_Customer_QR_False`

**8B. Increment Counter**
```
Name: varNotFoundCount
Value: 1
```

---

### Step 9: Log Completion (After Loop)

**Action**: Add a new row (Dataverse)
```
Table name: [THFinanceCashCollection]ProcessLogs
Fields:
  cr7bb_processdate: @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
  cr7bb_starttime: @{utcNow()}
  cr7bb_endtime: @{utcNow()}
  cr7bb_status: Completed
  cr7bb_processtype: QRAvailabilityCheck
  cr7bb_summary: QR check complete. Found: @{variables('varUpdatedCount')}, Not Found: @{variables('varNotFoundCount')}
```

---

## Alternative: Scheduled Trigger

To run automatically (e.g., weekly):

1. Change trigger to **Recurrence**
2. Configure:
   - Frequency: Week
   - Interval: 1
   - On these days: Monday
   - At these hours: 6
   - At these minutes: 0
   - Time zone: SE Asia Standard Time

---

## Expected Results

After running the flow, the Customer table will show accurate QR availability:

| Customer Code | QR Available |
|---------------|--------------|
| 12345678 | ✅ Yes |
| 23456789 | ❌ No |
| 34567890 | ✅ Yes |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| All customers show "No" | Verify SharePoint path is correct |
| Flow times out | Reduce concurrency or split into batches |
| File not found but exists | Check file extension (.jpg vs .jpeg) |
| Permission denied | Verify connection has access to SharePoint folder |

---

## Performance Notes

| Customer Count | Approximate Time (Concurrency=20) |
|----------------|-----------------------------------|
| 50 customers | 1-2 minutes |
| 100 customers | 2-4 minutes |
| 200 customers | 4-8 minutes |

---

## Integration with Power Apps

After running this flow, the Customer table automatically reflects QR availability. The `cr7bb_qrcodeavailable` column is already shown in the scnCustomer table view.

**Button on scnCustomer**: "QR Folder" opens SharePoint folder for manual upload.

---

---

## Flow 2: PowerApps Wrapper Flow (Detailed)

This flow enables calling the QR check from Power Apps. It wraps the main flow as a child flow.

---

### Step 1: Create Wrapper Flow

1. Go to **make.powerautomate.com**
2. Click **+ Create** → **Instant cloud flow**
3. Name: `[THFinance] CheckQRAvailability(PowerApps)`
4. Trigger: **PowerApps (V2)**
5. Click **Create**

---

### Step 2: Initialize Status Variable

**Action**: Initialize variable
```
Name: varStatus
Type: String
Value: Starting
```

---

### Step 3: Add Scope for Error Handling

**Action**: Scope
```
Name: Scope_RunQRCheck
```

Inside the Scope, add the child flow call:

---

### Step 4: Inside Scope - Call Child Flow

**Action**: Run a Child Flow

1. Click **+ New step** inside the Scope
2. Search for "Run a Child Flow"
3. Select your child flow: `[THFinance] Check QR Availability`

Rename to: `Run_QR_Check`

> **CRITICAL**: The child flow MUST have a **Response** action. See Step 7 below.

---

### Step 5: After Scope - Set Success Status

**Action**: Set variable
```
Name: varStatus
Value: Success
```

**Configure run after** (click ... → Configure run after):
- ✅ is successful

---

### Step 6: After Scope - Set Failed Status (Parallel Branch)

**Action**: Set variable
```
Name: varStatus
Value: Failed
```

**Configure run after** (click ... → Configure run after):
- ✅ has failed
- ✅ has timed out

---

### Step 7: Add Response to PowerApps

**Action**: Respond to a PowerApp or flow

1. Click **+ Add an output**
2. Select **Text**
   - Name: `Status`
   - Value: `@{variables('varStatus')}`
3. Click **+ Add an output** again
4. Select **Text**
   - Name: `Message`
   - Value: `QR availability check @{variables('varStatus')}`

---

### Step 8: Update Child Flow (REQUIRED - Add Response)

**Go back to** `[THFinance] Check QR Availability` and add Response at the end:

1. Open the child flow
2. After the "Log Completion" action, add:

**Action**: Respond to a PowerApp or flow
```
Click "+ Add an output":
  - Type: Number
    Name: FoundCount
    Value: @{variables('varUpdatedCount')}

  - Type: Number
    Name: NotFoundCount
    Value: @{variables('varNotFoundCount')}
```

3. **Save** the child flow

> **Why Response is Required**: Without a Response action, the child flow call will fail with error: "Action 'Run_a_Child_Flow' has defined a child flow that does not end with a response action."

---

### Complete Wrapper Flow Structure

```
[PowerApps (V2)] Trigger
  │
  ├── Initialize varStatus = "Starting"
  │
  ├── ═══ Scope: Scope_RunQRCheck ═══
  │   │
  │   └── Run_QR_Check (Child Flow)
  │           └── Returns: FoundCount, NotFoundCount
  │
  ├── Set varStatus = "Success"        [runs if Scope succeeded]
  │
  ├── Set varStatus = "Failed"         [runs if Scope failed/timed out]
  │
  └── Respond to a PowerApp or flow
        - Status: @{variables('varStatus')}
        - Message: "QR availability check @{variables('varStatus')}"
```

---

### Complete Child Flow Structure (Updated)

```
[Manually trigger a flow]
  │
  ├── Initialize varUpdatedCount = 0
  ├── Initialize varNotFoundCount = 0
  │
  ├── List_All_Customers
  │
  ├── Apply to each Customer (Concurrency: 20)
  │   │
  │   ├── Get_QR_File (SharePoint)
  │   │
  │   └── Condition: File exists?
  │       ├── Yes: Update cr7bb_qrcodeavailable = true
  │       │        Increment varUpdatedCount
  │       │
  │       └── No: Update cr7bb_qrcodeavailable = false
  │               Increment varNotFoundCount
  │
  ├── Log Completion (Process Log)
  │
  └── Respond to a PowerApp or flow    ⭐ REQUIRED
        - FoundCount: @{variables('varUpdatedCount')}
        - NotFoundCount: @{variables('varNotFoundCount')}
```

---

### Testing the Flow

1. **Save** both flows
2. Go to the wrapper flow `[THFinance] CheckQRAvailability(PowerApps)`
3. Click **Test** → **Manually** → **Test**
4. Flow should complete successfully
5. Verify:
   - Child flow was called
   - Response shows Status = "Success"
   - Customer records updated in Dataverse

---

### Troubleshooting

| Issue | Solution |
|-------|----------|
| "Child flow does not end with response action" | Add Response action to child flow |
| Flow times out | Increase timeout or reduce customer count |
| Permission denied on SharePoint | Verify connection has access |
| Child flow not found | Ensure child flow is saved and in same environment |

---

## Power Apps Integration

### Button on scnCustomer Action Bar

```yaml
- Customer_CheckQRBtn:
    Control: Button@0.0.45
    Properties:
      BasePaletteColor: =RGBA(0, 101, 161, 1)
      Height: =35
      Icon: ="Sync"
      OnSelect: |-
        =UpdateContext({_isCheckingQR: true});
        '[THFinance]CheckQRAvailability(PowerApps)'.Run();
        Refresh('[THFinanceCashCollection]Customers');
        UpdateContext({_isCheckingQR: false});
        Notify("QR availability updated for all customers", NotificationType.Success)
      Text: ="Check QR"
      Width: =110
```

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-26 | Initial step-by-step guide |
| 2026-01-26 | Added PowerApps wrapper flow pattern |
