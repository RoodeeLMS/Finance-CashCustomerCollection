# Screen Description: scnEmailMonitor

**Created**: 2025-01-11
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-table-view.yaml
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
Provides detailed view and management of all email communications sent by the Collections Engine, allowing AR team to review, filter, investigate failures, and manually resend emails.

**Who uses it**:
- **AR Analyst** - Reviews sent emails, investigates failures, resends failed emails
- **AR Manager** - Monitors email delivery success rates, reviews error patterns
- **AR Admin** - Manages email logs, deletes test records

**User Goals**:
- Review all emails sent to customers for a specific date
- Investigate and resend failed emails
- Preview email content before manual resend
- Filter by customer, status, template type
- Maintain audit trail of all communications

---

## 2. Design Mockup

**Visual Layout**:

```
┌───────────────────────────────────────────────────────────────┐
│ [HEADER - GroupContainer@1.3.0, AutoLayout, H:55]            │
│ ◰ Menu  Email Monitor                                        │
├───────────────────────────────────────────────────────────────┤
│ [CONTENT - GroupContainer@1.3.0, ManualLayout]               │
│                                                               │
│ [FILTER SECTION - GroupContainer, AutoLayout, H:140]         │
│ ┌───────────────────────────────────────────────────────────┐ │
│ │ Date: [DatePicker]  Status: [Dropdown: All/Success/Failed]││
│ │ Customer: [ComboBox: Search...]  Template: [Dropdown]    ││
│ │ [Clear Filters] [Apply Filters]  Showing: 85 results     ││
│ └───────────────────────────────────────────────────────────┘ │
│                                                               │
│ [EMAIL LIST - Gallery@2.15.0, H:Parent.Height-350]           │
│ ┌───────────────────────────────────────────────────────────┐ │
│ │ ✓ 10/01 08:35  | Charoen Pokphand | Success | ฿125,450 | A││
│ │ ⚠ 10/01 08:35  | Thai Beverage    | Failed  | ฿89,200  | B││
│ │ ⏳ 10/01 08:40  | Central Foods    | Pending | ฿45,800  | A││
│ │ [Row Actions: View Detail | Resend]                       ││
│ └───────────────────────────────────────────────────────────┘ │
│                                                               │
│ [PREVIEW PANEL - Visible when row selected, H:280]           │
│ ┌───────────────────────────────────────────────────────────┐ │
│ │ Email Details: Thai Beverage Ltd.                         ││
│ │ ───────────────────────────────────────────────────────   ││
│ │ To: accounts@thaibev.com                                  ││
│ │ CC: sales.rep@nestle.com; ar.backup@nestle.com           ││
│ │ Subject: Payment Reminder - Outstanding Balance          ││
│ │ Sent: 10/01/2025 08:35:12 | Status: Failed               ││
│ │ Error: SMTP Connection Timeout                           ││
│ │ ───────────────────────────────────────────────────────   ││
│ │ [✉️ Resend Email] [📄 Export Log] [🗑️ Delete (Admin)]   ││
│ └───────────────────────────────────────────────────────────┘ │
│                                                               │
└───────────────────────────────────────────────────────────────┘

[Navigation Menu - Left slide-in, W:260]
```

**Component Breakdown**:

