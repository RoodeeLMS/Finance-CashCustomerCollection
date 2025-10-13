# Screen Description: scnEmailApproval

**Created**: 2025-10-11
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-table-view.yaml
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
This screen displays draft emails calculated by Power Automate and allows AR team to review and approve them before sending. In Phase 1 (testing), emails are auto-approved. In Phase 2 (production), AR manually reviews each email before sending.

**Who uses it**:
- **AR Team Member** - Reviews and approves daily collection emails before sending
- **AR Manager** - Oversees approval process and handles exceptions
- **System Admin** - Configures auto-approval settings

**User Goals**:
- Review all draft emails for today before they go out
- Preview email content, recipient, amounts for each customer
- Manually exclude specific customers from today's email batch
- Approve selected emails for sending (or auto-approve all)
- Track approval status (Pending → Approved → Sent)

**Business Workflow**:
```
Power Automate (8:00 AM Daily)
├─ Calculates emails for all customers
├─ Creates Emaillog records with Status: "Pending"
├─ Sets cr7bb_sentstatus = 'Send Status Choice'.Pending
└─ Does NOT send emails yet

AR Team Reviews (scnEmailApproval)
├─ Views all Pending emails for today
├─ Preview content for each customer
├─ Phase 1: Auto-approve all (gblAutoApprove = true)
├─ Phase 2: Manual selection (checkbox per email)
└─ Clicks "Send Approved Emails" button

Power Automate (Triggered by Approval)
├─ Filters Emaillog where cr7bb_sentstatus = "Approved"
├─ Sends emails via Office 365
├─ Updates cr7bb_sentstatus = "Success" or "Failed"
└─ Updates cr7bb_sentdatetime
```

---

## 2. Design Mockup

**Visual Layout**:

```
┌───────────────────────────────────────────────────────────────┐
│ [HEADER - GroupContainer@1.3.0, AutoLayout, H:55]            │
│ ◰ Menu  Email Approval & Send                    [User Icon] │
├───────────────────────────────────────────────────────────────┤
│ [FILTER BAR - GroupContainer@1.3.0, AutoLayout, H:60]        │
│ Date: [2025-10-11 ▼]  Customers: [45 Pending]                │
│ [🔄 Refresh Data]  [✓ Auto-Approve: ON/OFF]                   │
├───────────────────────────────────────────────────────────────┤
│ [SPLIT VIEW - H:Parent.Height-115]                           │
│ ┌─────────────────────────────┬─────────────────────────────┐ │
│ │ DRAFT EMAIL LIST (W:50%)    │ EMAIL PREVIEW (W:50%)       │ │
│ │ Gallery@2.15.0              │ Preview Panel (conditional) │ │
│ │                             │                             │ │
│ │ [☑] Customer A              │ To: customer@email.com      │ │
│ │     Amount: 125,000 THB     │ CC: sales@nestle.com        │ │
│ │     Transactions: 5 DNs     │ Subject: [Customer A]...    │ │
│ │     Template: B (Day 3)     │ ─────────────────────────   │ │
│ │     Status: Pending         │ Dear Customer A,            │ │
│ │                             │                             │ │
│ │ [☑] Customer B              │ Your outstanding balance... │ │
│ │     Amount: 89,500 THB      │                             │ │
│ │     Transactions: 3 DNs     │ [Transaction Details Table] │ │
│ │     Template: A (Day 1)     │                             │ │
│ │     Status: Pending         │ Total: 125,000 THB          │ │
│ │                             │                             │ │
│ │ [☑] Customer C              │ Payment Instructions:       │ │
│ │     Amount: 230,450 THB     │ [QR Code] [Bank Details]    │ │
│ │     ...                     │                             │ │
│ └─────────────────────────────┴─────────────────────────────┘ │
│ [ACTION BAR - GroupContainer@1.3.0, AutoLayout, H:60]        │
│ Selected: 45 emails | Total Amount: 3,250,000 THB            │
│            [Exclude Selected] [📧 Send Approved Emails]       │
└───────────────────────────────────────────────────────────────┘

[Navigation Menu - Left slide-in, W:260]
```

