# URGENT: Critical Clarifications Required
**Date**: November 14, 2025
**Status**: 🔴 **BLOCKING** - Cannot proceed with Phase 1 until resolved
**Priority**: HIGH

---

## ⚠️ Summary

The latest customer confirmation document reveals **4 critical conflicts** between previous decisions and customer requirements. These must be resolved before implementation can proceed.

**Cannot start Phase 1 implementation until these are clarified.**

---

## 🔴 CRITICAL CONFLICT #1: QR Codes

### The Conflict

**Previous Decision (Message 5)**:
> "About QR codes : just don't show it"

**Customer Document (Latest)**:
> "specific QR Code" (mentioned in all 4 template sections)
> - Template A: "+ specific QR Code"
> - Template B: "+ specific QR Code"
> - Template C: "+ specific QR Code"
> - Template D: "+ specific QR Code"

### Why This Matters

This determines whether to:
- ✅ **Remove all QR code logic** (text-based only) - Current Phase 1 plan
- ❌ **Keep QR code logic** (retrieve from SharePoint, attach to email) - Requires reverting Phase 1 plan

### What to Ask

**"Regarding QR codes in the payment reminder emails:**

1. **Should we include a QR code attachment in each email?**
   - Option A: Yes, include specific QR code for each customer (per latest document)
   - Option B: No, use text-based payment instructions only (per previous message)

2. **If Yes (QR codes needed):**
   - Where are QR codes stored? (SharePoint /03-QR-Codes/ folder?)
   - File naming: {CustomerCode}.jpg?
   - What if QR not found? (Skip, show error, use default?)

**Please confirm which is correct for your system."**

### Impact

| If QR = YES | If QR = NO |
|-------------|-----------|
| Revert Phase 1 plan | Keep Phase 1 plan |
| Add SharePoint file retrieval | Remove file retrieval (already planned) |
| Add attachment logic | Skip attachment (already planned) |
| Add QR preview in scnEmailMonitor | Remove QR column (already planned) |
| Add QR preview in scnEmailApproval | Remove QR preview (already planned) |
| Slower email processing | Faster email processing |

---

## 🔴 CRITICAL CONFLICT #2: Day Count Calculation

### The Conflict

**Current Implementation**:
- Based on: Days since **Document Date** (cr7bb_daycount field)
- Formula: TODAY() - DocumentDate

**Customer Requirement**:
- Based on: Days since **Net Due Date** (Arrear After Net Due Date)
- Formula: TODAY() - NetDueDate
- Note: "Does not include bank holidays or weekends"

### Why This Matters

Template selection depends on this value:
- Template A: Value < 3 days
- Template B: Value = 3 days
- Template C: Value > 3 days

**Different calculation = Different template selection = Different emails sent**

### Example of Difference

```
Invoice Details:
  Document Date: Nov 9, 2025
  Payment Terms: Net 30
  Net Due Date: Dec 9, 2025
  Today: Nov 14, 2025

Current System:
  Days = Nov 14 - Nov 9 = 5 days
  Template: C (>3 days)
  Email: URGENT warning

Customer Requirement:
  Days = Nov 14 - Dec 9 = -25 days
  Template: NONE (not due yet!)
  Email: Not sent (customer still has 25 days)
```

### What to Ask

**"For the day count calculation used in template selection:**

1. **Should we use "Arrear After Net Due Date" as the basis?**
   - This means: Days AFTER the due date (negative if not yet due)
   - Example: If due Dec 9 and today is Nov 14 = -25 days (not due yet)