| Area | Component | Type | Details |
|------|-----------|------|---------|
| Header | EmailMon_Header | GroupContainer@1.3.0 AutoLayout | H:55, Nestlé Blue, white text |
| | EmailMon_MenuIcon | Classic/Icon@2.5.0 | Hamburger icon |
| | EmailMon_Title | Text@0.0.51 | "Email Monitor", Size 25 |
| Content | EmailMon_Content | GroupContainer@1.3.0 ManualLayout | Main content area |
| Filters | EmailMon_FilterSection | GroupContainer@1.3.0 AutoLayout | H:140, filter controls |
| | EmailMon_DatePicker | DatePicker@0.0.46 | Filter by date |
| | EmailMon_StatusDropdown | DropDown@0.0.45 | All/Success/Failed/Pending |
| | EmailMon_CustomerCombo | ComboBox@0.0.51 | Customer search |
| | EmailMon_TemplateDropdown | DropDown@0.0.45 | All/A/B/C/D |
| | EmailMon_ApplyBtn | Button@0.0.45 | Apply filters |
| | EmailMon_ClearBtn | Button@0.0.45 | Clear filters |
| Gallery | EmailMon_EmailGallery | Gallery@2.15.0 | Email log list |
| Preview | EmailMon_PreviewPanel | GroupContainer@1.3.0 AutoLayout | H:280, email details |
| | EmailMon_ResendBtn | Button@0.0.45 | Resend email |
| | EmailMon_ExportBtn | Button@0.0.45 | Export log |
| | EmailMon_DeleteBtn | Button@0.0.45 | Delete log (admin only) |
| Nav | EmailMon_NavigationMenu | CanvasComponent | NavigationMenu component |

**Template Base**: template-table-view.yaml

**Component Patterns to Add**:
- component-gallery-pattern.yaml (email list gallery)

**Custom Additions**:
- Preview panel with conditional visibility (visible when _selectedEmail is not blank)
- Status icon conditional coloring (Success=green, Failed=red, Pending=gray)
- Date filter initialized from global variable gblFilterDate
- Status filter initialized from global variable gblEmailStatusFilter
- Gallery TemplateSize: 70px for multi-line email rows

---

## 3. Database Schema

**Data Source**: Dataverse

**From**: `Documentation/DATABASE_SCHEMA.md` and `FIELD_NAME_REFERENCE.md`

### Primary Entity

**Name**: `[THFinanceCashCollection]Emaillogs`

**Fields/Columns Used**:
| Field Display Name | Logical Name | Type | Notes |
|--------------------|--------------|------|-------|
| Email Log ID | cr7bb_emaillogid | Primary Key | Auto-generated |
| Customer | cr7bb_customer | Lookup → [THFinanceCashCollection]Customers | Access: `Customer.'[THFinanceCashCollection]Customer'` |
| Process Date | cr7bb_processdate | DateTime | Date of email send |
| Email Subject | cr7bb_emailsubject | Text(500) | Subject line |
| Total Amount | cr7bb_totalamount | Currency | Amount owed |
| Send Status | cr7bb_sendstatus | Choice (Success, Failed, Pending) | Choice: 'Send Status Choice'.Success |
| Sent Date Time | cr7bb_sentdatetime | DateTime | When email was sent |
| Recipient Emails | cr7bb_recipientemails | Text(1000) | To: addresses |
| CC Emails | cr7bb_ccemails | Text(1000) | CC: addresses |
| Error Message | cr7bb_errormessage | Text(500) | Error details if failed |

### Related Entities (for Lookups)

**Entity**: `[THFinanceCashCollection]Customers`
**Used For**: Customer lookup dropdown, display customer name
**Fields Needed**:
- Customer Name (cr7bb_customername) - Text(255) - Display in gallery
- Customer Code (cr7bb_customercode) - Text(20) - Search filter
- Customer ID (cr7bb_customerid) - Primary Key - Lookup comparison

### Choice Field Syntax

**CRITICAL**: Use full choice label text, not short codes

```powerfx
// ✅ CORRECT - Send Status
cr7bb_sendstatus = 'Send Status Choice'.Success
cr7bb_sendstatus = 'Send Status Choice'.Failed
cr7bb_sendstatus = 'Send Status Choice'.Pending

// ❌ WRONG
cr7bb_sendstatus = 'Send Status Choice'.Sent  // Does not exist
```

### Lookup Field Syntax

```powerfx
// ✅ Access customer name from EmailLog
ThisItem.Customer.'[THFinanceCashCollection]Customer'

// ✅ Filter by customer lookup
Filter('[THFinanceCashCollection]Emaillogs',
    Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer'
)
```

---

