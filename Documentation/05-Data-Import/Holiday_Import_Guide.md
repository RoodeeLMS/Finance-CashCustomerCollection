# Holiday Import Guide

**Date**: January 10, 2026
**Purpose**: Step-by-step guide to import Holiday2026.csv into CalendarEvent table

---

## Source File

**File**: `client docs/Example Data/Holiday2026.csv`
**Records**: 19 Thai public holidays for 2026
**Format**: CSV with columns `Name,Date,ISO Date`

---

## Target Table

**Table**: `nc_thfinancecashcollectioncalendarevent`
**Display Name**: `[THFinanceCashCollection]CalendarEvent`

---

## Column Mapping

| Source CSV Column | Target Dataverse Column | Notes |
|-------------------|------------------------|-------|
| `Name` | `nc_description` | Thai holiday name (as-is) |
| `ISO Date` | `nc_eventdate` | Date format: YYYY-MM-DD |
| *(ignore)* | `Date` | Not needed (human-readable Thai format) |

---

## Import Options

### Option A: Power Apps Dataverse Connector (Recommended)

1. **Open make.powerapps.com**
2. Navigate to **Tables** > **CalendarEvent**
3. Click **Import** > **Import data from Excel**
4. Transform Holiday2026.csv:
   - Remove `Date` column (keep only `Name` and `ISO Date`)
   - Rename `Name` to `nc_description`
   - Rename `ISO Date` to `nc_eventdate`
5. Map columns and import

### Option B: Power Automate Flow

Create a simple flow to parse CSV and create records:

```
Trigger: Manual button
Action 1: Get file content from SharePoint
Action 2: Parse CSV
Action 3: Apply to each row:
  - Create CalendarEvent record
    - nc_description = row.Name
    - nc_eventdate = row['ISO Date']
```

### Option C: Excel Online Data Import

1. Copy Holiday2026.csv data to Excel
2. Format as table with columns:
   - `nc_description` (text)
   - `nc_eventdate` (date)
3. Use Dataverse Excel connector to import

---

## Pre-Import Checklist

- [ ] Verify table `[THFinanceCashCollection]CalendarEvent` exists
- [ ] Check if any 2026 holidays already exist (avoid duplicates)
- [ ] Backup existing CalendarEvent data (optional)
- [ ] Verify user has Create permission on CalendarEvent

---

## Data Preview

| nc_description | nc_eventdate |
|----------------|--------------|
| วันขึ้นปีใหม่ | 2026-01-01 |
| วันหยุดทำการเพิ่มเป็นกรณีพิเศษ | 2026-01-02 |
| วันมาฆบูชา | 2026-03-03 |
| วันพระบาทสมเด็จพระพุทธยอดฟ้าจุฬาโลกมหาราช และวันที่ระลึกมหาจักรีบรมราชวงศ์ | 2026-04-06 |
| วันสงกรานต์ | 2026-04-13 |
| วันสงกรานต์ | 2026-04-14 |
| วันสงกรานต์ | 2026-04-15 |
| วันแรงงานแห่งชาติ | 2026-05-01 |
| วันฉัตรมงคล | 2026-05-04 |
| ชดเชยวันวิสาขบูชา (วันอาทิตย์ที่ 31 พฤษภาคม 2569) | 2026-06-01 |
| วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าสุทิดา พัชรสุธาพิมลลักษณ พระบรมราชินี | 2026-06-03 |
| วันเฉลิมพระชนมพรรษาพระบาทสมเด็จพระเจ้าอยู่หัว | 2026-07-28 |
| วันอาสาฬหบูชา | 2026-07-29 |
| วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าสิริกิติ์ พระบรมราชินีนาถ พระบรมราชชนนีพันปีหลวง และวันแม่แห่งชาติ | 2026-08-12 |
| วันนวมินทรมหาราช | 2026-10-13 |
| วันปิยมหาราช | 2026-10-23 |
| ชดเชยวันคล้ายวันพระบรมราชสมภพ พระบาทสมเด็จพระบรมชนกาธิเบศร มหาภูมิพลอดุลยเดชมหาราช บรมนาถบพิตร วันชาติ และวันพ่อแห่งชาติ (วันเสาร์ที่ 5 ธันวาคม 2569) | 2026-12-07 |
| วันรัฐธรรมนูญ | 2026-12-10 |
| วันสิ้นปี | 2026-12-31 |

**Total**: 19 records

---

## Post-Import Verification

1. Go to CalendarEvent table in make.powerapps.com
2. Filter by Year 2026: `Year(nc_eventdate) = 2026`
3. Verify 19 records imported
4. Spot-check a few dates match the source CSV

---

## Next Step After Import

After holidays are imported, the **WorkingDayCalendar** needs to be generated/recalculated to account for these holidays. See `WorkingDayCalendar_Generation.md` for details.

---

**Status**: Ready for execution
