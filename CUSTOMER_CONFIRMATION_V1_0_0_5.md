# Customer Confirmation Update - v1.0.0.5
**Date**: November 14, 2025
**Source**: Latest customer confirmation document
**Status**: ✅ Received - Implementation requirements clarified

---

## 📋 System Overview (Confirmed)

The system implements the following flow:

### Data Sources ✅
1. **Excel File #1**: Customer Master Data
   - Manually maintained by AR team
   - Contains customer email addresses
   - Source: [cr7bb_customeremail field]

2. **Excel File #2**: Daily Cash (TT) Customer line items
   - Downloaded from SAP daily
   - Contains transaction line items with amounts and dates
   - Processed at scheduled time

### Processing Flow ✅
```
Excel File #2 (SAP data)
    ↓
Group by Customer Number
    ↓
Check Text Field for Exclusion Keywords
    ↓
If Excluded: Skip customer
If Not Excluded: Continue
    ↓
Separate CN (Credit Notes) and DN (Debit Notes)
    ↓
Apply FIFO matching
    ↓
Calculate arrears after net due date
    ↓
Select email template
    ↓
Generate and send email
```

---

## 🔑 KEY CLARIFICATIONS FROM CUSTOMER

### 1. Exclusion Keywords (5 Confirmed) ✅

**Text field to check**: Line item description/remarks field

**Keywords that trigger exclusion**:
1. "Paid" (case-insensitive)
2. "PP" or "Partial Payment" (case-insensitive)
3. "รักษาตลาด" (Thai - market maintenance)
4. "Bill credit 30 days" (case-insensitive)
5. "Exclude" (case-insensitive)

**Behavior**:
- If ANY line item for a customer contains these keywords → **SKIP ALL line items for that customer**
- AR team maintains this list (can add/update at beginning of year)
- User can manually enter holiday/weekend exclusions at start of year

**Status**: ✅ **CONFIRMED** - 5 keywords finalized

---

### 2. FIFO Matching Rules (REFINED) ⚠️ NEEDS UPDATE

**Current Implementation** (in system):
- Simple summation: CN Total + DN Total = Net Amount

**Customer Requirement** (NEW):
```
Step 1: Separate CN and DN
  CN = all Credit Notes (negative amounts)
  DN = all Debit Notes (positive amounts)

Step 2: Sort both by document date (FIFO)
  CN: Oldest first
  DN: Oldest first

Step 3: Match using absolute values
  IF Absolute(CN Total) < DN Total THEN
    → Net = DN Total - Absolute(CN Total)
    → Send email

  ELSE IF Absolute(CN Total) ≥ DN Total THEN
    → Apply FIFO matching:
      - Match CNs against DNs in order
      - When CN completely covers DN, move to next DN
      - STOP when Absolute(CN) < remaining DN
      - Ignore remaining CNs (don't process)
    → Send email with remaining DN balance

  ELSE IF No DN exists THEN
    → Don't send email
```

**Example Scenario**:
```
Customer 198609 has:
  DN1: 1000 (Doc Date: Nov 9)
  DN2: 2000 (Doc Date: Nov 10)
  CN1: -500 (Doc Date: Nov 8)
  CN2: -1500 (Doc Date: Nov 11)

Processing:
  Sort DN by date: [1000(Nov9), 2000(Nov10)]
  Sort CN by date: [-500(Nov8), -1500(Nov11)]

  Apply CN to DN:
    DN1(1000) - CN1(500) = 500 remaining
    Remaining DN1 + DN2 = 500 + 2000 = 2500
    CN2(1500) - ignore (CN exhausted previous DN)

  Net Amount: 2500 THB
```

**Status**: ⚠️ **NEEDS UPDATE** - Current system uses simple summation, customer requires line-by-line FIFO matching

---

### 3. Email Template Trigger (CRITICAL CHANGE) ⚠️ MAJOR UPDATE

**Current Implementation**:
- Based on: `cr7bb_daycount` (days since document date)
- Logic: Day 1-2 (A), Day 3 (B), Day 4+ (C)

**Customer Requirement** (NEW):
- Based on: **"Arrear After Net Due Date" from document type DR**
- **DR** = Debit Notes (invoices)
- Calculation: Today - Net Due Date (NOT document date)
- **Important**: Does NOT include bank holidays or weekends

