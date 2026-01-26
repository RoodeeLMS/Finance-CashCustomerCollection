# Step-by-Step: Modify Daily Collections Email Engine

**Date**: January 14, 2026
**Flow**: `[THFinance] Daily Collections Email Engine`
**Purpose**: Add FIFO STOP logic + AR Notification for Overdue ≥ 3 days
**Estimated Time**: 45 minutes

---

## Current Existing Actions (For Reference)

This section lists all actions currently in the exported flow `THFinanceCashCollectionDailyCollectionsEmailEngine-76DC1EF9-A9A3-F011-BBD2-6045BD1C675A.json`.

### Top-Level Actions (Execution Order)

| # | Action Name | Type | Runs After |
|---|-------------|------|------------|
| 1 | `Initialize_varProcessDate` | InitializeVariable | Trigger |
| 2 | `Set_variable_1` | SetVariable | Initialize_varProcessDate |
| 3 | `Initialize_varEmailsSent` | InitializeVariable | Set_variable_1 |
| 4 | `Initialize_varEmailsFailed` | InitializeVariable | Initialize_varEmailsSent |
| 5 | `Initialize_varCustomersProcessed` | InitializeVariable | Initialize_varEmailsFailed |
| 6 | `Initialize_varErrorMessages` | InitializeVariable | Initialize_varCustomersProcessed |
| 7 | `Initialize_varCNTotal` | InitializeVariable | Initialize_varErrorMessages |
| 8 | `Initialize_varDNTotal` | InitializeVariable | Initialize_varCNTotal |
| 9 | `List_Process_Logs` | ListRecords (Dataverse) | Initialize_varDNTotal |
| 10 | `Compose_Process_Logs` | Compose | List_Process_Logs |
| 11 | `Check_Import_Completed` | Condition | Compose_Process_Logs |
| 12 | `List_Transactions` | ListRecords (Dataverse) | Check_Import_Completed |
| 13 | `Compose_Transactions` | Compose | List_Transactions |
| 14 | `Select_Customer_IDs` | Select | Compose_Transactions |
| 15 | `Get_Unique_Customers` | Compose | Select_Customer_IDs |
| 16 | `Apply_to_each_Customer` | ForEach | Get_Unique_Customers |
| 17 | `Send_Summary_Email_to_AR` | SendEmailV2 | Apply_to_each_Customer |

### Inside Check_Import_Completed (If Yes - Import NOT Completed)

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Send_error_email` | SendEmailV2 | Alert that SAP import not completed |
| `Terminate` | Terminate | Stop flow with failure |

### Inside Apply_to_each_Customer Loop

| # | Action Name | Type | Runs After |
|---|-------------|------|------------|
| 1 | `Increment_varCustomersProcessed` | IncrementVariable | (loop start) |
| 2 | `Get_Customer` | GetItem (Dataverse) | Increment_varCustomersProcessed |
| 3 | `Compose_Customer` | Compose | Get_Customer |
| 4 | `Filter_Customer_Transactions` | Query | Compose_Customer |
| 5 | `Filter_Non_Excluded` | Query | Filter_Customer_Transactions |
| 6 | `Check_All_Excluded` | Condition | Filter_Non_Excluded |

### Inside Check_All_Excluded → Else Branch (Has Transactions)

| # | Action Name | Type | Runs After | Notes |
|---|-------------|------|------------|-------|
| 1 | `Filter_CN_List` | Query | (branch start) | Filters Amount < 0 |
| 2 | `Filter_DN_List` | Query | Filter_CN_List | Filters Amount > 0 |
| 3 | `Set_variable` | SetVariable | Filter_DN_List | Reset varCNTotal = 0 |
| 4 | `Set_variable_2` | SetVariable | Set_variable | Reset varDNTotal = 0 |
| 5 | `Apply_to_each_CN_List` | ForEach | Set_variable_2 | ⚠️ **TO BE REPLACED** |
| 6 | `Apply_to_each_DN_List` | ForEach | Apply_to_each_CN_List | Sums varDNTotal |
| 7 | `Compose_Net_Amount` | Compose | Apply_to_each_DN_List | ⚠️ **TO BE UPDATED** |
| 8 | `Check_Should_Send` | Condition | Compose_Net_Amount | |

### Inside Apply_to_each_CN_List (TO BE REPLACED)

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Increment_variable` | IncrementVariable | Adds CN amount to varCNTotal |

> ⚠️ **Problem**: This loop sums ALL CNs without FIFO sorting or STOP logic