2. **Where do we get the "Net Due Date"?**
   - Is it stored in SAP data export (Excel File #2)?
   - Is it calculated from payment terms (Net 30, Net 45, etc.)?
   - Which field contains it?

3. **Should we exclude bank holidays and weekends in calculation?**
   - Yes/No?
   - If yes, which calendar to use (Thailand holidays)?

**Please clarify the exact calculation formula."**

### Impact

| Current System | Customer Requirement |
|----------------|----------------------|
| Uses document date | Uses net due date |
| Counts from invoice date | Counts from payment deadline |
| May send urgent warnings too early | Sends warnings only when overdue |
| Template triggers: 1-2, 3, 4+ days | Template triggers: <3, =3, >3 days overdue |
| Simple calculation | Requires payment terms lookup |

---

## 🔴 CRITICAL CONFLICT #3: FIFO Matching Logic

### The Conflict

**Current Implementation**:
```
CN Total = Sum of all Credit Notes (negative amounts)
DN Total = Sum of all Debit Notes (positive amounts)
Net Amount = DN Total + CN Total

Example:
  CN: -500, -1000, -200 = -1700 total
  DN: 1000, 2000, 500 = 3500 total
  Net: 3500 - 1700 = 1800 THB
```

**Customer Requirement**:
```
Match line-by-line in FIFO order:
  1. Sort CN by date (oldest first)
  2. Sort DN by date (oldest first)
  3. Apply each CN to DN in sequence
  4. When CN covers DN completely, move to next DN
  5. STOP when remaining CN < remaining DN
  6. Ignore any CN that would make CN > DN

Example:
  DN sorted: [1000(Nov9), 2000(Nov10)]
  CN sorted: [-500(Nov8), -1500(Nov11)]

  Match:
    DN1(1000) - CN1(500) = 500 remaining
    Remaining: 500 + 2000 = 2500
    CN2(1500) - IGNORE (would exceed)

  Net: 2500 THB
```

### Why This Matters

Two different matching approaches = Potentially different net amounts = Different email amounts sent

### What to Ask

**"For Credit Note (CN) matching against Debit Notes (DN):**

1. **Is line-by-line FIFO matching required?**
   - Option A: Yes, match CN to DN in order until CN exhausted (per document)
   - Option B: No, simple summation is acceptable (current system)

2. **If line-by-line matching:**
   - How to handle remaining CN that doesn't match? (Ignore, apply to next month, etc.)
   - How to track which CN matched which DN?

**Please confirm the matching method."**

### Impact

| Simple Summation | Line-by-Line FIFO |
|-----------------|-------------------|
| Fast calculation | More complex calculation |
| Net: Sum(DN) + Sum(CN) | Net: After applying each CN to DN in order |
| May allow CN > DN | Stops when CN < DN |
| Simple storage | Requires tracking matching pairs |

---

## 🔴 CRITICAL CONFLICT #4: Processing Schedule

### The Conflict

**Current Implementation**:
- Load file: 8:00 AM (assumed)
- Generate emails: 8:30 AM (assumed)
- Send emails: 8:30 AM (assumed)

**Customer Requirement**:
- Says "confirm time" (no explicit times given in document)

### Why This Matters

Template selection and email timing depends on:
- When files are loaded from SAP
- When emails are generated
- When emails are sent

Different times may affect daily processing and SLA compliance.

### What to Ask

**"For the daily processing schedule, please confirm the exact times:**

1. **What time should we load the SAP data file (Excel File #2)?**
   - Current assumption: 8:00 AM SE Asia time
   - Correct? Or different time?

2. **What time should we generate the emails?**
   - Current assumption: 8:30 AM SE Asia time
   - Correct? Or different time?

3. **What time should we send the emails?**
   - Should match generation time?
   - Or after AR approval is complete?

4. **Should system run every day, or only on business days?**
   - Daily (7 days/week)?
   - Business days only (Mon-Fri)?
   - Exclude Thai holidays?

**Please provide confirmed times and frequency."**

### Impact

| Early Schedule (6 AM) | Current (8 AM) | Late Schedule (9 AM) |
|---------------------|-----------------|-------------------|
| Earliest processing | Mid-morning | Latest processing |
| Customers see early | Customers see standard | Customers see late |
| Earlier AR approval needed | Standard AR workflow | Extended AR window |

---

## 📋 Summary: What Needs Clarification

| # | Issue | Current | Customer Requirement | Status |
|---|-------|---------|---------------------|--------|
| 1 | **QR Codes** | Don't show | "specific QR Code" | 🔴 CONFLICT |
| 2 | **Day Count** | Doc Date | Net Due Date | 🔴 CONFLICT |
| 3 | **FIFO Matching** | Simple sum | Line-by-line | 🔴 CONFLICT |
| 4 | **Schedule Times** | 8:00/8:30 AM | "Confirm time" | 🔴 CONFLICT |
| 5 | **Template D** | N/A | Add for MI docs | ✅ CONFIRMED |
| 6 | **Exclusion Keywords** | 5 keywords | Same 5 keywords | ✅ CONFIRMED |
| 7 | **Subject Format** | Generic | Code/Name/Dates | ✅ CONFIRMED |
| 8 | **AR Approval** | Implemented | Confirmed needed | ✅ CONFIRMED |

---

## 🚀 Recommended Action

### Immediate

**Schedule clarification meeting with customer to resolve:**

1. QR codes: Show or not show?
2. Day count: Document date or net due date?
3. FIFO: Simple or line-by-line?
4. Schedule: Confirm exact times

### Then

Update implementation based on customer responses:
- If QR = YES: Revert Phase 1 plan (add QR logic)
- If QR = NO: Continue Phase 1 plan (remove QR logic)
- If day count changes: Update Email Engine logic
- If FIFO changes: Update SAP Import logic
- Update schedule if needed

### Then

Update documentation and create new implementation roadmap

### Then

Start Phase 1 implementation with confirmed requirements

---

## 📞 Conversation to Have

**Subject: Urgent Clarification Needed - 4 Key Items**

Dear [Customer],

Thank you for the latest confirmation document. We've reviewed it carefully and identified a few areas that need clarification before we proceed with implementation:

**1. QR Codes in Emails**
- Previous discussion: Don't include QR codes
- Latest document: Include "specific QR Code"
- **Which is correct?**

**2. Day Count for Template Selection**
- Currently: Days since invoice date (document date)
- Document says: Days since payment due date (Arrear After Net Due Date)
- **Which should we use?**

**3. Credit Note Matching**
- Currently: Sum all credits + sum all debits
- Document implies: Match credits to debits in order
- **Which matching method do you need?**

**4. Processing Schedule**
- Currently assumed: 8:00 AM load, 8:30 AM send
- **Please confirm the correct times**

Once we have these clarifications, we can finalize the implementation and deploy the system.

Thank you,
[Implementation Team]

---

**Status**: 🔴 **BLOCKING - Awaiting Customer Clarification**

Cannot proceed with Phase 1 until these 4 items are resolved.

