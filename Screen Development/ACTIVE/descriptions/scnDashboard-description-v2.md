# Dashboard Screen Redesign - v2.5

## Screen Name
`scnDashboard`

## Purpose
**AR Daily Operations Dashboard** - Primary screen for AR team to:
1. Monitor flow execution status (SAP Import, Email Engine)
2. Track today's outstanding amounts by urgency level
3. Track email send status (Sent/Failed/Pending)
4. Identify high-priority overdue customers (Day 4+)

---

## System Architecture

### Daily Flow Sequence
```
07:00 ── SAP Import Flow ─────────────────────────────────────────┐
         - Creates ONE ProcessLog record for the day               │
         - Imports transactions from Power BI                      │
         - Sets cr7bb_isexcluded on excluded transactions          │
                                                                   │
07:30 ── Email Engine Flow ───────────────────────────────────────┤
         - Creates EmailLog records (one per customer)             │
         - AUTO-APPROVES all emails (ApprovalStatus = Approved)    │
         - Sets SendStatus = Pending                               │
         - Selects template based on day count and MI documents    │
                                                                   │
08:00 ── Email Sending Flow ──────────────────────────────────────┘
         - Sends emails where ApprovalStatus = Approved
         - Updates SendStatus to Success/Failed
         - Updates SentDateTime
```

### Key Flow Behaviors
| Behavior | Details |
|----------|---------|
| **Auto-Approve** | Email Engine sets ApprovalStatus = Approved (676180001) directly |
| **Exclude Logic** | Data filtered at source (Power BI) before import - excluded transactions never enter system |
| **Template Selection** | D (has MI) → C (Day 4+) → B (Day 3) → A (Day 1-2) |

### Exclusion Rules (Applied at Power BI Source)
Transactions with these keywords in Text field are excluded before import:
- "Paid" / "Partial Payment"
- "รักษาตลาด" (Market maintenance)
- "Bill credit 30 days"
- "Exclude"

### Data Sources
| Table | Purpose |
|-------|---------|
| `[THFinanceCashCollection]Process Logs` | SAP Import status (ONE per day) |
| `[THFinanceCashCollection]Emaillogs` | Email records with approval/send status |
| `[THFinanceCashCollection]Transactions` | Transaction amounts, day counts |

---

## Screen Layout

```
+------------------------------------------------------------------+
| [=] Daily Control Center                              [Refresh]   |
+------------------------------------------------------------------+
|  [< Prev]  [  21/01/2026 (Today)  ]  [Next >]  [Today] [Pick]    |
+------------------------------------------------------------------+
|                                                                   |
|  +---------------------------+  +---------------------------+    |
|  | 📥 SAP IMPORT            |  | 📧 EMAIL GENERATION       |    |
|  | ✓ Completed 07:15        |  | ✓ Completed 07:45         |    |
|  |                          |  |                           |    |
|  | Transactions: 156        |  | Emails Created: 97        |    |
|  | Excluded: 12             |  | Customers: 97             |    |
|  |                          |  |                           |    |
|  +---------------------------+  +---------------------------+    |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | 💰 TODAY'S OUTSTANDING                                      |  |
|  |                                                              |  |
|  |  ฿ 2,450,000              97 Customers                      |  |
|  |                                                              |  |
|  |  +------------+ +------------+ +------------+               |  |
|  |  | Day 1-2    | | Day 3      | | Day 4+     |               |  |
|  |  | 45 cust    | | 28 cust    | | 24 cust    |               |  |
|  |  | ฿980K      | | ฿720K      | | ฿750K      |               |  |
|  |  | Standard   | | Warning    | | Urgent     |               |  |
|  |  +------------+ +------------+ +------------+               |  |
|  +------------------------------------------------------------+  |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | 📨 EMAIL SEND STATUS                                        |  |
|  |                                                              |  |
|  |  [✓ 82 Sent]    [⚠ 2 Failed]    [⏳ 13 Waiting]            |  |
|  |                                                              |  |
|  |  [📧 Review Emails]   [⚠️ View Failed]                      |  |
|  +------------------------------------------------------------+  |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | ⚠ TOP OVERDUE (Day 4+)                        [View All]    |  |
|  +------------------------------------------------------------+  |
|  | ABC Corporation          ฿450,000      7 days    [View]     |  |
|  | XYZ Trading Ltd          ฿320,000      5 days    [View]     |  |
|  | DEF Industries           ฿180,000      4 days    [View]     |  |
|  +------------------------------------------------------------+  |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | QUICK ACTIONS                                               |  |
|  | [Customers] [Transactions] [Calendar] [Export]              |  |
|  +------------------------------------------------------------+  |
|                                                                   |
+------------------------------------------------------------------+
```