### Inside Apply_to_each_DN_List

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Increment_variable_2` | IncrementVariable | Adds DN amount to varDNTotal |

### Inside Check_Should_Send → Yes Branch (Send Email)

| # | Action Name | Type | Runs After |
|---|-------------|------|------------|
| 1 | `Select_Day_Counts` | Select | (branch start) |
| 2 | `Select_Document_Date` | Select | Select_Day_Counts |
| 3 | `Compose_Max_DayCount` | Compose | Select_Document_Date |
| 4 | `Compose_Template_Selection` | Compose | Compose_Max_DayCount |
| 5 | `Compose_Email_Subject` | Compose | Compose_Template_Selection |
| 6 | `Create_HTML_table` | Table | Compose_Email_Subject |
| 7 | `Get_files_(properties_only)` | GetFileItems (SharePoint) | Create_HTML_table |
| 8 | `Get_AR_rep` | UserProfile_V2 (O365) | Get_files_(properties_only) |
| 9 | `Compose_Email_Body` | Compose | Get_AR_rep |
| 10 | `Compose_All_Recipient_Emails` | Compose | Compose_Email_Body |
| 11 | `Compose_All_CC_Emails` | Compose | Compose_All_Recipient_Emails |
| 12 | `Filter_Recipient_Emails` | Query | Compose_All_CC_Emails |
| 13 | `Filter_CC_Emails` | Query | Filter_Recipient_Emails |
| 14 | `Compose_Recipient_Emails` | Compose | Filter_CC_Emails |
| 15 | `Compose_CC_Emails` | Compose | Compose_Recipient_Emails |
| 16 | `Create_Email_Log` | CreateRecord (Dataverse) | Compose_CC_Emails |
| 17 | `Update_Email_Counters` | Scope | Create_Email_Log (Succeeded) |
| 18 | `Log_Email_Failed` | Scope | Create_Email_Log (Failed/TimedOut) |
| 19 | `Update_Transaction_Records` | ForEach | Update_Email_Counters |

### Inside Update_Email_Counters Scope

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Increment_EmailsSent` | IncrementVariable | Increment varEmailsSent |

### Inside Log_Email_Failed Scope

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Increment_EmailsFailed` | IncrementVariable | Increment varEmailsFailed |
| `Append_Email_Error` | AppendToArrayVariable | Add error to varErrorMessages |

### Inside Update_Transaction_Records ForEach

| Action Name | Type | Purpose |
|-------------|------|---------|
| `Update_Transaction` | UpdateRecord (Dataverse) | Set emailsent=true, isprocessed=true |

---

### Current Variables

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `varProcessDate` | String | utcNow yyyy-MM-dd | Today's date |
| `varEmailsSent` | Integer | 0 | Count of successful emails |
| `varEmailsFailed` | Integer | 0 | Count of failed emails |
| `varCustomersProcessed` | Integer | 0 | Count of customers processed |
| `varErrorMessages` | Array | [] | List of error messages |
| `varCNTotal` | Float | 0 | Sum of CN amounts (per customer) |
| `varDNTotal` | Float | 0 | Sum of DN amounts (per customer) |

---

### Key Observations for Modification

1. **No FIFO Sorting**: `Filter_CN_List` and `Filter_DN_List` query by amount sign but don't sort by `cr7bb_documentdate`

2. **Simple CN Sum**: `Apply_to_each_CN_List` sums ALL CNs without any STOP logic

3. **Net Amount Formula**: `Compose_Net_Amount` uses `varCNTotal + varDNTotal` (sums all)

4. **Missing AR Alert**: No check for MaxArrearDays >= 3 and no AR alert collection

5. **References to Update**: Multiple actions reference `body('Filter_DN_List')` - need to change to `outputs('Sort_DN_FIFO')`

---

## Overview of Changes

| Change | Description |
|--------|-------------|
| Add 5 variables | varAppliedCNTotal, varCNIndex, varStopFIFO, varARAlertCustomers, varTableRows |
| Add FIFO sorting | Sort CN and DN by document date |
| Replace CN loop | Delete simple sum, add Do Until with STOP |
| Add AR alert | Check MaxArrearDays ≥ 3, collect customers |
| Add AR email | Send summary email to AR team at end |

---

## Part 1: Add New Variables

**Location**: After existing variable initializations (after `Initialize_varDNTotal`)

---

### Step 1.1: Add varAppliedCNTotal

1. Click **+** after `Initialize_varDNTotal`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varAppliedCNTotal
   Type: Float
   Value: 0
   ```
4. Rename action to: `Initialize_varAppliedCNTotal`

---

### Step 1.2: Add varCNIndex

1. Click **+** after `Initialize_varAppliedCNTotal`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varCNIndex
   Type: Integer
   Value: 0
   ```
4. Rename action to: `Initialize_varCNIndex`

---

### Step 1.3: Add varStopFIFO

1. Click **+** after `Initialize_varCNIndex`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varStopFIFO
   Type: Boolean
   Value: false
   ```
4. Rename action to: `Initialize_varStopFIFO`

---

### Step 1.4: Add varARAlertCustomers

1. Click **+** after `Initialize_varStopFIFO`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varARAlertCustomers
   Type: Array
   Value: []
   ```
4. Rename action to: `Initialize_varARAlertCustomers`

---

### Step 1.5: Add varTableRows

1. Click **+** after `Initialize_varARAlertCustomers`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varTableRows
   Type: String
   Value: (leave empty)
   ```
4. Rename action to: `Initialize_varTableRows`

---

### Step 1.6: Update List_Process_Logs

1. Click on `List_Process_Logs`
2. Click **...** → **Settings**
3. Change **Run after** to: `Initialize_varTableRows`

---

## Part 2: Add FIFO Sorting

**Location**: Inside `Apply_to_each_Customer` → `Check_All_Excluded` → Else branch → After `Filter_DN_List`

---

### Step 2.1: Add Sort_CN_FIFO

1. Find `Filter_DN_List` inside the customer loop
2. Click **+** after `Filter_DN_List`
3. Search and select **Compose**
4. Configure:
   ```
   Inputs: @{if(empty(body('Filter_CN_List')), json('[]'), sort(body('Filter_CN_List'), 'cr7bb_documentdate'))}
   ```
5. Rename action to: `Sort_CN_FIFO`

> ⚠️ **IMPORTANT**: Must use `if(empty(), json('[]'), sort())` pattern. `sort()` on empty array fails with "createArray expects parameters" error.

