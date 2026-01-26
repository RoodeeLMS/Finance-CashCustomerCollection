# Screen Description: scnEmailApproval (v3.0)

**Screen Name:** scnEmailApproval
**Display Title:** Email Send Status
**Purpose:** Monitor daily email send status and take action on failed/pending emails
**Access Level:** Admin, AR Manager, AR Analyst
**Data Source:** Dataverse
**Created:** 2025-10-11
**Updated:** 2026-01-21
**Status:** READY FOR REBUILD

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-10-11 | Original with manual approval workflow |
| v2.0 | 2026-01-21 | Updated purpose, kept same layout |
| v3.0 | 2026-01-21 | **REDESIGNED**: Status-focused layout with summary cards |

---

## CRITICAL: System Architecture

### Daily Flow Sequence
```
07:00 -- SAP Import Flow
         - Imports transactions from Power BI (pre-filtered)
         - Creates ProcessLog record

07:30 -- Email Engine Flow
         - Creates EmailLog records (one per customer)
         - AUTO-APPROVES all emails:
           * ApprovalStatus = Approved (676180001)
           * SendStatus = Pending (676180002)
         - Template selection: D -> C -> B -> A

08:00 -- Email Sending Flow
         - Sends emails where SendStatus = Pending
         - Updates SendStatus to Success (676180000) or Failed (676180001)
         - Updates SentDateTime
```

### Key Point
**All emails are AUTO-APPROVED** at creation. This screen monitors **SendStatus**, not ApprovalStatus.

---

## 1. Purpose & Overview

**What this screen does:**
Monitor the status of daily collection emails - see what's sent, what failed, what's pending. Take action on failed emails.

**Who uses it:**
- **AR Team** - Check email status after 08:00, handle failures
- **AR Manager** - Monitor daily email completion rate

**User Goals:**
1. See at-a-glance status breakdown (Sent/Failed/Pending)
2. Quickly identify failed emails and view error details
3. Resend failed emails or exclude problematic customers
4. Review email content before 08:00 send time

**When it's used:**
- **Before 08:00**: Review generated emails, optionally exclude customers
- **After 08:00**: Monitor send status, handle failures

---

## 2. Screen Layout

### Design Philosophy
**Status-first approach**: The primary information is "how many sent/failed/pending" - make this immediately visible with clickable filter cards.

### ASCII Mockup

```
+------------------------------------------------------------------+
| [=] Email Send Status                           21/01/2026 [Ref] |
+------------------------------------------------------------------+
|                                                                   |
|  STATUS SUMMARY                                                   |
|  +----------------+  +----------------+  +----------------+       |
|  | [CheckCircle]  |  | [Warning]      |  | [Clock]        |       |
|  |      82        |  |       2        |  |      13        |       |
|  |     Sent       |  |    Failed      |  |    Pending     |       |
|  | B2,450,000     |  |   B125,000     |  |   B890,000     |       |
|  +----------------+  +----------------+  +----------------+       |
|   [Selected]                                                      |
|                                                                   |
+------------------------------------------------------------------+
|                                                                   |
|  EMAIL LIST                                          [Filter: All]|
|  +--------------------------------------------------------------+ |
|  | Customer              | Amount    | Template | Days | Status | |
|  |-----------------------|-----------|----------|------|--------| |
|  | ABC Corporation       | B450,000  |    C     |  7   | Sent   | |
|  | XYZ Trading Ltd       | B320,000  |    B     |  3   | Sent   | |
|  | DEF Industries        | B125,000  |    C     |  5   | Failed | |
|  | GHI Company           | B89,000   |    A     |  1   | Pending| |
|  | ...                   |           |          |      |        | |
|  +--------------------------------------------------------------+ |
|                                                                   |
+------------------------------------------------------------------+
|                                                                   |
|  DETAIL PANEL (visible when row selected)                         |
|  +--------------------------------------------------------------+ |
|  | DEF Industries                              Status: FAILED    | |
|  | Error: Invalid email address                                  | |
|  |--------------------------------------------------------------|  |
|  | To: invalid@email     CC: sales@nestle.com                    | |
|  | Template C (Day 5)    Amount: B125,000                        | |
|  |                                                               | |
|  | Transactions:                                                 | |
|  | DN-123456  01/12/2026  Day 5  B80,000                        | |
|  | DN-123457  05/12/2026  Day 3  B45,000                        | |
|  |                                                               | |
|  |                        [Exclude Customer] [Resend Email]      | |
|  +--------------------------------------------------------------+ |
|                                                                   |
+------------------------------------------------------------------+
| [NavigationMenu - Left slide-in]                                  |
+------------------------------------------------------------------+
```