**Component Breakdown**:

| Area | Component | Type | Details |
|------|-----------|------|---------|
| Header | EmailApprv_Header | GroupContainer@1.3.0 AutoLayout | H:55, Nestlé Blue |
| | EmailApprv_MenuIcon | Classic/Icon@2.5.0 | Hamburger menu |
| | EmailApprv_Title | Text@0.0.51 | "Email Approval & Send" |
| Filter | EmailApprv_FilterBar | GroupContainer@1.3.0 AutoLayout | H:60 |
| | EmailApprv_DatePicker | DatePicker | Filter date, default=Today() |
| | EmailApprv_CountLabel | Text@0.0.51 | "Customers: X Pending" |
| | EmailApprv_RefreshBtn | Button@0.0.45 | Refresh data |
| | EmailApprv_AutoApproveToggle | Toggle@0.0.51 | Auto-approve setting |
| Content | EmailApprv_SplitContainer | GroupContainer@1.3.0 ManualLayout | Split 50/50 |
| | EmailApprv_DraftGallery | Gallery@2.15.0 | Left 50%, draft emails |
| | EmailApprv_PreviewPanel | GroupContainer@1.3.0 AutoLayout | Right 50%, email preview |
| Actions | EmailApprv_ActionBar | GroupContainer@1.3.0 AutoLayout | H:60, bottom bar |
| | EmailApprv_SendBtn | Button@0.0.45 | Send approved emails |
| Nav | EmailApprv_NavigationMenu | CanvasComponent | NavigationMenu component |

**Template Base**: template-table-view.yaml (CRUD operations)

**Component Patterns to Add**:
- component-gallery-pattern.yaml (draft email list)
- Custom checkbox column for manual selection
- Email preview panel with conditional visibility

**Custom Additions**:
- **Checkbox Column**: Classic/Checkbox control in gallery (Phase 2 manual selection)
- **Auto-Approve Toggle**: Modern Toggle@0.0.51 to switch between Phase 1/2
- **Email Preview**: Right panel showing full email HTML preview
- **Transaction Detail Table**: Within preview, show line items (DN/CN breakdown)
- **Selection Counter**: Dynamic count of selected emails and total amount
- **Batch Actions**: Exclude Selected, Send Approved buttons

---

## 3. Database Schema

**Data Source**: Dataverse

**From**: `DATABASE_SCHEMA.md` - Section 3 (Email Processing Log)

### Primary Entity

**Name**: `[THFinanceCashCollection]Emaillogs`

**Fields Used**:
| Field Display Name | Logical Name | Type | Notes |
|--------------------|--------------|------|-------|
| Email Log ID | cr7bb_emaillogid | Primary Key | Auto-generated |
| Customer | cr7bb_customer | Lookup → Customers | Customer reference |
| Process Date | cr7bb_processdate | Date | Today's date filter |
| Email Subject | cr7bb_emailsubject | Text(500) | Preview subject line |
| Email Template | cr7bb_emailtemplate | Choice (A, B, C, D) | Template used |
| Max Day Count | cr7bb_maxdaycount | Whole Number | Highest day count |
| Total Amount | cr7bb_totalamount | Currency | Amount owed |
| Transaction Count | cr7bb_transactioncount | Whole Number | DN count |
| Recipient Emails | cr7bb_recipientemails | Text(1000) | To: addresses |
| CC Emails | cr7bb_ccemails | Text(1000) | CC: addresses |
| Sent Date Time | cr7bb_sentdatetime | DateTime | Timestamp (null until sent) |
| Send Status | cr7bb_sendstatus | Choice | **Pending, Approved, Success, Failed** |
| Error Message | cr7bb_errormessage | Text(500) | Error details if failed |
| QR Code Included | cr7bb_qrcodeincluded | Yes/No | QR code attachment |