**Template Selection Logic**:
```
Value = Arrear After Net Due Date (for DR document type)

IF Value < 3 THEN
  Template A (Standard reminder)

ELSE IF Value = 3 THEN
  Template B (Cash discount warning)

ELSE IF Value > 3 THEN
  Template C (Late fee warning + MI notice)

IF Document type = "MI" found THEN
  Template D (Late payment notification)
```

**Status**: ⚠️ **MAJOR CHANGE NEEDED** - Different calculation method required

---

### 4. Email Templates (4 Templates - UPDATED REQUIREMENTS)

#### Template A: Days < 3 (Standard Reminder) ✅
```
Subject: {CustomerCode} {CustomerName} รายละเอียดบิล DD.MM.YYYY-DD.MM.YYYY

Content:
  - Standard payment reminder
  - Amount owed: {NetAmount} บาท (with thousand separator)
  - Transaction details table
  - Text-based payment instructions

Include: Specific QR code for customer (if available)
Tone: Professional, standard
Format: 1,500.00 บาท (example amount)
```

#### Template B: Days = 3 (Cash Discount Warning) ⚠️
```
Subject: {CustomerCode} {CustomerName} รายละเอียดบิล DD.MM.YYYY-DD.MM.YYYY

Content:
  - Standard message
  - Amount owed: {NetAmount} บาท (with thousand separator)
  - ⚠️ CASH DISCOUNT WARNING:
    "If you don't pay by {Tomorrow's Date},
     you will lose Cash Discount eligibility"
  - Payment instructions

Include: Specific QR code for customer (if available)
Tone: Friendly but urgent
Format: 2,500.00 บาท (example amount)
```

**Important Note**: Customer said "just don't show it" for QR codes, but this document references "specific QR Code" per customer. This is a **CONFLICT** that needs clarification.

#### Template C: Days > 3 (Late Fee Warning) ⚠️
```
Subject: {CustomerCode} {CustomerName} รายละเอียดบิล DD.MM.YYYY-DD.MM.YYYY

Content:
  - Amount owed: {NetAmount} บาท (with thousand separator)
  - ⚠️ WARNING:
    "Payment is now overdue by {Days} days.
     Late fees (MI) will be applied.
     Contact AR immediately."
  - MI Note (NEW):
    "ท่านจะมียอดค่าใช้จ่าย MI ที่ต้องชำระเพิ่มเติม ซึ่งยอดดังกล่าวจะยังไม่ปรากฏในขณะนี้
     และจะปรากฏเมื่อระบบดำเนินการอัปเดตข้อมูลเรียบร้อยแล้ว (หากมีข้อสงสัยกรุณาติดต่อ....)"
  - Payment instructions

Include: Specific QR code for customer (if available)
Tone: Urgent, emphasizes penalties
Format: 10,500.00 บาท (example amount)
```

#### Template D: MI Document Type (Late Payment Notification) 🆕
```
Trigger: When document type = "MI" is found

Subject: {CustomerCode} {CustomerName} รายละเอียดบิล DD.MM.YYYY-DD.MM.YYYY

Content:
  - Late fee notice
  - Amount owed: {NetAmount} บาท (with thousand separator)
  - MI Explanation (NEW):
    "ยอด MI ที่ปรากฎ เป็นใบเพิ่มหนี้ที่ท่านชำระบิลล่าช้า หากมีข้อสงสัยกรุณาติดต่อ ...."
  - Calculation of MI charges
  - New total with MI (with thousand separator)
  - Urgent action required

Include: Specific QR code for customer (if available)
Tone: Formal, consequences emphasized
Format: 15,000.00 บาท (example amount)
```

**Status**: ⚠️ **TEMPLATES UPDATED** - Template D is new, Thai messaging added

---

### 5. Email Format & Subject Line ✅

**Subject Line Format**:
```
{CustomerCode} {CustomerName} รายละเอียดบิล DD.MM.YYYY-DD.MM.YYYY

Example:
198609 ABC Company รายละเอียดบิล 09.11.2025-14.11.2025

Where:
  - DD.MM.YYYY = earliest DN date (oldest invoice)
  - DD.MM.YYYY = latest DN date (newest invoice)
```

