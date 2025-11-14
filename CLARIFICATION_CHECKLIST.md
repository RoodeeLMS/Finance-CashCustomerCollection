# Implementation Clarification Checklist

**Purpose**: Questions to clarify before final deployment and ongoing operation
**Date**: November 14, 2025
**Status**: Ready for review

Please review these questions and provide clarifications. These will help ensure the system operates exactly as your business requires.

---

## 1️⃣ Exclusion Keywords

### Current Implementation
The system excludes transactions if text field contains:
- ✓ "Paid" (case-insensitive)
- ✓ "Partial Payment" (case-insensitive)
- ✓ "Exclude" (case-insensitive)
- ✓ "รักษาตลาด" (Thai - market maintenance)
- ✓ "Bill Credit 30 days" (case-insensitive)

### Questions
1. **Are these 5 keywords complete?**
   - [ ] Yes, these are sufficient
   - [ ] No, add more keywords:
     ```
     Please list additional keywords:
     _________________________________
     _________________________________
     ```

2. **Case sensitivity - should we match differently?**
   - [ ] Current approach (case-insensitive) is correct
   - [ ] Need exact case match for some keywords

3. **Partial matches - current approach**
   - Current: Checks if keyword is CONTAINED in text
   - Example: "Paid in full" → matches "Paid" ✓
   - [ ] This is correct
   - [ ] Need exact word match only

4. **Thai language handling**
   - Currently: "รักษาตลาด" (exact match)
   - [ ] This is correct
   - [ ] Need additional Thai keywords:
     ```
     _________________________________
     ```

---

## 2️⃣ Email Template Thresholds

### Current Implementation
```
Invoice Age Decision:
  Day 1-2    → Template A (Standard reminder)
  Day 3      → Template B (Warning + Discount notice)
  Day 4+     → Template C (Urgent + Late fee notice)
```

### Questions
1. **Is Day 3 the correct threshold for discount warning?**
   - [ ] Yes, correct
   - [ ] Change to Day: ___
   - [ ] Need different logic (explain):
     ```
     _________________________________
     ```

2. **Is Day 4+ correct for late fee warning?**
   - [ ] Yes, correct
   - [ ] Change to Day: ___
   - [ ] Need multiple thresholds (explain):
     ```
     _________________________________
     ```

3. **Template B (Day 3) - discount deadline**
   - Currently: "You will lose discount if you don't pay by tomorrow"
   - [ ] This is correct
   - [ ] Change message to:
     ```
     _________________________________
     ```

4. **Template C (Day 4+) - late fee calculation**
   - Currently: Generic late fee warning
   - [ ] Use fixed fee amount: _____ THB
   - [ ] Use percentage: _____ % per day
   - [ ] Use formula:
     ```
     _________________________________
     ```
   - [ ] Keep as generic warning (current)

5. **Template D - when should it be used?**
   - Currently: Not actively used
   - [ ] Activate for Day ___+
   - [ ] Only for specific customers
   - [ ] Use specific criteria:
     ```
     _________________________________
     ```

---

## 3️⃣ QR Code Configuration

### Current Implementation
```
Location: SharePoint /03-QR-Codes/ folder
Naming: {CustomerCode}.jpg
Example: 198609.jpg
```

### Questions
1. **QR code file location - is this correct?**
   - [ ] Yes, `/03-QR-Codes/` is correct
   - [ ] Change location to:
     ```
     _________________________________
     ```

2. **File naming convention - {CustomerCode}.jpg?**
   - [ ] Yes, correct (e.g., 198609.jpg)
   - [ ] Use different naming:
     ```
     Example: _________________________________
     ```

3. **File format - should we support other formats?**
   - Currently: Only .jpg
   - [ ] Also support: .png, .gif
   - [ ] Only jpg is fine

4. **If QR code missing - current behavior**
   - Currently: Email sends WITHOUT attachment, no warning
   - [ ] This is correct
   - [ ] Show warning in email
   - [ ] Don't send email (fail)
   - [ ] Other:
     ```
     _________________________________
     ```

5. **QR code content - what does it link to?**
   - Currently: Assumed to be PromptPay/banking QR
   - Verify QR code contains:
     ```
     _________________________________
     ```

---

## 4️⃣ Email Recipients

### Current Implementation
```
To: Customer primary email (cr7bb_customeremail)
CC: Sales rep email + AR backup email
From: System account
```