---

### Step 2.2: Add Sort_DN_FIFO

1. Click **+** after `Sort_CN_FIFO`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{if(empty(body('Filter_DN_List')), json('[]'), sort(body('Filter_DN_List'), 'cr7bb_documentdate'))}
   ```
4. Rename action to: `Sort_DN_FIFO`

> ⚠️ **IMPORTANT**: Must use `if(empty(), json('[]'), sort())` pattern for same reason as Sort_CN_FIFO.

---

## Part 3: Update DN Total Calculation

**Location**: After sorting, update existing actions to use sorted arrays

---

### Step 3.1: Update Set_variable_2 (varDNTotal reset)

1. Find `Set_variable_2` (sets varDNTotal to 0)
2. Click **...** → **Settings**
3. Change **Run after** to: `Sort_DN_FIFO`

---

### Step 3.2: Update Apply_to_each_DN_List

1. Find `Apply_to_each_DN_List`
2. Click on it to expand
3. Change **Select an output from previous steps** to:
   ```
   @{outputs('Sort_DN_FIFO')}
   ```

---

## Part 4: Replace CN Summing with FIFO STOP Loop

**Location**: Replace `Apply_to_each_CN_List` entirely

---

### Step 4.1: Delete Apply_to_each_CN_List

1. Find `Apply_to_each_CN_List` (the loop that sums all CNs)
2. Click **...** → **Delete**
3. Confirm deletion

---

### Step 4.2: Add Reset_varAppliedCNTotal

1. Click **+** after `Apply_to_each_DN_List`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varAppliedCNTotal
   Value: 0
   ```
4. Rename action to: `Reset_varAppliedCNTotal`

---

### Step 4.3: Add Reset_varCNIndex

1. Click **+** after `Reset_varAppliedCNTotal`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varCNIndex
   Value: 0
   ```
4. Rename action to: `Reset_varCNIndex`

---

### Step 4.4: Add Reset_varStopFIFO

1. Click **+** after `Reset_varCNIndex`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varStopFIFO
   Value: @{false}
   ```
4. Rename action to: `Reset_varStopFIFO`

---

### Step 4.5: Add Check_Has_CNs Condition ⭐ CRITICAL

> ⚠️ **WHY THIS IS NEEDED**: Do Until loops in Power Automate may still execute once even when the condition is immediately true. This causes errors when Sort_CN_FIFO returns an empty array `[]`. Adding an explicit check prevents the loop from running when there are no CNs.

1. Click **+** after `Reset_varStopFIFO`
2. Search and select **Condition**
3. Configure condition:
   ```
   @{length(outputs('Sort_CN_FIFO'))}
   is greater than
   0
   ```
4. Rename action to: `Check_Has_CNs`

---

### Step 4.6: Add FIFO_CN_Loop (Do Until) - Inside Check_Has_CNs Yes Branch

1. In the **If yes** branch of `Check_Has_CNs`, click **Add an action**
2. Search and select **Do until**
3. Configure condition:
   ```
   @{or(greaterOrEquals(variables('varCNIndex'), length(outputs('Sort_CN_FIFO'))), variables('varStopFIFO'))}
   is equal to
   @{true}
   ```
4. Click **...** → **Settings** → Change limits:
   - Count: `1000`
   - Timeout: `PT1H`
5. Rename action to: `FIFO_CN_Loop`

> **Note**: The **If no** branch remains empty - when no CNs exist, we skip directly to Compose_Net_Amount.

---

### Step 4.7: Inside FIFO_CN_Loop - Add Get_Current_CN

1. Click **Add an action** inside `FIFO_CN_Loop`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{outputs('Sort_CN_FIFO')?[variables('varCNIndex')]}
   ```
4. Rename action to: `Get_Current_CN`

---

### Step 4.8: Inside FIFO_CN_Loop - Add Calculate_Potential_Total

1. Click **+** after `Get_Current_CN`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{sub(0, add(variables('varAppliedCNTotal'), coalesce(outputs('Get_Current_CN')?['cr7bb_amountlocalcurrency'], 0)))}
   ```
4. Rename action to: `Calculate_Potential_Total`

> ⚠️ **IMPORTANT**:
> - NO `abs()` function in Power Automate - use `sub(0, value)` to negate
> - NO `float()` needed - Dataverse numbers are already numeric
> - Use `coalesce(value, 0)` for null handling

---

### Step 4.9: Inside FIFO_CN_Loop - Add Check_Can_Apply_CN

1. Click **+** after `Calculate_Potential_Total`
2. Search and select **Condition**
3. Configure condition:
   ```
   @{outputs('Calculate_Potential_Total')}
   is less than or equal to
   @{variables('varDNTotal')}
   ```
4. Rename action to: `Check_Can_Apply_CN`

---

### Step 4.10: Inside Check_Can_Apply_CN - If Yes (Apply CN)

> ⚠️ **IMPORTANT**: Power Automate does NOT allow SetVariable to reference the same variable in its value expression (self-reference error). Use **Increment variable** instead.

1. In the **If yes** branch, click **Add an action**
2. Search and select **Increment variable** (NOT Set variable!)
3. Configure:
   ```
   Name: varAppliedCNTotal
   Value: @{coalesce(outputs('Get_Current_CN')?['cr7bb_amountlocalcurrency'], 0)}
   ```
4. Rename action to: `Apply_CN_Amount`

