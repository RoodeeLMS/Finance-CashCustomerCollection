# Screen Description: scnTransactions (v2.0)

**Created**: 2025-01-10
**Updated**: 2026-01-21
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-basic-screen.yaml (customize with filters + Table control + FIFO preview)
**Language**: English only

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-01-10 | Original |
| v2.0 | 2026-01-21 | Updated exclusion logic (at Power BI source), added correct field references |

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

## 2. System Architecture Context

### Data Flow
```
Power BI (FBL5N Source)
├── Exclusions applied at source (Paid, Partial Payment, etc.)
├── Only valid transactions exported
│
SAP Import Flow (07:00 Daily)
├── Reads from Power BI dataset
├── Creates Transaction records in Dataverse
├── Sets cr7bb_daycount based on Working Day Calendar
├── Creates ProcessLog record
│
Transactions Table
├── All records are valid (pre-filtered)
├── cr7bb_isprocessed = false (awaiting email)
└── cr7bb_isprocessed = true (included in email)
```

### Important Notes
- **Exclusions happen at Power BI source** - Excluded transactions never enter the system
- **All transactions in this screen are valid** - No exclusion filtering needed
- **Day count is calculated at import time** - Uses Working Day Calendar

---

## 3. Design Mockup

**Visual Layout**:

```
+------------------------------------------------------------------+
| [=] Transaction Management                              [Refresh] |
+------------------------------------------------------------------+
| FILTERS (H:140)                                                   |
| Customer: [Search...v]  Type: [All v]  Status: [All v]           |
| Date: [DD/MM/YYYY] to [DD/MM/YYYY]                               |
| Records: 156  |  Total: B1,234,567.89                            |
+------------------------------------------------------------------+
| ACTION BAR                                                        |
| [Mark Processed]  [Export to Excel]                              |
+------------------------------------------------------------------+
| TRANSACTION TABLE (Table@1.0.278)                                |
| Type | Document | Date | Days | Amount | Note | Processed        |
|------|----------|------|------|--------|------|------------------|
| DN   | 123456   | 01/12| 8    | B45,000|      | Yes              |
| CN   | 123457   | 05/12| 4    |-B10,000| Paid | -                |
| DN   | 123458   | 10/12| 0    | B25,000|      | Yes              |
+------------------------------------------------------------------+
| FIFO CALCULATION PREVIEW                                          |
| Customer: Charoen Pokphand Foods PCL                             |
| ---------------------------------------------------------------- |
| CN Total: B10,000  |  DN Total: B70,000                          |
|                                                                   |
| FIFO Application:                                                 |
| 1. Sort CN and DN by document date (oldest first)                |
| 2. Apply CN to DN until CN exhausted                             |
| 3. Calculate remaining DN balances                               |
| 4. Determine max day count for template selection                |
|                                                                   |
| Net Owed: B60,000                                                |
+------------------------------------------------------------------+
| [NavigationMenu - Left slide-in, W:260]                          |
+------------------------------------------------------------------+
```

---

## 4. Database Schema

**Data Source**: Dataverse

**Primary Entity**: `[THFinanceCashCollection]Transactions`

**Fields Used**:
| Field | Logical Name | Type | Notes |
|-------|--------------|------|-------|
| Customer | cr7bb_customer | Lookup | → Customers table |
| Document Number | cr7bb_documentnumber | Text | SAP doc # |
| Document Date | cr7bb_documentdate | Date | Transaction date |
| Document Type | cr7bb_documenttype | Text | DG, DR, DZ |
| Transaction Type | cr7bb_transactiontype | Choice | CN or DN |
| Amount | cr7bb_amountlocalcurrency | Currency | + or - |
| Day Count | cr7bb_daycount | Number | Days overdue (set at import) |
| Text Field | cr7bb_textfield | Text | SAP note |
| Is Processed | cr7bb_isprocessed | Boolean | Included in email |
| Process Date | cr7bb_processdate | Date | SAP extract date |

**Choice Field Syntax**:
```powerfx
// Transaction Type Choice
cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note'
cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note'
```

