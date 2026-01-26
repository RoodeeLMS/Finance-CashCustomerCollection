# Step-by-Step: Add WorkingDayCalendar Arrear Calculation

**Date**: January 13, 2026
**Purpose**: Modify SAP Import flow to calculate arrear days using WorkingDayCalendar (working days only)
**Prerequisite**: WorkingDayCalendar table populated with 2025-2026 data

---

## Overview

**Current Logic** (Phase 1):
```
cr7bb_daycount = SAP's "ArrearsByNetDueDate" field  // Calendar days
```

**New Logic** (Phase 2):
```
cr7bb_daycount = TodayWDN - DueDateWDN  // Working days only
```

---

## Step 1: Open the Flow

1. Go to **make.powerautomate.com**
2. Navigate to **Solutions** → **THFinanceCashCollection**
3. Find and open: `[THFinanceCashCollection] Daily SAP Transaction Import`
4. Click **Edit**

---

## Step 2: Add Variable - varTodayWDN

**Location**: After `Initialize_varSourceFilePath`

1. Click **+** after `Initialize_varSourceFilePath`
2. Search and select **Initialize variable**
3. Configure:
   ```
   Name: varTodayWDN
   Type: Integer
   Value: 0
   ```
4. Rename action to: `Initialize_varTodayWDN`

---

## Step 3: Get Today's Working Day Number

**Location**: After `Create_Process_Log` (before the Apply to each loop)

1. Click **+** after `Set_varProcessLogID`
2. Search and select **List rows** (Dataverse)
3. Configure:
   ```
   Table name: WorkingDayCalendars
   Filter rows: nc_name eq '@{variables('varProcessDate')}'
   Row count: 1
   ```
4. Rename action to: `Get_Today_WDN`

---

## Step 4: Set Today's WDN Variable

**Location**: After `Get_Today_WDN`

1. Click **+** after `Get_Today_WDN`
2. Search and select **Set variable**
3. Configure:
   ```
   Name: varTodayWDN
   Value: @{coalesce(first(outputs('Get_Today_WDN')?['body/value'])?['nc_workingdaynumber'], 0)}
   ```
4. Rename action to: `Set_varTodayWDN`

> **Note**: `coalesce` returns 0 if today is a non-working day (weekend/holiday). This handles the edge case gracefully.

---

## Step 5: Inside Loop - Get DueDate's WDN

**Location**: Inside `Apply_to_each_row`, after `Compose_TransactionType` and BEFORE `Create_transaction`

1. Expand `Apply_to_each_row`
2. Expand `Check_if_Summary_Row` → else branch (transaction processing)
3. Click **+** after `Compose_TransactionType`
4. Search and select **List rows** (Dataverse)
5. Configure:
   ```
   Table name: WorkingDayCalendars
   Filter rows: nc_name eq '@{formatDateTime(items('Apply_to_each_row')?['NetDueDate'], 'yyyy-MM-dd')}'
   Row count: 1
   ```
6. Rename action to: `Get_DueDate_WDN`

---

## Step 6: Calculate Arrear Days (Simplified)

**Location**: After `Get_DueDate_WDN`, before `Create_transaction`

> **Note (2026-01-14 Update)**: With the single-pass buffered WorkingDayCalendar generation, **ALL dates have WDN values**. Non-working days (weekends/holidays) inherit the NEXT working day's WDN. This means **no null-check or fallback logic is needed**.

1. Click **+** after `Get_DueDate_WDN`
2. Search and select **Compose**
3. Configure:
   ```
   Inputs: @{sub(
       variables('varTodayWDN'),
       coalesce(first(outputs('Get_DueDate_WDN')?['body/value'])?['nc_workingdaynumber'], 0)
   )}
   ```
4. Rename to: `Calculated_ArrearDays`

> **Note**: The `coalesce(..., 0)` is a safety fallback if the date is outside the WorkingDayCalendar range. With proper calendar generation (2025-2027), this should never trigger.

---

## ~~Step 7: (REMOVED - No longer needed)~~