> ⚠️ **IMPORTANT**:
> - NO `float()` needed - Dataverse numbers are already numeric type
> - Use `coalesce(value, 0)` for null handling
> - **Why Increment?** SetVariable with `add(variables('varAppliedCNTotal'), ...)` causes error: "Self reference is not supported when updating the value of variable". IncrementVariable automatically adds to the existing value.

5. Click **+** after `Apply_CN_Amount`
6. Search and select **Increment variable**
7. Configure:
   ```
   Name: varCNIndex
   Value: 1
   ```
8. Rename action to: `Increment_CN_Index`

---

### Step 4.11: Inside Check_Can_Apply_CN - If No (STOP)

1. In the **If no** branch, click **Add an action**
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varStopFIFO
   Value: @{true}
   ```
4. Rename action to: `Set_Stop_Flag`

> **This is the STOP logic!** When CN would exceed DN, we set the flag and the loop exits.

---

## Part 5: Update Net Amount Calculation

**Location**: Find `Compose_Net_Amount`

---

### Step 5.1: Update Compose_Net_Amount Formula

1. Find `Compose_Net_Amount`
2. Click to edit
3. Change **Inputs** from:
   ```
   @{add(variables('varCNTotal'),variables('varDNTotal'))}
   ```
   To:
   ```
   @{add(variables('varDNTotal'), variables('varAppliedCNTotal'))}
   ```

4. Click **...** → **Settings**
5. Change **Run after** to: `FIFO_CN_Loop`

---

## Part 6: Add AR Alert Check

**Location**: Inside `Check_Should_Send` → If yes branch → After `Compose_Max_DayCount`

---

### Step 6.1: Add Check_AR_Alert Condition

1. Find `Compose_Max_DayCount` inside the "should send" branch
2. Click **+** after `Compose_Max_DayCount`
3. Search and select **Condition**
4. Configure condition:
   ```
   @{outputs('Compose_Max_DayCount')}
   is greater than or equal to
   3
   ```
5. Rename action to: `Check_AR_Alert`

---

### Step 6.2: Inside Check_AR_Alert - If Yes (Collect Customer)

1. In the **If yes** branch, click **Add an action**
2. Search and select **Append to array variable**
3. Configure:
   ```
   Name: varARAlertCustomers
   Value: {
     "CustomerCode": "@{outputs('Get_Customer')?['body/cr7bb_customercode']}",
     "CustomerName": "@{outputs('Get_Customer')?['body/cr7bb_customername']}",
     "MaxArrearDays": @{outputs('Compose_Max_DayCount')},
     "RemainingAmount": @{outputs('Compose_Net_Amount')},
     "TransactionCount": @{length(outputs('Sort_DN_FIFO'))}
   }
   ```
4. Rename action to: `Append_AR_Alert_Customer`

> Leave the **If no** branch empty

---

### Step 6.3: Update Compose_Template_Selection

1. Find `Compose_Template_Selection`
2. Click **...** → **Settings**
3. Change **Run after** to: `Check_AR_Alert`

---

## Part 7: Add AR Summary Email

**Location**: After `Apply_to_each_Customer` loop, before `Send_Summary_Email_to_AR`

---

### Step 7.1: Add Check_Has_AR_Alerts Condition

1. Find `Apply_to_each_Customer` (the main customer loop)
2. Click **+** after the loop ends
3. Search and select **Condition**
4. Configure condition:
   ```
   @{length(variables('varARAlertCustomers'))}
   is greater than
   0
   ```
5. Rename action to: `Check_Has_AR_Alerts`

---

### Step 7.2: Inside Check_Has_AR_Alerts - If Yes (Send AR Email)

> ⚠️ **NOTE**: Using **Apply to Each + Append to String** instead of Select action.
> Select action in text mode has JSON parsing issues with embedded HTML.

**Add: Apply_to_each_AR_Alert**

1. In the **If yes** branch, click **Add an action**
2. Search and select **Apply to each**
3. Configure:
   - **Select an output from previous steps**: `@{variables('varARAlertCustomers')}`
4. Rename action to: `Apply_to_each_AR_Alert`

**Inside Apply_to_each_AR_Alert - Add: Append_AR_Table_Row**

1. Click **Add an action** inside the loop
2. Search and select **Append to string variable**
3. Configure:
   - **Name**: `varTableRows`
   - **Value**:
   ```
   <tr><td>@{items('Apply_to_each_AR_Alert')?['CustomerCode']}</td><td>@{items('Apply_to_each_AR_Alert')?['CustomerName']}</td><td style="text-align:center;color:red;font-weight:bold;">@{items('Apply_to_each_AR_Alert')?['MaxArrearDays']}</td><td style="text-align:right;">@{formatNumber(coalesce(items('Apply_to_each_AR_Alert')?['RemainingAmount'], 0), 'N2')}</td><td style="text-align:center;">@{items('Apply_to_each_AR_Alert')?['TransactionCount']}</td></tr>
   ```
4. Rename action to: `Append_AR_Table_Row`

> **Note**: Variable `varTableRows` is initialized empty at flow start. Since `Check_Has_AR_Alerts` runs only ONCE after the customer loop (not inside any loop), no reset is needed.

**Add: Compose_AR_Alert_Body**

> ⚠️ **WHY COMPOSE?** Power Automate's email editor reformats HTML when you save. Using a Compose action preserves the exact HTML structure.

1. Click **+** after `Apply_to_each_AR_Alert` (outside the loop)
2. Search and select **Compose**
3. Configure **Inputs** (paste as single line):
   ```
   <html><body style="font-family: Arial, sans-serif;"><h2 style="color: #D83B01;">⚠️ Daily Overdue Alert</h2><p>The following <strong>@{length(variables('varARAlertCustomers'))}</strong> customer(s) have transactions overdue by <strong>3 or more working days</strong>:</p><table border="1" cellpadding="8" style="border-collapse: collapse; width: 100%;"><tr style="background-color: #D83B01; color: white;"><th>Customer Code</th><th>Customer Name</th><th>Max Arrear Days</th><th>Amount Due (THB)</th><th>Transactions</th></tr>@{variables('varTableRows')}</table><p style="margin-top: 20px;"><strong>Action Required:</strong> Please follow up with these customers regarding their overdue payments.</p><p style="color: #666; font-size: 12px;">Process Date: @{variables('varProcessDate')}<br/>Generated by: [THFinance] Daily Collections Email Engine</p></body></html>
   ```
4. Rename action to: `Compose_AR_Alert_Body`

**Add: Send_AR_Alert_Email**

1. Click **+** after `Compose_AR_Alert_Body`
2. Search and select **Send an email (V2)** (Office 365 Outlook)
3. Configure:

   **To:**
   ```
   @{parameters('System Notification Email (nc_SystemNotificationEmail)')}
   ```

   **Subject:**
   ```
   ⚠️ [THFinance] Overdue Alert - @{length(variables('varARAlertCustomers'))} Customers with Arrear ≥ 3 Days - @{variables('varProcessDate')}
   ```

   **Body:**
   ```
   @{outputs('Compose_AR_Alert_Body')}
   ```

   **Importance:** `High`

4. Rename action to: `Send_AR_Alert_Email`

> Leave the **If no** branch empty

---

### Step 7.3: Update Send_Summary_Email_to_AR

1. Find existing `Send_Summary_Email_to_AR`
2. Click **...** → **Settings**
3. Change **Run after** to: `Check_Has_AR_Alerts`

---

## Part 8: Update DN References

**Location**: Multiple actions throughout the flow

Find and update these actions to use `outputs('Sort_DN_FIFO')` instead of `body('Filter_DN_List')`:

---

### Step 8.1: Update Check_Should_Send

1. Find `Check_Should_Send` condition
2. Edit the condition - change:
   ```
   length(body('Filter_DN_List'))
   ```
   To:
   ```
   length(outputs('Sort_DN_FIFO'))
   ```

---

### Step 8.2: Update Create_HTML_table

1. Find `Create_HTML_table`
2. Change **From** to:
   ```
   @{outputs('Sort_DN_FIFO')}
   ```

---

### Step 8.3: Update Create_Email_Log

1. Find `Create_Email_Log`
2. Change `cr7bb_transactioncount` to:
   ```
   @{length(outputs('Sort_DN_FIFO'))}
   ```

---

### Step 8.4: Update Update_Transaction_Records

1. Find `Update_Transaction_Records` (Apply to each loop)
2. Change **Select an output** to:
   ```
   @{outputs('Sort_DN_FIFO')}
   ```

---

### Step 8.5: Update Select_Day_Counts

1. Find `Select_Day_Counts`
2. Change **From** to:
   ```
   @{outputs('Sort_DN_FIFO')}
   ```

---

### Step 8.6: Update Select_Document_Date

1. Find `Select_Document_Date`
2. Change **From** to:
   ```
   @{outputs('Sort_DN_FIFO')}
   ```

---

## Complete Flow Structure After Modification

```
[Recurrence Trigger]
  │
  ├── Initialize_varProcessDate
  ├── Initialize_varEmailsSent
  ├── Initialize_varEmailsFailed
  ├── Initialize_varCustomersProcessed
  ├── Initialize_varErrorMessages
  ├── Initialize_varCNTotal
  ├── Initialize_varDNTotal
  ├── Initialize_varAppliedCNTotal      ⭐ NEW
  ├── Initialize_varCNIndex             ⭐ NEW
  ├── Initialize_varStopFIFO            ⭐ NEW
  ├── Initialize_varARAlertCustomers    ⭐ NEW
  ├── Initialize_varTableRows           ⭐ NEW
  │
  ├── List_Process_Logs
  ├── Check_Import_Completed
  ├── List_Transactions
  ├── Get_Unique_Customers
  │
  ├── ═══ Apply_to_each_Customer ═══
  │   │
  │   ├── Get_Customer
  │   ├── Filter_Customer_Transactions
  │   ├── Filter_Non_Excluded
  │   │
  │   ├── Check_All_Excluded?
  │   │   └── No:
  │   │       ├── Filter_CN_List
  │   │       ├── Filter_DN_List
  │   │       ├── Sort_CN_FIFO               ⭐ NEW
  │   │       ├── Sort_DN_FIFO               ⭐ NEW
  │   │       │
  │   │       ├── Reset varDNTotal = 0
  │   │       ├── Apply_to_each_DN_List (sum DN)
  │   │       │
  │   │       ├── Reset_varAppliedCNTotal    ⭐ NEW
  │   │       ├── Reset_varCNIndex           ⭐ NEW
  │   │       ├── Reset_varStopFIFO          ⭐ NEW
  │   │       │
  │   │       ├── Check_Has_CNs?             ⭐ NEW (prevents empty array error)
  │   │       │   │
  │   │       │   ├── Yes (has CNs):
  │   │       │   │   └── ═══ FIFO_CN_Loop ═══  (Do Until)
  │   │       │   │       │
  │   │       │   │       ├── Get_Current_CN
  │   │       │   │       ├── Calculate_Potential_Total
  │   │       │   │       │
  │   │       │   │       └── Check_Can_Apply_CN?
  │   │       │   │           ├── Yes: Apply_CN_Amount, Increment_CN_Index
  │   │       │   │           └── No: Set_Stop_Flag (STOP!)
  │   │       │   │
  │   │       │   └── No (empty): (skip to Compose_Net_Amount)
  │   │       │
  │   │       ├── Compose_Net_Amount (updated formula)
  │   │       │
  │   │       └── Check_Should_Send?
  │   │           └── Yes:
  │   │               ├── Select_Day_Counts
  │   │               ├── Compose_Max_DayCount
  │   │               │
  │   │               ├── Check_AR_Alert?        ⭐ NEW
  │   │               │   └── Yes: Append_AR_Alert_Customer
  │   │               │
  │   │               ├── Compose_Template_Selection
  │   │               ├── Create_HTML_table
  │   │               ├── Compose_Email_Body
  │   │               ├── Create_Email_Log
  │   │               └── Update_Transaction_Records
  │
  ├── ═══ After Customer Loop ═══
  │
  ├── Check_Has_AR_Alerts?               ⭐ NEW
  │   └── Yes:
  │       ├── Apply_to_each_AR_Alert
  │       │   └── Append_AR_Table_Row (to varTableRows)
  │       ├── Compose_AR_Alert_Body (builds HTML with varTableRows)
  │       └── Send_AR_Alert_Email (uses Compose output)
  │
  └── Send_Summary_Email_to_AR