### Questions
1. **Email recipient list - is this correct?**
   - [ ] Yes, exactly as shown above
   - [ ] Change recipients:
     ```
     To: _________________________________
     CC: _________________________________
     BCC: _________________________________
     ```

2. **Customer has multiple emails - which to use?**
   - Currently: Primary email only
   - [ ] This is correct
   - [ ] Use order of preference:
     ```
     1. _________________________________
     2. _________________________________
     3. _________________________________
     ```

3. **CC behavior - should we always CC both?**
   - Currently: Always CC sales rep + AR backup
   - [ ] Yes, always both
   - [ ] Only CC if customer email fails
   - [ ] Different rules per customer

4. **Some customers should NOT receive emails?**
   - [ ] No, send to all
   - [ ] Yes, exclude these customers:
     ```
     _________________________________
     ```
   - [ ] Create exclusion flag in customer record

5. **Bounce handling - if email fails**
   - Currently: Logged as failed, not retried
   - [ ] This is correct
   - [ ] Retry on day ___
   - [ ] Escalate to manual review

---

## 5️⃣ Daily Processing Schedule

### Current Implementation
```
SAP Import:  8:00 AM (13:00 UTC) - Daily
Email Engine: 8:30 AM (13:30 UTC) - Daily
Timezone: SE Asia Standard Time (UTC+7)
```

### Questions
1. **Is 8:00 AM the right time for SAP import?**
   - [ ] Yes, correct
   - [ ] Change to: ___:___ AM
   - [ ] Make it variable (flexible trigger)

2. **Is 8:30 AM the right time for email sending?**
   - [ ] Yes, correct
   - [ ] Change to: ___:___ AM
   - [ ] Should be triggered after SAP import completes (flexible)

3. **Weekend/Holiday behavior**
   - Currently: Runs every day including weekends
   - [ ] Run every day (current)
   - [ ] Skip weekends
   - [ ] Use custom holiday calendar

4. **Multiple daily runs needed?**
   - Currently: Once per day only
   - [ ] Current is fine
   - [ ] Also run at: ___:___ AM
   - [ ] Also run at: ___:___ AM

5. **What if one process fails?**
   - Currently: Next process still runs (independent)
   - [ ] This is correct
   - [ ] Only run email if SAP succeeds
   - [ ] Different approach:
     ```
     _________________________________
     ```

---

## 6️⃣ Amount Formatting & Currency

### Current Implementation
```
Format: Standard number (1800.50)
Decimal places: 2
Thousand separator: None
Currency symbol: None in code, Thai description in email
Language: Thai (ภาษาไทย)
```

### Questions
1. **Amount display format**
   - [ ] Current (1800.50) is correct
   - [ ] Add thousand separator: 1,800.50
   - [ ] Use Thai format: 1.800,50
   - [ ] Other:
     ```
     _________________________________
     ```

2. **Decimal places**
   - [ ] 2 decimal places (current) is correct
   - [ ] Use 0 decimal places (whole numbers only)
   - [ ] Use 3 decimal places
   - [ ] Variable based on currency

3. **Currency symbol**
   - [ ] Don't show symbol (current)
   - [ ] Add ฿ (Baht symbol)
   - [ ] Add THB
   - [ ] Add "บาท"

4. **Email language**
   - [ ] Thai only (current)
   - [ ] Bilingual (English + Thai)
   - [ ] English only
   - [ ] Customer's preferred language

5. **Financial rounding rules**
   - [ ] Round to nearest satang (.01)
   - [ ] Round down
   - [ ] Round up
   - [ ] Other:
     ```
     _________________________________
     ```

---

## 7️⃣ Transaction Date Handling

### Current Implementation
```
Process Date: TEXT field (format: yyyy-MM-dd)
Example: "2025-11-14"
Usage: Group transactions by date
```

### Questions
1. **Date format is correct?**
   - [ ] Yes, yyyy-MM-dd is correct
   - [ ] Change to: _________
   - [ ] Need datetime with time

2. **Process date field**
   - Currently: Text field, set to TODAY
   - [ ] This is correct
   - [ ] Should capture actual upload time
   - [ ] Should capture document date instead

3. **Date range filtering**
   - Currently: Only "today's" transactions (same date)
   - [ ] This is correct
   - [ ] Should process last 24 hours (rolling window)
   - [ ] Should process specific date range

4. **Future-dated invoices**
   - Currently: Included in processing
   - [ ] Include all dates (current)
   - [ ] Exclude future-dated invoices
   - [ ] Exclude invoices newer than ___ days

---

