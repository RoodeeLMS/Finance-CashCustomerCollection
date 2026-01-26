# Screen Description: scnCustomerHistory (v2.0)

**Screen Name:** scnCustomerHistory
**Purpose:** Display complete transaction and email history for a selected customer
**Access Level:** Admin, AR Manager, AR Analyst
**Data Source:** Dataverse
**Created:** 2025-01-07
**Updated:** 2026-01-21
**Status:** ACTIVE - Ready for Implementation

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-01-07 | Original |
| v2.0 | 2026-01-21 | Updated choice field syntax, added Send Status references, clarified email auto-approve |

---

## Business Requirements

### Primary Use Cases
1. **Transaction History Review**: View all past transactions for a customer (CN/DN)
2. **Email Communication Audit**: Track all emails sent to the customer
3. **Payment Tracking**: Monitor customer's payment history and outstanding balances
4. **Compliance**: Audit trail for customer communications

### User Stories
- As an AR Analyst, I want to see a customer's full transaction history so I can understand their payment patterns
- As an AR Manager, I want to review email communication history so I can verify follow-ups
- As an Admin, I want to audit customer interactions for compliance purposes

---

## System Architecture Context

### Email Auto-Approve Behavior
```
Email Engine (07:30 Daily)
├── Creates EmailLog records
├── ApprovalStatus = Approved (676180001) ← AUTO-APPROVED
├── SendStatus = Pending (676180002)
│
Email Sending Flow (08:00 Daily)
├── Sends emails where ApprovalStatus = Approved
├── Updates SendStatus to Success/Failed
└── Updates SentDateTime
```

**Note**: All emails shown in history will have `ApprovalStatus = Approved` since they are auto-approved at creation.

---

## Screen Layout & Design

### ASCII Mockup

```
+------------------------------------------------------------------+
| [=] Customer History                                              |
+------------------------------------------------------------------+
|                                                                   |
| CUSTOMER SELECTION                                                |
| +--------------------------------------------------------------+ |
| | Select Customer: [ABC Company Ltd v]                          | |
| | ABC Company Ltd  |  Code: 200123  |  Region: Central          | |
| +--------------------------------------------------------------+ |
|                                                                   |
| TRANSACTION HISTORY                                               |
| +--------------------------------------------------------------+ |
| | Filter: [All v] [Last 30 Days v]                              | |
| | +------+------------+-----------+------+-----------+--------+ | |
| | | Type | Doc Number |   Date    | Days |  Amount   | Status | | |
| | +------+------------+-----------+------+-----------+--------+ | |
| | | DN   | 9000123456 | 2025-01-05|  35  |  25,000   |   Yes  | | |
| | | CN   | 9000123457 | 2025-01-03|  -   | -10,000   |   Yes  | | |
| | | DN   | 9000123450 | 2024-12-20|  50  |  15,000   |   Yes  | | |
| | +------+------------+-----------+------+-----------+--------+ | |
| |                                                                | |
| | Total: B30,000.00  |  Outstanding: B30,000.00                 | |
| +--------------------------------------------------------------+ |
|                                                                   |
| EMAIL HISTORY                                                     |
| +--------------------------------------------------------------+ |
| | [Last 90 Days v]                                              | |
| | +------------+----------+----------+------+---------+--------+| |
| | |    Date    | Template |  Amount  | Days |  Send   | Apprvl || |
| | +------------+----------+----------+------+---------+--------+| |
| | | 2025-01-05 |    A     |  25,000  |  2   | Success | Apprvd || |
| | | 2025-01-03 |    B     |  40,000  |  3   | Success | Apprvd || |
| | | 2024-12-28 |    C     |  15,000  |  5   | Success | Apprvd || |
| | +------------+----------+----------+------+---------+--------+| |
| |                                                                | |
| | Total Emails: 15  |  Last Email: 2025-01-05                   | |
| +--------------------------------------------------------------+ |
|                                                                   |
+------------------------------------------------------------------+
```

---

## Data Sources

### Primary Entities

1. **`[THFinanceCashCollection]Customers`**
   - Purpose: Customer selection dropdown
   - Fields: `cr7bb_customerid`, `cr7bb_customername`, `cr7bb_customercode`, `cr7bb_Region`

2. **`[THFinanceCashCollection]Transactions`**
   - Purpose: Transaction history table
   - Fields:
     - `cr7bb_transactiontype` (Choice: CN/DN)
     - `cr7bb_documentnumber`
     - `cr7bb_documentdate`
     - `cr7bb_daycount`
     - `cr7bb_amountlocalcurrency`
     - `cr7bb_isprocessed`
     - `Customer` (lookup to Customers)