**Body Format**:
```
Header: เรียน คุณ {CustomerName}

Content:
1. Greeting + intro
2. Transaction table:
   - Document Number
   - Date
   - Amount (formatted: 1,000.50 บาท)
   - Balance (formatted: 2,500.00 บาท)
3. Total Due: {NetAmount} บาท (bold, with thousand separator)
4. Payment Instructions (text-based)
5. Template-specific Warning (if applicable)
6. Footer: AR team signature

Amount Formatting: 1,000.50 บาท (thousand separator, 2 decimals)
Font: Arial, sans-serif
Colors: Black text, Blue headers
Tables: 1px borders, cell padding
Warnings: Orange/Red, bold
```

**Status**: ✅ **CONFIRMED**

---

### 6. QR Code Handling ⚠️ CONFLICT DETECTED

**What Customer Document Says**:
- Include "specific QR Code" per customer in all templates
- All 4 templates mention: "+ specific QR Code"

**What Customer Said Previously (Message 5)**:
- "About QR codes : just don't show it"

**Current Status**: ⚠️ **CONFLICTING REQUIREMENTS**

**Options**:
1. **QR codes ARE included** (per latest document) → Revert decision
2. **QR codes NOT included** (per previous message) → Ignore in this document
3. **Ask customer to clarify** → Request definitive answer

**Status**: ⚠️ **NEEDS CLARIFICATION** - Which is correct?

---

### 7. Processing Schedule ✅

**Load File**:
- Time: To be confirmed (currently 8:00 AM SE Asia time)
- Source: SAP Excel export
- Action: Confirm time with customer

**Generate Email**:
- Time: To be confirmed (currently 8:30 AM SE Asia time)
- Action: Confirm time with customer

**AR Review**:
- AR team checks emails for correctness
- If errors found: Mark emails as "Unsend"
- Prevents sending incorrect emails

**Send Emails**:
- Time: By scheduled time (confirm with customer)

**Status**: ⏳ **NEEDS CONFIRMATION** - Specific times to be confirmed

---

### 8. New Requirement: AR Email Approval Workflow ✅

**NEW FEATURE**: AR can review and reject emails before sending

**Process**:
```
1. System generates emails
2. AR team reviews in email monitoring screen
3. If AR finds error:
   - Mark email as "Unsend"
   - Prevents sending
4. If email is correct:
   - Approve for sending
5. Send at scheduled time
```

**Status**: ✅ **CONFIRMED** - Approval workflow needed (already in Canvas App as scnEmailApproval)

---

### 9. Pending Requirement: Manual Trigger ⏸️

**Requirement**:
- Re-run the whole process OR
- Function to manually trigger email sending

**Use Case**:
- If need to re-process a customer
- If need to resend emails

**Status**: ⏸️ **PENDING** - Needs design and implementation

---

## 🔄 IMPACT ANALYSIS

### Changes Required vs. Current Implementation

| Aspect | Current | Customer Requirement | Status | Impact |
|--------|---------|---------------------|--------|--------|
| **Exclusion Keywords** | 5 keywords (confirmed) | Same 5 keywords | ✅ Match | No change |
| **FIFO Matching** | Simple summation | Line-by-line FIFO | ⚠️ Different | **MAJOR CHANGE** |
| **Day Count** | Days since Doc Date | Days since Net Due Date | ⚠️ Different | **MAJOR CHANGE** |
| **Templates** | 3 templates (A, B, C) | 4 templates (A, B, C, D) | ⚠️ Add Template D | **ADD TEMPLATE D** |
| **Template D** | N/A | MI document notification | 🆕 New | **NEW FEATURE** |
| **Subject Line** | Generic | Specific format with date range | ⚠️ Different | **UPDATE FORMAT** |
| **QR Codes** | Don't show (previous decision) | Show specific QR (this document) | ⚠️ Conflict | **NEEDS CLARIFICATION** |
| **AR Approval** | Already implemented | Confirmed needed | ✅ Match | No change |
| **Manual Trigger** | Not in current design | Required | ⏸️ Pending | **ADD FEATURE** |

---

## ⚠️ CRITICAL ISSUES REQUIRING CLARIFICATION

### Issue 1: QR Code Conflict 🔴

**Problem**: Two conflicting statements
- Previous message: "just don't show it"
- This document: "specific QR Code"

**Action Required**: Clarify with customer which is correct