## 8️⃣ Process Logs & Reporting

### Current Implementation
```
Log when: Each SAP import completes
Captured: Rows processed, errors, status
Visibility: Dashboard screen, downloadable reports
```

### Questions
1. **Log detail level - is this sufficient?**
   - [ ] Yes, current level is good
   - [ ] Add more details:
     ```
     _________________________________
     ```
   - [ ] Reduce noise, less detail

2. **Email logs - do we track enough?**
   - Currently: Customer, date, status, amount, template, error
   - [ ] Yes, sufficient
   - [ ] Also track:
     ```
     _________________________________
     ```

3. **Log retention policy**
   - [ ] Keep all logs indefinitely
   - [ ] Archive after ___ months
   - [ ] Delete after ___ months
   - [ ] Move to separate database

4. **Audit trail requirements**
   - [ ] Current logging is sufficient
   - [ ] Need WHO modified which fields
   - [ ] Need approval audit trail
   - [ ] Need compliance signatures

---

## 9️⃣ Role & Access Control

### Current Implementation
```
Admin: Full access
AR Team: View/send emails
Manager: Approve/override
Viewer: Read-only
```

### Questions
1. **Are the 4 roles correct?**
   - [ ] Yes, these are fine
   - [ ] Add roles:
     ```
     _________________________________
     ```
   - [ ] Remove roles:
     ```
     _________________________________
     ```

2. **Role permissions - should they differ?**
   - [ ] Current permissions are correct
   - [ ] Modify these permissions:
     ```
     _________________________________
     ```

3. **Field-level security needed?**
   - [ ] No, role-based is sufficient
   - [ ] Yes, hide these fields from certain roles:
     ```
     _________________________________
     ```

4. **Data isolation - by region/customer?**
   - [ ] No isolation needed (everyone sees all)
   - [ ] Yes, isolate by:
     ```
     _________________________________
     ```

---

## 🔟 Canvas App Functionality

### Current Screens
1. scnDashboard - Monitor daily processing
2. scnCustomer - Manage customers
3. scnCustomerHistory - View transaction history
4. scnEmailApproval - Approve/override emails
5. scnEmailMonitor - Monitor email deliverability
6. scnTransactions - Manage transactions
7. scnRole - Manage user access

### Questions
1. **Are these 7 screens sufficient?**
   - [ ] Yes, complete
   - [ ] Add screen:
     ```
     _________________________________
     ```
   - [ ] Remove screen:
     ```
     _________________________________
     ```

2. **scnEmailApproval - is this workflow needed?**
   - [ ] Yes, keep as-is
   - [ ] Remove approval step
   - [ ] Modify workflow:
     ```
     _________________________________
     ```

3. **Missing functionality**
   - [ ] No, everything is covered
   - [ ] Need feature:
     ```
     _________________________________
     ```

4. **Navigation - is menu structure clear?**
   - [ ] Yes, navigation is intuitive
   - [ ] Change menu structure:
     ```
     _________________________________
     ```

---

## 🔟 Error Handling & Recovery

### Current Implementation
```
Strategy: Log and continue (don't stop on errors)
Errors tracked: Process logs + Email logs
Recovery: Manual review and resend
```

### Questions
1. **Current error handling is acceptable?**
   - [ ] Yes, log and continue is correct
   - [ ] Stop on first error
   - [ ] Retry failed items automatically

2. **Who should be notified of errors?**
   - [ ] Summary email to AR team (current)
   - [ ] Real-time alerts to Slack/Teams
   - [ ] Only if error count > ___
   - [ ] Daily digest regardless

3. **Automatic retry logic**
   - Currently: No automatic retries
   - [ ] Don't retry (current)
   - [ ] Retry failed emails once
   - [ ] Retry failed emails ___ times

4. **What if SAP import fails completely?**
   - [ ] Skip that day, notify AR
   - [ ] Retry next day with same file
   - [ ] Create manual override option

---

## Submission

Please respond to as many questions as you can. Mark with:
- ✅ = Confirmed correct
- ❌ = Need to change
- ❓ = Uncertain, need clarification

Send responses back and I'll:
1. Update business logic based on clarifications
2. Modify flows/screens as needed
3. Update documentation
4. Re-commit to git with changes
5. Mark system ready for final deployment

---

**Next Steps**
1. Review all questions above
2. Provide answers/clarifications
3. I'll update system accordingly
4. Final validation before go-live

**Status**: ✅ Analysis complete, **⏳ Awaiting clarifications**