### Related Entities

**Customers** (`[THFinanceCashCollection]Customers`):
| Field | Logical Name | Usage |
|-------|--------------|-------|
| Customer ID | cr7bb_customerid | Lookup join |
| Customer Code | cr7bb_customercode | Display in gallery |
| Customer Name | cr7bb_customername | Display in gallery |
| Region | cr7bb_region | Filter option (future) |

**Transactions** (`[THFinanceCashCollection]Transactions`):
| Field | Logical Name | Usage |
|-------|--------------|-------|
| Transaction ID | cr7bb_transactionid | Primary key |
| Customer | cr7bb_customer | Join to Emaillog customer |
| Process Date | cr7bb_processdate | Match to today's date |
| Document Number | cr7bb_documentnumber | Show in preview table |
| Document Date | cr7bb_documentdate | Show in preview table |
| Net Due Date | cr7bb_netduedate | Show in preview table |
| Amount Local Currency | cr7bb_amountlocalcurrency | Show DN/CN amounts |
| Transaction Type | cr7bb_transactiontype | Choice (Credit Note, Debit Note) |
| Day Count | cr7bb_daycount | Show in preview table |

### Critical Syntax Patterns

**Choice Field Syntax**:
```powerfx
// Send Status Choice
cr7bb_sendstatus = 'Send Status Choice'.Pending
cr7bb_sendstatus = 'Send Status Choice'.Approved
cr7bb_sendstatus = 'Send Status Choice'.Success
cr7bb_sendstatus = 'Send Status Choice'.Failed

// Email Template Choice
cr7bb_emailtemplate = 'Email Template Choice'.A
cr7bb_emailtemplate = 'Email Template Choice'.B
cr7bb_emailtemplate = 'Email Template Choice'.C
cr7bb_emailtemplate = 'Email Template Choice'.D

// Transaction Type Choice
cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note'
cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note'
```

**Lookup Field Syntax**:
```powerfx
// Display customer name from lookup
LookUp('[THFinanceCashCollection]Customers', cr7bb_customerid = ThisItem.cr7bb_customer).cr7bb_customername

// Display customer code from lookup
LookUp('[THFinanceCashCollection]Customers', cr7bb_customerid = ThisItem.cr7bb_customer).cr7bb_customercode

// Compare lookup fields
Customer.'[THFinanceCashCollection]Customer' = _selectedEmail.cr7bb_customer
```

---

## 4. Features & Functionality

### 4.1 Filter Bar Features

**Date Picker**:
- Default: `Today()`
- Filter: Only show Emaillogs where `cr7bb_processdate = _filterDate`
- OnChange: Refresh gallery

**Customer Count**:
- Display: `CountRows(colDraftEmails) & " Pending"`
- Dynamic update when filters change

**Refresh Button**:
- Icon: "Sync"
- OnSelect: Re-query Emaillog table, refresh colDraftEmails
- Show loading spinner during refresh

**Auto-Approve Toggle**:
- Variable: `gblAutoApprove` (Boolean)
- Default: `true` (Phase 1 - auto-approve all)
- Label: "Auto-Approve: ON" or "OFF"
- Phase 1: All emails auto-selected (checkbox disabled)
- Phase 2: Manual selection enabled (checkbox clickable)

### 4.2 Draft Email Gallery

**Data Source**:
```powerfx
colDraftEmails = Filter(
    '[THFinanceCashCollection]Emaillogs',
    cr7bb_processdate = _filterDate &&
    (cr7bb_sendstatus = 'Send Status Choice'.Pending ||
     cr7bb_sendstatus = 'Send Status Choice'.Approved)
)
```

