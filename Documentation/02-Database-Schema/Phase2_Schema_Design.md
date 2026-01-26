# Phase 2 Database Schema Design

**Date**: January 9, 2026
**Status**: Draft - Ready for Implementation

---

## Overview

Phase 2 introduces Power BI as the data source instead of Excel files. This requires:
1. New transaction snapshot table (daily snapshots from Power BI)
2. Holiday master table (for arrear calculation)
3. Updated flow architecture

---

## Table Changes

### 1. Existing Transaction Table (REUSE)

**Table Name**: `[THFinanceCashCollection]Transactions`
**Decision**: ✅ **REUSE existing table** - no new table needed

**Required Change**: Add 1 new column for Power BI matching

| New Column | Display Name | Type | Required | Purpose |
|------------|--------------|------|----------|---------|
| `cr7bb_customercode` | Customer Code | Text (20) | No | Match KUNNR from Power BI |

**Power BI → Existing Field Mapping**:
| Power BI Column | Dataverse Field | Notes |
|-----------------|-----------------|-------|
| KUNNR | `cr7bb_customercode` | **NEW** - for matching |
| KUNNR | `cr7bb_customer` | Lookup (resolve after match) |
| BELNR | `cr7bb_documentnumber` | Existing |
| ZUONR | `cr7bb_assignment` | Existing |
| BLART | `cr7bb_documenttype` | Existing (Text: DR/DG/MI/RV) |
| BLART | `cr7bb_transactiontype` | Existing (Choice: derive CN/DN) |
| BLDAT | `cr7bb_documentdate` | Existing |
| NETDT | `cr7bb_netduedate` | Existing |
| S_DMBTR | `cr7bb_amountlocalcurrency` | Existing |
| SGTXT | `cr7bb_textfield` | Existing |
| XBLNR | `cr7bb_reference` | Existing |
| VERZN | `cr7bb_arrearsdays` | Existing (SAP value) |
| - | `cr7bb_daycount` | Existing (calculated working days) |
| - | `cr7bb_processdate` | Existing (sync date) |
| - | `cr7bb_recordtype` | Existing (set to "Transaction") |
| - | `cr7bb_isexcluded` | Existing (set to No) |
| - | `cr7bb_isprocessed` | Existing |
| - | `cr7bb_emailsent` | Existing |

**BLART to Transaction Type Mapping**:
| BLART | Transaction Type | Choice Value |
|-------|-----------------|--------------|
| DR | DN - Debit Note | 676180001 |
| DG | CN - Credit Note | 676180000 |
| MI | DN - Debit Note | 676180001 |
| RV | CN - Credit Note | 676180000 |

**Benefits of Reusing Existing Table**:
- ✅ Canvas Apps already connected
- ✅ Email flow already works
- ✅ EmailLog relationships intact
- ✅ No migration needed
- ✅ Existing views/filters work

---

### 2. CalendarEvent Table (REUSE - NO CHANGES)

**Table Name**: `nc_thfinancecashcollectioncalendarevent`
**Display Name**: `[THFinanceCashCollection]CalendarEvent`
**Decision**: ✅ **REUSE existing table as-is** - no new columns needed

#### Existing Columns (Use As-Is):
| Column | Display Name | Type | Required | Purpose |
|--------|--------------|------|----------|---------|
| `nc_thfinancecashcollectioncalendareventid` | CalendarEvent | Unique ID | Auto | Primary key |
| `nc_description` | Description | Text (850) | Yes | Holiday name (Thai from client) |
| `nc_eventdate` | Event Date | Date Only | No | The holiday date |

#### Client Data Format (Holiday2026.csv):
```csv
Name,Date,ISO Date
วันขึ้นปีใหม่,1/1/2026,2026-01-01T00:00:00Z
วันหยุดทำการเพิ่มเป็นกรณีพิเศษ,1/2/2026,2026-01-02T00:00:00Z
...
```

**Import Mapping**:
- `Name` → `nc_description` (Thai name)
- `ISO Date` → `nc_eventdate`

#### Benefits of Reusing:
- ✅ Table already exists in solution
- ✅ **No schema changes needed**
- ✅ scnCalendar screen already connected
- ✅ Holidays will appear in Calendar view automatically
- ✅ Same `nc_` prefix as other tables

#### Filtering for Arrear Calculation:
```
// Filter by year using Year() function
Filter('[THFinanceCashCollection]CalendarEvents',
    Year('Event Date') = 2026
)
```

