# WorkingDayCalendar Generation Flow Design

**Date**: January 14, 2026 (Updated)
**Purpose**: Power Automate flows to generate and maintain WorkingDayCalendar table

---

## Overview

**Required Flow:**
1. **Generate Flow** - Populate/regenerate calendar for date range (manual trigger)

**Optional Flow (Future Enhancement):**
2. **Recalculation Flow** - Update when holidays change (automatic trigger)

> **Phase 2 Decision**: Flow 1 alone is sufficient. It supports regeneration (upsert pattern), so users can run it after holiday changes. Flow 2 adds automation but is not required for initial deployment.

---

## Critical Business Rule: WDN Assignment

**Client Clarification (2026-01-14):**
> If a due date falls on a weekend (e.g., Saturday), the first working day after (Monday) should be counted as Day 0, not Day 1.

**Implementation:** Non-working days inherit the **NEXT** working day's WDN (not previous).

| Date | Day Type | WDN | Explanation |
|------|----------|-----|-------------|
| Friday | Working | 100 | Working day |
| Saturday | Weekend | **101** | Inherits Monday's WDN |
| Sunday | Weekend | **101** | Inherits Monday's WDN |
| Monday | Working | 101 | New working day |
| Tuesday | Working | 102 | Working day |

**Result:** If DueDate = Saturday and Today = Tuesday:
- Saturday WDN = 101, Tuesday WDN = 102
- ArrearDays = 102 - 101 = **1 day** ✅

---

## Flow 1: Generate/Regenerate WorkingDayCalendar (Single-Pass Buffered)

**Trigger**: Manual (button) or Scheduled (yearly)
**Purpose**: Create or update calendar records for a specified year range
**Supports**: Initial generation AND regeneration (idempotent)

### Algorithm: Single-Pass Buffered Approach

**Key Insight:** Instead of two passes, buffer non-working days and assign WDN when the next working day is encountered.

```
varWDN = starting value
pendingNonWorkingDays = []  // Buffer

For each date in range:
    If IsWorkingDay:
        Increment varWDN
        Assign WDN to this working day
        Assign same WDN to ALL buffered non-working days
        Clear buffer
    Else (non-working day):
        Add to pendingNonWorkingDays buffer (don't assign WDN yet)

After loop (edge case):
    If buffer not empty:
        // Last days of range are non-working - use last WDN as fallback
        Assign varWDN to all remaining buffered days
```

### Flow Diagram (Single-Pass Buffered)

```
[Manual Trigger with Year Input]
  Inputs: StartYear (e.g., 2025), EndYear (e.g., 2027)
        │
        ▼
[Initialize Variables]
  - varStartDate = Jan 1 of StartYear
  - varEndDate = Dec 31 of EndYear
  - varWorkingDayNumber = 0
  - varCurrentDate = varStartDate
  - varPendingNonWorkingDays = []  // Array to buffer non-working day record IDs
        │
        ▼
[Get Starting WDN (for appending to existing data)]
  Query: WorkingDayCalendar WHERE CalendarDate < varStartDate
         AND IsWorkingDay = true
         ORDER BY CalendarDate DESC, TOP 1
  If found: varWorkingDayNumber = result.WorkingDayNumber
  If not found: varWorkingDayNumber = 0 (fresh start)
        │
        ▼
[Get All Holidays for Date Range]
  Filter: Year(EventDate) >= StartYear AND Year(EventDate) <= EndYear
  Select: EventDate only
  Store in: varHolidayDates (array)
        │
        ▼
════════════════════════════════════════════════════════════════
              SINGLE PASS: Process All Days with Buffering
════════════════════════════════════════════════════════════════
        │
        ▼
[Do Until: varCurrentDate > varEndDate]
        │
        ├──► [Compose: Check Day Type]
        │      DayOfWeek = dayOfWeek(varCurrentDate)
        │      IsWeekend = DayOfWeek in [0, 6]  // Sun=0, Sat=6
        │      IsHoliday = varCurrentDate in varHolidayDates
        │      IsWorkingDay = NOT(IsWeekend OR IsHoliday)
        │
        ├──► [Check if Record Exists]
        │      Query: WHERE Name = formatDateTime(varCurrentDate, 'yyyy-MM-dd')
        │
        ├──► [Condition: Record Exists?]
        │      │
        │      ├─► Yes: Store existing record ID in varCurrentRecordID
        │      │
        │      └─► No: [Create Dataverse Row]
        │               Name: formatDateTime(varCurrentDate, 'yyyy-MM-dd')
        │               CalendarDate: varCurrentDate
        │               IsWorkingDay: calculated
        │               WorkingDayNumber: null (will be set below)
        │               Year: year(varCurrentDate)
        │               → Store new record ID in varCurrentRecordID
        │
        ├──► [Condition: IsWorkingDay = true]
        │      │
        │      ├─► Yes (Working Day):
        │      │      │
        │      │      ├──► [Increment varWorkingDayNumber]
        │      │      │
        │      │      ├──► [Update Current Record with WDN]
        │      │      │      WorkingDayNumber: varWorkingDayNumber
        │      │      │
        │      │      ├──► [Condition: Buffer Not Empty?]
        │      │      │      Yes: [Apply to Each Buffered Record]
        │      │      │             Update WorkingDayNumber: varWorkingDayNumber
        │      │      │
        │      │      └──► [Clear Buffer]
        │      │             varPendingNonWorkingDays = []
        │      │
        │      └─► No (Non-Working Day):
        │             │
        │             ├──► [Update IsWorkingDay = false]
        │             │
        │             └──► [Add to Buffer]
        │                    Append varCurrentRecordID to varPendingNonWorkingDays
        │
        └──► [Increment varCurrentDate by 1 day]
        │
        ▼
════════════════════════════════════════════════════════════════
            POST-LOOP: Handle Edge Case (Trailing Non-Working Days)
════════════════════════════════════════════════════════════════
        │
        ▼
[Condition: varPendingNonWorkingDays is NOT empty]
  │
  └─► Yes: [Apply to Each Remaining Buffered Record]
             // Use last known WDN as fallback
             // (These are end-of-year holidays/weekends)
             Update WorkingDayNumber: varWorkingDayNumber
```