**Gallery Layout** (Template Height: 120):
- **Checkbox** (left, 40px):
  - Visible: `!gblAutoApprove` (Phase 2 only)
  - Default: `gblAutoApprove` (auto-checked in Phase 1)
  - OnCheck: Add to `colSelectedEmails`
- **Customer Info** (main area):
  - Customer Code + Name (Size 16, Bold)
  - Amount: `Text(ThisItem.cr7bb_totalamount, "$#,##0.00") & " THB"`
  - Transaction Count: `ThisItem.cr7bb_transactioncount & " DNs"`
  - Template: `"Template " & Text(ThisItem.cr7bb_emailtemplate)` + Day Count
- **Status Badge** (right, 80px):
  - Pending: Gray badge
  - Approved: Green badge
  - Icon: Checkmark if Approved

**Sorting**:
- Primary: Day Count DESC (highest day count first = most urgent)
- Secondary: Total Amount DESC (largest amounts first)

**OnSelect**:
```powerfx
Set(_selectedEmail, ThisItem);
Set(_showPreview, true)
```

### 4.3 Email Preview Panel

**Visibility**: `!IsBlank(_selectedEmail)`

**Preview Sections**:

1. **Header Info**:
   - To: `_selectedEmail.cr7bb_recipientemails`
   - CC: `_selectedEmail.cr7bb_ccemails`
   - Subject: `_selectedEmail.cr7bb_emailsubject`
   - Template: `"Template " & Text(_selectedEmail.cr7bb_emailtemplate) & " (Day " & Text(_selectedEmail.cr7bb_maxdaycount) & ")"`

2. **Transaction Detail Table** (Gallery):
   ```powerfx
   Data = Filter(
       '[THFinanceCashCollection]Transactions',
       cr7bb_customer = _selectedEmail.cr7bb_customer &&
       cr7bb_processdate = _selectedEmail.cr7bb_processdate
   )
   ```
   Columns:
   - Document Number
   - Document Date (format: "dd/MM/yyyy")
   - Net Due Date (format: "dd/MM/yyyy")
   - Amount (positive = DN, negative = CN)
   - Day Count
   - Type Badge (CN = blue, DN = red)

3. **Summary Info**:
   - CN Total: `Sum(Filter(transactions, cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note'), cr7bb_amountlocalcurrency)`
   - DN Total: `Sum(Filter(transactions, cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note'), cr7bb_amountlocalcurrency)`
   - Net Amount: `_selectedEmail.cr7bb_totalamount`

4. **Payment Instructions**:
   - QR Code: If `_selectedEmail.cr7bb_qrcodeincluded = true`
   - Bank Details: Company account info (from global variable)
   - Bill Payment Reference: "999" + Customer Code

5. **Warning Messages** (Template B/C):
   - Template B (Day 3): "⚠️ Payment today will NOT qualify for cash discount (MI)"
   - Template C (Day 4+): "⚠️ Additional MI charges will apply"

### 4.4 Action Bar

**Selection Summary**:
```powerfx
"Selected: " & CountRows(colSelectedEmails) & " emails | Total Amount: " &
Text(Sum(colSelectedEmails, cr7bb_totalamount), "$#,##0.00") & " THB"
```

**Exclude Selected Button**:
- Appearance: Secondary
- Icon: "Cancel"
- Enabled: `CountRows(colSelectedEmails) > 0`
- OnSelect:
  ```powerfx
  ForAll(
      colSelectedEmails,
      Patch(
          '[THFinanceCashCollection]Emaillogs',
          LookUp('[THFinanceCashCollection]Emaillogs', cr7bb_emaillogid = cr7bb_emaillogid),
          {cr7bb_sendstatus: 'Send Status Choice'.Failed, cr7bb_errormessage: "Manually excluded by AR team"}
      )
  );
  Remove(colDraftEmails, colSelectedEmails);
  Clear(colSelectedEmails);
  Notify("Excluded " & CountRows(colSelectedEmails) & " emails", NotificationType.Success)
  ```