**Sample Data** (2026 - from client Holiday2026.csv):
```
| Date       | Thai Name                                          |
|------------|---------------------------------------------------|
| 2026-01-01 | วันขึ้นปีใหม่                                        |
| 2026-01-02 | วันหยุดทำการเพิ่มเป็นกรณีพิเศษ (Special additional)    |
| 2026-03-03 | วันมาฆบูชา                                          |
| 2026-04-06 | วันพระบาทสมเด็จพระพุทธยอดฟ้าจุฬาโลกมหาราชฯ            |
| 2026-04-13 | วันสงกรานต์                                         |
| 2026-04-14 | วันสงกรานต์                                         |
| 2026-04-15 | วันสงกรานต์                                         |
| 2026-05-01 | วันแรงงานแห่งชาติ                                    |
| 2026-05-04 | วันฉัตรมงคล                                         |
| 2026-06-01 | ชดเชยวันวิสาขบูชา (substitute)                       |
| 2026-06-03 | วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าสุทิดาฯ             |
| 2026-07-28 | วันเฉลิมพระชนมพรรษาพระบาทสมเด็จพระเจ้าอยู่หัว          |
| 2026-07-29 | วันอาสาฬหบูชา                                       |
| 2026-08-12 | วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าสิริกิติ์ฯ          |
| 2026-10-13 | วันนวมินทรมหาราช                                    |
| 2026-10-23 | วันปิยมหาราช                                        |
| 2026-12-07 | ชดเชยวันพ่อแห่งชาติ (substitute for Dec 5)           |
| 2026-12-10 | วันรัฐธรรมนูญ                                       |
| 2026-12-31 | วันสิ้นปี                                           |
```

**Note**: 19 holidays total. Includes substitute holidays (ชดเชย) and special holidays.

---

### 3. Working Day Calendar Table (NEW)

**Table Name**: `cr7bb_workingdaycalendar`
**Display Name**: `[THFinanceCashCollection]WorkingDayCalendar`
**Purpose**: Pre-calculated lookup for O(1) arrear days calculation

| Column | Display Name | Type | Required | Description |
|--------|--------------|------|----------|-------------|
| `cr7bb_workingdaycalendarid` | Working Day Calendar | Unique ID | Auto | Primary key |
| `cr7bb_calendardate` | Calendar Date | Date Only | Yes | The calendar date |
| `cr7bb_isworkingday` | Is Working Day | Yes/No | Yes | True if not weekend/holiday |
| `cr7bb_workingdaynumber` | Working Day Number | Whole Number | No | **Absolute** counter (null if non-working) |
| `cr7bb_year` | Year | Whole Number | Yes | Year for filtering (2025, 2026, etc.) |

#### Cross-Year Calculation Support

**Key Design Decision**: `WorkingDayNumber` is an **absolute counter** that continues across years, NOT reset each January.

**Example Data** (Year-End 2025 → 2026):
```
| Date       | IsWorkingDay | WorkingDayNumber | Year | Notes                |
|------------|--------------|------------------|------|----------------------|
| 2025-12-29 | Yes          | 260              | 2025 | Monday               |
| 2025-12-30 | Yes          | 261              | 2025 | Tuesday              |
| 2025-12-31 | Yes          | 262              | 2025 | Wednesday            |
| 2026-01-01 | No           | NULL             | 2026 | New Year's Day       |
| 2026-01-02 | Yes          | 263              | 2026 | Friday (continues!)  |
| 2026-01-03 | No           | NULL             | 2026 | Saturday             |
| 2026-01-04 | No           | NULL             | 2026 | Sunday               |
| 2026-01-05 | Yes          | 264              | 2026 | Monday               |
| 2026-01-06 | Yes          | 265              | 2026 | Tuesday              |
```

**Cross-Year Calculation Example**:
```
NETDT (Due Date) = 2025-12-30 → WorkingDayNumber = 261
TODAY            = 2026-01-06 → WorkingDayNumber = 265

ArrearDays = 265 - 261 = 4 working days overdue ✅
```

**Why This Works**:
- No special handling needed for year boundaries
- Simple subtraction regardless of date range
- Works for due dates up to years in the past

#### Arrear Calculation Formula (O(1) Lookup)

```
ArrearDays = Lookup(TODAY).WorkingDayNumber - Lookup(NETDT).WorkingDayNumber
```

**Edge Cases** (Updated 2026-01-14):
- If NETDT falls on non-working day: Non-working days inherit **NEXT** working day's WDN (no special handling needed)
- If TODAY falls on non-working day: Flow shouldn't run (weekdays only trigger)
- Negative result = days UNTIL due
- Positive result = days OVERDUE
- Zero = Due today

> **Note**: With single-pass buffered generation, ALL dates have WDN values. No null checks needed.

