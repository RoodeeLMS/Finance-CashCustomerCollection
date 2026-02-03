# Flow: Reset Today's Transaction Status

> **Type**: Manual/On-Demand Flow
> **Purpose**: Reset all transaction statuses processed today and delete today's email logs
> **Use Case**: Re-run the Daily Collections Email Engine after fixing issues (clean slate)
> **Created**: 2026-01-29

---

## Overview

This flow resets all transactions that were processed today and deletes today's email logs, allowing the Daily Collections Email Engine to be re-run with a clean slate.

### Transaction Fields Reset:

| Field | Reset Value |
|-------|-------------|
| `cr7bb_isprocessed` | No |
| `cr7bb_isexcluded` | No |
| `cr7bb_emailsent` | No |
| `cr7bb_excludereason` | (blank) |

### Records Deleted:

| Table | Filter Criteria |
|-------|-----------------|
| EmailLogs | `cr7bb_processdate` = Today (DateTime range) |

---

## Prerequisites

1. Open **Power Automate** → **Solutions** → **TH Finance Cash Collection**
2. Click **+ New** → **Automation** → **Cloud flow** → **Instant cloud flow**
3. Name: `Reset Today Transaction Status`
4. Trigger: **Manually trigger a flow**
5. Click **Create**

---

## Step-by-Step Instructions

### Step 1: Add Manual Trigger

The flow starts with "Manually trigger a flow" (already added when creating).

**Optional**: Add an input to confirm the date:
1. Click on the trigger
2. Click **+ Add an input** → **Date**
3. Label: `Reset Date (leave blank for today)`

---

### Step 2: Initialize Variable for Today's Date

1. Click **+** → **Add an action**
2. Search for `Initialize variable`
3. Select **Variable** → **Initialize variable**
4. Configure:

| Field | Value |
|-------|-------|
| **Name** | `varResetDate` |
| **Type** | String |
| **Value** | *(see expression below)* |

5. For **Value**, click **Expression** tab and enter:
```
if(empty(triggerBody()?['date']), formatDateTime(utcNow(), 'yyyy-MM-dd'), formatDateTime(triggerBody()?['date'], 'yyyy-MM-dd'))
```

This uses today's date if no date is provided, otherwise uses the input date.

---

### Step 3: List Transactions to Reset

1. Click **+** → **Add an action**
2. Search for `List rows`
3. Select **Microsoft Dataverse** → **List rows**
4. **Rename** to: `List_Transactions_To_Reset`
5. Configure:

| Field | Value |
|-------|-------|
| **Table name** | Transactions *(or THFinanceCashCollectionTransactions)* |
| **Filter rows** | *(see below)* |

6. For **Filter rows**, enter:
```
cr7bb_transactionprocessdate eq '@{variables('varResetDate')}' and (cr7bb_isprocessed eq true or cr7bb_emailsent eq true or cr7bb_isexcluded eq true)
```