```

---

## Testing Checklist

### Test 1: FIFO STOP Logic
**Setup:**
- Customer with DN Total = 10,000 THB
- CN1 = -3,000 (Jan 1)
- CN2 = -5,000 (Jan 2)
- CN3 = -4,000 (Jan 3)

**Expected:**
- CN1 applied (running: 3,000)
- CN2 applied (running: 8,000)
- CN3 **STOPPED** (8,000 + 4,000 = 12,000 > 10,000)
- Remaining Amount = 10,000 - 8,000 = **2,000 THB**

---

### Test 2: AR Alert Triggered
**Setup:**
- Customer with MaxArrearDays = 5

**Expected:**
- Customer added to varARAlertCustomers
- AR alert email sent with customer in table

---

### Test 3: No AR Alert
**Setup:**
- All customers with MaxArrearDays < 3

**Expected:**
- varARAlertCustomers is empty
- AR alert email NOT sent

---

### Test 4: Normal Processing
**Setup:**
- Regular customers with various amounts

**Expected:**
- Emails sent with correct sorted transactions
- Amounts calculated correctly

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Loop doesn't stop | varStopFIFO not set to true | Check condition in Check_Can_Apply_CN |
| Wrong CN order | Not sorted by date | Verify Sort_CN_FIFO uses cr7bb_documentdate |
| AR alert missing | Condition wrong | Check >= 3 (not > 3) |
| Net amount wrong | Using old varCNTotal | Verify using varAppliedCNTotal |
| Actions not found | Wrong runAfter | Verify dependencies updated |
| **Self reference error** | SetVariable can't use same variable in value | **Use IncrementVariable instead** (see Step 4.9) |
| Infinite loop | Wrong variable incremented | Verify `Increment_CN_Index` uses `varCNIndex` (not `varCNTotal`) |

---

## Rollback Plan

If issues occur after modification:
1. Export modified flow as backup
2. Re-import original solution `THFinanceCashCollection_1_0_0_5.zip`
3. Flow reverts to previous logic

---

## Part 9: Display Applied CNs in Customer Email (Enhancement)

> **Purpose**: Show customers which Credit Notes (CNs) were applied to their account in the email table, for transparency.
>
> **Prerequisite**: Parts 1-8 must be completed first (FIFO STOP logic implemented).
>
> **Estimated Time**: 15 minutes

---

### Overview of Part 9 Changes

| Change | Description |
|--------|-------------|
| Add 1 variable | varAppliedCNList (Array to track applied CNs) |
| Add 1 reset action | Reset_varAppliedCNList before FIFO loop |
| Add 1 append action | Append_Applied_CN inside FIFO loop |
| Modify email table | Combine DN + Applied CNs using `union()` |
| Update transaction records | Mark both DN + Applied CNs as `emailsent=true` |

---

### Step 9.1: Add varAppliedCNList Variable

**Location**: After `Initialize_varARAlertCustomers` (Part 1 variables)

1. Click **+** after `Initialize_varARAlertCustomers`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varAppliedCNList
   Type: Array
   Value: []
   ```