3. **`[THFinanceCashCollection]Emaillogs`**
   - Purpose: Email communication history
   - Fields:
     - `cr7bb_sentdatetime` (DateTime)
     - `cr7bb_emailtemplate` (Text: A, B, C, D)
     - `cr7bb_totalamount`
     - `cr7bb_maxdaycount`
     - `cr7bb_sendstatus` (Choice)
     - `cr7bb_approvalstatus` (Choice - always Approved)
     - `Customer` (lookup to Customers)

---

## Choice Field Syntax Reference

### Transaction Type Choice
```powerfx
cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note'
cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note'
```

### Send Status Choice
```powerfx
cr7bb_sendstatus = 'Send Status Choice'.Success     // 676180000
cr7bb_sendstatus = 'Send Status Choice'.Failed      // 676180001
cr7bb_sendstatus = 'Send Status Choice'.Pending     // 676180002
```

### Approval Status Choice
```powerfx
cr7bb_approvalstatus = ApprovalStatusChoice.Pending   // 676180000
cr7bb_approvalstatus = ApprovalStatusChoice.Approved  // 676180001
cr7bb_approvalstatus = ApprovalStatusChoice.Rejected  // 676180002
```

**Note**: All EmailLog records will have `ApprovalStatusChoice.Approved` since emails are auto-approved by the Email Engine.

---

## Screen Components

### 1. Customer Selection Panel
**Control:** GroupContainer (AutoLayout)
**Location:** Top of screen
**Contents:**
- Customer ComboBox with search
- Selected customer info display (Name, Code, Region)

### 2. Transaction History Section
**Control:** Table@1.0.278
**Features:**
- Sortable columns
- Filter by type (All, CN, DN)
- Filter by date range
- Real-time totals calculation

**Columns:**
| Column | Field | Type | Width |
|--------|-------|------|-------|
| Type | TransactionTypeText (calculated) | Text | 80px |
| Document | `cr7bb_documentnumber` | Text | 120px |
| Date | `cr7bb_documentdate` | Date | 100px |
| Days | `cr7bb_daycount` | Number | 80px |
| Amount | AmountFormatted (calculated) | Text | 120px |
| Processed | `cr7bb_isprocessed` | Boolean | 80px |

### 3. Email History Section
**Control:** Table@1.0.278
**Features:**
- Sortable columns
- Filter by date range
- Shows send status

**Columns:**
| Column | Field | Type | Width |
|--------|-------|------|-------|
| Date | `cr7bb_sentdatetime` | DateTime | 150px |
| Template | `cr7bb_emailtemplate` | Text | 100px |
| Amount | AmountFormatted (calculated) | Text | 120px |
| Days | `cr7bb_maxdaycount` | Number | 80px |
| Send Status | `cr7bb_sendstatus` | Choice | 100px |

**Note**: ApprovalStatus column is optional since all emails are auto-approved.

---

## Behavior & Logic

### OnVisible
```powerfx
UpdateContext({
    currentScreen: "Customer History",
    _showMenu: false,
    _selectedCustomer: Blank(),
    _transactionTypeFilter: "All",
    _transactionDateRange: 30,
    _emailDateRange: 90
});

// Load customers for dropdown
ClearCollect(
    colCustomers,
    Sort('[THFinanceCashCollection]Customers', cr7bb_customername, SortOrder.Ascending)
);
```

### Customer Selection OnChange
```powerfx
UpdateContext({
    _selectedCustomer: If(
        CountRows(Self.SelectedItems) > 0,
        First(Self.SelectedItems),
        Blank()
    )
});

// Load customer transactions
If(
    !IsBlank(_selectedCustomer),
    ClearCollect(
        colCustomerTransactions,
        AddColumns(
            Filter(
                '[THFinanceCashCollection]Transactions',
                Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer'
            ),
            TransactionTypeText,
            If(
                cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note',
                "CN",
                If(
                    cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note',
                    "DN",
                    ""
                )
            ),
            AmountFormatted,
            "B" & Text(cr7bb_amountlocalcurrency, "#,##0.00")
        )
    );
    ClearCollect(
        colCustomerEmails,
        AddColumns(
            Filter(
                '[THFinanceCashCollection]Emaillogs',
                Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer'
            ),
            AmountFormatted,
            "B" & Text(cr7bb_totalamount, "#,##0.00")
        )
    )
)
```