---

## Functional Sections

### 1. Header + Date Selection
| Element | Control | Properties |
|---------|---------|------------|
| Menu Icon | Classic/Icon@2.5.0 | Icon.Hamburger, toggles _showMenu |
| Title | Text@0.0.51 | "Daily Control Center" |
| Refresh | Button@0.0.45 | Refreshes all data |
| Date Navigation | Buttons | Previous, Next, Today, Pick Date |

### 2. SAP Import Panel
**Data Source**: ProcessLog table

```powerfx
With(
    {
        _log: First(Filter('[THFinanceCashCollection]Process Logs',
            cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")))
    },
    // Display status, transactions, excluded
)
```

| Element | Display |
|---------|---------|
| Status Icon | CheckBadge (Completed), Clock (Running), CancelBadge (Failed) |
| Time | "Completed HH:mm" or "Running..." or "Not started" |
| Transactions | `cr7bb_transactionsprocessed` |
| Excluded | `cr7bb_transactionsexcluded` |

### 3. Email Generation Panel
**Data Source**: EmailLog table

```powerfx
// Emails created today
CountRows(
    Filter('[THFinanceCashCollection]Emaillogs',
        DateValue(cr7bb_processdate) = _selectedDate)
)
```

| Element | Display |
|---------|---------|
| Status Icon | CheckBadge (emails exist), CancelBadge (no emails) |
| Emails Created | Count of EmailLog records for date |
| Customers | Same as emails (1 email per customer) |

**Status Logic**:
- Emails > 0: Green icon (completed)
- Emails = 0: Gray icon (not run or no customers)

**Note**: Emails are AUTO-APPROVED by the Email Engine flow. No manual approval step required.

### 4. Today's Outstanding Section
**Data Source**: EmailLog table (aggregated)

```powerfx
// Total outstanding
Sum(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate),
    cr7bb_totalamount)

// Customer count
CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate))

// Day count breakdown
CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate &&
    cr7bb_maxdaycount <= 2))  // Day 1-2

CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate &&
    cr7bb_maxdaycount = 3))   // Day 3

CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate &&
    cr7bb_maxdaycount >= 4))  // Day 4+
```

**Day Count Cards**:
| Day Range | Template | Color | Label |
|-----------|----------|-------|-------|
| 1-2 | A | Gray | "Standard" |
| 3 | B | Amber | "Warning" |
| 4+ | C/D | Red | "Urgent" |

### 5. Email Send Status Section
**Data Source**: EmailLog table

```powerfx
// Sent successfully (SendStatus = Success)
CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_sentdatetime) = _selectedDate &&
    cr7bb_sendstatus = 'Send Status Choice'.Success))

// Failed (SendStatus = Failed)
CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_sentdatetime) = _selectedDate &&
    cr7bb_sendstatus = 'Send Status Choice'.Failed))

// Waiting to send (SendStatus = Pending, before 08:00 flow runs)
CountRows(Filter('[THFinanceCashCollection]Emaillogs',
    DateValue(cr7bb_processdate) = _selectedDate &&
    cr7bb_sendstatus = 'Send Status Choice'.Pending))
```

**Status Badges** (display counts):
| Status | Color | Meaning |
|--------|-------|---------|
| Sent | Green | Successfully delivered |
| Failed | Red | Send error (click to view details) |
| Waiting | Gray | Queued for 08:00 send |

**Action Buttons**:
| Button | Action | Condition |
|--------|--------|-----------|
| Review Emails | `Navigate(scnEmailApproval)` | Always visible |
| View Failed | `Navigate(scnEmailApproval, ScreenTransition.None, {_statusFilter: "Failed"})` | Only if Failed > 0 |

**Deep Link Parameters**:
The Email Send Status screen (scnEmailApproval) accepts these navigation parameters:
- `_statusFilter`: "All", "Sent", "Failed", or "Pending" - pre-filters the email list

### 6. Top Overdue Gallery
**Data Source**: EmailLog table (Day 4+ only)

```powerfx
FirstN(
    SortByColumns(
        Filter('[THFinanceCashCollection]Emaillogs',
            DateValue(cr7bb_processdate) = _selectedDate &&
            cr7bb_maxdaycount >= 4),
        "cr7bb_totalamount", SortOrder.Descending
    ),
    3
)
```

