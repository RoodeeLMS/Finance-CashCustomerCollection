# Business Rules Clarifications

**Date**: January 14, 2026
**Source**: Client clarification during development
**Status**: Confirmed

---

## 1. Negative Arrear Days (Bills Not Yet Due)

**Question (Thai):**
ถ้าบิลนั้นยังไม่ถึงกำหนด due date ให้ส่งให้ลูกค้าด้วยมั้ย เช่น arrears ใน SAP มีค่าติดลบ

**Question (English):**
If a bill hasn't reached its due date yet (negative arrear days in SAP), should we still send notification to the customer?

**Answer:**
✅ **Yes, send the notification to the customer.**

**Additional Rule (Separate Requirement):**
⚠️ If Arrear Days >= 3 (POSITIVE = overdue), also send a notification to the AR team.

**Implementation:**
```
If (ArrearDays < 0):
    - Include in customer email (bill not yet due, reminder)

If (ArrearDays >= 3):
    - Collect customer info for AR summary email
```

**AR Notification Method (Selected):**
✅ **Option 2: Separate summary email to AR team**
- At end of daily email flow, send ONE summary email to AR team
- Contains list of all customers with any transaction having ArrearDays ≥ 3
- NOT CC on each customer email (avoids email overload)

**Clarification**: The AR notification is for **overdue** bills (positive arrear ≥ 3 working days), not for pre-due bills (negative arrear).

---

## 2. Due Date on Weekend/Holiday - Day Counting

**Question (Thai):**
ถ้าบิล due date ไปตกวันหยุดแล้วจะเริ่มนับเกินกำหนดวันไหน เช่นบิลไปลง due date วันเสาร์ แล้ววันนี้เป็นวันอังคาร จะนับว่าเกินกำหนดมาแล้ว 1 วัน(วันจันทร์นับว่าเป็นวันที่ 0) หรือว่า 2 วัน(วันจันทร์นับว่าเป็นวันที่ 1)

**Question (English):**
If a bill's due date falls on a weekend (e.g., Saturday), and today is Tuesday, how do we count overdue days? Is Monday counted as day 0 or day 1?

**Example:**
| Day | Date | Question |
|-----|------|----------|
| Saturday | Due Date | (weekend) |
| Sunday | - | (weekend) |
| Monday | First working day after due | Day 0 or Day 1? |
| Tuesday | Today | Day 1 or Day 2? |

**Answer:**
✅ **Monday is counted as Day 0** (the grace day)

**Result:** Tuesday = 1 day overdue (not 2)

**Implementation (Option B - Selected):**

Non-working days inherit the **NEXT** working day's WDN (not previous).

| Date | Day Type | WDN | Explanation |
|------|----------|-----|-------------|
| Friday | Working | 100 | Working day |
| Saturday | Weekend | **101** | Inherits Monday's WDN |
| Sunday | Weekend | **101** | Inherits Monday's WDN |
| Monday | Working | 101 | New working day |
| Tuesday | Working | 102 | Working day |

**Calculation:**
- DueDate = Saturday → WDN = 101
- Today = Tuesday → WDN = 102
- ArrearDays = 102 - 101 = **1 day** ✅

**Simple Formula (No Special Cases):**
```
ArrearDays = TodayWDN - DueDateWDN
```

**WorkingDayCalendar Generation:** Single-pass buffered approach
- Buffer non-working days until next working day is reached
- When working day hit: assign WDN to working day + all buffered days
- Post-loop cleanup for trailing non-working days

See: `Documentation/03-Power-Automate/WorkingDayCalendar_Flow_Design.md`

---

## 3. FIFO CN Application - Stop vs Skip

**Question (Thai):**
ถ้า FIFO CN ไปเจออันที่จะทำให้ CN>DN จะให้หยุดเลย หรือให้แค่ข้ามอันนั้นแล้วเช็ค CN ถัดไปต่อ

**Question (English):**
When applying FIFO to CN, if we encounter a CN that would make total CN exceed total DN, should we stop completely or skip that CN and check the next one?

**Answer:**
✅ **Stop completely** (do not skip to next CN)

**Implementation Logic:**
```
Sort CN by DocumentDate ASC (oldest first)
Sort DN by DocumentDate ASC (oldest first)

varRemainingCredit = 0
varAppliedCNs = []

For each CN in sorted order:
    If (Abs(varRemainingCredit) + Abs(CN.Amount) <= Total_DN):
        varRemainingCredit += CN.Amount  // Apply this CN
        varAppliedCNs.push(CN)
    Else:
        BREAK  // Stop - don't check remaining CNs

// Remaining DN to show = Total_DN + varRemainingCredit (which is negative)
```

**Example:**
| CN | Amount | Running Total | DN Total | Action |
|----|--------|---------------|----------|--------|
| CN1 | -3,000 | -3,000 | 10,000 | ✅ Apply (3,000 < 10,000) |
| CN2 | -5,000 | -8,000 | 10,000 | ✅ Apply (8,000 < 10,000) |
| CN3 | -4,000 | -12,000 | 10,000 | ❌ STOP (12,000 > 10,000) |

**Result:** Applied CNs = CN1 + CN2 = -8,000. Remaining DN = 10,000 - 8,000 = 2,000

**Important:** CN3 is NOT applied and NOT skipped to check CN4. The process stops at CN3.

**See:** `Documentation/03-Power-Automate/Flow_StepByStep_FIFO_EmailEngine.md` for step-by-step implementation

---

## Summary Table

| Rule | Clarification | Impact |
|------|---------------|--------|
| Negative Arrear | Send to customer (reminder) | Email flow - include pre-due bills |
| **Overdue >= 3 days** | **Also notify AR team** | **Email flow - CC or separate email to AR** |
| Weekend Due Date | Monday after weekend = Day 0 | WDN calculation adjustment |
| FIFO CN Stop | Stop when next CN would exceed DN | Email flow FIFO logic |

---

**Document History:**
- 2026-01-14: Initial clarifications documented
- 2026-01-14: Option B selected for WDN assignment (inherit NEXT working day)
- 2026-01-14: Updated to single-pass buffered approach (more efficient than two-pass)
- 2026-01-14: Clarified AR notification is for overdue ≥3 days (positive), not negative arrear
- 2026-01-14: Added FIFO implementation guide reference
- 2026-01-14: Selected Option 2 for AR notification (separate summary email)