### Transaction History Items
```powerfx
=If(
    IsBlank(_selectedCustomer),
    Blank(),
    SortByColumns(
        Filter(
            colCustomerTransactions,
            (_transactionTypeFilter = "All" ||
             (_transactionTypeFilter = "CN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note') ||
             (_transactionTypeFilter = "DN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note')) &&
            cr7bb_documentdate >= DateAdd(Today(), -_transactionDateRange, TimeUnit.Days)
        ),
        "cr7bb_documentdate",
        SortOrder.Descending
    )
)
```

### Email History Items
```powerfx
=If(
    IsBlank(_selectedCustomer),
    Blank(),
    SortByColumns(
        Filter(
            colCustomerEmails,
            DateValue(cr7bb_sentdatetime) >= DateAdd(Today(), -_emailDateRange, TimeUnit.Days)
        ),
        "cr7bb_sentdatetime",
        SortOrder.Descending
    )
)
```

### Calculations
```powerfx
// Total Amount
="Total: B" & Text(
    Sum(
        Filter(
            colCustomerTransactions,
            (_transactionTypeFilter = "All" ||
             (_transactionTypeFilter = "CN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note') ||
             (_transactionTypeFilter = "DN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note')) &&
            cr7bb_documentdate >= DateAdd(Today(), -_transactionDateRange, TimeUnit.Days)
        ),
        cr7bb_amountlocalcurrency
    ),
    "#,##0.00"
)

// Outstanding Balance (only unprocessed)
="Outstanding: B" & Text(
    Sum(
        Filter(
            colCustomerTransactions,
            (_transactionTypeFilter = "All" ||
             (_transactionTypeFilter = "CN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note') ||
             (_transactionTypeFilter = "DN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note')) &&
            cr7bb_documentdate >= DateAdd(Today(), -_transactionDateRange, TimeUnit.Days) &&
            !cr7bb_isprocessed
        ),
        cr7bb_amountlocalcurrency
    ),
    "#,##0.00"
)

// Total Emails
="Total Emails: " & CountRows(
    Filter(
        colCustomerEmails,
        DateValue(cr7bb_sentdatetime) >= DateAdd(Today(), -_emailDateRange, TimeUnit.Days)
    )
)

// Last Email Date
=If(
    CountRows(Filter(colCustomerEmails,
        DateValue(cr7bb_sentdatetime) >= DateAdd(Today(), -_emailDateRange, TimeUnit.Days))) > 0,
    "Last Email: " & Text(
        Max(
            Filter(colCustomerEmails,
                DateValue(cr7bb_sentdatetime) >= DateAdd(Today(), -_emailDateRange, TimeUnit.Days)),
            cr7bb_sentdatetime
        ),
        "yyyy-mm-dd hh:mm"
    ),
    "No emails sent"
)
```

---

## Validation Rules

1. **Customer Selection Required**
   - Tables disabled until customer selected
   - Show message: "Please select a customer to view history"

2. **Date Range Validation**
   - Minimum: 7 days
   - Maximum: 365 days
   - Default: 30 days (transactions), 90 days (emails)

---

## Access Control

### Role Permissions
- **Admin**: Full access
- **AR Manager**: Full access
- **AR Analyst**: Full access

### Visibility Rules
- All users can view history
- No edit/delete operations (read-only view)

---

## Navigation

### Entry Points
- Dashboard -> "View Customer History" button
- Customer Management -> "View History" button (per customer)
- Navigation Menu -> "Customer History"

### Exit Points
- Back to Dashboard
- Back to Customer Management
- Navigation Menu

---

## UI/UX Guidelines

### Nestle Brand Standards
- **Primary Color**: Nestle Blue (RGBA(0, 101, 161, 1))
- **Font**: Lato
- **Header Height**: 55px
- **Table Row Height**: 40px

### Send Status Color Coding
| Status | Color | Meaning |
|--------|-------|---------|
| Success | Green | Email delivered |
| Failed | Red | Send error |
| Pending | Gray | Waiting for send |

### Transaction Type Color Coding
| Type | Color | Meaning |
|------|-------|---------|
| CN | Green | Credit Note (negative) |
| DN | Red | Debit Note (positive) |

---

## Error Handling

1. **No Customer Selected**: Disable tables, show instructional message
2. **No Transactions**: Show "No transactions found for selected period"
3. **No Emails**: Show "No emails sent during selected period"
4. **Data Load Errors**: Show error notification with retry option

---

## Testing Checklist

- [ ] Customer selection populates both tables
- [ ] Transaction filters work correctly (type, date)
- [ ] Email filters work correctly (date)
- [ ] Calculations display correct totals
- [ ] Tables sort properly
- [ ] Send status shows correct colors
- [ ] Performance acceptable with 100+ records
- [ ] Navigation menu works
- [ ] Responsive on different screen sizes

---

**READY FOR IMPLEMENTATION**
