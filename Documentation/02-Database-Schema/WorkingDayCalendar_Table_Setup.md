# WorkingDayCalendar Table Setup Guide

**Date**: January 10, 2026
**Purpose**: Create and populate WorkingDayCalendar table for O(1) arrear calculation

---

## Table Overview

| Property | Value |
|----------|-------|
| **Logical Name** | `cr7bb_workingdaycalendar` |
| **Display Name** | `[THFinanceCashCollection]WorkingDayCalendar` |
| **Purpose** | Pre-calculated lookup for working day number by date |
| **Records** | 1,095 rows (2025-2027, 730 working days) |

---

## Step 1: Create Table in Dataverse

### Navigate to Power Apps
1. Go to **make.powerapps.com**
2. Select environment: **Nestle TH Finance**
3. Click **Tables** in left navigation
4. Click **+ New table** > **Set advanced properties**

### Table Settings
| Setting | Value |
|---------|-------|
| Display name | `[THFinanceCashCollection]WorkingDayCalendar` |
| Plural display name | `WorkingDayCalendars` |
| Schema name | `cr7bb_workingdaycalendar` |
| Primary column name | `Name` |
| Primary column data type | `Text` (required by Dataverse) |

> **Note**: Dataverse requires primary column to be Text type. We'll use the date string (e.g., "2026-01-05") as the Name field for easy identification.

---

## Step 2: Add Columns

### Column 1: Name (Primary - Auto-created)
Auto-created as primary column. Use date string format for identification.

| Property | Value |
|----------|-------|
| Display name | `Name` |
| Logical name | `cr7bb_name` |
| Data type | `Text (100)` |
| Required | Yes |
| Format | `yyyy-MM-dd` (e.g., "2026-01-05") |

### Column 2: Calendar Date
| Property | Value |
|----------|-------|
| Display name | `Calendar Date` |
| Logical name | `cr7bb_calendardate` |
| Data type | `Date Only` |
| Required | Yes |
| Searchable | Yes (enable in Advanced options) |

### Column 3: Is Working Day
| Property | Value |
|----------|-------|
| Display name | `Is Working Day` |
| Logical name | `cr7bb_isworkingday` |
| Data type | `Yes/No` |
| Required | Yes |
| Default | No |

### Column 4: Working Day Number
| Property | Value |
|----------|-------|
| Display name | `Working Day Number` |
| Logical name | `cr7bb_workingdaynumber` |
| Data type | `Whole Number` |
| Required | No |
| Min value | 1 |
| Max value | 999999 |

### Column 5: Year
| Property | Value |
|----------|-------|
| Display name | `Year` |
| Logical name | `cr7bb_year` |
| Data type | `Whole Number` |
| Required | Yes |
| Min value | 2020 |
| Max value | 2099 |

---

## Step 3: Import Data

### Source File
**Location**: `dataExample/WorkingDayCalendar_2025-2027.csv`

### CSV Format
```csv
"cr7bb_name","cr7bb_calendardate","cr7bb_isworkingday","cr7bb_workingdaynumber","cr7bb_year"
"2025-01-01","2025-01-01","No","","2025"
"2025-01-02","2025-01-02","Yes","1","2025"
...
```

> **Note**: `cr7bb_name` uses the same date string as `cr7bb_calendardate` for easy identification in Dataverse views.

### Import Options

**Option A: Power Apps Data Import (Recommended)**
1. Open table in make.powerapps.com
2. Click **Import** > **Import data from Excel**
3. Upload `WorkingDayCalendar_2025-2027.csv`
4. Map columns:
   - `cr7bb_calendardate` → Calendar Date
   - `cr7bb_isworkingday` → Is Working Day (convert Yes/No to boolean)
   - `cr7bb_workingdaynumber` → Working Day Number
   - `cr7bb_year` → Year
5. Run import

**Option B: Power Automate Flow**
1. Create flow with manual trigger
2. Action: Get file content from SharePoint/OneDrive
3. Action: Parse CSV
4. Action: Apply to each → Create Dataverse row

---

## Step 4: Enable Searchable (for faster lookup)

Dataverse doesn't have manual index creation. Instead, enable **Searchable** on key columns:

1. Open the table in **make.powerapps.com**
2. Click on **Calendar Date** column
3. Expand **Advanced options**
4. Set **Searchable** = Yes
5. Save the column

> **Note**: The Name column (primary) is automatically searchable/indexed.

---

## Data Verification

After import, verify:

```
// Total records
CountRows('[THFinanceCashCollection]WorkingDayCalendars') = 1095

// Working days count
CountIf('[THFinanceCashCollection]WorkingDayCalendars', 'Is Working Day' = true) = 730

// Check cross-year transition
LookUp(
    '[THFinanceCashCollection]WorkingDayCalendars',
    'Calendar Date' = Date(2025, 12, 30)
).WorkingDayNumber = 245

LookUp(
    '[THFinanceCashCollection]WorkingDayCalendars',
    'Calendar Date' = Date(2026, 1, 5)
).WorkingDayNumber = 246
```

---

## Usage in Power Automate

### Get Today's Working Day Number
```
Lookup WorkingDayCalendar
Filter: CalendarDate = @{utcNow('yyyy-MM-dd')}
Output: WorkingDayNumber → varTodayWDN
```

### Get Due Date's Working Day Number
```
Lookup WorkingDayCalendar
Filter: CalendarDate = @{triggerBody()?['NETDT']}
Output: WorkingDayNumber → varDueDateWDN
```

### Calculate Arrear Days
```
ArrearDays = varTodayWDN - varDueDateWDN
```

### ~~Handle NETDT on Non-Working Day~~ (No Longer Needed)

> **Update (2026-01-14)**: With single-pass buffered generation, **ALL dates have WDN values**. Non-working days inherit the NEXT working day's WDN. No special handling required.

```
// OLD approach (deprecated):
// If WorkingDayNumber is NULL: Lookup previous working day...

// NEW approach: Simple lookup works for any date
ArrearDays = varTodayWDN - varDueDateWDN  // Always works
```

---

## Recalculation Trigger

When CalendarEvent is modified:
1. Get affected holiday date
2. Find starting point (last working day number before affected date)
3. Recalculate all WorkingDayNumbers from that point forward
4. Log to ProcessLog with ProcessType = "WorkingDayRecalc"

See: `Documentation/03-Power-Automate/Recalculation_Flow_Design.md`

---

## Data Statistics

| Year | Working Days | WDN Range |
|------|--------------|-----------|
| 2025 | 245 | 1 - 245 |
| 2026 | 242 | 246 - 487 |
| 2027 | 243 | 488 - 730 |

**Total**: 730 working days across 1,095 calendar days

---

**Status**: Ready for implementation