> **Previous Step 7** handled non-working day due dates with complex conditional logic. This is **no longer needed** because:
> - Non-working days now have WDN assigned (inherit NEXT working day's WDN)
> - Simple lookup returns valid WDN for any date
> - No null checks or fallback queries required

---

## Step 7: Update Create_transaction Action

**Location**: `Create_transaction` action inside the loop

1. Find the `Create_transaction` action
2. Change the `cr7bb_daycount` field:

**Before** (old):
```
"item/cr7bb_daycount": "@int(coalesce(items('Apply_to_each_row')?['ArrearsByNetDueDate'], 0))"
```

**After** (new):
```
"item/cr7bb_daycount": "@outputs('Calculated_ArrearDays')"
```

3. Optionally, you can also update `cr7bb_arrearsdays` to keep the original SAP value for reference, or change it to the calculated value.

---

## Step 8: Save and Test

1. Click **Save**
2. Click **Test** → **Manually**
3. Verify:
   - `varTodayWDN` is set correctly (check flow run details)
   - Each transaction has correct `cr7bb_daycount` (working days, not calendar days)

---

## Flow Diagram (Updated)

```
[Trigger: 8:00 AM Daily]
        │
        ▼
[Initialize Variables]
  + varTodayWDN = 0 (NEW)
        │
        ▼
[Get SAP File from SharePoint]
        │
        ▼
[Create Process Log]
        │
        ▼
[Get Today's WDN] (NEW)
  Query: WorkingDayCalendar WHERE Name = varProcessDate
        │
        ▼
[Set varTodayWDN] (NEW)
        │
        ▼
[Parse Excel → JSON]
        │
        ▼
[Apply to Each Row]
        │
        ├──► [Check Summary Row?]
        │      │
        │      └──► Transaction Row:
        │            │
        │            ├──► [Compose: isExcluded]
        │            ├──► [Compose: ParsedAmount]
        │            ├──► [Compose: TransactionType]
        │            │
        │            ├──► [Get_DueDate_WDN] (NEW)
        │            │      Query: WHERE Name = NetDueDate
        │            │
        │            ├──► [Condition: Non-working day?] (NEW)
        │            │      Yes: Get Previous Working Day
        │            │      No: Use direct WDN
        │            │
        │            ├──► [Final_DueDateWDN] (NEW)
        │            │
        │            ├──► [Calculated_ArrearDays] (NEW)
        │            │      = varTodayWDN - Final_DueDateWDN
        │            │
        │            └──► [Create_transaction]
        │                   cr7bb_daycount = Calculated_ArrearDays (MODIFIED)
        │
        ▼
[Rename File → Update Log → Send Email]
```

---

## Verification Checklist

After running the flow, verify in Dataverse:

| Check | Expected |
|-------|----------|
| Transaction with DueDate = Today | `daycount = 0` |
| Transaction with DueDate = Yesterday (working day) | `daycount = 1` |
| Transaction with DueDate = Last Friday (if today is Monday) | `daycount = 1` (not 3) |
| Transaction with DueDate = 5 working days ago | `daycount = 5` |

---

## Troubleshooting

### Error: "The template language expression 'outputs('Get_DueDate_WDN')...' cannot be evaluated"

**Cause**: Action name mismatch
**Fix**: Verify the exact action name in the flow and use it in `outputs('...')`

### Error: "Invalid type. Expected Integer but got Null"

**Cause**: WDN is null for non-working days
**Fix**: Wrap with `coalesce(..., 0)` to provide default value

### Performance: Flow is slow

**Cause**: Lookup inside loop adds latency
**Options**:
1. Accept the latency (recommended for ~500 transactions)
2. Pre-fetch all WDN values into an array (complex but faster)
3. Use parallel processing (set concurrency > 1, but careful with variable updates)

---

## Why No Condition Needed (2026-01-14 Update)

With the **single-pass buffered** WorkingDayCalendar generation:
- **ALL dates have WDN values** (no nulls)
- Non-working days inherit the **NEXT** working day's WDN
- Simple subtraction works for any date combination

**Standard Approach (Step 6):**

```
Action: Compose
Name: Calculated_ArrearDays
Inputs: @{sub(
  variables('varTodayWDN'),
  coalesce(
    first(outputs('Get_DueDate_WDN')?['body/value'])?['nc_workingdaynumber'],
    0
  )
)}
```

The `coalesce(..., 0)` is only a safety fallback for dates outside the calendar range. With proper generation (2025-2027), all lookups return valid WDN.

---

## Field Reference

| Field | Prefix | Example |
|-------|--------|---------|
| WorkingDayCalendar.Name | `nc_` | `nc_name` |
| WorkingDayCalendar.CalendarDate | `nc_` | `nc_calendardate` |
| WorkingDayCalendar.IsWorkingDay | `nc_` | `nc_isworkingday` |
| WorkingDayCalendar.WorkingDayNumber | `nc_` | `nc_workingdaynumber` |
| Transaction.DayCount | `cr7bb_` | `cr7bb_daycount` |

---

**Status**: Ready for implementation