**Impact**:
- If QR codes ARE included: Revert decision, add SharePoint file retrieval
- If QR codes NOT included: Ignore in this document, proceed with text-only

---

### Issue 2: Day Count Calculation 🔴

**Problem**: Different calculation method required
- Current: Days since document date (cr7bb_daycount field)
- Required: Days since net due date

**Difference Example**:
```
Invoice dated: Nov 9
Payment terms: Net 30
Net Due Date: Dec 9

Current calc: 5 days (Nov 14 - Nov 9)
Customer requirement: -25 days (Dec 9 - Nov 14, not due yet!)
```

**Action Required**: Confirm customer means "Arrear days" (days AFTER due date, not before)

**Impact**:
- **MAJOR CHANGE** needed in Email Engine flow
- Need to calculate net due date from payment terms
- Different template triggers

---

### Issue 3: FIFO Line-by-Line Matching 🔴

**Problem**: Customer requires complex line-by-line FIFO, not simple summation

**Current Logic**:
```
NetAmount = Sum(DN) + Sum(CN) = 3500 - 1700 = 1800
```

**Required Logic**:
```
Match CN to DN in FIFO order
Sort both by date
Apply CN to DN until CN exhausted
Ignore remaining CN
```

**Action Required**: Confirm if this is truly line-by-line or if simple summation is acceptable

**Impact**:
- **MAJOR CHANGE** to SAP Import and Email Engine flows
- Need to track individual CN/DN matching
- More complex logic and storage

---

### Issue 4: Processing Schedule 🟡

**Problem**: Times need confirmation

**Current**: 8:00 AM & 8:30 AM (assumed)
**Customer**: Says "confirm time" - no explicit times given

**Action Required**: Confirm exact times for:
- Load file from SAP
- Generate emails
- Send emails

**Impact**: May need to adjust flow triggers

---

## 📋 Summary of Changes Needed

### ✅ Already Correct (No Change)
1. Exclusion keywords (5 keywords confirmed)
2. AR email approval workflow
3. Basic email format and subject structure

### ⚠️ Need to Update
1. **FIFO matching logic** (line-by-line instead of summation)
2. **Day count calculation** (net due date instead of document date)
3. **Email templates** (add Template D for MI documents)
4. **Subject line format** (date range format)
5. **Processing schedule** (confirm times)

### 🔴 Need Clarification First
1. **QR codes** - show or not show? (CRITICAL CONFLICT)
2. **Day count** - confirm "arrear days" interpretation
3. **FIFO** - confirm line-by-line matching is required
4. **Times** - confirm exact schedule

### 🆕 Need to Add
1. **Manual trigger function** (re-run or resend capability)
2. **Template D** (MI document notifications)

---

## 🎯 Recommended Next Steps

### Priority 1 (Blocking): Clarify Conflicts
1. **QR Code Decision**
   - Is it: "Show specific QR for each customer" OR "Don't show any QR"?
   - This affects Email Engine and scnEmailMonitor/scnEmailApproval screens

2. **Day Count Calculation**
   - Confirm "Arrear After Net Due Date" means: Today - Payment Due Date (not document date)
   - Need to know where to get payment terms (Net 30, Net 45, etc.)

3. **FIFO Matching Detail**
   - Is line-by-line FIFO matching required or is simple summation acceptable?
   - Current system uses simple summation (Sum all CN + Sum all DN)

### Priority 2 (Implementation): Update if Conflicts Resolved
1. Update Email Engine flow for new calculations
2. Add Template D for MI documents
3. Update subject line format
4. Confirm and update processing schedule
5. Add manual trigger/resend function

### Priority 3 (Documentation): Update Records
1. Update BUSINESS_LOGIC_ANALYSIS with customer requirements
2. Update implementation roadmap
3. Create new implementation task list

---

## 📁 Document References

- Previous customer decision: Message 5 (QR codes: "just don't show it")
- Latest customer confirmation: This document (QR codes: "specific QR Code")
- Current implementation: BUSINESS_LOGIC_ANALYSIS_V1_0_0_5.md
- Current system: Email Engine flow (1044 lines)

---

**Status**: ⚠️ **AWAITING CLARIFICATION ON 4 CRITICAL ISSUES**

Once conflicts are resolved, implementation roadmap can be updated and Phase 1 can proceed.