**Gallery Template**:
| Column | Source |
|--------|--------|
| Customer Name | `cr7bb_customer.cr7bb_customername` |
| Amount | `cr7bb_totalamount` formatted as currency |
| Days | `cr7bb_maxdaycount` & " days" |
| View Button | Navigate to customer history |

### 7. Quick Actions
| Button | Action |
|--------|--------|
| Customers | Navigate(scnCustomer) |
| Transactions | Navigate(scnTransactions) with date filter |
| Calendar | Navigate(scnCalendar) |
| Export | Future: Export daily report |

---

## Screen Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `_selectedDate` | Date | Date being viewed |
| `_showMenu` | Boolean | Navigation menu visibility |
| `_showDatePicker` | Boolean | Date picker modal |
| `_refreshTrigger` | Boolean | Force data refresh |
| `_processLog` | Record | Cached ProcessLog for date |
| `currentScreen` | Text | "Daily Control Center" |

---

## OnVisible Logic

```powerfx
// Initialize
Set(_showMenu, false);
Set(_showDatePicker, false);
UpdateContext({currentScreen: "Daily Control Center"});

// Set date if not already set
If(IsBlank(_selectedDate), Set(_selectedDate, Today()));

// Refresh data
Refresh('[THFinanceCashCollection]Process Logs');
Refresh('[THFinanceCashCollection]Emaillogs');

// Cache ProcessLog
Set(_processLog,
    First(Filter('[THFinanceCashCollection]Process Logs',
        cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd"))));
```

---

## CRITICAL NOTES

### 1. ProcessLog Date is TEXT
```powerfx
// CORRECT
cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")

// WRONG
cr7bb_processdate = _selectedDate
```

### 2. EmailLog Date Comparison
```powerfx
// For process date (when email was generated)
DateValue(cr7bb_processdate) = _selectedDate

// For sent date (when email was sent)
DateValue(cr7bb_sentdatetime) = _selectedDate
```

### 3. ApprovalStatusChoice Values
```powerfx
ApprovalStatusChoice.Pending   // 676180000
ApprovalStatusChoice.Approved  // 676180001
ApprovalStatusChoice.Rejected  // 676180002
```

### 4. Send Status Choice Values
```powerfx
'Send Status Choice'.Success   // 676180000
'Send Status Choice'.Failed    // 676180001
'Send Status Choice'.Pending   // 676180002
```

---

## Styling

### Nestle Brand Colors
| Purpose | Color |
|---------|-------|
| Header | `RGBA(0, 101, 161, 1)` - Nestle Blue |
| Success/Sent | `RGBA(16, 124, 16, 1)` - Green |
| Warning/Day3 | `RGBA(255, 185, 0, 1)` - Amber |
| Error/Day4+ | `RGBA(168, 0, 0, 1)` - Red |
| Secondary | `RGBA(100, 81, 61, 1)` - Oak Brown |
| Background | `RGBA(243, 242, 241, 1)` - Light Gray |

### Card Styling
```yaml
Fill: =RGBA(255, 255, 255, 1)
RadiusBottomLeft: =10
RadiusBottomRight: =10
RadiusTopLeft: =10
RadiusTopRight: =10
DropShadow: =DropShadow.Regular
LayoutMinHeight: =100
LayoutMinWidth: =100
```

### Typography
| Element | Size | Weight |
|---------|------|--------|
| Page Title | 24 | Medium |
| Card Header | 16 | Semibold |
| Large Number | 36 | Bold |
| Body | 14 | Regular |
| Small Label | 12 | Regular |

---

## Performance Considerations

1. **Use Collections**: Cache EmailLog aggregations on screen load
2. **Limit Queries**: Top Overdue shows only 3 items
3. **Refresh Strategy**: Only refresh on button click, not timer
4. **Date Filtering**: Always filter by date to limit records

---

## Version History
| Version | Date | Changes |
|---------|------|---------|
| v1.0 | Original | Email-focused dashboard |
| v2.0 | 2026-01-21 | Flow operations monitoring |
| v2.1 | 2026-01-21 | Fixed architecture - Email uses EmailLogs |
| v2.2 | 2026-01-21 | Enhanced with financial summary, pending approvals, top overdue |
| v2.3 | 2026-01-21 | Removed Pending Approval (emails are auto-approved by flow). Replaced with Email Generation status. Added action buttons. |
| v2.4 | 2026-01-21 | Clarified exclusion happens at Power BI source, not in flows. |
| v2.5 | 2026-01-21 | Added deep link syntax for Email Send Status navigation with _statusFilter parameter. |