4. Rename action to: `Initialize_varAppliedCNList`

5. Update `List_Process_Logs`:
   - Click on `List_Process_Logs`
   - Click **...** → **Settings**
   - Change **Run after** to: `Initialize_varAppliedCNList`

---

### Step 9.2: Add Reset_varAppliedCNList

**Location**: Inside customer loop → After `Reset_varStopFIFO`, before `FIFO_CN_Loop`

1. Click **+** after `Reset_varStopFIFO`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varAppliedCNList
   Value: @{json('[]')}
   ```
4. Rename action to: `Reset_varAppliedCNList`

5. Update `FIFO_CN_Loop`:
   - Click on `FIFO_CN_Loop`
   - Click **...** → **Settings**
   - Change **Run after** to: `Reset_varAppliedCNList`

---

### Step 9.3: Add Append_Applied_CN Action

**Location**: Inside `FIFO_CN_Loop` → Inside `Check_Can_Apply_CN` → If Yes branch → After `Apply_CN_Amount`

1. Inside the **If yes** branch, click **+** after `Apply_CN_Amount`
2. Search and select **Append to array variable**
3. Configure:
   ```
   Name: varAppliedCNList
   Value: @{outputs('Get_Current_CN')}
   ```
4. Rename action to: `Append_Applied_CN`

5. Update `Increment_CN_Index`:
   - Click on `Increment_CN_Index`
   - Click **...** → **Settings**
   - Change **Run after** to: `Append_Applied_CN`

---

### Step 9.4: Add Combine_DN_and_CN Compose

**Location**: Inside `Check_Should_Send` → If Yes branch → Before `Create_HTML_table`

1. Find `Compose_Email_Subject` (before `Create_HTML_table`)
2. Click **+** after `Compose_Email_Subject`
3. Search and select **Compose**
4. Configure:
   ```
   Inputs: @{sort(union(outputs('Sort_DN_FIFO'), variables('varAppliedCNList')), 'cr7bb_documentdate')}
   ```
5. Rename action to: `Combine_DN_and_CN`

> **Note**: The `sort()` ensures DN and CN transactions appear in chronological order by document date.

---

### Step 9.5: Update Create_HTML_table

**Location**: `Create_HTML_table` action

1. Find `Create_HTML_table`
2. Click **...** → **Settings**
3. Change **Run after** to: `Combine_DN_and_CN`
4. Change **From** to:
   ```
   @{outputs('Combine_DN_and_CN')}
   ```

> **Note**: The combined array contains both DNs (positive amounts) and Applied CNs (negative amounts), sorted chronologically by document date.

---

### Step 9.6: Update Transaction Count (Optional)

If you want the transaction count to include applied CNs:

1. Find `Create_Email_Log`
2. Change `cr7bb_transactioncount` to:
   ```
   @{length(outputs('Combine_DN_and_CN'))}
   ```

> **Alternative**: Keep using `length(outputs('Sort_DN_FIFO'))` if you only want to count DNs.

---

### Step 9.7: Update Update_Transaction_Records

**Purpose**: Mark both DN and Applied CN transactions as sent in email

**Location**: `Update_Transaction_Records` (Apply to each loop)

1. Find `Update_Transaction_Records` loop
2. Change **Select an output from previous steps** to:
   ```
   @{outputs('Combine_DN_and_CN')}
   ```

> **Note**: This marks both DNs and Applied CNs with `emailsent=true` and `isprocessed=true`. CNs that were STOPPED will NOT be marked (they aren't in the combined array).

---

### Updated Flow Structure (After Part 9)

```
FIFO_CN_Loop
│
├── Get_Current_CN
├── Calculate_Potential_Total
│
└── Check_Can_Apply_CN?
    ├── Yes:
    │   ├── Apply_CN_Amount
    │   ├── Append_Applied_CN        ⭐ NEW (Part 9)
    │   └── Increment_CN_Index
    └── No: Set_Stop_Flag