---

## 3. Component Breakdown

### 3.1 Header
| Control | Type | Properties |
|---------|------|------------|
| Container | GroupContainer@1.3.0 AutoLayout | H:55, Fill: Nestle Blue |
| Menu Icon | Classic/Icon@2.5.0 | Icon.Hamburger, toggles _showMenu |
| Title | Text@0.0.51 | "Email Send Status", White, Size 24 |
| Date Display | Text@0.0.51 | Today's date |
| Refresh Button | Button@0.0.45 | Icon: Sync, Subtle appearance |

### 3.2 Status Summary Cards
| Control | Type | Properties |
|---------|------|------------|
| Container | GroupContainer@1.3.0 AutoLayout | Horizontal, Gap: 15, H:120 |
| Sent Card | GroupContainer@1.3.0 AutoLayout | Vertical, Clickable, Green accent |
| Failed Card | GroupContainer@1.3.0 AutoLayout | Vertical, Clickable, Red accent |
| Pending Card | GroupContainer@1.3.0 AutoLayout | Vertical, Clickable, Gray accent |

**Card Contents:**
- Icon (CheckCircle/Warning/Clock)
- Count (large number, Size 32, Bold)
- Label ("Sent"/"Failed"/"Pending")
- Amount subtotal

**Card Behavior:**
```powerfx
// OnSelect for each card
Set(_statusFilter, "Sent")  // or "Failed" or "Pending"
```

**Selected State:**
- Border highlight or background shade
- Use `_statusFilter` variable to track selection

### 3.3 Email List (Table)
| Control | Type | Properties |
|---------|------|------------|
| Filter Dropdown | DropDown@0.0.45 | Items: ["All", "Sent", "Failed", "Pending"] |
| Email Table | Table@1.0.278 | Filterable, Sortable, Single-select |

**Table Columns:**
| Column | Field | Width | Format |
|--------|-------|-------|--------|
| Customer | Lookup → cr7bb_customername | 200 | Text |
| Amount | cr7bb_totalamount | 120 | Currency B#,##0 |
| Template | cr7bb_emailtemplate | 80 | Text (A/B/C/D) |
| Days | cr7bb_maxdaycount | 60 | Number |
| Status | cr7bb_sendstatus | 100 | Badge with color |

**Table Items Formula:**
```powerfx
=SortByColumns(
    Filter(
        '[THFinanceCashCollection]Emaillogs',
        cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd") &&
        (_statusFilter = "All" ||
         (_statusFilter = "Sent" && cr7bb_sendstatus = 'Send Status Choice'.Success) ||
         (_statusFilter = "Failed" && cr7bb_sendstatus = 'Send Status Choice'.Failed) ||
         (_statusFilter = "Pending" && cr7bb_sendstatus = 'Send Status Choice'.Pending))
    ),
    "cr7bb_maxdaycount", SortOrder.Descending
)
```

**Row Selection:**
```powerfx
// OnSelect (table selection)
Set(_selectedEmail, Self.Selected)
```

### 3.4 Detail Panel
| Control | Type | Properties |
|---------|------|------------|
| Container | GroupContainer@1.3.0 AutoLayout | Vertical, Visible: !IsBlank(_selectedEmail) |
| Header Row | GroupContainer@1.3.0 AutoLayout | Customer name + Status badge |
| Error Message | Text@0.0.51 | Visible: SendStatus = Failed, Red color |
| Email Info | Text@0.0.51 | To, CC, Template, Amount |
| Transaction List | Gallery@2.15.0 | Filtered transactions |
| Action Buttons | GroupContainer@1.3.0 AutoLayout | Exclude + Resend buttons |