**Send Approved Emails Button**:
- Appearance: Primary (Nestlé Blue)
- Icon: "Send"
- Enabled: `CountRows(colSelectedEmails) > 0 || gblAutoApprove`
- OnSelect:
  ```powerfx
  // Phase 1 (Auto-Approve): Select all Pending emails
  If(
      gblAutoApprove,
      ClearCollect(colSelectedEmails, Filter(colDraftEmails, cr7bb_sendstatus = 'Send Status Choice'.Pending))
  );

  // Update status to Approved (triggers Power Automate flow)
  ForAll(
      colSelectedEmails,
      Patch(
          '[THFinanceCashCollection]Emaillogs',
          LookUp('[THFinanceCashCollection]Emaillogs', cr7bb_emaillogid = cr7bb_emaillogid),
          {cr7bb_sendstatus: 'Send Status Choice'.Approved}
      )
  );

  // Show confirmation
  Notify(
      "Approved " & CountRows(colSelectedEmails) & " emails for sending. Power Automate will send within 5 minutes.",
      NotificationType.Success
  );

  // Clear selection and refresh
  Clear(colSelectedEmails);
  Set(_refreshTrigger, !_refreshTrigger)
  ```

---

## 5. Behavior & Logic

### 5.1 OnVisible (Screen Load)

```powerfx
// Set current screen for navigation
UpdateContext({currentScreen: "Email Approval"});

// Initialize variables
Set(_filterDate, Today());
Set(_showPreview, false);
Set(_selectedEmail, Blank());
Set(_refreshTrigger, true);

// Load auto-approve setting (default true for Phase 1)
Set(gblAutoApprove,
    If(
        IsBlank(LookUp('[THFinanceCashCollection]Settings', cr7bb_settingkey = "AutoApproveEmails").cr7bb_settingvalue),
        true,
        Value(LookUp('[THFinanceCashCollection]Settings', cr7bb_settingkey = "AutoApproveEmails").cr7bb_settingvalue)
    )
);

// Load draft emails
ClearCollect(
    colDraftEmails,
    SortByColumns(
        Filter(
            '[THFinanceCashCollection]Emaillogs',
            cr7bb_processdate = _filterDate &&
            (cr7bb_sendstatus = 'Send Status Choice'.Pending ||
             cr7bb_sendstatus = 'Send Status Choice'.Approved)
        ),
        "cr7bb_maxdaycount", SortOrder.Descending,
        "cr7bb_totalamount", SortOrder.Descending
    )
);

// Initialize selection collection
Clear(colSelectedEmails);

// Auto-select all if Phase 1
If(
    gblAutoApprove,
    ClearCollect(colSelectedEmails, colDraftEmails)
)
```

### 5.2 Reactive Data Pattern

**Gallery Items** (with refresh trigger):
```powerfx
=If(
    _refreshTrigger || !_refreshTrigger,
    SortByColumns(
        Filter(
            '[THFinanceCashCollection]Emaillogs',
            cr7bb_processdate = _filterDate &&
            (cr7bb_sendstatus = 'Send Status Choice'.Pending ||
             cr7bb_sendstatus = 'Send Status Choice'.Approved)
        ),
        "cr7bb_maxdaycount", SortOrder.Descending,
        "cr7bb_totalamount", SortOrder.Descending
    )
)
```

### 5.3 Conditional Visibility

- **Checkboxes in Gallery**: `Visible = !gblAutoApprove`
- **Preview Panel**: `Visible = !IsBlank(_selectedEmail)`
- **Exclude Button**: `Enabled = CountRows(colSelectedEmails) > 0`
- **Send Button**: `Enabled = CountRows(colSelectedEmails) > 0 || gblAutoApprove`

---

## 6. Navigation Integration

### 6.1 Navigation Collection