#### Calendar Generation

**Scope**: Generate 3 years of data (2025-2027) initially
- 2025: ~250 working days (historical for old transactions)
- 2026: ~250 working days (current year)
- 2027: ~250 working days (future buffer)

**Total Records**: ~1,095 rows (3 years × 365 days)

#### Recalculation Flow

**Trigger**: When holiday is added/modified/deleted in CalendarEvent

```
┌─────────────────────────────────────────────────────────────┐
│  TRIGGER: When record created/modified/deleted              │
│           in CalendarEvent table                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Get affected year from holiday record              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Get all holidays from affected year onwards        │
│  (Changes ripple forward through all future dates)          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Find starting WorkingDayNumber                     │
│  (Last number before affected date)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: Loop through all dates from affected date          │
│  - If working day: increment counter, update record         │
│  - If non-working: set NULL                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: Log recalculation completion                       │
└─────────────────────────────────────────────────────────────┘
```

**Performance Note**: Recalculation from mid-year affects ~6 months of data (~180 rows). Power Automate can handle this in batches.

---

### 4. scnCalendar Enhancement (Holiday Management)

**Decision**: Use existing scnCalendar screen for holiday CRUD + add recalculation status

#### Existing Features (Keep):
- ✅ Calendar grid view
- ✅ Add new event (Form1)
- ✅ Edit existing event
- ✅ Delete event
- ✅ Event gallery list

#### New Enhancement: Recalculation Status Indicator

**Purpose**: Show users when WorkingDayCalendar needs recalculation after holiday changes

**UI Components to Add**:
```
┌─────────────────────────────────────────────────────────────┐
│  Holiday Management                           [Status Badge]│
│                                                              │
│  Status Badge States:                                        │
│  🟢 "Calendar Up to Date" - No recalculation needed         │
│  🟡 "Recalculating..." - Flow is running                    │
│  🔴 "Recalculation Needed" - Holiday changed, pending sync  │
└─────────────────────────────────────────────────────────────┘
```

**Implementation Options**:

| Option | How It Works | Pros/Cons |
|--------|--------------|-----------|
| A. ProcessLog check | Query last recalc log vs last holiday modifiedon | Simple, uses existing table |
| B. Config table | Store LastRecalcDate in settings table | Clean, but new table |
| C. Timer trigger | Flow runs every X minutes if changes detected | Automatic, slight delay |

**Recommended**: Option A - Check ProcessLog

**Power Fx Logic**:
```
// Check if recalculation is needed
Set(
    _recalcStatus,
    If(
        // Get latest holiday modification
        Max('[THFinanceCashCollection]CalendarEvents', 'Modified On') >
        // Get latest recalc log
        LookUp(
            '[THFinanceCashCollection]ProcessLogs',
            'Process Type' = "WorkingDayRecalc",
            'Created On'
        ),
        "Pending",  // Holiday modified after last recalc
        "UpToDate"  // All synced
    )
)
```

**Status Badge Control**:
```yaml
- lblRecalcStatus:
    Control: Text@0.0.51
    Properties:
      Text: |
        =Switch(
            _recalcStatus,
            "Pending", "🔴 Recalculation Needed",
            "Running", "🟡 Recalculating...",
            "🟢 Up to Date"
        )
      FontColor: |
        =Switch(
            _recalcStatus,
            "Pending", RGBA(212, 41, 57, 1),
            "Running", RGBA(255, 191, 0, 1),
            RGBA(0, 128, 0, 1)
        )
```

---

## Existing Tables (No Changes)

### Customer Table
`cr7bb_thfinancecashcollectioncustomer` - Already linked to Power BI via `IsActive` column

### Email Log Table
`cr7bb_thfinancecashcollectionemaillog` - Keep as-is for email tracking

### Process Log Table
`cr7bb_thfinancecashcollectionprocesslog` - Keep as-is for process tracking

---

## Flow Architecture

### Main Flow: Daily Transaction Sync & Email

**Trigger**: Scheduled (7:00 AM, Mon-Fri)
**After**: Power BI refresh completes at 6:00 AM