### Edge Cases Handled

| Edge Case | Scenario | Solution |
|-----------|----------|----------|
| **First days non-working** | Jan 1 is weekend/holiday | Buffered until first working day; all get that WDN ✅ |
| **Last days non-working** | Dec 31 is weekend/holiday | Post-loop cleanup assigns last WDN to buffer ✅ |
| **Long holiday streak** | Week of holidays | All buffered, assigned together when working day hit ✅ |
| **Single day gap** | Friday → Monday | Sat/Sun buffered, assigned Monday's WDN ✅ |

### Why Single-Pass is Better

| Aspect | Two-Pass | Single-Pass Buffered |
|--------|----------|---------------------|
| **Dataverse calls** | N creates + M updates (2N total) | N creates/updates (N total) |
| **Passes through data** | 2 | 1 |
| **Memory** | Query non-working days again | Buffer array in memory |
| **Complexity** | Simpler logic | Slightly more complex |
| **Performance** | Slower (extra queries) | **Faster** ✅ |

### Regeneration Behavior

| Scenario | Behavior |
|----------|----------|
| First run (empty table) | Creates all records |
| Re-run same years | Updates existing records |
| Run with new year | Creates new + keeps existing |
| Holiday added/removed | Re-run with same years - updates all records |

### Why Upsert Pattern?

- **Idempotent**: Safe to run multiple times
- **No data loss**: Doesn't delete existing records
- **Flexible**: Can regenerate subset of years
- **Recovery**: If flow fails mid-run, just re-run

### Key Expressions

**Check if Weekend**:
```
// dayOfWeek returns 0=Sunday, 6=Saturday
@or(equals(dayOfWeek(variables('varCurrentDate')), 0),
    equals(dayOfWeek(variables('varCurrentDate')), 6))
```

**Check if Holiday**:
```
@contains(variables('varHolidayDates'),
          formatDateTime(variables('varCurrentDate'), 'yyyy-MM-dd'))
```

**Format Date for Name**:
```
@formatDateTime(variables('varCurrentDate'), 'yyyy-MM-dd')
```

### Performance Optimization

For 3 years (1,095 rows), use **batch processing**:

```
[Get Holidays into Array]
        │
        ▼
[Compose: Generate All Dates Array]
  Use range() and addDays() to create date array
        │
        ▼
[Apply to Each (Concurrency: 20)]
  Create WorkingDayCalendar rows in parallel batches
```

**Alternative**: Use Dataverse bulk import action if available.

---

## Flow 2: Recalculate on Holiday Change (OPTIONAL)

**Status**: Optional for Phase 2 - implement if automation is requested
**Trigger**: When CalendarEvent row created/modified/deleted
**Purpose**: Recalculate WorkingDayNumbers from affected date onwards

### Flow Diagram

