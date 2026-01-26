# Arrear Days Calculation Logic v2.0

**Date**: January 9, 2026
**Status**: Draft - Pending Approval
**Purpose**: Calculate working days between Due Date and Today, excluding weekends and holidays

---

## Overview

The system needs to calculate "Arrear Days" (days overdue/until due) for each transaction to:
1. Determine whether to send notification
2. Select appropriate email template
3. Prioritize collection efforts

**Key Change from v1**: SAP's pre-calculated VERZN field is NOT used because it doesn't exclude weekends/holidays.

---

## Calculation Formula

```
Arrear Days = CountWorkingDays(NETDT, TODAY)

Where:
- NETDT = Net Due Date from SAP (Power BI export)
- TODAY = Current processing date
- Working Days = Excludes Saturdays, Sundays, and Thai Public Holidays
```

### Result Interpretation

| Arrear Days | Meaning | Action |
|-------------|---------|--------|
| Negative (e.g., -5) | 5 working days UNTIL due | Send reminder |
| Zero (0) | Due TODAY | Send due today notice |
| Positive (e.g., 3) | 3 working days OVERDUE | Send overdue warning |

---

## Calculation Algorithm

### Pseudocode

```
FUNCTION CountWorkingDays(DueDate, CurrentDate):

    IF DueDate = CurrentDate THEN
        RETURN 0

    // Determine direction
    IF DueDate > CurrentDate THEN
        // Not yet due - count forward, result will be negative
        StartDate = CurrentDate
        EndDate = DueDate
        Direction = -1
    ELSE
        // Overdue - count forward, result will be positive
        StartDate = DueDate
        EndDate = CurrentDate
        Direction = 1

    // Count working days
    WorkingDays = 0
    CurrentDay = StartDate

    WHILE CurrentDay < EndDate:
        CurrentDay = CurrentDay + 1 day

        // Skip weekends
        IF DayOfWeek(CurrentDay) = Saturday OR Sunday THEN
            CONTINUE

        // Skip holidays
        IF CurrentDay IN HolidayMaster THEN
            CONTINUE

        WorkingDays = WorkingDays + 1

    RETURN WorkingDays * Direction

END FUNCTION
```

### Example Calculations

**Example 1: Not Yet Due**
```
Due Date: January 15, 2026 (Wednesday)
Today: January 9, 2026 (Thursday)

Days between: Jan 10 (Fri), Jan 11 (Sat-skip), Jan 12 (Sun-skip),
              Jan 13 (Mon), Jan 14 (Tue), Jan 15 (Wed-not counted as end)

Working days: 10, 13, 14 = 3 working days
Result: -3 (3 working days until due)
```

**Example 2: Overdue**
```
Due Date: January 3, 2026 (Friday)
Today: January 9, 2026 (Thursday)

Days between: Jan 4 (Sat-skip), Jan 5 (Sun-skip), Jan 6 (Mon),
              Jan 7 (Tue), Jan 8 (Wed), Jan 9 (Thu-not counted as end)

Working days: 6, 7, 8 = 3 working days
Result: +3 (3 working days overdue)
```

**Example 3: With Holiday**
```
Due Date: January 1, 2026 (Wednesday) - NEW YEAR HOLIDAY
Today: January 3, 2026 (Friday)

Days between: Jan 2 (Thu), Jan 3 (Fri-not counted as end)
Holiday skip: Jan 1 is holiday but it's the start date, not counted anyway

Working days: 2 = 1 working day (Jan 2 only)
Result: +1 (1 working day overdue)
```

---

## Template Selection Logic

**Source**: Customer Confirmation Document (November 2025)

Based on calculated Arrear Days (working days after Net Due Date):

| Arrear Days | Template | Description | Tone |
|-------------|----------|-------------|------|
| < 3 (including negative) | Template A | Standard reminder | Professional |
| = 3 | Template B | Cash discount warning | Friendly but urgent |
| > 3 | Template C | Late fee warning + MI notice | Urgent |
| **MI document type exists** | Template D | Late payment notification | Formal, consequences |

### Template Selection Pseudocode

```
FUNCTION SelectTemplate(MaxArrearDays, HasMIDocument):

    // Template D takes priority if MI document exists
    IF HasMIDocument = true THEN
        RETURN "Template_D"  // Late payment notification

    // Otherwise, select based on arrear days
    IF MaxArrearDays < 3 THEN
        RETURN "Template_A"  // Standard reminder (includes pre-due items)

    ELSE IF MaxArrearDays = 3 THEN
        RETURN "Template_B"  // Cash discount warning

    ELSE  // MaxArrearDays > 3
        RETURN "Template_C"  // Late fee warning

END FUNCTION
```

### Template Details (from Customer)

**Template A** (Arrear < 3 days):
- Standard payment reminder
- Transaction details table
- Amount formatted: 1,000.50 บาท
- QR Code (if available)

**Template B** (Arrear = 3 days):
- Standard message + WARNING
- "If you don't pay by {Tomorrow}, you will lose Cash Discount eligibility"
- QR Code (if available)

**Template C** (Arrear > 3 days):
- Late fee warning
- "Payment is now overdue. Late fees (MI) will be applied."
- MI Note in Thai
- QR Code (if available)

