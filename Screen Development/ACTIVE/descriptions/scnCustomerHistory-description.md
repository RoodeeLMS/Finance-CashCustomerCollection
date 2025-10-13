# Screen Description: Customer History

**Screen Name:** scnCustomerHistory
**Purpose:** Display complete transaction and email history for a selected customer
**Access Level:** Admin, AR Manager, AR Analyst
**Data Source:** Dataverse
**Created:** 2025-01-07
**Status:** ACTIVE - Ready for Implementation

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

## Screen Layout & Design

### ASCII Mockup

```
┌─────────────────────────────────────────────────────────────────────┐
│ ☰ Customer History                                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│ ┌───────────────────────────────────────────────────────────────┐  │
│ │ Customer Selection                                             │  │
│ │ ┌────────────────────────────┐                                 │  │
│ │ │ [Select Customer ▼]        │  [ABC Company Ltd]              │  │
│ │ └────────────────────────────┘  Customer Code: 200123          │  │
│ │                                  Region: Central                 │  │
│ └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│ ┌─ Transaction History ────────────────────────────────────────┐   │
│ │ Filter: [All ▼] [Last 30 Days ▼]                             │   │
│ │                                                                 │   │
│ │ ┌─────┬────────────┬───────────┬────────┬──────────┬────────┐ │   │
│ │ │Type │ Doc Number │   Date    │  Days  │  Amount  │ Status │ │   │
│ │ ├─────┼────────────┼───────────┼────────┼──────────┼────────┤ │   │
│ │ │ DN  │ 9000123456 │ 2025-01-05│   35   │  25,000  │   ✓    │ │   │
│ │ │ CN  │ 9000123457 │ 2025-01-03│   -    │ -10,000  │   ✓    │ │   │
│ │ │ DN  │ 9000123450 │ 2024-12-20│   50   │  15,000  │   ✓    │ │   │
│ │ └─────┴────────────┴───────────┴────────┴──────────┴────────┘ │   │
│ │                                                                 │   │
│ │ Total: ฿30,000.00  │  Outstanding: ฿30,000.00                 │   │
│ └─────────────────────────────────────────────────────────────────┘   │
│                                                                       │
│ ┌─ Email History ──────────────────────────────────────────────┐   │
│ │ [Last 90 Days ▼]                                              │   │
│ │                                                                 │   │
│ │ ┌────────────┬──────────────┬──────────┬────────┬──────────┐ │   │
│ │ │    Date    │  Template    │  Amount  │  Days  │  Status  │ │   │
│ │ ├────────────┼──────────────┼──────────┼────────┼──────────┤ │   │
│ │ │ 2025-01-05 │ Template A   │  25,000  │   2    │ Success  │ │   │
│ │ │ 2025-01-03 │ Template B   │  40,000  │   3    │ Success  │ │   │
│ │ │ 2024-12-28 │ Template C   │  15,000  │   5    │ Success  │ │   │
│ │ └────────────┴──────────────┴──────────┴────────┴──────────┘ │   │
│ │                                                                 │   │
│ │ Total Emails Sent: 15  │  Last Email: 2025-01-05              │   │
│ └─────────────────────────────────────────────────────────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
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
     - `cr7bb_transactiontype` (CN/DN)
     - `cr7bb_documentnumber`
     - `cr7bb_documentdate`
     - `cr7bb_daycount`
     - `cr7bb_amountlocalcurrency`
     - `cr7bb_isprocessed`
     - `Customer` (lookup to Customers)

3. **`[THFinanceCashCollection]Emaillogs`**
   - Purpose: Email communication history
   - Fields:
     - `cr7bb_sentdatetime`
     - `cr7bb_emailtemplate`
     - `cr7bb_totalamount`
     - `cr7bb_maxdaycount`
     - `cr7bb_sendstatus`
     - `Customer` (lookup to Customers)

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
| Type | `cr7bb_transactiontype` | Choice | 80px |
| Document | `cr7bb_documentnumber` | Text | 120px |
| Date | `cr7bb_documentdate` | Date | 100px |
| Days | `cr7bb_daycount` | Number | 80px |
| Amount | `cr7bb_amountlocalcurrency` | Currency | 120px |
| Processed | `cr7bb_isprocessed` | Boolean | 80px |

**Summary Row:**
- Total Amount
- Outstanding Balance (sum of unprocessed DN minus CN)

### 3. Email History Section
**Control:** Table@1.0.278
**Features:**
- Sortable columns
- Filter by date range
- Click to view email details

**Columns:**
| Column | Field | Type | Width |
|--------|-------|------|-------|
| Date | `cr7bb_sentdatetime` | DateTime | 150px |
| Template | `cr7bb_emailtemplate` | Choice | 100px |
| Amount | `cr7bb_totalamount` | Currency | 120px |
| Days | `cr7bb_maxdaycount` | Number | 80px |
| Status | `cr7bb_sendstatus` | Choice | 100px |

**Summary Row:**
- Total Emails Sent
- Last Email Date

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

### Customer Selection
```powerfx
// OnChange of customer combobox
UpdateContext({
    _selectedCustomer: Self.Selected
});
```

### Transaction History Items
```powerfx
=SortByColumns(
    Filter(
        '[THFinanceCashCollection]Transactions',
        !IsBlank(_selectedCustomer) &&
        Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer' &&
        cr7bb_recordtype = 'Record Type Choice'.Transaction &&
        (_transactionTypeFilter = "All" ||
         (_transactionTypeFilter = "CN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note') ||
         (_transactionTypeFilter = "DN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note')) &&
        cr7bb_documentdate >= DateAdd(Today(), -_transactionDateRange, TimeUnit.Days)
    ),
    "cr7bb_documentdate",
    SortOrder.Descending
)
```

### Email History Items
```powerfx
=SortByColumns(
    Filter(
        '[THFinanceCashCollection]Emaillogs',
        !IsBlank(_selectedCustomer) &&
        Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer' &&
        DateValue(cr7bb_sentdatetime) >= DateAdd(Today(), -_emailDateRange, TimeUnit.Days)
    ),
    "cr7bb_sentdatetime",
    SortOrder.Descending
)
```

### Calculations
```powerfx
// Total Amount
="Total: ฿" & Text(
    Sum(CustHistory_TransactionTable.AllItems, cr7bb_amountlocalcurrency),
    "#,##0.00"
)

// Outstanding Balance (only unprocessed)
="Outstanding: ฿" & Text(
    Sum(
        Filter(CustHistory_TransactionTable.AllItems, !cr7bb_isprocessed),
        cr7bb_amountlocalcurrency
    ),
    "#,##0.00"
)

// Total Emails
="Total Emails Sent: " & CountRows(CustHistory_EmailTable.AllItems)

// Last Email Date
="Last Email: " & Text(
    Max(CustHistory_EmailTable.AllItems, cr7bb_sentdatetime),
    "yyyy-mm-dd"
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
- Dashboard → "View Customer History" button
- Customer Management → "View History" button (per customer)
- Navigation Menu → "Customer History"

### Exit Points
- Back to Dashboard
- Back to Customer Management
- Navigation Menu

---

## Performance Considerations

1. **Initial Load**: No data loaded until customer selected
2. **Transaction Table**: Filter by date range (default 30 days)
3. **Email Table**: Filter by date range (default 90 days)
4. **Calculations**: Use Table.AllItems for aggregations

---

## UI/UX Guidelines

### Nestlé Brand Standards
- **Primary Color**: Nestlé Blue (RGBA(0, 101, 161, 1))
- **Font**: Lato
- **Header Height**: 55px
- **Table Row Height**: 40px

### Visual Hierarchy
1. Customer selection (prominent, top)
2. Transaction history (primary focus)
3. Email history (secondary)

### Responsive Design
- Tables scroll horizontally if needed
- Minimum width: 1024px recommended

---

## Error Handling

1. **No Customer Selected**: Disable tables, show instructional message
2. **No Transactions**: Show "No transactions found for selected period"
3. **No Emails**: Show "No emails sent during selected period"
4. **Data Load Errors**: Show error notification with retry option

---

## Future Enhancements (V2)

1. Export to Excel functionality
2. Email detail view (popup modal)
3. Transaction detail view
4. Payment status indicators
5. Graphical charts (amount over time)
6. Comparison view (multiple customers)

---

## Technical Notes

- Uses direct Dataverse queries (no collections except colCustomers)
- Real-time filtering via date range dropdowns
- Tables auto-refresh when filters change
- Read-only screen (no CRUD operations)

---

## Testing Checklist

- [ ] Customer selection populates both tables
- [ ] Transaction filters work correctly (type, date)
- [ ] Email filters work correctly (date)
- [ ] Calculations display correct totals
- [ ] Tables sort properly
- [ ] Performance acceptable with 100+ records
- [ ] Unauthorized users redirected
- [ ] Navigation menu works
- [ ] Responsive on different screen sizes
