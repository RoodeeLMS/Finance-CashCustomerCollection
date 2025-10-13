# Screen Description: scnTransactions

**Created**: 2025-01-10
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-basic-screen.yaml (customize with filters + Table control + FIFO preview)
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
View and manage AR transaction line items, verify FIFO logic application, investigate discrepancies, and manually mark transactions as processed.

**Who uses it**:
- **AR Analyst** - Daily transaction review, FIFO verification
- **AR Manager** - Audit transactions, investigate discrepancies

**User Goals**:
- See all outstanding invoices per customer
- Verify FIFO logic was applied correctly
- View CN (Credit Notes) vs DN (Debit Notes) calculation
- Manually mark transactions as processed
- Export transaction data

---

## 2. Design Mockup

**Visual Layout**:

```
┌─────────────────────────────────────────────────────────────────┐
│ [HEADER - GroupContainer@1.3.0, AutoLayout, H:55]              │
│ ◰  Transaction Management                  [User Profile] 🚪    │
├─────────────────────────────────────────────────────────────────┤
│ [CONTENT - GroupContainer@1.3.0, ManualLayout]                  │
│                                                                  │
│ ┌────────────── FILTERS (H:140) ────────────────────┐          │
│ │ Customer: [Search...▼]  Type: [All▼]  Status: [All▼] │      │
│ │ Date: [DD/MM/YYYY] to [DD/MM/YYYY]                    │      │
│ │ [Apply] Total: ฿1,234,567.89                          │      │
│ └────────────────────────────────────────────────────────┘      │
│                                                                  │
│ ┌──────────── TRANSACTION TABLE (Table@1.5.3) ─────────┐      │
│ │ Select │Type│Doc #  │Date      │Days │Amount      │Note│✓│ │
│ │────────┼────┼───────┼──────────┼─────┼────────────┼────┼─│ │
│ │   ☐    │DN  │123456 │01/12/2024│Day 8│฿45,000.00  │    │✓│ │
│ │   ☐    │CN  │123457 │05/12/2024│Day 4│-฿10,000.00 │Paid│ │ │
│ │   ☐    │DN  │123458 │10/12/2024│Day 0│฿25,000.00  │    │✓│ │
│ │ [Mark Processed] [Export]                             │      │
│ └────────────────────────────────────────────────────────┘      │
│                                                                  │
│ ┌────────── FIFO CALCULATION PREVIEW ────────────┐            │
│ │ Customer: Charoen Pokphand Foods PCL            │            │
│ │ ──────────────────────────────────────────       │            │
│ │ CN Total: ฿10,000  │  DN Total: ฿70,000          │            │
│ │                                                  │            │
│ │ FIFO Application:                                │            │
│ │ 1. CN ฿10,000 → DN-123456 (฿45,000 - ฿10,000) │            │
│ │ 2. DN-123456 remaining: ฿35,000 (Day 8)        │            │
│ │ 3. DN-123458: ฿25,000 (Day 0)                  │            │
│ │                                                  │            │
│ │ Net Owed: ฿60,000   Template: C (Day 4+)       │            │
│ └──────────────────────────────────────────────────┘            │
│                                                                  │
│ [NavigationMenu - Left slide-in, W:260]                        │
└─────────────────────────────────────────────────────────────────┘
```

**Template Base**: template-basic-screen.yaml

---

## 3. Database Schema

**Data Source**: Dataverse

**Primary Entity**: `[THFinanceCashCollection]Transactions`

**Fields Used**:
| Field | Logical Name | Type | Notes |
|-------|--------------|------|-------|
| Customer | cr7bb_customer | Lookup | → Customers |
| Document Number | cr7bb_documentnumber | Text | SAP doc # |
| Document Date | cr7bb_documentdate | Date | Transaction date |
| Document Type | cr7bb_documenttype | Text | DG, DR, DZ |
| Transaction Type | cr7bb_transactiontype | Choice | CN or DN |
| Amount | cr7bb_amountlocalcurrency | Currency | + or - |
| Day Count | cr7bb_daycount | Number | Days overdue |
| Text Field | cr7bb_textfield | Text | SAP note |
| Is Processed | cr7bb_isprocessed | Boolean | Included in email |
| Process Date | cr7bb_processdate | Date | SAP extract date |