**Template D** (MI Document exists):
- Triggered when BLART = "MI" in transaction
- Explains MI charges
- "ยอด MI ที่ปรากฎ เป็นใบเพิ่มหนี้ที่ท่านชำระบิลล่าช้า"
- QR Code (if available)

---

## Power Automate Implementation

### ✅ Option A: WorkingDayCalendar Lookup (SELECTED - Simplest)

**Status**: Recommended approach as of 2026-01-14

Pre-compute Working Day Numbers (WDN) for all dates in a calendar table, then calculate with simple subtraction.

```
ArrearDays = TodayWDN - DueDateWDN
```

**Why This Works:**
- WorkingDayCalendar has WDN for ALL dates (including non-working days)
- Non-working days inherit NEXT working day's WDN
- Simple subtraction gives correct result for any date combination

**Flow Logic (2 lookups + 1 calculation):**
```
1. Lookup Today's WDN from WorkingDayCalendar
2. Lookup DueDate's WDN from WorkingDayCalendar
3. ArrearDays = TodayWDN - DueDateWDN
```

**Benefits:**
- Extremely fast (no loops)
- No complex date math
- Works correctly for any edge case (weekends, holidays)
- Pre-computed once, used many times

**See:** `Documentation/03-Power-Automate/WorkingDayCalendar_Flow_Design.md`

### Option B: Child Flow (Legacy)

Create a separate flow `Calculate Working Days` that can be called from the main flow.

**Input Parameters:**
- `DueDate` (DateTime)
- `CurrentDate` (DateTime)

**Output:**
- `ArrearDays` (Integer)

**Benefits:**
- Reusable across multiple flows
- Easier to test and maintain
- Can be updated independently

**Drawback:** Slower due to looping through dates

### Option C: Expression-Based (Not Recommended)

Use Power Automate expressions directly in the main flow.

```
// This is complex and requires multiple compose actions
// Not recommended due to complexity
```

---

## Holiday Master Data Source

### Option 1: SharePoint List (Recommended)
- **List Name**: `HolidayMaster`
- **Site**: Same as other project lists
- **Columns**:
  - `HolidayDate` (Date)
  - `HolidayName` (Text)
  - `Year` (Number)

### Option 2: Dataverse Table
- **Table Name**: `cr7bb_holidaymaster`
- **Same columns as above

### Data Maintenance
- AR team can add/remove holidays through:
  - SharePoint list directly
  - Canvas App admin screen (if built)

---

## Processing Flow

```
1. Get transactions from Power BI (DAX query or export)
   ↓
2. Get HolidayMaster list for current year
   ↓
3. For each transaction:
   a. Get NETDT (due date)
   b. Calculate ArrearDays = CountWorkingDays(NETDT, TODAY)
   ↓
4. Filter out exclusion keywords (SGTXT check)
   ↓
5. Group by KUNNR (customer)
   ↓
6. For each customer:
   a. Calculate Net Amount (Sum of S_DMBTR)
   b. Find Max ArrearDays among all transactions
   c. If Net Amount > 0:
      - Select template based on Max ArrearDays
      - Compose email with transaction table
      - Send email
   ↓
7. Log results
```

---

## Edge Cases

### 1. Due Date in the Past, Many Holidays
If there were many holidays between due date and today, the calculated arrear days will be lower than calendar days.

**Example**:
- Due Dec 31, Today Jan 3
- Jan 1 is holiday
- Calendar days = 3, Working days = 2

### 2. Due Date on Weekend
If the due date falls on a weekend, it's not counted as a working day.

### 3. Due Date on Holiday
If the due date falls on a holiday, it's not counted as a working day.

### 4. Same Day (Due = Today)
Result is always 0, regardless of whether today is a holiday/weekend.

---

## Testing Scenarios

| # | Due Date | Today | Holidays Between | Expected Result |
|---|----------|-------|------------------|-----------------|
| 1 | Jan 15 | Jan 9 | None | -4 (4 days until due) |
| 2 | Jan 9 | Jan 9 | N/A | 0 (due today) |
| 3 | Jan 6 | Jan 9 | None | +3 (3 days overdue) |
| 4 | Jan 1 | Jan 9 | Jan 1 (holiday) | +5 (not +6) |
| 5 | Dec 30 | Jan 9 | Jan 1 (holiday) | +6 (10 calendar - 4 weekend - 1 holiday + 1 adjustment) |

---

## Questions for Confirmation

1. ~~**Template thresholds**~~ → ✅ CONFIRMED (from Customer Confirmation Document):
   - < 3: Template A
   - = 3: Template B
   - > 3: Template C
   - MI doc exists: Template D

2. **Holiday source**: SharePoint List recommended
   - See: `dataExample/HolidayMaster_2026.json` for schema and 2026 holidays

3. **Weekend definition**: Saturday and Sunday (Thailand standard)

4. **Processing day**: To be confirmed - Should flow run on weekends/holidays?

---

**Status**: ✅ Template logic confirmed, Holiday data ready, WDN approach selected

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-09 | Initial v2 draft with loop-based calculation |
| 2026-01-14 | Added WorkingDayCalendar lookup option (selected as primary approach) |
| 2026-01-14 | Updated to reference simplified WDN calculation (inherit NEXT working day)