```
[Trigger: When CalendarEvent modified]
  Outputs: EventDate, ChangeType (Create/Update/Delete)
        │
        ▼
[Get Affected Date]
  - For Create/Update: Use EventDate from trigger
  - For Delete: Use EventDate from trigger (before delete)
        │
        ▼
[Find Starting Point]
  Query WorkingDayCalendar:
    Filter: CalendarDate < AffectedDate AND IsWorkingDay = true
    OrderBy: CalendarDate DESC
    Top: 1
  Output: LastWorkingDayNumber before affected date
        │
        ▼
[Get All Holidays from Affected Date]
  Filter: EventDate >= AffectedDate
  Select: EventDate
  Store in: varHolidayDates
        │
        ▼
[Get All Calendar Records to Update]
  Filter: CalendarDate >= AffectedDate
  OrderBy: CalendarDate ASC
        │
        ▼
[Initialize varWorkingDayNumber = LastWorkingDayNumber]
        │
        ▼
[Apply to Each Calendar Record]
        │
        ├──► [Check if Working Day]
        │      IsWeekend = dayOfWeek in [0, 6]
        │      IsHoliday = CalendarDate in varHolidayDates
        │      IsWorkingDay = NOT(IsWeekend OR IsHoliday)
        │
        ├──► [Condition: IsWorkingDay = true]
        │      Yes: Increment varWorkingDayNumber
        │
        └──► [Update Dataverse Row]
               IsWorkingDay: calculated value
               WorkingDayNumber: If(IsWorkingDay, varWorkingDayNumber, null)
        │
        ▼
[Create ProcessLog Record]
  ProcessType: "WorkingDayRecalc"
  ProcessDate: utcNow()
  Summary: "Recalculated from {AffectedDate}, updated {count} records"
```

### Trigger Configuration

**Dataverse Trigger**: "When a row is added, modified or deleted"
- Table: CalendarEvent
- Scope: Organization
- Change type: Added, Modified, Deleted

### Edge Cases

**Multiple holiday changes in quick succession**:
- Use "Concurrency Control" = Off (process one at a time)
- Or implement queue-based processing

**Holiday moved to different date**:
- Treated as: Old date recalc + New date recalc
- Flow handles this automatically (two trigger fires)

**Holiday deleted**:
- Date that was holiday becomes potential working day
- Recalc from that date forward

---

## Flow 3: Daily Arrear Calculation (Inline - Simplified)

No separate flow needed. Arrear calculation is **inline** in the main Daily Transaction Sync flow.

**With Single-Pass Buffered WDN:** ALL dates have WDN assigned (non-working days inherit next working day's WDN), so **no null check needed**.

```
[For Each Transaction from Power BI]
        │
        ▼
[Lookup: Today's WorkingDayNumber]
  Filter: CalendarDate = @{utcNow('yyyy-MM-dd')}
  Output: varTodayWDN
        │
        ▼
[Lookup: DueDate's WorkingDayNumber]
  Filter: CalendarDate = @{items('Apply_to_each')?['NETDT']}
  Output: varDueDateWDN
        │
        ▼
[Calculate ArrearDays]
  @sub(variables('varTodayWDN'), variables('varDueDateWDN'))
        │
        ▼
[Store in Transaction Record]
  cr7bb_daycount = ArrearDays
```

**Simplified!** No conditional logic needed because:
- Working days: Have their own WDN
- Non-working days: Have NEXT working day's WDN

**Example:**
| DueDate | DueDate WDN | Today | Today WDN | ArrearDays |
|---------|-------------|-------|-----------|------------|
| Friday (Working) | 100 | Tuesday | 102 | 2 |
| Saturday (Weekend) | 101 | Tuesday | 102 | 1 ✅ |
| Sunday (Weekend) | 101 | Tuesday | 102 | 1 ✅ |
| Monday (Working) | 101 | Tuesday | 102 | 1 |

---

## Implementation Order

### Phase 2 (Required)
1. **Create WorkingDayCalendar table** (Dataverse)
2. **Create Flow 1** (Generation) - Run for 2025-2027
3. **Test**: Add a holiday in CalendarEvent, re-run Flow 1, verify update
4. **Integrate**: Add arrear lookup to Daily Transaction Sync flow

### Future (Optional)
5. **Create Flow 2** (Recalculation) - Enable trigger for automation

---

## Dataverse Actions Used

| Action | Purpose |
|--------|---------|
| List rows | Get holidays, get calendar records |
| Add a new row | Create calendar record |
| Update a row | Update WorkingDayNumber |
| Get a row by ID | Lookup specific date |

---

## Variables Summary

| Variable | Type | Purpose |
|----------|------|---------|
| varCurrentDate | DateTime | Loop counter for generation |
| varWorkingDayNumber | Integer | Running counter for WDN |
| varHolidayDates | Array | List of holiday dates for lookup |
| varPendingNonWorkingDays | Array | Buffer for non-working day record IDs (single-pass) |
| varCurrentRecordID | String | ID of current record being processed |
| varTodayWDN | Integer | Today's working day number (arrear calc) |
| varDueDateWDN | Integer | Due date's working day number (arrear calc) |

---

**Status**: Ready for implementation

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-14 | Initial design with two-pass approach |
| 2026-01-14 | Updated to single-pass buffered approach (more efficient) |
| 2026-01-14 | Added edge case handling for trailing non-working days |