**Filter Example**:
```powerfx
SortByColumns(
    Filter(
        '[THFinanceCashCollection]Transactions',
        (IsBlank(_selectedCustomer) || cr7bb_customer = _selectedCustomer) &&
        cr7bb_documentdate >= _dateFrom &&
        cr7bb_documentdate <= _dateTo &&
        (_statusFilter = "All" ||
         (_statusFilter = "Processed" && cr7bb_isprocessed = true) ||
         (_statusFilter = "Unprocessed" && cr7bb_isprocessed = false))
    ),
    "cr7bb_documentdate",
    SortOrder.Ascending  // FIFO order
)
```

---

## 4. Key Features

### Filter Section
- Customer combo box (searchable)
- Date range (from/to)
- Type filter (All/CN/DN/Invoice/MI)
- Status filter (All/Processed/Unprocessed)
- Total amount display

### Transaction Table (Table@1.5.3)
**Control**: Modern Table control with selection checkboxes

**Columns**:
1. **Select** (Checkbox column) - Multi-select for bulk operations
2. **Type** (Text column) - CN/DN badge with color formatting
3. **Document #** (Text column) - Document number
4. **Date** (Date column) - Format: dd/MM/yyyy
5. **Days** (Number column) - Day count with conditional formatting
6. **Amount** (Currency column) - ฿ symbol with color formatting
7. **Note** (Text column) - SAP text field
8. **Processed** (Icon column) - Checkmark or empty

**Formatting**:
- Type badge: CN=Green background, DN=Red background
- Day count colors: Day 0-2=Gray, Day 3=Yellow, Day 4+=Red
- Amount colors: Negative=Green (CN), Positive=Red (DN)
- Processed: Green checkmark if true, gray circle if false

**Features**:
- Sortable columns (click header)
- Multi-row selection via checkboxes
- Scrollable (Height based on parent container)

### FIFO Preview Panel
- Shows selected customer's CN/DN breakdown
- FIFO calculation step-by-step
- Net amount owed
- Email template used

### Actions
- Mark selected as processed
- Export to Excel

---

## 5. Variables

**Screen Variables**:
- `_selectedCustomer` (Record): Filtered customer
- `_dateFrom` (Date): Start date (default: Today() - 30)
- `_dateTo` (Date): End date (default: Today())
- `_typeFilter` (Text): "All", "CN", "DN", etc.
- `_statusFilter` (Text): "All", "Processed", "Unprocessed"

**Collections**:
- `colCustomers` (Collection): Customer list for filter dropdown
- `colTransactions` (Collection): Filtered transaction records for table

**Note**: Table control has built-in selection handling via `Table.SelectedItems` property - no need for separate collection

---

## 6. Business Rules

### FIFO Logic Display
1. Separate CN (negative amounts) and DN (positive amounts)
2. Sort both by document date (oldest first)
3. Apply CN to DN until CN exhausted
4. Display remaining DN balances
5. Calculate max day count
6. Show which email template would be used

### Day Count Color Coding
- **Gray**: Day 0-2 (Template A)
- **Yellow**: Day 3 (Template B - warning)
- **Red**: Day 4+ (Template C - late fees)

### Mark Processed Logic
```powerfx
// Use Table control's SelectedItems property
ForAll(
    Trans_Table.SelectedItems,
    Patch(
        '[THFinanceCashCollection]Transactions',
        ThisRecord,
        {cr7bb_isprocessed: true}
    )
);
Notify("Transactions marked as processed", NotificationType.Success);
// Refresh table data
ClearCollect(
    colTransactions,
    SortByColumns(
        Filter('[THFinanceCashCollection]Transactions', /* filter conditions */),
        "cr7bb_documentdate",
        SortOrder.Ascending
    )
)
```

---

## 7. Navigation

**From**:
- scnDashboard (Transactions button)
- scnCustomer (Customer drill-down)

**To**:
- scnDashboard (nav menu)
- scnCustomer (nav menu)

---

## 8. Success Criteria

- ✅ Filter by customer, date, type, status works
- ✅ Table displays transactions in FIFO order with sortable columns
- ✅ Table selection allows multi-row selection via checkboxes
- ✅ FIFO preview shows correct calculation for selected customer
- ✅ Mark processed updates selected records
- ✅ Total amount calculates correctly
- ✅ Color coding matches business rules (type badges, day count, amounts)
- ✅ Table is responsive and scrollable

---

**READY FOR SUBAGENT CREATION** ✅