## 4. Data & Collections

### Collections to Load

**Collection 1**:
- **Name**: `colEmailLogs`
- **Source**: `Filter('[THFinanceCashCollection]Emaillogs', DateValue(cr7bb_sentdatetime) = _filterDate)`
- **Sort**: `SortByColumns(colEmailLogs, "cr7bb_sentdatetime", SortOrder.Descending)`
- **When**: OnVisible and after filter changes
- **Purpose**: Filtered email logs for display in gallery

**Collection 2**:
- **Name**: `colCustomers`
- **Source**: `Sort('[THFinanceCashCollection]Customers', cr7bb_customername, SortOrder.Ascending)`
- **When**: OnVisible
- **Purpose**: Customer dropdown filter options

### Gallery Data Source

**Items**:
```powerfx
=If(
    _refreshTrigger || !_refreshTrigger,
    SortByColumns(
        Filter(
            '[THFinanceCashCollection]Emaillogs',
            DateValue(cr7bb_sentdatetime) = _filterDate &&
            (_statusFilter = "All" ||
             (_statusFilter = "Success" && cr7bb_sendstatus = 'Send Status Choice'.Success) ||
             (_statusFilter = "Failed" && cr7bb_sendstatus = 'Send Status Choice'.Failed) ||
             (_statusFilter = "Pending" && cr7bb_sendstatus = 'Send Status Choice'.Pending)) &&
            (IsBlank(_selectedCustomer) ||
             Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer')
        ),
        "cr7bb_sentdatetime",
        SortOrder.Descending
    )
)
```

---

## 5. Variables & Context

### Screen Variables (Set in OnVisible)

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `_showMenu` | Boolean | false | Navigation menu visibility |
| `_filterDate` | Date | `If(!IsBlank(gblFilterDate), gblFilterDate, Today())` | Date filter |
| `_statusFilter` | Text | `If(!IsBlank(gblEmailStatusFilter), gblEmailStatusFilter, "All")` | Status filter |
| `_selectedCustomer` | Record | Blank() | Customer filter |
| `_selectedEmail` | Record | Blank() | Selected email for preview panel |
| `_refreshTrigger` | Boolean | false | Force gallery refresh |

### Global Variables (Read from other screens)

| Variable | Type | Source | Purpose |
|----------|------|--------|---------|
| `gblFilterDate` | Date | scnDashboard | Initial date filter |
| `gblEmailStatusFilter` | Text | scnDashboard | Initial status filter ("Failed") |
| `gblSelectedEmail` | Record | scnDashboard | Pre-selected email to view |

### Context Variables

| Variable | Type | Scope | Purpose |
|----------|------|-------|---------|
| `currentScreen` | Text | Screen | Navigation tracking ("Email Monitor") |

---

## 6. Features & Behaviors

### Feature 1: Date & Status Filtering

**User Flow**:
1. User selects date from DatePicker (default: gblFilterDate or Today)
2. User selects status from dropdown (All/Success/Failed/Pending)
3. User clicks "Apply Filters"
4. Gallery refreshes with filtered results

**Implementation**:
- DatePicker OnChange: `Set(_filterDate, Self.SelectedDate)`
- Status Dropdown OnChange: `Set(_statusFilter, Self.Selected.Value)`
- Apply Filters Button OnSelect: `Set(_refreshTrigger, !_refreshTrigger)`
- Gallery Items formula includes filter conditions (see Section 4)

**Edge Cases**:
- If no results, show message: "No emails found for this date/filter"
- Clear Filters resets to: Today's date, "All" status, no customer selected

### Feature 2: Customer Search Filter

**User Flow**:
1. User types customer name in ComboBox
2. ComboBox shows matching customers (searchable)
3. User selects customer
4. Gallery filters to show emails for that customer only

**Implementation**:
- ComboBox Items: `colCustomers`
- ComboBox IsSearchable: `true`
- ComboBox OnChange:
  ```powerfx
  Set(_selectedCustomer,
      If(CountRows(Self.SelectedItems) > 0,
         First(Self.SelectedItems),
         Blank()))
  ```
