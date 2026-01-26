# Step-by-Step: WorkingDayCalendar Generation Flow

**Date**: January 14, 2026 (Updated)
**Flow Name**: `[THFinance] Generate WorkingDayCalendar`
**Purpose**: Populate WorkingDayCalendar table with WDN for all dates
**Algorithm**: Single-Pass Buffered (non-working days inherit NEXT working day's WDN)

---

## Critical Business Rule

> **Client Clarification (2026-01-14):** If a due date falls on a weekend (e.g., Saturday), the first working day after (Monday) should be counted as Day 0, not Day 1.

**Solution:** Non-working days inherit the **NEXT** working day's WDN.

| Date | Day Type | WDN |
|------|----------|-----|
| Friday | Working | 100 |
| Saturday | Weekend | **101** ← Same as Monday |
| Sunday | Weekend | **101** ← Same as Monday |
| Monday | Working | 101 |

---

## Prerequisites

1. **WorkingDayCalendar table** exists in Dataverse:
   - `cr7bb_name` (Text, Primary) - Format: "yyyy-MM-dd"
   - `cr7bb_calendardate` (Date Only)
   - `cr7bb_isworkingday` (Yes/No)
   - `cr7bb_workingdaynumber` (Whole Number)
   - `cr7bb_year` (Whole Number)

2. **CalendarEvent table** exists with holiday data:
   - `cr7bb_eventdate` (Date Only)
   - `cr7bb_eventname` (Text)

---

## Flow 1: Generate/Regenerate WorkingDayCalendar

### Step 1: Create Flow

1. Go to **make.powerautomate.com**
2. Click **+ Create** → **Instant cloud flow**
3. Name: `[THFinance] Generate WorkingDayCalendar`
4. Trigger: **Manually trigger a flow**
5. Click **Create**

---

### Step 2: Add Trigger Inputs

1. Click on the trigger **Manually trigger a flow**
2. Click **+ Add an input** → **Number**
   - Input name: `StartYear`
   - Default: `2025`
3. Click **+ Add an input** → **Number**
   - Input name: `EndYear`
   - Default: `2027`

---

### Step 3: Initialize Variables

Add **5 variables** (click **+ New step** for each):

> **Note**: Power Automate names number inputs as `number`, `number_1`, etc.

**Variable 1: varStartDate**
```
Name: varStartDate
Type: String
Value: @{concat(string(triggerBody()?['number']), '-01-01')}
```

**Variable 2: varEndDate**
```
Name: varEndDate
Type: String
Value: @{concat(string(triggerBody()?['number_1']), '-12-31')}
```

**Variable 3: varWorkingDayNumber**
```
Name: varWorkingDayNumber
Type: Integer
Value: 0
```

**Variable 4: varCurrentDate**
```
Name: varCurrentDate
Type: String
Value: @{variables('varStartDate')}
```

**Variable 5: varPendingBuffer** ⭐ NEW
```
Name: varPendingBuffer
Type: Array
Value: []
```
> This buffers non-working day record IDs until the next working day

---

### Step 4: Get Starting WDN (for append mode)

**Action**: List rows (Dataverse)
```
Table name: WorkingDayCalendars
Filter rows: cr7bb_calendardate lt @{variables('varStartDate')} and cr7bb_isworkingday eq true
Order by: cr7bb_calendardate desc
Row count: 1
```
Rename to: `Get_Last_WDN_Before`

**Action**: Condition
```
Condition: length(outputs('Get_Last_WDN_Before')?['body/value']) is greater than 0
```

**If Yes**: Set variable
```
Name: varWorkingDayNumber
Value: @{coalesce(first(outputs('Get_Last_WDN_Before')?['body/value'])?['cr7bb_workingdaynumber'], 0)}
```

---

### Step 5: Get All Holidays

**Action**: List rows (Dataverse)
```
Table name: CalendarEvents
Filter rows: cr7bb_eventdate ge @{variables('varStartDate')} and cr7bb_eventdate le @{variables('varEndDate')}
```
Rename to: `Get_All_Holidays`

**Action**: Select (Data Operations)
```
From: @{outputs('Get_All_Holidays')?['body/value']}
Map: @{formatDateTime(item()?['cr7bb_eventdate'], 'yyyy-MM-dd')}
```
Rename to: `Holiday_Dates_Array`

---

### Step 6: Do Until Loop

**Action**: Do until
```
Condition: @{variables('varCurrentDate')} is greater than @{variables('varEndDate')}
```

**Settings** (click ... → Change limits):
- Count: `1500` (for 3+ years)
- Timeout: `PT4H`

---

### Step 7: Inside Loop - Calculate Day Type

**Action 1**: Compose
```
Inputs: @{or(equals(dayOfWeek(variables('varCurrentDate')), 0), equals(dayOfWeek(variables('varCurrentDate')), 6))}
```
Rename to: `IsWeekend`

**Action 2**: Compose
```
Inputs: @{contains(body('Holiday_Dates_Array'), variables('varCurrentDate'))}
```
Rename to: `IsHoliday`

**Action 3**: Compose
```
Inputs: @{and(not(outputs('IsWeekend')), not(outputs('IsHoliday')))}
```
Rename to: `IsWorkingDay`

---

### Step 8: Inside Loop - Check if Record Exists

**Action**: List rows (Dataverse)
```
Table name: WorkingDayCalendars
Filter rows: cr7bb_name eq '@{variables('varCurrentDate')}'
Row count: 1
```
Rename to: `Check_Existing_Record`

---

### Step 9: Inside Loop - Create or Get Record ID

**Action**: Condition
```
Condition: length(outputs('Check_Existing_Record')?['body/value']) is greater than 0
```

**If Yes (Record Exists)**:

Add: Compose
```
Inputs: @{first(outputs('Check_Existing_Record')?['body/value'])?['cr7bb_workingdaycalendarid']}
```
Rename to: `Existing_Record_ID`

**If No (Create New)**:

Add: Add a new row (Dataverse)
```
Table name: WorkingDayCalendars
Name: @{variables('varCurrentDate')}
Calendar Date: @{variables('varCurrentDate')}
Is Working Day: @{outputs('IsWorkingDay')}
Year: @{int(substring(variables('varCurrentDate'), 0, 4))}
```
> Leave Working Day Number empty (will be set later)

Rename to: `Create_New_Record`

Add: Compose
```
Inputs: @{outputs('Create_New_Record')?['body/cr7bb_workingdaycalendarid']}
```
Rename to: `New_Record_ID`

---

### Step 10: After Condition - Get Current Record ID

**Location**: After the Create/Get condition (parallel branch merge point)

**Action**: Compose
```
Inputs: @{coalesce(outputs('Existing_Record_ID'), outputs('New_Record_ID'))}
```
Rename to: `Current_Record_ID`

---

### Step 11: Inside Loop - Process Based on Day Type ⭐ KEY CHANGE

**Action**: Condition
```
Condition: @{outputs('IsWorkingDay')} is equal to true
```

---

#### If Yes (Working Day) - 4 Actions

**11A.1**: Increment variable
```
Name: varWorkingDayNumber
Value: 1
```

**11A.2**: Update a row (Dataverse)
```
Table name: WorkingDayCalendars
Row ID: @{outputs('Current_Record_ID')}
Is Working Day: Yes
Working Day Number: @{variables('varWorkingDayNumber')}
```
Rename to: `Update_Working_Day`

**11A.3**: Condition (Flush Buffer)
```
Condition: length(variables('varPendingBuffer')) is greater than 0
```

**If Buffer Not Empty**:

Add: Apply to each
```
Select an output: @{variables('varPendingBuffer')}
```
> **Settings**: Concurrency = 20 (parallel updates)

Inside Apply to each, add: Update a row (Dataverse)
```
Table name: WorkingDayCalendars
Row ID: @{items('Apply_to_each')}
Working Day Number: @{variables('varWorkingDayNumber')}
```
Rename to: `Update_Buffered_Records`

**11A.4**: Set variable (Clear Buffer)
```
Name: varPendingBuffer
Value: []
```

---

#### If No (Non-Working Day) - 2 Actions

**11B.1**: Update a row (Dataverse)
```
Table name: WorkingDayCalendars
Row ID: @{outputs('Current_Record_ID')}
Is Working Day: No
```
Rename to: `Update_NonWorking_Day`

> Note: Do NOT set WorkingDayNumber here - it will be set when next working day is processed

**11B.2**: Append to array variable
```
Name: varPendingBuffer
Value: @{outputs('Current_Record_ID')}
```

---

### Step 12: Inside Loop - Increment Date

**Action 1**: Compose
```
Inputs: @{formatDateTime(addDays(variables('varCurrentDate'), 1), 'yyyy-MM-dd')}
```
Rename to: `NextDate`

**Action 2**: Set variable
```
Name: varCurrentDate
Value: @{outputs('NextDate')}
```

---

### Step 13: After Loop - Handle Trailing Non-Working Days ⭐ EDGE CASE

**Location**: OUTSIDE the Do Until loop

**Action**: Condition
```
Condition: length(variables('varPendingBuffer')) is greater than 0
```
Rename to: `Check_Trailing_Buffer`

**If Yes (Buffer has items)**:

Add: Apply to each
```
Select an output: @{variables('varPendingBuffer')}
```

Inside, add: Update a row (Dataverse)
```
Table name: WorkingDayCalendars
Row ID: @{items('Apply_to_each')}
Working Day Number: @{variables('varWorkingDayNumber')}
```
Rename to: `Update_Trailing_NonWorking`

> **Why**: If Dec 31 is a weekend/holiday, those days are in the buffer but never flushed. This assigns them the last known WDN as fallback.

---

### Step 14: Log Completion

**Action**: Add a new row (Dataverse)
```
Table name: [THFinanceCashCollection]Process Logs
Fields:
  cr7bb_processdate: @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
  cr7bb_starttime: @{utcNow()}
  cr7bb_endtime: @{utcNow()}
  cr7bb_status: Completed
  cr7bb_processtype: WorkingDayGeneration
  cr7bb_summary: Generated @{variables('varStartDate')} to @{variables('varEndDate')}. Final WDN: @{variables('varWorkingDayNumber')}
```

---

### Step 15: Save and Test

1. Click **Save**
2. Click **Test** → **Manually**
3. Enter: StartYear = `2026`, EndYear = `2026`
4. Click **Run flow**
5. Wait for completion (~5-10 min for 1 year)

---

## Complete Flow Structure

```
[Manually trigger a flow]
  ├── Inputs: StartYear, EndYear
  │
  ├── Initialize varStartDate
  ├── Initialize varEndDate
  ├── Initialize varWorkingDayNumber
  ├── Initialize varCurrentDate
  ├── Initialize varPendingBuffer          ⭐ NEW
  │
  ├── Get_Last_WDN_Before
  ├── Condition: Has previous data?
  │   └── Yes: Set varWorkingDayNumber
  │
  ├── Get_All_Holidays
  ├── Holiday_Dates_Array (Select)
  │
  ├── ═══ Do Until (varCurrentDate > varEndDate) ═══
  │   │
  │   ├── IsWeekend (Compose)
  │   ├── IsHoliday (Compose)
  │   ├── IsWorkingDay (Compose)
  │   │
  │   ├── Check_Existing_Record
  │   ├── Condition: Record exists?
  │   │   ├── Yes: Existing_Record_ID
  │   │   └── No: Create_New_Record → New_Record_ID
  │   │
  │   ├── Current_Record_ID (Compose)
  │   │
  │   ├── Condition: IsWorkingDay?
  │   │   │
  │   │   ├── ✅ Yes (Working Day):
  │   │   │   ├── Increment varWorkingDayNumber
  │   │   │   ├── Update_Working_Day (set WDN)
  │   │   │   ├── Condition: Buffer not empty?
  │   │   │   │   └── Yes: Apply to each → Update_Buffered_Records
  │   │   │   └── Clear varPendingBuffer = []
  │   │   │
  │   │   └── ❌ No (Non-Working Day):
  │   │       ├── Update_NonWorking_Day (no WDN yet)
  │   │       └── Append to varPendingBuffer
  │   │
  │   ├── NextDate (Compose)
  │   └── Set varCurrentDate
  │
  ├── ═══ After Loop ═══
  │
  ├── Check_Trailing_Buffer               ⭐ EDGE CASE
  │   └── If buffer not empty:
  │       └── Apply to each → Update_Trailing_NonWorking
  │
  └── Log Completion
```

---

## Testing Scenarios

### Test 1: Weekend Buffer
**Setup**: Run for January 2026

| Date | Expected WDN |
|------|--------------|
| Fri Jan 2 | 2 |
| Sat Jan 3 | **5** (same as Mon) |
| Sun Jan 4 | **5** (same as Mon) |
| Mon Jan 5 | 5 |

**Verify**: Saturday and Sunday have Monday's WDN

### Test 2: Long Holiday
**Setup**: Add Dec 31 - Jan 2 as holidays

**Verify**: All 3 days get WDN of Jan 3 (first working day after)

### Test 3: Year End Edge Case
**Setup**: Dec 31, 2026 is Thursday (working day)

**Verify**: Dec 31 has a WDN (not null)

### Test 4: Year End on Weekend
**Setup**: Dec 31, 2027 is Friday; Dec 30/31 should buffer

**Verify**: Post-loop cleanup assigns WDN to weekend days

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Loop times out | Reduce year range or increase timeout |
| Buffer not clearing | Ensure Set variable is AFTER Apply to each |
| Wrong WDN on weekends | Verify buffer append/flush logic |
| Null WDN at year end | Check post-loop buffer processing |
| Duplicate records | Verify upsert logic in Step 9 |

---

## Performance Notes

| Year Range | Approximate Time |
|------------|------------------|
| 1 year (365 days) | 5-10 minutes |
| 2 years (730 days) | 10-20 minutes |
| 3 years (1,095 days) | 15-30 minutes |

**Optimization Tips**:
- Enable concurrency = 20 on buffer flush loops
- Run during off-peak hours
- Test with 1 year first

---

## Flow 2: Recalculate on Holiday Change (OPTIONAL)

> **Note**: Optional for Phase 2. The Generate flow supports regeneration, so users can manually run it after holiday changes.

For automated recalculation on holiday changes, see the original detailed steps below. The key change is to also implement the buffering logic.

**When to implement Flow 2**:
- Users frequently forget to run Flow 1 after holiday changes
- Real-time WDN accuracy is critical
- Holidays change more than 2-3 times per year

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-10 | Initial step-by-step guide (two-pass approach) |
| 2026-01-14 | **Updated to single-pass buffered approach** |
| 2026-01-14 | Added varPendingBuffer variable |
| 2026-01-14 | Added post-loop edge case handling |
| 2026-01-14 | Non-working days now inherit NEXT working day's WDN |
