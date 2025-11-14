# Configuration Decisions - v1.0.0.5

**Date**: November 14, 2025
**Status**: ✅ Confirmed with User
**Purpose**: Document final configuration decisions before deployment

---

## 1️⃣ Exclusion Keywords Configuration

### Decision
**Status**: ⏳ **To be clarified with client**

**Current Keywords** (5 implemented):
- "Paid" (case-insensitive)
- "Partial Payment" (case-insensitive)
- "Exclude" (case-insensitive)
- "รักษาตลาด" (Thai - exact match)
- "Bill Credit 30 days" (case-insensitive)

### Action Items
- [ ] Confirm with client if these 5 keywords are sufficient
- [ ] Identify any additional keywords needed
- [ ] Determine any keyword-specific handling rules
- [ ] Document final list for operational reference

### Implementation
Once client clarifies, I will:
1. Update SAP Import flow (if keywords change)
2. Update documentation
3. Test with sample data
4. Deploy to production

**Current Status**: Ready for client input - System will work with current 5 keywords until client specifies changes.

---

## 2️⃣ Email Template Thresholds

### Decision
**Status**: ⏳ **To be clarified with client**

**Current Implementation**:
```
Day 1-2    → Template A (Standard reminder)
Day 3      → Template B (Discount deadline warning)
Day 4+     → Template C (Late fee warning)
```

### What We Need from Client
- [ ] Confirm Day 3 is correct for cash discount warning
- [ ] Confirm Day 4+ is correct for late fee charges
- [ ] Provide exact wording for discount deadline
- [ ] Provide late fee calculation method/amount
- [ ] Clarify if Template D is needed for MI documents

### Action Items
1. Client provides threshold confirmation
2. If changes needed:
   - [ ] Update flow decision logic
   - [ ] Update email templates with correct messaging
   - [ ] Test template selection with various day counts
3. Final approval before deployment

**Current Status**: Ready for client input - System will work with current thresholds until client specifies changes.

---

## 3️⃣ QR Code Handling

### Decision
**Status**: ✅ **CONFIRMED** - Don't show QR code attachment

### Implementation
**What Changed**:
```
Previous behavior:
  ✗ Look in /03-QR-Codes/ for {CustomerCode}.jpg
  ✗ Attach to email if found
  ✗ Skip if missing

New behavior:
  ✗ Don't retrieve QR code from SharePoint
  ✗ Don't show attachment in email
  ✗ Don't reference QR code in email body
  ✗ Email still sends successfully without QR
```

### Email Content Updates
- **Removed**: QR code image/attachment reference
- **Kept**: Payment instruction text
- **Updated**: Email body to not mention QR code

### Affected Flows
1. **Daily Collections Email Engine** (1044 lines)
   - Remove: "Get file" action for QR code
   - Remove: "Attach file" action
   - Remove: QR code image tag from HTML
   - Keep: Payment instructions and banking details

### Affected Screens
- scnEmailMonitor: Remove "QR Attached" column/field
- scnEmailApproval: Remove QR code preview

### Implementation Status
**Todo**: Update flow to remove QR code retrieval logic

---

## 4️⃣ Processing Schedule

### Decision
**Status**: ✅ **CONFIRMED** - Current schedule is correct, no additional runs needed

### Schedule Confirmed
```
SAP Import Flow:        8:00 AM daily (13:00 UTC / SE Asia +7)
Email Engine Flow:      8:30 AM daily (13:30 UTC / SE Asia +7)
Frequency:             Once per day only
Weekends:              Run every day (no weekend skip)
Holiday Handling:      Not configured (runs daily)
```

### No Changes Needed
- Schedule is optimal
- 30-minute gap between SAP import and email engine allows processing time
- Once-per-day frequency is sufficient for business requirements
- All transactions processed same day

### Confirmation
✅ Keep both flows scheduled as-is
✅ No additional daily runs needed
✅ Current timezone setting (SE Asia Standard Time) is correct

---

## 5️⃣ Amount Formatting & Currency

### Decision
**Status**: ✅ **CONFIRMED**

### Display Format
```
Standard: 1,800.50 บาท (with thousand separator)

Examples:
- 100.00 บาท
- 1,000.50 บาท
- 10,500.75 บาท
- 123,456.00 บาท
```

### Implementation Details
| Aspect | Setting |
|--------|---------|
| Thousand Separator | ✅ Yes (comma) |
| Decimal Places | ✅ 2 (.00) |
| Currency Symbol | ✅ No (฿ not shown) |
| Currency Text | ✅ Yes ("บาท" shown) |
| Language | ✅ Thai |
| Format Example | ✅ 1,800.50 บาท |