**Filter Example**:
```powerfx
SortByColumns(
    Filter(
        '[THFinanceCashCollection]Transactions',
        (IsBlank(_selectedCustomer) ||
         Customer.'[THFinanceCashCollection]Customer' = _selectedCustomer.'[THFinanceCashCollection]Customer') &&
        cr7bb_documentdate >= _dateFrom &&
        cr7bb_documentdate <= _dateTo &&
        (_typeFilter = "All" ||
         (_typeFilter = "CN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Credit Note') ||
         (_typeFilter = "DN" && cr7bb_transactiontype = 'Transaction Type Choice'.'Debit Note')) &&
        (_statusFilter = "All" ||
         (_statusFilter = "Processed" && cr7bb_isprocessed = true) ||
         (_statusFilter = "Unprocessed" && cr7bb_isprocessed = false))
    ),
    "cr7bb_documentdate",
    SortOrder.Ascending  // FIFO order
)
```

---

## 5. Key Features

### Filter Section
- Customer combo box (searchable)
- Date range (from/to)
- Type filter (All/CN/DN)
- Status filter (All/Processed/Unprocessed)
- Record count and total amount display

### Transaction Table (Table@1.0.278)
**Control**: Modern Table control with selection checkboxes

**Columns**:
1. **Type** (Text) - CN/DN with color formatting
2. **Document #** (Text) - Document number
3. **Date** (Date) - Format: dd/MM/yyyy
4. **Days** (Number) - Day count with conditional formatting
5. **Amount** (Text) - Formatted currency with color
6. **Note** (Text) - SAP text field
7. **Processed** (Boolean) - Checkmark indicator

**Formatting**:
- Type colors: CN=Green, DN=Red
- Day count colors: Day 0-2=Gray, Day 3=Yellow, Day 4+=Red
- Amount colors: Negative=Green (CN), Positive=Red (DN)

### FIFO Preview Panel
- Shows selected customer's CN/DN breakdown
- FIFO calculation explanation
- Net amount owed

### Actions
- Mark selected as processed
- Export to Excel (future)

---

## 6. Variables

**Screen Variables**:
- `_selectedCustomer` (Record): Filtered customer
- `_dateFrom` (Date): Start date (default: Today() - 30)
- `_dateTo` (Date): End date (default: Today())
- `_typeFilter` (Text): "All", "CN", "DN"
- `_statusFilter` (Text): "All", "Processed", "Unprocessed"

**Collections**:
- `colCustomers` (Collection): Customer list for filter dropdown
- `colTransactions` (Collection): Transaction records with calculated columns

**AddColumns Pattern** (for display formatting):
```powerfx
ClearCollect(
    colTransactions,
    AddColumns(
        '[THFinanceCashCollection]Transactions',
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
)
```

---

## 7. Business Rules

### FIFO Logic Display
1. Separate CN (negative amounts) and DN (positive amounts)
2. Sort both by document date (oldest first)
3. Apply CN to DN until CN exhausted
4. Display remaining DN balances
5. Calculate max day count
6. Show which email template would be used

### Day Count Color Coding
| Day Range | Template | Color | Label |
|-----------|----------|-------|-------|
| 0-2 | A | Gray | Standard |
| 3 | B | Yellow | Warning |
| 4+ | C/D | Red | Urgent |

### Mark Processed Logic
```powerfx
ForAll(
    Trans_Table.SelectedItems,
    Patch(
        '[THFinanceCashCollection]Transactions',
        ThisRecord,
        {cr7bb_isprocessed: true}
    )
);
Notify(
    CountRows(Trans_Table.SelectedItems) & " transactions marked as processed",
    NotificationType.Success
);
// Refresh collection
```

---

## 8. Navigation

**From**:
- scnDashboard (Transactions button)
- scnCustomer (Customer drill-down)

**To**:
- scnDashboard (nav menu)
- scnCustomer (nav menu)

---

## 9. Success Criteria

- [ ] Filter by customer, date, type, status works
- [ ] Table displays transactions in FIFO order with sortable columns
- [ ] Table selection allows multi-row selection via checkboxes
- [ ] FIFO preview shows correct calculation for selected customer
- [ ] Mark processed updates selected records
- [ ] Total amount calculates correctly
- [ ] Color coding matches business rules
- [ ] Table is responsive and scrollable

---

**READY FOR IMPLEMENTATION**