- Gallery filter includes customer comparison (see Section 4)

**Edge Cases**:
- If customer blank, show all customers
- ComboBox uses ComboBoxDataField@1.5.0 children for field mapping

### Feature 3: Email Preview Panel

**User Flow**:
1. User clicks row in gallery (or clicks "View" button)
2. Preview panel becomes visible below gallery
3. Panel shows email details: To, CC, Subject, Sent time, Status, Error message
4. Action buttons enabled based on status and role

**Implementation**:
- Gallery OnSelect: `Set(_selectedEmail, ThisItem)`
- Preview Panel Visible: `!IsBlank(_selectedEmail)`
- Preview fields bound to: `_selectedEmail.cr7bb_fieldname`
- Resend button enabled if: `_selectedEmail.cr7bb_sendstatus = 'Send Status Choice'.Failed`
- Delete button visible if: `gblUserRole = "Admin"`

**Edge Cases**:
- If no email selected, panel hidden
- If status = Pending, show message "Email sending in progress"
- If status = Success, Resend button disabled

### Feature 4: Resend Failed Email

**User Flow**:
1. User selects failed email from gallery
2. User reviews email details in preview panel
3. User clicks "✉️ Resend Email" button
4. Confirmation dialog appears: "Resend email to [customer name]?"
5. If confirmed, trigger Power Automate flow to resend
6. Show notification: "Email resend initiated"

**Implementation**:
- Resend Button OnSelect:
  ```powerfx
  If(
      Confirm("Resend email to " & _selectedEmail.Customer.'[THFinanceCashCollection]Customer' & "?"),
      /* Trigger Power Automate flow - TO BE IMPLEMENTED */
      Notify("Email resend initiated. Check status in a few minutes.", NotificationType.Information);
      Set(_selectedEmail, Blank());
      Set(_refreshTrigger, !_refreshTrigger)
  )
  ```
- Button DisplayMode:
  ```powerfx
  If(_selectedEmail.cr7bb_sendstatus = 'Send Status Choice'.Failed,
     DisplayMode.Edit,
     DisplayMode.Disabled)
  ```

**Edge Cases**:
- If Power Automate flow not configured, show warning message
- If resend fails, keep original error message
- Resend increments retry count (handled by Power Automate)

### Feature 5: Export & Delete Actions

**User Flow (Export)**:
1. User selects email from gallery
2. User clicks "📄 Export Log" button
3. System exports email details to CSV or JSON

**User Flow (Delete - Admin only)**:
1. Admin selects email from gallery
2. Admin clicks "🗑️ Delete" button
3. Confirmation dialog: "Delete this email log? Cannot be undone."
4. If confirmed, remove record from Dataverse

**Implementation**:
- Export Button OnSelect: `Notify("Export functionality coming soon", NotificationType.Information)`
- Delete Button OnSelect:
  ```powerfx
  If(
      Confirm("Delete this email log? This action cannot be undone."),
      Remove('[THFinanceCashCollection]Emaillogs', _selectedEmail);
      Notify("Email log deleted", NotificationType.Warning);
      Set(_selectedEmail, Blank());
      Set(_refreshTrigger, !_refreshTrigger)
  )
  ```
- Delete Button Visible: `gblUserRole = "Admin"`

**Edge Cases**:
- Export shows "Coming soon" notification (future enhancement)
- Delete requires Admin role
- Delete requires confirmation to prevent accidents

---

## 7. Navigation & Integration

### Navigation Into This Screen

**From scnDashboard**:
1. **"📧 Review Emails" button**:
   - Sets: `gblFilterDate = _selectedDate`
   - Navigation: `Navigate(scnEmailMonitor)`
   - Result: Shows all emails for that date

