# Flow Modification: Email Engine - Granular isExcluded Tracking

> **Priority**: Enhancement
> **Flow**: Daily Collections Email Engine
> **Created**: 2026-01-27
> **Approach**: Granular (transaction-level tracking)

---

## Overview

Mark individual transactions as excluded based on FIFO logic:
- **Transactions IN email**: Not excluded (both DNs and applied CNs that customer sees)
- **Transactions NOT in email**: Excluded (when customer's Net ≤ 0)

---

## Transaction States After Flow Runs

| Scenario | isProcessed | emailSent | isExcluded | excludeReason |
|----------|-------------|-----------|------------|---------------|
| **Before flow runs** | No | No | No | (blank) |
| **DN in email** | Yes | Yes | No | (blank) |
| **Applied CN in email** | Yes | Yes | No | (blank) |
| **DN when Net ≤ 0** | Yes | No | Yes | FIFO: Net amount zero |
| **CN when Net ≤ 0** | Yes | No | Yes | FIFO: Net amount zero |
| **Non-applied CN (edge case)** | Yes | No | Yes | Credit Note - exceeds balance |

---

## Prerequisites

1. Open **Power Automate** → **Solutions** → **TH Finance Cash Collection**
2. Find **Daily Collections Email Engine** → Click **Edit**
3. Wait for the flow designer to load

---

## MODIFICATION 1: Mark Emailed Transactions as Not Excluded

**Why**: Transactions included in emails should explicitly have `Is Excluded = No`.

### Navigation Path
```
Apply_to_each_Customer
  └── Check_All_Excluded → If no (NO branch)
        └── Check_Should_Send → If yes (YES branch)
              └── Update_Transaction_Records
                    └── Update_Transaction  ← MODIFY THIS
```

### Step-by-Step Instructions

1. **Expand** `Apply_to_each_Customer` (click to expand)

2. **Scroll down** and find `Check_All_Excluded` condition

3. **Click** the **No** branch (left side or "If no")

4. **Scroll down** and find `Check_Should_Send` condition

5. **Click** the **Yes** branch (left side or "If yes")

6. **Expand** `Update_Transaction_Records` loop

7. **Click** on `Update_Transaction` action to open it

8. **Click** "Show all" or expand "Advanced options"

9. **Find** the field **Is Excluded** and set it to: `No`

10. **Leave** the field **Exclude Reason** blank (don't set it)

11. **Click** outside the action to save changes

---

## MODIFICATION 2: Mark All Transactions Excluded When Net ≤ 0

**Why**: When customer's Net ≤ 0, credits fully cover debits, so no email is sent. All transactions should be marked as excluded.

### Navigation Path
```
Apply_to_each_Customer
  └── Check_All_Excluded → If no (NO branch)
        └── Check_Should_Send → If no (NO branch)  ← ADD ACTIONS HERE
              (currently empty)
```

### Step-by-Step Instructions

#### Part A: Add Loop for DNs

1. **Navigate** to `Check_Should_Send` condition (same path as above)

2. **Click** the **No** branch (right side or "If no") - this is currently empty

3. **Click** the **+** button → **Add an action**

4. **Search** for `Apply to each`

5. **Select** "Control" → "Apply to each"

6. **Rename** the action:
   - Click the three dots (⋮) → **Rename**
   - Enter: `Mark_DNs_Excluded`

7. **Configure "Select an output from previous steps"**:
   - Click the input field
   - Click **Expression** tab (or fx icon)
   - Type: `outputs('Sort_DN_FIFO')`
   - Click **OK** or **Add**

8. **Inside the loop**, click **+** → **Add an action**

9. **Search** for `Update a row`

10. **Select** "Microsoft Dataverse" → "Update a row"

11. **Configure the Update action**:

    | Field | Value |
    |-------|-------|
    | **Table name** | Transactions *(or search: THFinanceCashCollectionTransactions)* |
    | **Row ID** | *(click Expression tab)* `items('Mark_DNs_Excluded')?['cr7bb_thfinancecashcollectiontransactionid']` |
    | **Is Processed** | Yes |
    | **Is Excluded** | Yes |
    | **Exclude Reason** | `FIFO: Net amount zero` |

#### Part B: Add Loop for CNs

1. **After** `Mark_DNs_Excluded`, click **+** → **Add an action**

2. **Search** for `Apply to each` → Select it

3. **Rename** to: `Mark_CNs_Excluded`

4. **Configure "Select an output"**:
   - Click **Expression** tab
   - Type: `outputs('Sort_CN_FIFO')`
   - Click **OK**

5. **Inside**, add **Update a row** with:

    | Field | Value |
    |-------|-------|
    | **Table name** | Transactions |
    | **Row ID** | *(Expression)* `items('Mark_CNs_Excluded')?['cr7bb_thfinancecashcollectiontransactionid']` |
    | **Is Processed** | Yes |
    | **Is Excluded** | Yes |
    | **Exclude Reason** | `FIFO: Net amount zero` |

---

## MODIFICATION 3: Mark Non-Applied CNs (Edge Case)

**Scenario**: Customer has DN=1000, CN=-400, CN=-700 (total CN = -1100)
- Net = 1000 - 400 = 600 → Email IS sent
- First CN (-400) is applied and included in email
- Second CN (-700) is NOT applied (would exceed DN total)
- Without this fix, the non-applied CN stays with `isProcessed = No`

### Navigation Path
```
Apply_to_each_Customer
  └── Check_All_Excluded → If no (NO branch)
        └── Check_Should_Send → If yes (YES branch)
              └── Update_Transaction_Records
              └── [ADD NEW ACTIONS HERE - after Update_Transaction_Records]
```

### Step-by-Step Instructions

#### Part A: Extract Applied CN IDs

1. **Navigate** to `Check_Should_Send` → **Yes** branch

2. **After** `Update_Transaction_Records`, click **+** → **Add an action**

3. **Search** for `Select` → Choose "Data Operations" → "Select"

4. **Rename** to: `Select_Applied_CN_IDs`

5. **Configure**:

    | Field | How to set |
    |-------|------------|
    | **From** | Click Expression → type: `variables('varAppliedCNList')` → OK |
    | **Map** | Click "Switch to text mode" (T icon), then enter: `@item()?['cr7bb_thfinancecashcollectiontransactionid']` |

    **Alternative (Key/Value mode)**: If using key-value mode instead of text mode:
    - Key: `id`
    - Value: Click Expression → `item()?['cr7bb_thfinancecashcollectiontransactionid']`

#### Part B: Filter Non-Applied CNs

1. **After** `Select_Applied_CN_IDs`, click **+** → **Add an action**

2. **Search** for `Filter array` → Choose "Data Operations" → "Filter array"

3. **Rename** to: `Filter_Non_Applied_CNs`

4. **Configure**:

    | Field | How to set |
    |-------|------------|
    | **From** | Click Expression → type: `outputs('Sort_CN_FIFO')` → OK |

5. **For the condition**, click "Edit in advanced mode"

6. **Enter this expression**:
   ```
   @not(contains(body('Select_Applied_CN_IDs'), item()?['cr7bb_thfinancecashcollectiontransactionid']))
   ```

#### Part C: Update Non-Applied CNs

1. **After** `Filter_Non_Applied_CNs`, click **+** → **Add an action**

2. **Search** for `Apply to each` → Select it

3. **Rename** to: `Mark_Non_Applied_CNs_Excluded`

4. **Configure "Select an output"**:
   - Click Expression → type: `body('Filter_Non_Applied_CNs')` → OK

5. **Inside**, add **Update a row** with:

    | Field | Value |
    |-------|-------|
    | **Table name** | Transactions |
    | **Row ID** | *(Expression)* `items('Mark_Non_Applied_CNs_Excluded')?['cr7bb_thfinancecashcollectiontransactionid']` |
    | **Is Processed** | Yes |
    | **Is Excluded** | Yes |
    | **Exclude Reason** | `Credit Note - exceeds balance` |

---

## Save and Test

1. **Click** "Save" at the top of the flow designer

2. **Wait** for save to complete

3. **Test** with sample data (see Testing Checklist below)

---

## Visual Summary (After All Modifications)

```
Check_Should_Send (Net > 0 AND has DNs)
│
├── YES (Send Email):
│   ├── Combine_DN_and_CN
│   ├── Create_Email_Log
│   ├── Update_Email_Counters
│   ├── Update_Transaction_Records
│   │   └── Update_Transaction               ← MOD 1: Is Excluded = No
│   │
│   ├── Select_Applied_CN_IDs                ← MOD 3 (new)
│   ├── Filter_Non_Applied_CNs               ← MOD 3 (new)
│   └── Mark_Non_Applied_CNs_Excluded        ← MOD 3 (new)
│       └── Update: Is Excluded = Yes
│                   Exclude Reason = "Credit Note - exceeds balance"
│
└── NO (Net ≤ 0, Skip Email):                ← MOD 2 (new)
    ├── Mark_DNs_Excluded
    │   └── Update: Is Excluded = Yes
    │               Exclude Reason = "FIFO: Net amount zero"
    │
    └── Mark_CNs_Excluded
        └── Update: Is Excluded = Yes
                    Exclude Reason = "FIFO: Net amount zero"
```

---

## Testing Checklist

After modification, test these scenarios:

| # | Test Case | Expected Result |
|---|-----------|-----------------|
| 1 | Customer: DN=1000, no CN | DN: emailSent=Yes, isExcluded=No |
| 2 | Customer: DN=1000, CN=-400 | Both: emailSent=Yes, isExcluded=No |
| 3 | Customer: DN=1000, CN=-1000 | All: emailSent=No, isExcluded=Yes, reason="FIFO: Net amount zero" |
| 4 | Customer: DN=500, CN=-800 | All: emailSent=No, isExcluded=Yes, reason="FIFO: Net amount zero" |
| 5 | Customer: DN=1000, CN=-400, CN=-700 | DN + first CN: emailSent=Yes, isExcluded=No; Second CN: isExcluded=Yes, reason="Credit Note - exceeds balance" |

### How to Test

1. Create test customer with transactions matching scenarios above
2. Run the flow manually (or wait for scheduled run)
3. Check Transaction records in Dataverse:
   - Open **Power Apps** → **Tables** → **Transactions**
   - Filter by test customer
   - Verify `isProcessed`, `emailSent`, `isExcluded`, `excludeReason` fields

---

## Rollback Instructions

If issues occur, remove the modifications:

1. **MOD 1**: In `Update_Transaction`, remove the `Is Excluded = No` field (leave it unset)

2. **MOD 2**: Delete both loops from the NO branch:
   - Right-click `Mark_DNs_Excluded` → Delete
   - Right-click `Mark_CNs_Excluded` → Delete

3. **MOD 3**: Delete all three new actions from the YES branch:
   - Right-click `Select_Applied_CN_IDs` → Delete
   - Right-click `Filter_Non_Applied_CNs` → Delete
   - Right-click `Mark_Non_Applied_CNs_Excluded` → Delete

4. **Save** the flow

---

## Dashboard Formula (After Flow Change)

Once flow is updated, you can simplify dashboard stats:

```
# Count excluded transactions (use cr7bb_isexcluded directly)
="Excluded: " & CountRows(Filter('[THFinanceCashCollection]Transactions',
    cr7bb_transactionprocessdate >= _selectedDate &&
    cr7bb_transactionprocessdate < DateAdd(_selectedDate, 1, TimeUnit.Days) &&
    cr7bb_isexcluded = true))

# Count transactions in emails
="In Emails: " & CountRows(Filter('[THFinanceCashCollection]Transactions',
    cr7bb_transactionprocessdate >= _selectedDate &&
    cr7bb_transactionprocessdate < DateAdd(_selectedDate, 1, TimeUnit.Days) &&
    cr7bb_emailsent = true))
```

---

## Expression Quick Reference

| Action | Field | Expression to Enter |
|--------|-------|---------------------|
| Loop over DNs | Select an output | `outputs('Sort_DN_FIFO')` |
| Loop over CNs | Select an output | `outputs('Sort_CN_FIFO')` |
| Get DN transaction ID | Row ID | `items('Mark_DNs_Excluded')?['cr7bb_thfinancecashcollectiontransactionid']` |
| Get CN transaction ID | Row ID | `items('Mark_CNs_Excluded')?['cr7bb_thfinancecashcollectiontransactionid']` |
| Get applied CN list | From | `variables('varAppliedCNList')` |
| Select: Map (text mode) | Map | `@item()?['cr7bb_thfinancecashcollectiontransactionid']` |
| Filter: From | From | `outputs('Sort_CN_FIFO')` |
| Filter: Condition | Advanced mode | `@not(contains(body('Select_Applied_CN_IDs'), item()?['cr7bb_thfinancecashcollectiontransactionid']))` |
| Loop over filtered CNs | Select an output | `body('Filter_Non_Applied_CNs')` |

**Note on Select action**: The Map field has two modes:
- **Text mode** (click T icon): Enter `@item()?['field']` directly
- **Key/Value mode**: Add key name + value expression

---

## Related Documents

- [FIELD_NAME_REFERENCE.md](../02-Database-Schema/FIELD_NAME_REFERENCE.md) - Field names
- [Flow_StepByStep_FIFO_EmailEngine.md](Flow_StepByStep_FIFO_EmailEngine.md) - FIFO logic
- [Flow_Inventory.md](Flow_Inventory.md) - All flows