### Where This Applies
1. **Email body**:
   - Total amount due
   - Transaction line items
   - Summary line items

2. **Canvas App**:
   - Dashboard totals
   - Customer history amounts
   - Email monitor amounts
   - Transaction amounts

3. **Process logs**:
   - Email log amounts
   - Summary reports

### Implementation Status
**Todo**: Update all amount formatting in flows and screens to use format:
```
formatNumber(amount, '#,##0.00') & " บาท"
```

### Rounding Rules
- **Method**: Round to nearest satang (.01)
- **Direction**: Standard rounding (>= .005 rounds up)
- **Currency**: Thai Baht (smallest unit: .01)

---

## 📊 Summary of Decisions

| Area | Decision | Status | Action |
|------|----------|--------|--------|
| **Exclusion Keywords** | Clarify with client | ⏳ Pending | Client input needed |
| **Email Templates** | Clarify with client | ⏳ Pending | Client input needed |
| **QR Codes** | Don't show | ✅ Done | Update flows/screens |
| **Scheduling** | 8 AM & 8:30 AM | ✅ Confirmed | No changes needed |
| **Amount Format** | 1,800.50 บาท | ✅ Confirmed | Update all amounts |

---

## 🚀 Implementation Roadmap

### Phase 1: Implement Confirmed Decisions (This Sprint)
1. ✅ Update amount formatting throughout system
   - [ ] Update Email Engine flow (HTML template)
   - [ ] Update Canvas App (all screens showing amounts)
   - [ ] Update process logs

2. ✅ Update QR code handling
   - [ ] Remove QR file retrieval from Email Engine
   - [ ] Remove QR attachment logic
   - [ ] Remove QR references from HTML email
   - [ ] Update scnEmailMonitor screen
   - [ ] Update scnEmailApproval screen

3. ✅ Confirm scheduling (no changes needed)
   - [ ] Verify trigger times are 8:00 AM & 8:30 AM
   - [ ] Document in deployment guide

### Phase 2: Await Client Clarifications
1. ⏳ Keywords - Client provides final list
2. ⏳ Templates - Client provides thresholds & messaging

### Phase 3: Implement Client Decisions
1. Update exclusion keyword logic (if changed)
2. Update email template selection (if changed)
3. Update template messaging (if changed)

### Phase 4: Final Deployment
1. Comprehensive testing with all changes
2. Final documentation updates
3. Deploy to Power Platform environment

---

## 📝 Configuration File Template

For future reference, here are all configurable values:

```yaml
# EXCLUSION_KEYWORDS.yml
Keywords:
  - "Paid"
  - "Partial Payment"
  - "Exclude"
  - "รักษาตลาด"
  - "Bill Credit 30 days"
  # Add more as client clarifies

# EMAIL_TEMPLATES.yml
Templates:
  A:
    DayRange: "1-2"
    Title: "Standard Reminder"
  B:
    DayRange: "3"
    Title: "Discount Deadline Warning"
  C:
    DayRange: "4+"
    Title: "Late Fee Warning"
  # Confirm with client

# AMOUNT_FORMAT.yml
Currency:
  Symbol: "บาท"
  ShowSymbol: false
  ShowText: true
  ThousandSeparator: ","
  DecimalSeparator: "."
  DecimalPlaces: 2
  Example: "1,800.50 บาท"

# SCHEDULE.yml
Timezone: "SE Asia Standard Time"
Import:
  Time: "08:00"
  Frequency: "Daily"
EmailEngine:
  Time: "08:30"
  Frequency: "Daily"
  DependsOn: "None (independent)"
```

---

## ✅ Sign-Off

### Confirmed by User
- ✅ QR codes: Don't show
- ✅ Scheduling: 8 AM & 8:30 AM is correct
- ✅ Amount formatting: 1,800.50 บาท (thousand separator + Thai text)
- ⏳ Exclusion keywords: Will clarify with client
- ⏳ Email templates: Will clarify with client

### Next Steps
1. **Immediate** (this session):
   - Update amount formatting throughout system
   - Remove QR code logic from flows
   - Update screens to remove QR references

2. **Next** (after client clarification):
   - Update exclusion keywords
   - Update email template thresholds
   - Final testing and validation

3. **Final** (deployment):
   - Commit all changes to git
   - Deploy to Power Platform environment
   - Provide operational documentation

---

**Status**: ✅ **Partially Confirmed, Ready for Implementation**

Some decisions locked in (QR codes, schedule, amount format).
Awaiting client clarification on keywords & templates.

Ready to proceed with confirmed items now?