2. **"⚠️ Failed (X)" button**:
   - Sets: `gblFilterDate = _selectedDate`, `gblEmailStatusFilter = "Failed"`
   - Navigation: `Navigate(scnEmailMonitor)`
   - Result: Shows only failed emails for that date

3. **"View" button in Activity Gallery**:
   - Sets: `gblSelectedEmail = ThisItem`
   - Navigation: `Navigate(scnEmailMonitor)`
   - Result: Opens with that email pre-selected in preview panel

### Navigation Out of This Screen

**Via NavigationMenu**:
- User clicks menu icon → Opens navigation menu
- User selects destination screen from menu
- Standard navigation pattern (same as all screens)

**Back to Dashboard**:
- Navigation menu → "Daily Control Center"

---

## 8. Styling & Branding

### Nestlé Brand Colors

- **Nestlé Blue**: RGBA(0, 101, 161, 1) - Header, primary buttons
- **Nestlé Red**: RGBA(212, 41, 57, 1) - Delete button, error indicators
- **Oak Brown**: RGBA(100, 81, 61, 1) - Secondary buttons
- **Success Green**: RGBA(16, 124, 16, 1) - Success status
- **Warning Orange**: RGBA(255, 185, 0, 1) - Warning/pending status
- **Error Red**: RGBA(168, 0, 0, 1) - Failed status

### Typography

- **Font**: Lato (primary), Segoe UI (fallback)
- **Header Title**: Size 25, Weight.Medium, White
- **Section Headers**: Size 16, Weight.Bold, Black
- **Body Text**: Size 14, Weight.Semibold/Regular, Black
- **Labels**: Size 12-14, Weight.Semibold, Gray

### Status Badge Colors

**Gallery Status Badge**:
```powerfx
Fill: =If(
    ThisItem.cr7bb_sendstatus = 'Send Status Choice'.Success,
    RGBA(16, 124, 16, 0.1),
    If(ThisItem.cr7bb_sendstatus = 'Send Status Choice'.Failed,
       RGBA(168, 0, 0, 0.1),
       RGBA(96, 94, 92, 0.1)))

FontColor: =If(
    ThisItem.cr7bb_sendstatus = 'Send Status Choice'.Success,
    RGBA(16, 124, 16, 1),
    If(ThisItem.cr7bb_sendstatus = 'Send Status Choice'.Failed,
       RGBA(168, 0, 0, 1),
       RGBA(96, 94, 92, 1)))
```

**Status Icons**:
- Success: Icon.CheckBadge (green)
- Failed: Icon.Warning (red)
- Pending: Icon.Clock (gray)

---

## 9. Error Handling

### Scenario 1: No Emails Found

**Trigger**: Gallery returns 0 results after filtering
**User Experience**: Show message in gallery empty state
**Message**: "No emails found for selected date and filters. Try adjusting filters or selecting a different date."

### Scenario 2: Resend Failed Email Error

**Trigger**: Power Automate flow fails during resend
**User Experience**: Show error notification
**Message**: "Failed to resend email. Please contact support if issue persists."
**Action**: Keep email in Failed status, increment retry count

### Scenario 3: Customer Lookup Missing

**Trigger**: Email log has null or invalid customer lookup
**User Experience**: Display "Unknown Customer" in gallery
**Formula**:
```powerfx
Text: =If(
    IsBlank(ThisItem.Customer.'[THFinanceCashCollection]Customer'),
    "Unknown Customer",
    ThisItem.Customer.'[THFinanceCashCollection]Customer'
)
```

### Scenario 4: Date Filter in Future

**Trigger**: User selects date after today
**User Experience**: Show warning, disable Apply Filters
**Message**: "Cannot filter emails for future dates"
**Validation**: `_filterDate <= Today()`

---

## 10. Testing Checklist

### Functional Tests

