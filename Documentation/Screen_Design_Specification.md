# Screen Design Specification
## Nestlé Finance Cash Customer Collection System

**Version:** 1.0
**Date:** 2025-01-10
**Author:** System Design Team

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Navigation Architecture](#navigation-architecture)
3. [Screen Specifications](#screen-specifications)
   - [Daily Control Center](#1-daily-control-center-scndailycontrolcenter)
   - [Email Monitor](#2-email-monitor-scnemailmonitor)
   - [Customer Management](#3-customer-management-scncustomer)
   - [Transaction View](#4-transaction-view-scntransactions)
   - [Settings](#5-settings-scnsettings)
4. [Common Components](#common-components)
5. [Data Flow](#data-flow)
6. [User Roles & Permissions](#user-roles--permissions)
7. [Technical Standards](#technical-standards)

---

## System Overview

### Purpose
Automated Accounts Receivable (AR) collections system that processes SAP data daily and sends personalized payment reminder emails to ~100 cash customers.

### Core Business Functions
1. **Daily Processing**: Import SAP data, apply FIFO logic, generate emails
2. **Monitoring**: Track email delivery, system status, and exceptions
3. **Customer Management**: Maintain customer master data
4. **Transaction Review**: View and manage AR transactions
5. **Reporting**: Generate audit reports and analytics

### Technology Stack
- **Platform**: Microsoft Power Apps (Canvas App)
- **Data Source**: Microsoft Dataverse
- **Integration**: Power Automate (Collections Engine)
- **Storage**: SharePoint (QR codes, files)
- **Email**: Office 365

---

## Navigation Architecture

### Primary Navigation
```
┌─────────────────────────────────────────┐
│  Hamburger Menu (All Screens)           │
├─────────────────────────────────────────┤
│  📊 Daily Control Center (Dashboard)    │ ← Home/Default
│  📧 Email Monitor                        │
│  👥 Customer Management                  │
│  💰 Transactions                         │
│  ⚙️  Settings                            │
│  📄 Reports                              │
│  ℹ️  Help & Documentation                │
└─────────────────────────────────────────┘
```

### Navigation Component
- **Type**: Slide-out menu from left
- **Width**: 260px
- **Trigger**: Hamburger icon (all screens)
- **Behavior**: Overlay with semi-transparent backdrop
- **State Management**: `_showMenu` variable

### Breadcrumb Navigation
- Format: `Home > Section > Subsection`
- Clickable links to parent levels
- Current page highlighted in Nestlé Blue

---

## Screen Specifications

---

## 1. Daily Control Center (`scnDailyControlCenter`)

### Purpose
Primary dashboard for AR team to monitor daily automation status, system health, and take quick actions.

### User Story
> "As an AR Analyst, I need to see at a glance whether today's email run completed successfully, how many emails were sent/failed, and quickly access any customers requiring attention."

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Daily Control Center                    [User Profile]      │ ← Header (55px, Nestlé Blue)
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────── DATE SELECTOR ─────────────────────┐   │
│  │  Audit Date Selection                    [↻ Refresh]     │   │
│  │  View Date: [◄ Previous] [2025-01-10 (Today)] [Next ►]  │   │
│  │                                    [Today] [📅 Pick Date] │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌───────────────────── SYSTEM STATUS ─────────────────────┐   │
│  │  System Status - 10/01/2025                             │   │
│  │                                                          │   │
│  │  ✓ SAP Import                    📧 Email Engine        │   │
│  │    Completed at 08:30              85 sent, 2 failed    │   │
│  │    1,245 transactions processed    3 customers skipped  │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌───────────────────── QUICK ACTIONS ──────────────────────┐   │
│  │  [📧 Review Emails] [⚠️ Failed (2)] [🔍 Customers]       │   │
│  │  [📊 Transactions] [📄 Export Report]                    │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌────────────────────── ACTIVITY ──────────────────────────┐   │
│  │  Activity - 10/01/2025 (87 emails)                       │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │ ✓ Email Sent to Charoen Pokphand Foods   08:35:12  │  │   │
│  │  │ ⚠ Email Failed to Thai Beverage           08:35:08  │  │   │
│  │  │ ✓ Email Sent to Central Retail Corp       08:35:05  │  │   │
│  │  │ ... (show 10 most recent)                          │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Sections

#### 1.1 Date Selector Section
**Purpose**: Allow AR team to audit historical dates or view today's run

**Controls**:
- **Audit Date Selection** (Title)
- **Refresh Button**: Reload all data for selected date
- **Previous Day**: Navigate to previous date
- **Date Display**: Shows selected date with "(Today)" indicator
  - Format: `dd/mm/yyyy` (Thai locale)
  - Highlight if different from today
- **Next Day**: Navigate forward (disabled if today)
- **Today Button**: Quick return to today (green if already today)
- **Pick Date**: Open modal calendar picker

**Behavior**:
- Navigation updates `_selectedDate` variable
- Triggers data refresh via `_refreshTrigger`
- All cards below update to show selected date's data

**Data Sources**: None (UI only)

#### 1.2 System Status Card
**Purpose**: Display health of two critical automated processes

**Indicators**:

**SAP Import Status**:
- **Icon**:
  - ✓ Green = Completed
  - ✗ Red = Failed
  - 🕐 Gray = Pending/Not Run
- **Status Text**: "Completed at 08:30" or "Failed" or "No run recorded"
- **Records Processed**: "1,245 transactions processed"
- **Data Source**: `[THFinanceCashCollection]Process Logs`
  - Filter: `cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")`
  - Field: `cr7bb_status` (Text: "Completed", "Failed", "Running")
  - Field: `cr7bb_recordsprocessed` (Number)

**Email Engine Status**:
- **Icon**:
  - ✓ Green = All sent successfully
  - ⚠ Yellow = Some failures
  - 🕐 Gray = Not run
- **Status Text**: "85 sent, 2 failed" or "No emails sent"
- **Skipped Count**: "3 customers skipped (CN > DN)" if > 0
- **Data Source**: `[THFinanceCashCollection]Emaillogs`
  - Filter: `DateValue(cr7bb_sentdatetime) = _selectedDate`
  - Count by: `cr7bb_sendstatus` (Choice: Sent, Failed, Skipped)

**Reactive Formulas**: Uses `With()` statements referencing `_refreshTrigger`

#### 1.3 Quick Actions Card
**Purpose**: One-click access to common tasks

**Buttons**:

1. **📧 Review Emails**
   - Navigate to Email Monitor screen
   - Pass selected date via `gblFilterDate`
   - Shows all emails for that date

2. **⚠️ Failed (X)**
   - Show count of failed emails in button text
   - Red background if failures > 0, gray if 0
   - Disabled if no failures
   - Navigate to Email Monitor filtered to "Failed" status
   - Sets `gblEmailStatusFilter = "Failed"`

3. **🔍 Customers**
   - Navigate to Customer Management screen
   - General customer lookup/editing

4. **📊 Transactions**
   - Navigate to Transaction View
   - Pass selected date for filtering

5. **📄 Export Report**
   - Generate daily audit report (PDF/Excel)
   - Currently: Show "Coming soon" notification

#### 1.4 Activity Summary Card
**Purpose**: Quick scan of recent email activity for selected date

**Header**: "Activity - dd/mm/yyyy (X emails)"
- Shows total count of emails for date

**Gallery** (10 items, scrollable):
- **Template Height**: 70px
- **Columns**:
  - **Icon** (40px): Status-based
    - ✓ Green = Sent
    - ⚠ Red = Failed
    - 📤 Gray = Skipped
  - **Activity Text**: "Email [Status] to [Customer Name]"
  - **Timestamp**: "hh:mm:ss" (Thai locale)
  - **Status Badge**: Colored text (Sent/Failed/Skipped)
  - **View Button**: Navigate to detailed email log

**Data Source**:
```powerfx
FirstN(
    Sort(
        Filter(
            '[THFinanceCashCollection]Emaillogs',
            DateValue(cr7bb_sentdatetime) = _selectedDate
        ),
        cr7bb_sentdatetime,
        SortOrder.Descending
    ),
    10
)
```

**Choice Field Syntax**:
- Comparison: `cr7bb_sendstatus = 'Send Status Choice'.Sent`
- Display: `Text(cr7bb_sendstatus)`

### Variables Used
- `_selectedDate` (Date): Currently viewed date
- `_refreshTrigger` (Boolean): Toggle to force data reload
- `_showMenu` (Boolean): Navigation menu visibility
- `_showDatePicker` (Boolean): Modal calendar visibility
- `currentScreen` (Text): "Daily Control Center"

### Performance Considerations
- All data queries are reactive (recalculate on `_refreshTrigger` change)
- No collections stored in OnVisible (except initial load)
- Gallery queries directly from Dataverse with filters
- Email stats calculated inline using `With()` for performance

---

## 2. Email Monitor (`scnEmailMonitor`)

### Purpose
Detailed view and management of all email communications sent by the system.

### User Story
> "As an AR Analyst, I need to review all emails sent to customers, investigate failures, resend emails manually, and verify email content before it goes out."

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Email Monitor                           [User Profile]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────── FILTERS ──────────────────────────┐     │
│  │  Date: [DD/MM/YYYY]  Status: [All/Sent/Failed/Skipped] │     │
│  │  Customer: [Search...] Template: [All/A/B/C/D]         │     │
│  │  [Clear Filters] [🔍 Search]  Showing: 85 results      │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌───────────────────── EMAIL LIST ────────────────────────┐    │
│  │ ┌────┬──────────────┬───────────┬────────┬──────────┐   │    │
│  │ │ ✓  │ 10/01 08:35  │ Charoen   │ Sent   │ [View]   │   │    │
│  │ │    │              │ Pokphand  │        │ [Resend] │   │    │
│  │ ├────┼──────────────┼───────────┼────────┼──────────┤   │    │
│  │ │ ⚠  │ 10/01 08:35  │ Thai Bev  │ Failed │ [View]   │   │    │
│  │ │    │              │           │        │ [Resend] │   │    │
│  │ └────┴──────────────┴───────────┴────────┴──────────┘   │    │
│  │ [< Prev] Page 1 of 5 [Next >]                           │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌───────────────── EMAIL PREVIEW PANEL ───────────────────┐    │
│  │  [Email Details for: Thai Beverage Ltd.]                │    │
│  │  ─────────────────────────────────────────────────────   │    │
│  │  To: accounts@thaibev.com                                │    │
│  │  CC: sales.rep@nestle.com; ar.team@nestle.com           │    │
│  │  Subject: Payment Reminder - Invoice #DN2025012345       │    │
│  │  Sent: 10/01/2025 08:35:12                               │    │
│  │  Status: Failed                                          │    │
│  │  Error: SMTP Connection Timeout                          │    │
│  │  ─────────────────────────────────────────────────────   │    │
│  │  [Email Body Preview]                                    │    │
│  │  Dear Thai Beverage Ltd.,                                │    │
│  │  This is a reminder that payment is due...               │    │
│  │  ...                                                     │    │
│  │  ─────────────────────────────────────────────────────   │    │
│  │  Attachments: Invoice.pdf, QR_Code.png                   │    │
│  │  ─────────────────────────────────────────────────────   │    │
│  │  [✉️ Resend Email] [📄 Download] [🗑️ Delete Log]        │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Sections

#### 2.1 Filter Section
**Controls**:
- **Date Picker**: Default to `gblFilterDate` passed from dashboard
- **Status Dropdown**: All, Sent, Failed, Skipped
  - Auto-set to `gblEmailStatusFilter` if passed
- **Customer Search**: Text input with autocomplete
- **Template Filter**: A (Day 1-2), B (Day 3), C (Day 4+), D (MI)
- **Result Count**: "Showing: X results"

**Behavior**:
- Filters combine with AND logic
- Gallery updates reactively
- Clear Filters resets all to defaults

#### 2.2 Email List Gallery
**Data Source**: `[THFinanceCashCollection]Emaillogs`
**Sort**: `cr7bb_sentdatetime` descending (most recent first)
**Pagination**: 20 items per page

**Columns**:
1. **Status Icon** (40px)
2. **Sent Date/Time** (120px): dd/mm hh:mm
3. **Customer Name** (200px): From lookup `cr7bb_customer.cr7bb_customername`
4. **Status** (100px): Badge with color coding
5. **Amount Due** (120px): Total amount from transactions
6. **Template** (60px): A/B/C/D
7. **Actions** (150px): View, Resend buttons

**Row Selection**: Click row to load preview panel below

#### 2.3 Email Preview Panel
**Visibility**: Shows when row selected in gallery

**Information Displayed**:
- **Recipient Details**:
  - To: `cr7bb_customer.cr7bb_customeremail`
  - CC: Sales rep + AR backup
  - Subject line
- **Status Information**:
  - Sent timestamp
  - Current status
  - Error message (if failed)
  - Retry count
- **Email Content**:
  - Rendered HTML preview
  - Template used
  - Personalization data (customer name, amounts, etc.)
- **Attachments**:
  - QR code image
  - Invoice PDF (if applicable)

**Actions**:
- **Resend Email**: Trigger Power Automate flow to resend
- **Download**: Export email content + attachments
- **Delete Log**: Mark record as deleted (admin only)

### Data Sources
**Primary**: `[THFinanceCashCollection]Emaillogs`

**Fields Used**:
- `cr7bb_sentdatetime` (DateTime): When email was sent
- `cr7bb_sendstatus` (Choice): Sent, Failed, Skipped
- `cr7bb_customer` (Lookup): Customer record
- `cr7bb_emailtemplate` (Text): A, B, C, D
- `cr7bb_emailsubject` (Text): Subject line
- `cr7bb_emailbody` (Text): HTML content
- `cr7bb_errorMessage` (Text): Error details if failed
- `cr7bb_retrycount` (Number): How many retries

**Lookups**:
- Customer name: `cr7bb_customer.cr7bb_customername`
- Customer email: `cr7bb_customer.cr7bb_customeremail`

### Variables
- `gblFilterDate` (Date): Passed from dashboard
- `gblEmailStatusFilter` (Text): Passed from Failed button
- `_selectedEmail` (Record): Currently selected email log

---

## 3. Customer Management (`scnCustomer`)

### Purpose
Maintain master data for ~100 cash customers, including contact information, payment terms, and exclusion rules.

### User Story
> "As an AR Manager, I need to add new customers, update email addresses, set exclusion rules (e.g., 'Paid', 'Bill credit 30 days'), and ensure sales reps receive copies of collection emails."

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Customer Management                     [User Profile]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────── TOOLBAR ───────────────────────────┐    │
│  │  [+ New Customer] [📥 Import Excel] [📤 Export]          │    │
│  │  Search: [______________] [🔍]   [Active/Inactive/All]   │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌───────────────────── CUSTOMER LIST ──────────────────────┐   │
│  │ ┌──────────┬────────────────┬──────────────┬──────────┐  │   │
│  │ │ Code     │ Customer Name  │ Email        │ Status   │  │   │
│  │ ├──────────┼────────────────┼──────────────┼──────────┤  │   │
│  │ │ CP001    │ Charoen        │ ar@cp.co.th  │ Active   │  │   │
│  │ │          │ Pokphand Foods │              │ [Edit]   │  │   │
│  │ ├──────────┼────────────────┼──────────────┼──────────┤  │   │
│  │ │ TB002    │ Thai Beverage  │ pay@tb.com   │ Active   │  │   │
│  │ │          │                │              │ [Edit]   │  │   │
│  │ └──────────┴────────────────┴──────────────┴──────────┘  │   │
│  │ Showing 100 customers                                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌───────────────── CUSTOMER DETAIL PANEL ──────────────────┐   │
│  │  Edit Customer: Charoen Pokphand Foods                    │   │
│  │  ─────────────────────────────────────────────────────    │   │
│  │  Customer Code:  [CP001]                 (Read-only)      │   │
│  │  Customer Name:  [Charoen Pokphand Foods PCL]             │   │
│  │  Email Address:  [accounts.receivable@cpf.co.th]          │   │
│  │  Sales Rep:      [john.doe@nestle.com] ☑ CC on emails    │   │
│  │  AR Backup:      [ar.team@nestle.com]                     │   │
│  │  Payment Terms:  [30 days]                                │   │
│  │  ─────────────────────────────────────────────────────    │   │
│  │  Exclusion Rules:                                         │   │
│  │  ☑ Skip if note contains: "Paid"                          │   │
│  │  ☑ Skip if note contains: "Partial Payment"               │   │
│  │  ☑ Skip if note contains: "รักษาตลาด"                     │   │
│  │  ☑ Skip if note contains: "Bill credit 30 days"           │   │
│  │  [+ Add Custom Rule]                                      │   │
│  │  ─────────────────────────────────────────────────────    │   │
│  │  Status: ● Active  ○ Inactive                             │   │
│  │  ─────────────────────────────────────────────────────    │   │
│  │  [💾 Save Changes] [❌ Cancel] [🗑️ Delete Customer]       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Sections

#### 3.1 Toolbar
**Controls**:
- **New Customer**: Open blank form in detail panel
- **Import Excel**: Upload customer master file
  - Validates required fields
  - Shows preview before save
  - Updates existing, creates new
- **Export**: Download current customer list to Excel
- **Search**: Filter customers by code/name/email
- **Status Filter**: Active, Inactive, All

#### 3.2 Customer List Gallery
**Data Source**: `[THFinanceCashCollection]Customers`
**Sort**: Alphabetical by `cr7bb_customername`
**Pagination**: 50 per page

**Columns**:
- Customer Code
- Customer Name
- Email Address
- Status (Active/Inactive badge)
- Edit button

**Selection**: Click row to load detail panel

#### 3.3 Customer Detail Panel
**Mode**: Edit form (EditForm or manual fields)

**Sections**:

**Basic Information**:
- **Customer Code**: Auto-generated, read-only once created
- **Customer Name**: Required, text
- **Customer Email**: Required, validated format
- **Sales Rep Email**: Optional, validated format
- **AR Backup Email**: Required, validated format
- **Payment Terms**: Dropdown (15/30/45/60 days)

**Exclusion Rules**:
- Pre-defined checkboxes:
  - "Paid"
  - "Partial Payment"
  - "รักษาตลาด" (Thai: Maintain market)
  - "Bill credit 30 days"
- Custom rules: Text collection, can add/remove
- **Logic**: If transaction note contains ANY checked phrase → skip customer

**Status**:
- Radio buttons: Active / Inactive
- Inactive customers not included in daily processing

**Actions**:
- **Save**: Patch to Dataverse, refresh gallery
- **Cancel**: Discard changes, close panel
- **Delete**: Confirmation dialog, soft delete (admin only)

### Data Sources
**Primary**: `[THFinanceCashCollection]Customers`

**Fields**:
- `cr7bb_customercode` (Text, Primary): Unique code
- `cr7bb_customername` (Text): Full legal name
- `cr7bb_customeremail` (Text): Accounts payable email
- `cr7bb_salesrepemail` (Text): Sales rep to CC
- `cr7bb_arbackupemail` (Text): AR team backup
- `cr7bb_paymentterms` (Number): Days (15/30/45/60)
- `cr7bb_exclusionrules` (Text, multi-line): JSON array of rules
- `cr7bb_isactive` (Boolean): Active status

### Validation Rules
1. Email format validation (regex)
2. Customer code unique constraint
3. At least one email required (customer OR AR backup)
4. Payment terms > 0

---

## 4. Transaction View (`scnTransactions`)

### Purpose
View and manage individual AR transaction line items imported from SAP.

### User Story
> "As an AR Analyst, I need to see all outstanding invoices for each customer, verify FIFO logic was applied correctly, manually mark transactions as processed, and investigate discrepancies."

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Transaction Management                  [User Profile]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────── FILTERS ──────────────────────────┐     │
│  │  Customer: [Search/Select...] ▼                         │     │
│  │  Date Range: [DD/MM/YYYY] to [DD/MM/YYYY]              │     │
│  │  Type: [All / CN / DN / Invoice / MI]                  │     │
│  │  Status: [All / Processed / Unprocessed]               │     │
│  │  [Clear] [Apply Filters]  Total: ฿1,234,567.89         │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌──────────────────── TRANSACTION LIST ──────────────────┐     │
│  │ ┌─────┬────────┬──────────┬────────┬─────────┬────────┐ │     │
│  │ │ DN  │ 123456 │ 01/12/24 │ Day 8  │ ฿45,000 │ [View] │ │     │
│  │ │ CN  │ 123457 │ 05/12/24 │ Day 4  │-฿10,000 │ [View] │ │     │
│  │ │ DN  │ 123458 │ 10/12/24 │ Day 0  │ ฿25,000 │ [View] │ │     │
│  │ └─────┴────────┴──────────┴────────┴─────────┴────────┘ │     │
│  │ ☑ Select All  [Mark as Processed] [Export Selected]    │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌──────────────── FIFO CALCULATION PREVIEW ──────────────┐     │
│  │  Customer: Charoen Pokphand Foods                       │     │
│  │  ─────────────────────────────────────────────────────  │     │
│  │  Credit Notes (CN) - Total: ฿10,000                     │     │
│  │    • CN-123457 (05/12/24): ฿10,000                      │     │
│  │                                                         │     │
│  │  Debit Notes (DN) - Total: ฿70,000                      │     │
│  │    • DN-123456 (01/12/24): ฿45,000  ← Oldest (Day 8)    │     │
│  │    • DN-123458 (10/12/24): ฿25,000  (Day 0)             │     │
│  │                                                         │     │
│  │  FIFO Application:                                      │     │
│  │  1. CN ฿10,000 applied to DN-123456                     │     │
│  │  2. DN-123456 remaining: ฿35,000 (Day 8) → Send Email   │     │
│  │  3. DN-123458: ฿25,000 (Day 0) → Send Email             │     │
│  │                                                         │     │
│  │  Total Owed: ฿60,000                                    │     │
│  │  Email Template: Template B (Day 3+)                    │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Sections

#### 4.1 Filter Section
**Controls**:
- **Customer Dropdown**: Searchable, all active customers
- **Date Range**: From/To date pickers
- **Type Filter**: CN (Credit Note), DN (Debit Note), Invoice, MI
- **Status**: Processed vs Unprocessed
- **Total Display**: Sum of filtered amounts

#### 4.2 Transaction List Gallery
**Data Source**: `[THFinanceCashCollection]Transactions`
**Sort**: By customer, then document date (FIFO order)

**Columns**:
1. **Type** (40px): CN/DN/MI badge (color-coded)
2. **Document #** (100px): SAP document number
3. **Document Date** (100px): dd/mm/yyyy
4. **Day Count** (80px): Days overdue
5. **Amount** (120px): ฿XX,XXX.XX (negative for CN)
6. **Processed** (80px): ✓ or ✗
7. **Note** (200px): Payment note from SAP
8. **View** (60px): Detail button

**Bulk Actions**:
- Select All checkbox
- Mark as Processed button
- Export Selected to Excel

#### 4.3 FIFO Calculation Preview
**Purpose**: Visual explanation of how email engine applied FIFO logic

**Display When**: Customer selected in filter

**Logic Shown**:
1. List all CN (credits) for customer, oldest first
2. List all DN (debits) for customer, oldest first
3. Show how CNs applied to DNs
4. Show remaining balances
5. Indicate which transactions triggered emails
6. Show template selection logic (based on day count)

**Formulas**:
```powerfx
// Group transactions by customer
GroupBy(Transactions, "cr7bb_customercode", "TransactionsByCustomer")

// Separate CN and DN
Filter(Transactions, cr7bb_type = "CN")  // Credits
Filter(Transactions, cr7bb_type = "DN")  // Debits

// Apply FIFO (done in Power Automate, show results here)
```

### Data Sources
**Primary**: `[THFinanceCashCollection]Transactions`

**Fields**:
- `cr7bb_customercode` (Text): Links to customer
- `cr7bb_documentnumber` (Text): SAP doc #
- `cr7bb_documentdate` (Date): Transaction date
- `cr7bb_type` (Text): CN, DN, Invoice, MI
- `cr7bb_amount` (Currency): Amount (negative for CN)
- `cr7bb_daycount` (Number): Days since due date
- `cr7bb_note` (Text): Payment note from SAP
- `cr7bb_processed` (Boolean): Included in email run
- `cr7bb_processeddate` (Date): When processed

### Business Rules
1. **CN (Credit Notes)**: Negative amounts, reduce customer balance
2. **DN (Debit Notes)**: Positive amounts, increase customer balance
3. **FIFO Order**: Oldest document date first
4. **Day Count**:
   - Day 0-2: Template A (standard)
   - Day 3: Template B (warning)
   - Day 4+: Template C (MI charges)
5. **Exclusion**: Skip if note contains exclusion text

---

## 5. Settings (`scnSettings`)

### Purpose
Configure system parameters, user preferences, email templates, and automation schedules.

### User Story
> "As an AR Manager, I need to configure email templates, set automation schedules, manage user access, and adjust system thresholds."

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Settings                                [User Profile]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────── SETTINGS TABS ───────────┐                        │
│  │ [General] [Email] [Automation] [Users] [Advanced]            │
│  └───────────────────────────────────────┘                      │
│                                                                  │
│  ┌───────────────── GENERAL SETTINGS ──────────────────────┐    │
│  │                                                          │    │
│  │  System Configuration                                   │    │
│  │  ─────────────────────────────────────────────────────  │    │
│  │  Company Name: [Nestlé Thai Ltd.]                       │    │
│  │  AR Team Email: [ar.thailand@nestle.com]                │    │
│  │  AR Manager:    [manager@nestle.com]                    │    │
│  │                                                          │    │
│  │  Business Rules                                          │    │
│  │  ─────────────────────────────────────────────────────  │    │
│  │  Important Customer Threshold: [฿100,000]                │    │
│  │  Critical Day Count:           [3 days]                 │    │
│  │  Max Retry Attempts:           [3]                      │    │
│  │                                                          │    │
│  │  Regional Settings                                       │    │
│  │  ─────────────────────────────────────────────────────  │    │
│  │  Language:         [English (Thai locale)]              │    │
│  │  Currency:         [THB (฿)]                             │    │
│  │  Date Format:      [dd/mm/yyyy]                         │    │
│  │  Time Zone:        [GMT+7 Bangkok]                      │    │
│  │                                                          │    │
│  │  [💾 Save Settings]                                      │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Tabs

#### 5.1 General Tab
**System Configuration**:
- Company name
- AR team contact email
- AR manager email

**Business Rules**:
- Important customer threshold (amount)
- Critical day count (when to escalate)
- Max retry attempts for failed emails

**Regional Settings**:
- Language/locale
- Currency
- Date/time formats
- Time zone

#### 5.2 Email Tab
**Email Templates**:
- **Template A** (Day 1-2): Standard reminder
- **Template B** (Day 3): Warning about cash discount
- **Template C** (Day 4+): Late fees notice
- **Template D** (MI Documents): MI explanation

**Each Template Editor**:
```
Subject: [Payment Reminder - Invoice #{invoice_number}]

Body: (Rich text editor)
Dear {customer_name},

This is a friendly reminder that payment is due for...

Variables available:
- {customer_name}
- {invoice_number}
- {amount_due}
- {due_date}
- {day_count}
- {qr_code} (image embed)

[Preview] [Test Send] [Save Template]
```

**Email Settings**:
- From address (display name)
- Reply-to address
- Default CC list
- Attachment settings

#### 5.3 Automation Tab
**Daily Run Schedule**:
- SAP Import Time: [08:00]
- Email Send Time: [08:30]
- Time Zone: GMT+7 Bangkok

**Automation Toggles**:
- ☑ Enable Daily SAP Import
- ☑ Enable Automatic Email Sending
- ☑ Send Summary Report to Manager
- ☑ Alert on Failures

**Notification Rules**:
- Email manager if > X failures
- Alert on SAP import failure
- Daily summary time

#### 5.4 Users Tab
**User Management**:
- List of users with access
- Role assignment (Viewer, Analyst, Manager, Admin)
- Add/Remove users
- Permissions matrix

**Roles**:
- **Viewer**: Read-only access to dashboard
- **Analyst**: Full access except settings
- **Manager**: All access except user management
- **Admin**: Full system access

#### 5.5 Advanced Tab
**Integration Settings**:
- Dataverse connection strings
- SharePoint QR folder path
- Power Automate flow IDs

**Logging & Debugging**:
- Enable detailed logging
- Log retention period
- Export system logs

**Maintenance**:
- Clear cache
- Rebuild indexes
- Data cleanup utilities

### Data Sources
**Settings Storage**: `[THFinanceCashCollection]Settings` (single row, key-value pairs)

---

## Common Components

### Standard Header
**All screens share this header component**:
- Height: 55px
- Background: Nestlé Blue (RGBA(0, 101, 161, 1))
- Layout: Horizontal, space-between alignment

**Left Section**:
- Hamburger menu icon (opens navigation)
- Screen title (Text@0.0.51, white, 25px, Lato font)

**Right Section**:
- User profile dropdown
- Logout button

### Navigation Menu Component
**File**: `NavigationMenu.msapp` (CanvasComponent)

**Properties**:
- Width: 260px
- Slide-in from left
- Backdrop overlay (RGBA(0,0,0,0.5))
- Items: Collection of navigation links
- Selected: Current screen name

**Styling**:
- Active item: Nestlé Blue background
- Hover: Light blue highlight
- Icons: Fluent UI icons

### Date Picker Modal
**Reusable across screens**:
- DatePicker@0.0.46 control
- Modal overlay
- Select/Cancel buttons
- Updates parent screen's date variable

### Loading Spinner
**Show during data operations**:
- Nestlé Brown color (RGBA(100, 81, 61, 1))
- Center screen
- Overlay with semi-transparent backdrop

### Error Dialog
**Standard error display**:
- Red header
- Error message
- Optional technical details (expandable)
- Retry / Close buttons

---

## Data Flow

### Daily Automation Flow

```
06:00 - SAP Data Export
   ↓ (Excel file to SharePoint)
08:00 - Power Automate: SAP Import Flow
   ↓ (Parse Excel, load to Dataverse Transactions table)
   ├─ Log to Process Logs (Status: Running)
   └─ If success → Status: Completed
08:30 - Power Automate: Collections Engine Flow
   ↓ (For each active customer)
   ├─ Get transactions (CN and DN)
   ├─ Apply FIFO logic
   ├─ Check exclusion rules
   ├─ Calculate total owed
   ├─ If owed > 0:
   │   ├─ Select email template (A/B/C/D)
   │   ├─ Compose personalized email
   │   ├─ Attach QR code from SharePoint
   │   ├─ Send via Office 365
   │   └─ Log to Emaillogs (Status: Sent/Failed)
   └─ If owed ≤ 0: Skip (log as Skipped)
09:00 - Power Automate: Summary Report Flow
   ↓ Send summary email to AR manager
   └─ Total sent, failed, skipped counts
```

### User Interaction Flows

**AR Analyst Daily Routine**:
1. Open app → Navigate to Daily Control Center
2. Check system status (SAP import, email engine)
3. If failures → Click "Failed" button → Review in Email Monitor
4. Investigate failed emails → Resend manually
5. Check important customers → Navigate if needed
6. Export daily report for records

**AR Manager Weekly Review**:
1. Navigate to Transactions
2. Filter by date range (past week)
3. Review FIFO calculations
4. Export to Excel for analysis
5. Update customer exclusions if needed

---

## User Roles & Permissions

### Role Matrix

| Screen/Feature          | Viewer | Analyst | Manager | Admin |
|------------------------|--------|---------|---------|-------|
| Daily Control Center   | View   | View    | View    | View  |
| Email Monitor          | View   | View    | Edit    | Full  |
| Customer Management    | View   | Edit    | Full    | Full  |
| Transaction View       | View   | View    | Edit    | Full  |
| Settings - General     | -      | View    | Edit    | Full  |
| Settings - Email       | -      | View    | Edit    | Full  |
| Settings - Automation  | -      | -       | View    | Full  |
| Settings - Users       | -      | -       | -       | Full  |
| Resend Email          | -      | Yes     | Yes     | Yes   |
| Delete Records        | -      | -       | Yes     | Yes   |
| Modify Automation     | -      | -       | -       | Yes   |

### Permission Implementation
```powerfx
// In App.OnStart
Set(
    gblUserRole,
    LookUp(
        UserRoles,
        Email = User().Email,
        Role
    )
);

// Per screen/control
Visible: gblUserRole in ["Manager", "Admin"]
DisplayMode: If(gblUserRole = "Viewer", DisplayMode.View, DisplayMode.Edit)
```

---

## Technical Standards

### Naming Conventions

**Screens**: `scn[ScreenName]`
- Example: `scnDailyControlCenter`

**Controls**:
- Prefix by screen: `DCC_MenuIcon`
- Descriptive name: `DCC_EmailStatusText`

**Variables**:
- Local: `_variableName` (underscore prefix)
- Global: `gblVariableName`
- Collections: `colCollectionName`

### Control Versions
- **Modern Controls**: Always specify version
  - Button@0.0.45
  - Text@0.0.51
  - DatePicker@0.0.46
- **Classic Controls**: Include version
  - Classic/Icon@2.5.0
  - Gallery@2.15.0

### Colors (Nestlé Brand)
- **Primary Blue**: RGBA(0, 101, 161, 1)
- **Secondary Brown**: RGBA(100, 81, 61, 1)
- **Success Green**: RGBA(16, 124, 16, 1)
- **Error Red**: RGBA(168, 0, 0, 1)
- **Warning Yellow**: RGBA(255, 185, 0, 1)
- **Background Gray**: RGBA(243, 242, 241, 1)
- **White**: RGBA(255, 255, 255, 1)

### Fonts
- **Primary**: Lato (Nestlé standard)
- **Fallback**: Segoe UI
- **Sizes**: 12px (small), 14px (body), 16px (subheading), 20px (heading), 25px (title)

### Layout Standards
- **Header Height**: 55px
- **Card Padding**: 20px
- **Card Gap**: 24px
- **Button Height**: 40-50px
- **Input Height**: 40px
- **Border Radius**: 8-10px
- **Drop Shadow**: Light/Regular (no Heavy)

### Performance Guidelines
- Use `With()` for complex formulas
- Reference `_refreshTrigger` for reactive data
- Direct queries instead of collections where possible
- Pagination for large datasets (20-50 items)
- Avoid delegation warnings (filter on indexed fields)

### Choice Field Syntax (Dataverse)
**Comparison**:
```powerfx
ThisItem.cr7bb_sendstatus = 'Send Status Choice'.Sent
```

**Display**:
```powerfx
Text(ThisItem.cr7bb_sendstatus)
```

### Error Handling
```powerfx
IfError(
    // Operation
    Patch(...),
    // Error handler
    Notify("Error: " & FirstError.Message, NotificationType.Error)
)
```

---

## Appendix

### A. Dataverse Schema Summary

**Tables**:
1. `[THFinanceCashCollection]Customers` - Customer master
2. `[THFinanceCashCollection]Transactions` - AR line items
3. `[THFinanceCashCollection]Emaillogs` - Email history
4. `[THFinanceCashCollection]Process Logs` - Automation logs
5. `[THFinanceCashCollection]Settings` - App configuration

### B. Power Automate Flows
1. **SAP Import Flow**: Import transactions from Excel
2. **Collections Engine Flow**: FIFO processing + email sending
3. **Summary Report Flow**: Daily manager report
4. **Manual Resend Flow**: Triggered from Email Monitor

### C. SharePoint Libraries
1. **QR Codes**: PromptPay codes (filename = customer_code.png)
2. **SAP Exports**: Daily Excel files
3. **Email Attachments**: Invoices, receipts

---

**Document Version**: 1.0
**Last Updated**: 2025-01-10
**Next Review**: 2025-02-10

**Approval**:
- [ ] AR Manager
- [ ] IT Manager
- [ ] Project Sponsor

---

## Change Log

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-01-10 | 1.0 | System Design Team | Initial comprehensive design specification |