**Visibility:**
```powerfx
Visible = !IsBlank(_selectedEmail)
```

**Error Message (Failed only):**
```powerfx
Visible = _selectedEmail.cr7bb_sendstatus = 'Send Status Choice'.Failed
Text = "Error: " & _selectedEmail.cr7bb_errormessage
```

**Action Buttons:**
| Button | Appearance | Visible | Action |
|--------|------------|---------|--------|
| Exclude Customer | Secondary, Red | SendStatus = Pending | Mark as Failed with "Excluded" message |
| Resend Email | Primary, Blue | SendStatus = Failed | Trigger resend flow |

---

## 4. Data Schema

### Primary Entity: `[THFinanceCashCollection]Emaillogs`

| Field | Logical Name | Type | Notes |
|-------|--------------|------|-------|
| ID | cr7bb_thfinancecashcollectionemaillogid | GUID | Primary Key |
| Customer | cr7bb_customer | Lookup | → Customers |
| Process Date | cr7bb_processdate | Text | "yyyy-mm-dd" format |
| Total Amount | cr7bb_totalamount | Currency | |
| Max Day Count | cr7bb_maxdaycount | Number | |
| Email Template | cr7bb_emailtemplate | Text | A, B, C, D |
| Recipient Emails | cr7bb_recipientemails | Text | |
| CC Emails | cr7bb_ccemails | Text | |
| Send Status | cr7bb_sendstatus | Choice | Success/Failed/Pending |
| Sent DateTime | cr7bb_sentdatetime | DateTime | |
| Error Message | cr7bb_errormessage | Text | Error details |
| Approval Status | cr7bb_approvalstatus | Choice | Always Approved |

### Choice Field Syntax

```powerfx
// Send Status (note: quotes required due to space in name)
'Send Status Choice'.Success    // 676180000
'Send Status Choice'.Failed     // 676180001
'Send Status Choice'.Pending    // 676180002

// Approval Status (no quotes needed)
ApprovalStatusChoice.Approved   // 676180001 (always this value)
```

---

## 5. Screen Variables

| Variable | Type | Purpose | Default |
|----------|------|---------|---------|
| `_selectedDate` | Date | Date filter | Today() |
| `_statusFilter` | Text | Status card selection | "All" |
| `_selectedEmail` | Record | Selected table row | Blank() |
| `_showMenu` | Boolean | Navigation menu visibility | false |
| `currentScreen` | Text | Navigation context | "Email Send Status" |

---

## 6. Behavior & Logic

### OnVisible
```powerfx
UpdateContext({currentScreen: "Email Send Status"});
Set(_showMenu, false);
Set(_selectedDate, Today());
Set(_statusFilter, "All");
Set(_selectedEmail, Blank());

// Pre-load collections for summary counts
ClearCollect(
    colEmailsToday,
    Filter(
        '[THFinanceCashCollection]Emaillogs',
        cr7bb_processdate = Text(Today(), "yyyy-mm-dd")
    )
);
```

### Status Card Calculations
```powerfx
// Sent count and amount
Set(_sentCount, CountRows(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Success)));
Set(_sentAmount, Sum(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Success), cr7bb_totalamount));

// Failed count and amount
Set(_failedCount, CountRows(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Failed)));
Set(_failedAmount, Sum(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Failed), cr7bb_totalamount));

// Pending count and amount
Set(_pendingCount, CountRows(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Pending)));
Set(_pendingAmount, Sum(Filter(colEmailsToday, cr7bb_sendstatus = 'Send Status Choice'.Pending), cr7bb_totalamount));
```