- [ ] Date filter correctly filters emails by cr7bb_sentdatetime
- [ ] Status dropdown filters to Success/Failed/Pending
- [ ] Customer ComboBox filters to specific customer
- [ ] Clear Filters resets all filters to defaults
- [ ] Gallery displays correct columns: Icon, DateTime, Customer, Status, Amount
- [ ] Gallery sorts by cr7bb_sentdatetime descending (most recent first)
- [ ] Clicking row populates preview panel with email details
- [ ] Preview panel shows: To, CC, Subject, Status, Error message
- [ ] Resend button enabled only for Failed status
- [ ] Resend confirmation dialog appears
- [ ] Delete button visible only for Admin role
- [ ] Delete confirmation dialog appears
- [ ] Navigation menu opens/closes correctly
- [ ] Screen initializes with gblFilterDate if passed
- [ ] Screen initializes with gblEmailStatusFilter if passed
- [ ] Screen pre-selects gblSelectedEmail if passed

### Data Validation Tests

- [ ] Choice field syntax correct: 'Send Status Choice'.Success/Failed/Pending
- [ ] Lookup field syntax correct: Customer.'[THFinanceCashCollection]Customer'
- [ ] Gallery handles blank customer lookup gracefully
- [ ] Gallery handles missing error messages
- [ ] Date comparison works correctly (DateValue vs DateTime)
- [ ] Currency formatting displays correctly for cr7bb_totalamount

### UI/UX Tests

- [ ] Status badges color-coded correctly (green/red/gray)
- [ ] Status icons display correctly (CheckBadge/Warning/Clock)
- [ ] Filter section height: 140px
- [ ] Gallery TemplateSize: 70px
- [ ] Preview panel height: 280px
- [ ] All text uses Lato font
- [ ] Header uses Nestlé Blue background
- [ ] Buttons use correct Nestlé brand colors

### Performance Tests

- [ ] Gallery loads 100+ emails without lag
- [ ] Filter operations complete in <2 seconds
- [ ] Gallery scrolling smooth
- [ ] Preview panel updates instantly on row click

---

## 11. Future Enhancements

1. **Email Body Preview**: Display full HTML email content in preview panel
2. **Export to Excel**: Download email log data to Excel file
3. **Bulk Resend**: Select multiple failed emails and resend in batch
4. **Email Templates**: Preview A/B/C/D templates before sending
5. **Attachments Download**: Download QR codes and PDFs from email logs
6. **Advanced Search**: Full-text search across subject and body
7. **Date Range Filter**: Select date range instead of single date
8. **Pagination**: Add page controls for large result sets (20 per page)
9. **Email Status History**: Show retry attempts and status changes over time
10. **Performance Metrics**: Show delivery success rate, average send time

---

## 12. Implementation Notes

### For Screen Creator Subagent

**Template**: Start with template-table-view.yaml

**Key Modifications**:
1. Replace table with Gallery@2.15.0 (TemplateSize: 70px)
2. Add filter section at top (GroupContainer@1.3.0 AutoLayout, H:140)
3. Add preview panel at bottom (GroupContainer@1.3.0 AutoLayout, H:280, Visible: conditional)
4. Gallery Items formula must include all filter conditions
5. Use reactive data pattern: `If(_refreshTrigger || !_refreshTrigger, Filter(...))`
6. Initialize from global variables: gblFilterDate, gblEmailStatusFilter, gblSelectedEmail

**Critical Syntax Patterns**:
1. **Choice Field**: `'Send Status Choice'.Success` (NOT .Sent)
2. **Lookup Field**: `Customer.'[THFinanceCashCollection]Customer'` (NOT .cr7bb_customerid)
3. **Date Comparison**: `DateValue(cr7bb_sentdatetime) = _filterDate`
4. **NavigationMenu**: `navItems: =Navigation`, `navSelected: =currentScreen`

**Data Source**: Dataverse table `[THFinanceCashCollection]Emaillogs`

**YAML Syntax**:
- Text with colons MUST use block scalar `|-`
- ComboBox@0.0.51 requires ComboBoxDataField@1.5.0 children
- LayoutMinHeight and LayoutMinWidth MUST be set for AutoLayout containers

---

**End of Description**