**Alternative filter** (if the above doesn't work with string date):
```
cr7bb_transactionprocessdate eq @{variables('varResetDate')} and (cr7bb_isprocessed eq true or cr7bb_emailsent eq true or cr7bb_isexcluded eq true)
```

---

### Step 4: Count Records (Optional - for logging)

1. Click **+** → **Add an action**
2. Search for `Compose`
3. Select **Data Operation** → **Compose**
4. **Rename** to: `Count_Records`
5. For **Inputs**, click **Expression** and enter:
```
length(outputs('List_Transactions_To_Reset')?['body/value'])
```

---

### Step 5: Check if Records Exist

1. Click **+** → **Add an action**
2. Search for `Condition`
3. Select **Control** → **Condition**
4. **Rename** to: `Check_Has_Records`
5. Configure condition:
   - Left side: Click **Expression** → `outputs('Count_Records')`
   - Operator: **is greater than**
   - Right side: `0`

---

### Step 6: Reset Each Transaction (Yes Branch)

1. In the **Yes** branch, click **+** → **Add an action**
2. Search for `Apply to each`
3. Select **Control** → **Apply to each**
4. **Rename** to: `Reset_Each_Transaction`
5. For **Select an output from previous steps**:
   - Click the input field
   - Select **Dynamic content** → `value` from `List_Transactions_To_Reset`

6. Inside the loop, click **+** → **Add an action**
7. Search for `Update a row`
8. Select **Microsoft Dataverse** → **Update a row**
9. **Rename** to: `Update_Transaction_Reset`
10. Configure:

| Field | Value |
|-------|-------|
| **Table name** | Transactions |
| **Row ID** | *(Dynamic content)* `Transaction` from current item |
| **Is Processed** | No |
| **Is Excluded** | No |
| **Email Sent** | No |
| **Exclude Reason** | *(leave blank or type a single space then delete)* |

**For Row ID using Expression** (if dynamic content doesn't show):
```
items('Reset_Each_Transaction')?['cr7bb_thfinancecashcollectiontransactionid']
```

---

### Step 7: List Email Logs to Delete

1. After `Reset_Each_Transaction` loop (still in Yes branch), click **+** → **Add an action**
2. Search for `List rows`
3. Select **Microsoft Dataverse** → **List rows**
4. **Rename** to: `List_EmailLogs_To_Delete`
5. Configure:

| Field | Value |
|-------|-------|
| **Table name** | Emaillogs *(or THFinanceCashCollectionEmaillogs)* |
| **Filter rows** | *(see below)* |

6. For **Filter rows**, enter (DateTime range for today):
```
Microsoft.Dynamics.CRM.On(PropertyName='cr7bb_processdate',PropertyValue=@{variables('varResetDate')})
```

**Alternative filter** using date range:
```
cr7bb_processdate ge @{variables('varResetDate')}T00:00:00Z and cr7bb_processdate lt @{variables('varResetDate')}T23:59:59Z
```

---

### Step 8: Count Email Logs (Optional - for logging)

1. Click **+** → **Add an action**
2. Search for `Compose`
3. Select **Data Operation** → **Compose**
4. **Rename** to: `Count_EmailLogs`
5. For **Inputs**, click **Expression** and enter:
```
length(outputs('List_EmailLogs_To_Delete')?['body/value'])
```

---

### Step 9: Delete Each Email Log

1. Click **+** → **Add an action**
2. Search for `Apply to each`
3. Select **Control** → **Apply to each**
4. **Rename** to: `Delete_Each_EmailLog`
5. For **Select an output from previous steps**:
   - Click the input field
   - Select **Dynamic content** → `value` from `List_EmailLogs_To_Delete`

6. Inside the loop, click **+** → **Add an action**
7. Search for `Delete a row`
8. Select **Microsoft Dataverse** → **Delete a row**
9. **Rename** to: `Delete_EmailLog`
10. Configure:

| Field | Value |
|-------|-------|
| **Table name** | Emaillogs |
| **Row ID** | *(Dynamic content)* `EmailLog` from current item |

**For Row ID using Expression** (if dynamic content doesn't show):
```
items('Delete_Each_EmailLog')?['cr7bb_thfinancecashcollectionemaillogid']
```

---

### Step 10: Log Completion

After the email log deletion loop, add a notification:

1. Click **+** → **Add an action** (after the email log deletion loop, still in Yes branch)
2. Search for `Compose`
3. **Rename** to: `Completion_Message`
4. For **Inputs**, enter:
```
Reset complete for date @{variables('varResetDate')}. Transactions reset: @{outputs('Count_Records')}. Email logs deleted: @{outputs('Count_EmailLogs')}.
```

---

### Step 11: No Records Message (No Branch)

1. In the **No** branch, click **+** → **Add an action**
2. Search for `Compose`
3. **Rename** to: `No_Records_Message`
4. For **Inputs**, enter:
```
No transactions found to reset for date @{variables('varResetDate')}.
```

---

## Complete Flow Structure

```
Manually_trigger_a_flow
│   └── Input: Reset Date (optional)
│
├── Initialize_variable (varResetDate)
│
├── List_Transactions_To_Reset
│   └── Filter: cr7bb_transactionprocessdate eq date AND any status field is true
│
├── Count_Records
│
└── Check_Has_Records (Count > 0?)
    │
    ├── YES:
    │   ├── Reset_Each_Transaction
    │   │   └── Update_Transaction_Reset
    │   │       ├── Is Processed = No
    │   │       ├── Is Excluded = No
    │   │       ├── Email Sent = No
    │   │       └── Exclude Reason = (blank)
    │   │
    │   ├── List_EmailLogs_To_Delete
    │   │   └── Filter: cr7bb_processdate = today (DateTime range)
    │   │
    │   ├── Count_EmailLogs
    │   │
    │   ├── Delete_Each_EmailLog
    │   │   └── Delete_EmailLog (by ID)
    │   │
    │   └── Completion_Message
    │       └── "Transactions reset: X. Email logs deleted: Y."
    │
    └── NO:
        └── No_Records_Message
```

---

## How to Run the Flow

### Method 1: From Power Automate Portal

1. Go to **Power Automate** → **My flows**
2. Find **Reset Today Transaction Status**
3. Click **Run** button
4. Optionally enter a specific date (leave blank for today)
5. Click **Run flow**

### Method 2: From Power Apps (Add Button)

Add a button in the Canvas App that runs this flow:

```powerfx
// In a Button's OnSelect:
// WARNING: This will reset all transactions AND delete all email logs for the date!
'ResetTodayTransactionStatus'.Run()
```

Or with a date parameter:
```powerfx
// WARNING: This will reset all transactions AND delete all email logs for the date!
'ResetTodayTransactionStatus'.Run({date: Today()})
```

**Recommended**: Add a confirmation dialog before running:
```powerfx
Set(_showResetConfirmation, true);
// Then in a confirmation dialog's "Yes" button:
'ResetTodayTransactionStatus'.Run();
Set(_showResetConfirmation, false);
```

---

## Safety Considerations

1. **Confirmation**: Consider adding a confirmation step before resetting
2. **Audit Log**: The Dataverse audit trail will track all changes
3. **Email Logs**: This flow **DELETES** all EmailLog records for the reset date - use with caution
4. **ProcessLog**: Consider also resetting/deleting the ProcessLog entry for the date (see Optional Enhancement below)
5. **Cannot Undo**: Email log deletion is permanent - ensure you want to re-run the entire process

---

## Optional Enhancement: Also Reset ProcessLog

If you want to also delete the ProcessLog entry for the date:

1. After `List_Transactions_To_Reset`, add another **List rows** action:
   - **Rename**: `List_ProcessLog_To_Delete`
   - **Table**: ProcessLogs
   - **Filter**: `cr7bb_processdate eq '@{variables('varResetDate')}'`

2. Add **Apply to each** over the result:
   - Inside: **Delete a row** action
   - Table: ProcessLogs
   - Row ID: `items('loop_name')?['cr7bb_thfinancecashcollectionprocesslogid']`

---

## Expression Quick Reference

| Purpose | Expression |
|---------|------------|
| Today's date (formatted) | `formatDateTime(utcNow(), 'yyyy-MM-dd')` |
| Count of transactions | `length(outputs('List_Transactions_To_Reset')?['body/value'])` |
| Count of email logs | `length(outputs('List_EmailLogs_To_Delete')?['body/value'])` |
| Transaction ID in loop | `items('Reset_Each_Transaction')?['cr7bb_thfinancecashcollectiontransactionid']` |
| EmailLog ID in loop | `items('Delete_Each_EmailLog')?['cr7bb_thfinancecashcollectionemaillogid']` |
| Check if empty | `empty(outputs('List_Transactions_To_Reset')?['body/value'])` |

---

## Testing Checklist

| # | Test | Expected Result |
|---|------|-----------------|
| 1 | Run with no processed transactions | "No transactions found" message |
| 2 | Run after Email Engine ran | All today's transactions reset |
| 3 | Verify transactions in Dataverse | All status fields = No, Exclude Reason = blank |
| 4 | Verify email logs in Dataverse | No EmailLog records exist for today's date |
| 5 | Run Email Engine again | Transactions processed normally, new EmailLogs created |
| 6 | Check completion message | Shows both transaction and email log counts |

---

## Troubleshooting

### "No transactions found" but Email Engine ran today

- Check the date format in `cr7bb_transactionprocessdate` - it's a TEXT field
- Verify the date format matches: `yyyy-MM-dd` (e.g., "2026-01-29")
- Try checking the raw data in Dataverse

### Flow runs but transactions not reset

- Check the Row ID expression is correct
- Verify the table name matches exactly
- Check flow run history for errors

### Filter not working (Transactions)

If the OData filter doesn't work with quotes, try without:
```
cr7bb_transactionprocessdate eq @{variables('varResetDate')}
```

Or use `contains` if exact match fails:
```
contains(cr7bb_transactionprocessdate, '@{variables('varResetDate')}')
```

### EmailLog filter not working

**Important**: EmailLog `cr7bb_processdate` is **DateTime** type (not Text like Transaction/ProcessLog).

Try these alternatives:

**Using OData `On` function**:
```
Microsoft.Dynamics.CRM.On(PropertyName='cr7bb_processdate',PropertyValue=@{variables('varResetDate')})
```

**Using date range comparison**:
```
cr7bb_processdate ge @{variables('varResetDate')}T00:00:00Z and cr7bb_processdate lt @{addDays(variables('varResetDate'), 1)}T00:00:00Z
```

### Email logs not being deleted

- Verify the EmailLog Row ID expression is correct
- Check the table name: `Emaillogs` (not `EmailLogs` or `Email Logs`)
- Verify flow run history for errors in the delete action

---

## Related Documents

- [Flow_Modification_EmailEngine_IsExcluded.md](Flow_Modification_EmailEngine_IsExcluded.md) - isExcluded tracking
- [Flow_StepByStep_FIFO_EmailEngine.md](Flow_StepByStep_FIFO_EmailEngine.md) - Email Engine details
- [FIELD_NAME_REFERENCE.md](../02-Database-Schema/FIELD_NAME_REFERENCE.md) - Field names