### Exclude Customer Action
```powerfx
Patch(
    '[THFinanceCashCollection]Emaillogs',
    _selectedEmail,
    {
        cr7bb_sendstatus: 'Send Status Choice'.Failed,
        cr7bb_errormessage: "Manually excluded by AR team on " & Text(Now(), "yyyy-mm-dd hh:mm")
    }
);
Notify("Customer excluded from today's emails", NotificationType.Success);
Set(_selectedEmail, Blank());
// Refresh collection
ClearCollect(colEmailsToday, Filter('[THFinanceCashCollection]Emaillogs', cr7bb_processdate = Text(Today(), "yyyy-mm-dd")));
```

### Resend Email Action
```powerfx
// Option 1: Reset status to trigger flow
Patch(
    '[THFinanceCashCollection]Emaillogs',
    _selectedEmail,
    {
        cr7bb_sendstatus: 'Send Status Choice'.Pending,
        cr7bb_errormessage: Blank()
    }
);
Notify("Email queued for resend", NotificationType.Success);

// Option 2: Call Power Automate flow directly
// THFinanceCashCollectionManualEmailResend.Run(_selectedEmail.cr7bb_thfinancecashcollectionemaillogid)
```

---

## 7. Styling

### Nestle Brand Colors
| Element | Color |
|---------|-------|
| Header | RGBA(0, 101, 161, 1) - Nestle Blue |
| Sent Card Accent | RGBA(16, 124, 16, 1) - Green |
| Failed Card Accent | RGBA(168, 0, 0, 1) - Red |
| Pending Card Accent | RGBA(100, 100, 100, 1) - Gray |
| Primary Button | RGBA(0, 101, 161, 1) - Nestle Blue |
| Danger Button | RGBA(168, 0, 0, 1) - Red |

### Status Badge Colors
| Status | Background | Text |
|--------|------------|------|
| Success/Sent | RGBA(16, 124, 16, 0.1) | RGBA(16, 124, 16, 1) |
| Failed | RGBA(168, 0, 0, 0.1) | RGBA(168, 0, 0, 1) |
| Pending | RGBA(100, 100, 100, 0.1) | RGBA(100, 100, 100, 1) |

### Typography
| Element | Size | Weight |
|---------|------|--------|
| Screen Title | 24 | Medium |
| Card Count | 32 | Bold |
| Card Label | 14 | Semibold |
| Table Header | 14 | Semibold |
| Table Body | 14 | Regular |
| Detail Title | 18 | Bold |

---

## 8. Navigation

### Entry Points
- Dashboard → "Review Emails" button
- Dashboard → "View Failed" button (pre-filters to Failed)
- Navigation Menu

### Exit Points
- Navigation Menu → Any screen
- Back button (if implemented)

### Deep Link Support
```powerfx
// From Dashboard "View Failed" button
Navigate(scnEmailApproval, ScreenTransition.None, {_statusFilter: "Failed"})
```

---

## 9. Success Criteria

### Functional
- [ ] Status cards show correct counts and amounts
- [ ] Clicking status card filters the list
- [ ] Table shows all emails with correct status badges
- [ ] Selecting row shows detail panel
- [ ] Exclude action marks email as Failed
- [ ] Resend action queues email for retry
- [ ] Failed emails show error message

### Performance
- [ ] Screen loads in < 2 seconds
- [ ] Status counts update immediately after actions
- [ ] Table filters instantly on card click

### UX
- [ ] Clear visual hierarchy (Status → List → Details)
- [ ] Status is immediately visible on load
- [ ] Failed emails are easy to identify
- [ ] Actions are contextual (Exclude for Pending, Resend for Failed)

---

## 10. Testing Scenarios

### Before 08:00
1. Open screen at 7:45 AM
2. Expected: All cards show Pending status
3. Click a pending email → Exclude
4. Expected: Card counts update, email moves to Failed

### After 08:00
1. Open screen at 9:00 AM
2. Expected: Mix of Sent/Failed/Pending
3. Click Failed card → List filters to failed only
4. Select failed email → View error message
5. Click Resend → Email queued

### Edge Cases
1. No emails for today → Show empty state message
2. All emails sent successfully → Failed card shows 0, disabled appearance
3. Network error on action → Show error notification

---

**READY FOR REBUILD**