```
┌─────────────────────────────────────────────────────────────┐
│  TRIGGER: Recurrence (7:00 AM, Weekdays)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Initialize Variables                               │
│  - varProcessDate = Today                                   │
│  - varSuccessCount = 0                                      │
│  - varErrorCount = 0                                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Get Today's Working Day Number                     │
│  - Query WorkingDayCalendar where CalendarDate = Today      │
│  - Store in varTodayWorkingDayNumber                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Query Power BI                                     │
│  - Run DAX query against semantic model                     │
│  - Filter: IsActiveCustomer = TRUE                          │
│  - Get all columns: KUNNR, BELNR, BLART, etc.              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: Process Each Transaction                           │
│  FOR EACH row in Power BI results:                          │
│    4a. Lookup NETDT in WorkingDayCalendar                   │
│    4b. Calculate ArrearDays = Today# - DueDate#             │
│    4c. Create/Update Transaction record in Dataverse        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: Group by Customer                                  │
│  - Get distinct customers from today's snapshot             │
│  - Filter out excluded customers                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 6: Process Each Customer                              │
│  FOR EACH customer:                                         │
│    6a. Get all transactions for customer                    │
│    6b. Calculate Net Amount (DR + DG + MI + RV)            │
│    6c. Find Max Arrear Days                                 │
│    6d. Check for MI document type                           │
│    6e. Select Template (A/B/C/D)                           │
│    6f. Compose Email HTML                                   │
│    6g. Send Email                                           │
│    6h. Create EmailLog record                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 7: Create Process Log                                 │
│  - Record success/error counts                              │
│  - Store summary                                            │
└─────────────────────────────────────────────────────────────┘
```

### Arrear Days Calculation (Inline - O(1) Lookup)

**Method**: Direct lookup from WorkingDayCalendar table (no child flow needed)

**Input**: NETDT (Due Date), ProcessDate (Today)
**Output**: ArrearDays (Integer)

```
┌─────────────────────────────────────────────────────────────┐
│  FOR EACH transaction:                                       │
│                                                              │
│  1. Lookup TODAY's WorkingDayNumber                          │
│     Filter: CalendarDate = ProcessDate                       │
│     → varTodayNumber = 265                                   │
│                                                              │
│  2. Lookup NETDT's WorkingDayNumber                          │
│     Filter: CalendarDate = NETDT                             │
│     → varDueDateNumber = 261                                 │
│                                                              │
│  3. Calculate ArrearDays                                     │
│     ArrearDays = varTodayNumber - varDueDateNumber           │
│     → 265 - 261 = 4 (4 days overdue)                        │
│                                                              │
│  Note: No edge case handling needed!                         │
│  - Non-working days have WDN (inherit NEXT working day)     │
│  - All lookups return valid WDN values                       │
│  - Simple subtraction works for any date                     │
└─────────────────────────────────────────────────────────────┘
```

**Performance Benefit**:
- Old method: Loop through each day, check weekend, check holiday list → O(n)
- New method: Two lookups by date → O(1)
- For 500 transactions: 500 lookups vs 500 × ~30 days = 15,000 operations

---

## Data Retention Policy

### Transaction Snapshots
- Keep for **90 days** (configurable)
- Auto-delete older records via scheduled flow
- Or archive to Azure Blob Storage

### Email Logs
- Keep for **1 year**
- Required for audit trail

### Process Logs
- Keep for **1 year**
- Required for troubleshooting

---

## Migration Notes

### From Phase 1 to Phase 2

1. **Old Transaction Table**: Keep for reference, don't delete
2. **New Snapshot Table**: Start fresh with new structure
3. **Customer Table**: No changes (already connected)
4. **Flows**: Create new flows, disable old ones

---

## Implementation Steps

### Step 1: Modify Existing Transaction Table
1. Add `cr7bb_customercode` column (Text 20) for Power BI KUNNR matching
2. No other changes needed - existing fields already mapped

### Step 2: Import Holidays + Create WorkingDayCalendar
1. Import Holiday2026.csv into CalendarEvent (19 holidays)
2. Create `cr7bb_workingdaycalendar` table
3. Generate WorkingDayCalendar data (2025-2027, ~1095 rows)

### Step 3: Create Recalculation Flow
1. Create "Recalculate Working Days" flow
2. Trigger: When CalendarEvent record created/modified/deleted
3. Logic: Recalculate WorkingDayNumber from affected date onwards
4. Create ProcessLog record with ProcessType = "WorkingDayRecalc"

### Step 4: Enhance scnCalendar Screen
1. Add recalculation status badge (lblRecalcStatus)
2. Add OnVisible logic to check status
3. Test status updates after holiday changes

### Step 5: Create Main Flow
1. Create "Daily Transaction Sync" flow
2. Connect to Power BI semantic model
3. Add WorkingDayCalendar lookup logic
4. Test with small dataset (1 customer)

### Step 6: Testing
1. Verify cross-year calculation (Dec 2025 → Jan 2026)
2. Verify template selection based on arrear days
3. Verify email generation compatibility
4. Full run with all customers

---

**Status**: Ready for implementation