...

Check_Should_Send?
└── Yes:
    ├── Select_Day_Counts
    ├── Compose_Max_DayCount
    ├── Check_AR_Alert?
    ├── Compose_Template_Selection
    ├── Compose_Email_Subject
    ├── Combine_DN_and_CN            ⭐ NEW (Part 9)
    ├── Create_HTML_table (uses combined array)
    ├── ...
    └── Update_Transaction_Records (uses combined array) ⭐ UPDATED (Part 9)
```

---

### Part 9 Testing Checklist

#### Test 5: CN Display in Email
**Setup:**
- Customer with DN Total = 10,000 THB
- CN1 = -3,000 (Jan 1) - Applied
- CN2 = -5,000 (Jan 2) - Applied
- CN3 = -4,000 (Jan 3) - STOPPED

**Expected Email Table:**
| Document Date | Document Number | Amount |
|---------------|-----------------|--------|
| 2026-01-01 | CN0001 | -3,000 |
| 2026-01-02 | CN0002 | -5,000 |
| 2026-01-05 | DN0001 | 10,000 |

**Verify:**
- ✅ CN1 and CN2 appear in email (they were applied)
- ✅ CN3 does NOT appear (it was stopped)
- ✅ All DNs appear
- ✅ Negative amounts show for CNs
- ✅ Net total = 10,000 - 3,000 - 5,000 = 2,000 THB

---

#### Test 6: No CNs Applied
**Setup:**
- Customer with DN Total = 1,000 THB
- CN1 = -5,000 (would exceed DN)

**Expected:**
- varAppliedCNList is empty
- Email table shows only DNs
- CN1 does NOT appear (was stopped immediately)

---

#### Test 7: CN Transaction Records Updated
**Setup:**
- Same as Test 5 (CN1 applied, CN2 applied, CN3 stopped)

**After Flow Run - Check Dataverse:**
| Transaction | emailsent | Expected |
|-------------|-----------|----------|
| CN1 | true | ✅ Applied, shown in email |
| CN2 | true | ✅ Applied, shown in email |
| CN3 | false | ✅ STOPPED, NOT in email |
| DN1 | true | ✅ In email |

**Verify:**
- ✅ Applied CNs marked as `emailsent=true`
- ✅ Stopped CNs remain `emailsent=false` (available for next day)
- ✅ All DNs marked as `emailsent=true`

---

### Part 9 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| CNs not showing | Append_Applied_CN not added | Verify action exists after Apply_CN_Amount |
| Empty email table | union() failed | Check both arrays have data |
| Wrong CN order | Not sorted | CNs come from sorted array, should be in order |
| All CNs showing | Using wrong variable | Must use varAppliedCNList, not Sort_CN_FIFO |
| CNs not marked in DB | Update loop uses wrong array | Change to `outputs('Combine_DN_and_CN')` |
| Stopped CNs marked | Bug in FIFO loop | Only varAppliedCNList items should be in combined array |

---

## Implementation Notes (Lessons Learned)

### Power Automate Variable Limitations

1. **Self-Reference Not Allowed in SetVariable**
   - ❌ `SetVariable varX = add(variables('varX'), newValue)` → Error
   - ✅ `IncrementVariable varX by newValue` → Works
   - Power Automate cannot reference the same variable in a SetVariable value expression

2. **Email Flow Approval Status**
   - Email Sending Flow filters for `approvalstatus eq 676180001` (Approved)
   - If no manual approval needed, Engine must create logs with `676180001` (auto-approved)
   - Value `676180000` = Pending (requires manual approval)
   - Value `676180001` = Approved (ready to send)

### Power Automate Expression Limitations

3. **No `abs()` Function**
   - ❌ `abs(value)` → Error: "function 'abs' is not defined"
   - ✅ Use `sub(0, value)` to negate a negative value
   - Example: To get absolute value of CN amount: `sub(0, add(var1, var2))`

4. **`float()` Fails on Null or Numeric**
   - ❌ `float(outputs('X')?['field'])` → Error if field is null or already numeric
   - ✅ Use `coalesce(outputs('X')?['field'], 0)` for null handling
   - Dataverse number fields are already numeric, no conversion needed

5. **`createArray()` Requires Parameters**
   - ❌ `createArray()` → Error: "expects a comma separated list of parameters"
   - ✅ Use `json('[]')` to create an empty array
   - Example: `if(empty(body('Filter')), json('[]'), sort(body('Filter'), 'field'))`

6. **Array Access Returns Null When Empty**
   - If array is empty, `array[0]` returns null (no error)
   - Check `empty(array)` or use Do Until with `length(array)` condition
   - `Get_Current_CN` showing "No outputs" means array element is null/undefined

7. **Do Until Loop May Execute Once Even When Condition is True**
   - ⚠️ Even if the Do Until condition evaluates to TRUE immediately, the loop body may still execute once
   - **Workaround**: Add a **Condition** action BEFORE the Do Until to check if the array has items
   - Example: `Check_Has_CNs` checks `length(Sort_CN_FIFO) > 0` before entering `FIFO_CN_Loop`
   - This is a known Power Automate behavior - the condition might be evaluated AFTER the first iteration

8. **No `map()` Function**
   - ❌ `map(array, 'template')` → Error: "function 'map' is not defined"
   - ✅ Use **Apply to Each** + **Append to String Variable** for HTML building
   - Alternative: **Select** action + `join()` (but has JSON parsing issues with HTML)
   - Example: Build HTML table rows from array of customer objects

9. **Email Editor Reformats HTML**
   - Power Automate's visual email editor parses and reorganizes HTML when saving
   - ❌ Pasting raw HTML in Body field → Gets reformatted, elements rearranged
   - ✅ Use **Compose** action to build complete HTML, then reference in Body
   - Body field: `@{outputs('Compose_Email_Body')}` (single expression, not editable HTML)

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-14 | Initial modification guide created |
| 2026-01-14 | Converted from JSON to step-by-step format |
| 2026-01-14 | Added Part 9: Display Applied CNs in Customer Email |
| 2026-01-14 | Added Implementation Notes: SetVariable self-reference fix |
| 2026-01-14 | Added Implementation Notes: Approval status values |
| 2026-01-14 | Added troubleshooting entries for common implementation errors |
| 2026-01-15 | Added Implementation Notes: Power Automate expression limitations (abs, float, createArray) |
| 2026-01-15 | Updated Sort_CN_FIFO/Sort_DN_FIFO formulas to handle empty arrays |
| 2026-01-15 | Updated Calculate_Potential_Total to use sub(0,) instead of abs() |
| 2026-01-15 | Updated Apply_CN_Amount to use coalesce() instead of float() |
| 2026-01-15 | **Added Check_Has_CNs condition** to prevent Do Until executing on empty array |
| 2026-01-15 | Updated step numbers (4.5-4.11) to accommodate new Check_Has_CNs step |
| 2026-01-15 | Added Implementation Notes: Do Until may execute once even when condition is true |
| 2026-01-15 | Fixed Build_AR_Alert_Table formula to use coalesce() instead of float() |
| 2026-01-15 | **Fixed map() error**: Replaced with Select action + join() for AR Alert table |
| 2026-01-15 | Added Implementation Notes: map() function does not exist in Power Automate |
| 2026-01-15 | **Replaced Select with Apply to Each**: Select text mode has JSON parsing issues with embedded HTML |
| 2026-01-15 | Added varTableRows (String) variable for AR Alert email table building |
| 2026-01-15 | **Added Compose_AR_Alert_Body**: Email editor reformats HTML; using Compose preserves structure |