**Updated loadingScreen.yaml** (OnVisible):
```powerfx
ClearCollect(
    Navigation,
    Table(
        {Icon: "Home", Text: "Daily Control Center", Screen: "scnDashboard", Role: "Analyst"},
        {Icon: "MailCheck", Text: "Email Approval", Screen: "scnEmailApproval", Role: "Analyst"},
        {Icon: "Mail", Text: "Email Monitor", Screen: "scnEmailMonitor", Role: "Analyst"},
        {Icon: "People", Text: "Customer Management", Screen: "scnCustomer", Role: "Manager"},
        {Icon: "Money", Text: "Transactions", Screen: "scnTransactions", Role: "Analyst"},
        {Icon: "Settings", Text: "Settings", Screen: "scnSettings", Role: "Admin"},
        {Icon: "AddUser", Text: "Role Management", Screen: "scnRole", Role: "Admin"}
    )
)
```

### 6.2 Deep Links

**From scnDashboard**:
- Quick Action: "Review & Approve Emails" → `Navigate(scnEmailApproval)`
- Pending Emails Card OnSelect → `Navigate(scnEmailApproval)`

**From scnEmailMonitor**:
- Button: "Back to Approval" → `Navigate(scnEmailApproval)` (if today's date and Pending status)

---

## 7. Styling & Branding

### 7.1 Nestlé Brand Colors

- **Header Fill**: RGBA(0, 101, 161, 1) - Nestlé Blue
- **Primary Button**: RGBA(0, 101, 161, 1) - Nestlé Blue
- **Warning Badge**: RGBA(212, 41, 57, 1) - Nestlé Red (Day 3+)
- **Success Badge**: RGBA(0, 128, 96, 1) - Green
- **Pending Badge**: RGBA(150, 150, 150, 1) - Gray

### 7.2 Typography

- **Screen Title**: Size 25, Weight.Bold, Color White
- **Gallery Customer Name**: Size 16, Weight.Semibold
- **Gallery Details**: Size 14, Weight.Regular
- **Preview Headers**: Size 18, Weight.Bold
- **Preview Body**: Size 14, Weight.Regular

### 7.3 Modern Controls

- **Button@0.0.45**: Primary (Send), Secondary (Exclude), Subtle (Refresh)
- **Text@0.0.51**: All text labels
- **Toggle@0.0.51**: Auto-Approve switch
- **DatePicker**: Standard control (not modern)

---

## 8. Error Handling & Validation

### 8.1 Data Load Errors

```powerfx
// OnVisible error handling
If(
    IsError(colDraftEmails),
    Notify("Error loading draft emails. Please refresh.", NotificationType.Error);
    Set(_dataLoadError, true),
    Set(_dataLoadError, false)
)
```

### 8.2 Send Action Errors

```powerfx
// Send button error handling
If(
    CountRows(colSelectedEmails) = 0 && !gblAutoApprove,
    Notify("No emails selected. Please select at least one email to send.", NotificationType.Warning);
    Exit(),

    // Proceed with approval
    UpdateIf(
        colSelectedEmails,
        true,
        {cr7bb_sendstatus: 'Send Status Choice'.Approved}
    )
)
```

### 8.3 Missing Data Warnings

- **No QR Code**: Show warning icon in preview: "⚠️ QR code not available"
- **Missing Recipient Email**: Show error: "❌ Customer email missing - cannot send"
- **Missing CC Email**: Show warning: "⚠️ Sales email missing - email will send without CC"

---

## 9. Success Criteria

### 9.1 Functional Requirements

- ✅ Load all Pending/Approved emails for selected date
- ✅ Display customer info, amount, transaction count, template type
- ✅ Preview full email content including transaction table
- ✅ Phase 1: Auto-approve all emails with single click
- ✅ Phase 2: Manual selection via checkboxes
- ✅ Update email status to Approved (triggers Power Automate)
- ✅ Exclude selected emails from sending

### 9.2 Performance Requirements

- ✅ Load <100 draft emails within 2 seconds
- ✅ Preview panel updates <500ms when clicking gallery item
- ✅ Send approval action completes within 5 seconds
- ✅ Reactive refresh updates gallery without full reload

### 9.3 User Experience Requirements

- ✅ Clear visual distinction between Pending/Approved status
- ✅ Selection counter shows total emails and amount
- ✅ Preview panel shows complete email as customer will receive it
- ✅ Confirmation notification after approving emails
- ✅ Error handling for missing data (email, QR code)

---

## 10. Testing Scenarios

### 10.1 Phase 1 Testing (Auto-Approve)

1. **Scenario**: AR team opens screen at 8:15 AM
   - Expected: See all 45 Pending emails, auto-approve toggle ON
   - Action: Click "Send Approved Emails"
   - Expected: All 45 emails approved, notification shows success

2. **Scenario**: AR team excludes 3 customers before sending
   - Action: Select 3 emails, click "Exclude Selected"
   - Expected: 3 emails marked Failed with "Manually excluded" message
   - Action: Click "Send Approved Emails"
   - Expected: Remaining 42 emails approved

### 10.2 Phase 2 Testing (Manual Approval)

1. **Scenario**: AR team reviews emails one-by-one
   - Action: Toggle auto-approve OFF
   - Expected: All checkboxes unchecked, Send button disabled
   - Action: Check 10 emails
   - Expected: Selection counter shows "10 emails | Total: 850,000 THB"
   - Action: Click "Send Approved Emails"
   - Expected: Only 10 selected emails approved

2. **Scenario**: AR team previews high-risk customer
   - Action: Click Customer Z (Day 7, 500,000 THB)
   - Expected: Preview shows Template C, warning message, transaction breakdown
   - Action: Uncheck Customer Z
   - Expected: Customer Z not included in send batch

### 10.3 Error Scenarios

1. **Scenario**: Customer has no email address
   - Expected: Gallery row shows "❌ Email missing" warning
   - Action: Try to approve
   - Expected: Error notification, email skipped

2. **Scenario**: Power Automate flow is disabled
   - Action: Approve emails
   - Expected: Emails marked Approved, but remain in gallery
   - Note: AR team can manually trigger flow or wait for scheduled run

---

## 11. Future Enhancements

### Phase 3 (Post-Production)

1. **Email Template Preview**: Show actual HTML email preview (not just text)
2. **Bulk Edit**: Change template type before sending (A → B override)
3. **Scheduled Send**: Approve now, send at specific time (e.g., 3:00 PM)
4. **Filter by Region**: Filter draft emails by customer region
5. **Search**: Search customers by name/code within draft list
6. **Approval History**: Track who approved which emails (audit log)
7. **Mobile Support**: Approve emails from mobile device (responsive layout)

---

## Implementation Notes

**For AI Assistant (powerapp-screen-creator)**:

1. **Template Base**: Start with template-table-view.yaml, modify for split-view layout
2. **Critical Properties**:
   - Gallery must use ManualLayout (not AutoLayout) for checkbox overlay
   - Preview panel must be conditional: `Visible = !IsBlank(_selectedEmail)`
   - NavigationMenu: `navItems: =Navigation`, `navSelected: =currentScreen`
3. **YAML Syntax**: All colons in formulas must use block scalar `|-`
4. **Choice Fields**: Use full label text: `'Send Status Choice'.Pending`
5. **Lookup Fields**: Use table reference syntax for comparison
6. **Width Properties**: ALL Text controls must have Width property specified

**Testing Checklist**:
- [ ] Load screen with Pending emails
- [ ] Toggle auto-approve ON/OFF
- [ ] Select multiple emails via checkbox
- [ ] Preview email content
- [ ] Approve selected emails (status → Approved)
- [ ] Exclude emails (status → Failed)
- [ ] Navigation menu works correctly
- [ ] Refresh button reloads data
- [ ] Date picker filters by date

---

**End of Description File**
