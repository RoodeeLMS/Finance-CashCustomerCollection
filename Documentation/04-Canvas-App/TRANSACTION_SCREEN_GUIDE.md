# Transaction Screen Implementation Guide

**Screen Name**: `scnTransactions`
**Purpose**: View, filter, and manage daily transaction data from SAP imports
**Created**: September 30, 2025

---

## 🎯 Screen Overview

The Transaction screen provides comprehensive transaction management capabilities for the AR team:

### Key Features
1. **Advanced Filtering** - Search, date range, record type, excluded status
2. **Transaction List View** - Sortable table with 10 key columns
3. **Detailed View** - Complete transaction information display
4. **Quick Actions** - Mark as paid, exclude, refresh data
5. **Statistics** - Real-time transaction count and total amount
6. **Responsive Layout** - Auto-layout containers for consistent spacing

---

## 📋 Screen Structure

```
scnTransactions
├── TransactionHeader (Navigation bar with hamburger menu)
├── TransactionMainContainer
│   ├── TransactionContent
│   │   ├── TransactionTableView (View Mode)
│   │   │   ├── TransactionFilterBar (3 rows of filters)
│   │   │   │   ├── Row 1: Search, Date Picker, Clear Date
│   │   │   │   ├── Row 2: Record Type Dropdown, Excluded Toggle
│   │   │   │   └── Row 3: Stats (Count, Amount), Action Buttons
│   │   │   └── TransactionTableTbl (Data table)
│   │   └── TransactionDetailsView (Details Mode)
│   │       ├── Basic Information Section
│   │       ├── Processing Status Section
│   │       └── Back Button
│   └── TransactionNavigationMenu
```

---

## 🔍 Filter Bar Components

### Row 1: Search and Date
```yaml
TransactionSearchInput:
  - Type: TextInput
  - Placeholder: "Search by document number, customer code, or reference..."
  - Width: 400px
  - Updates: transactionSearchText variable

TransactionProcessDatePicker:
  - Type: DatePicker
  - Default: Today()
  - Format: dd/mm/yyyy
  - Width: 200px
  - Updates: filterProcessDate variable

TransactionClearDateBtn:
  - Type: Button
  - Text: "All Dates"
  - Action: Clear date filter (show all dates)
  - Width: 100px
```

### Row 2: Type and Status
```yaml
TransactionRecordTypeDropdown:
  - Type: ComboBox
  - Items: Choices('Transaction Record Type')
  - Options: Transaction, Summary, Header
  - Default: Transaction
  - Width: 200px
  - Updates: filterRecordType variable

TransactionExcludedToggle:
  - Type: Toggle
  - Text: "Excluded Only"
  - Default: false
  - Width: 150px
  - Updates: filterExcludedOnly variable
```

### Row 3: Statistics and Actions
```yaml
TransactionCountLabel:
  - Shows: "Total: X transactions"
  - Dynamic: Counts filtered results

TransactionAmountLabel:
  - Shows: "Total Amount: X,XXX.XX"
  - Dynamic: Sums amounts in filtered results
  - Format: Currency with comma separators

Action Buttons:
  - View Details (Blue) - Opens detail view
  - Mark Paid (Green) - Marks transaction as excluded (paid)
  - Exclude (Orange) - Marks transaction as excluded (manual)
  - Refresh (Gray) - Refreshes data from Dataverse
```

---

## 📊 Table Columns

### Column Configuration

| # | Column | Field Name | Type | Width | Description |
|---|--------|------------|------|-------|-------------|
| 1 | Customer | `cr7bb_customer` | Lookup | Auto | Customer GUID (shows ID) |
| 2 | Document Number | `cr7bb_documentnumber` | Text | Auto | SAP document number |
| 3 | Doc Type | `cr7bb_documenttype` | Text | Auto | DG, DR, DZ, etc. |
| 4 | Document Date | `cr7bb_documentdate` | Date | Auto | Transaction date |
| 5 | Due Date | `cr7bb_netduedate` | Date | Auto | Payment due date |
| 6 | Days | `cr7bb_daycount` | Number | Auto | Days overdue |
| 7 | Amount | `cr7bb_amountlocalcurrency` | Currency | Auto | Transaction amount |
| 8 | Type | `cr7bb_transactiontype` | Choice | Auto | CN or DN |
| 9 | Excluded | `cr7bb_isexcluded` | Boolean | Auto | Excluded flag |
| 10 | Process Date | `cr7bb_processdate` | Date | Auto | Import date |

---

## 🔎 Filter Logic

### Complex Filter Formula

The table uses a sophisticated filter combining all criteria:

```javascript
Filter(
  '[THFinanceCashCollection]Transactions',
  And(
    // Search filter - matches document number, reference, or customer code
    Or(
      IsBlank(transactionSearchText),
      StartsWith(Upper(cr7bb_documentnumber), Upper(transactionSearchText)),
      StartsWith(Upper(cr7bb_reference), Upper(transactionSearchText)),
      StartsWith(Upper(LookUp('[THFinanceCashCollection]Customers',
        cr7bb_customerid = cr7bb_customer).cr7bb_customercode),
        Upper(transactionSearchText))
    ),
    // Date filter - exact match or show all
    Or(
      IsBlank(filterProcessDate),
      cr7bb_processdate = filterProcessDate
    ),
    // Record type filter
    Or(
      IsBlank(filterRecordType),
      cr7bb_recordtype = LookUp(Choices('Transaction Record Type'),
        Value = filterRecordType).Value
    ),
    // Excluded filter - toggle on/off
    Or(
      Not(filterExcludedOnly),
      cr7bb_isexcluded = true
    )
  )
)
```

### Filter Behavior

**Search Box**:
- Case-insensitive search
- Searches in: Document Number, Reference, Customer Code
- Uses `StartsWith()` for partial matching

**Date Picker**:
- Defaults to today's date
- Shows only transactions from selected date
- "All Dates" button clears filter

**Record Type Dropdown**:
- Transaction (default) - shows actual transactions
- Summary - shows customer totals
- Header - shows CSV headers (usually hidden)

**Excluded Toggle**:
- OFF (default) - shows all transactions
- ON - shows only excluded transactions

---

## 📝 Detail View Sections

### Basic Information Section (Blue Background)

Displays core transaction data:
- Customer name and code (looked up from Customers table)
- Document number
- Document type (DG, DR, DZ)
- Document date
- Net due date
- **Amount** (colored: Green if negative/CN, Red if positive/DN)
- Day count
- Reference
- Text field (multi-line, auto-height)

### Processing Status Section (Orange Background)

Shows system processing information:
- Record type
- Transaction type (CN/DN)
- **Excluded status** (colored: Red if yes, Green if no)
- Exclude reason
- Process date
- Process batch ID
- Is processed flag
- Email sent flag

---

## ⚡ Quick Actions

### Mark as Paid Button
```javascript
Patch(
  '[THFinanceCashCollection]Transactions',
  TransactionTableTbl.Selected,
  {
    cr7bb_isexcluded: true,
    cr7bb_excludereason: "Manually marked as paid"
  }
);
Notify("Transaction marked as paid", NotificationType.Success);
```

**When to use**: Customer has paid but not yet reflected in SAP

### Exclude Button
```javascript
Patch(
  '[THFinanceCashCollection]Transactions',
  TransactionTableTbl.Selected,
  {
    cr7bb_isexcluded: true,
    cr7bb_excludereason: "Manually excluded by user"
  }
);
Notify("Transaction excluded", NotificationType.Success);
```

**When to use**: Transaction should not be included in email processing (e.g., disputes, errors)

### Refresh Button
```javascript
Refresh('[THFinanceCashCollection]Transactions')
```

**When to use**: After Power Automate flow completes, to see new imported data

---

## 🎨 Design Patterns Used

### Color Coding
- **Blue** (`RGBA(174, 208, 221, 1)`) - Basic information section
- **Orange** (`RGBA(255, 243, 224, 1)`) - Processing status section
- **Light Blue** (`RGBA(240, 248, 255, 1)`) - Filter bar background
- **Green** - Positive status, Credit Notes (negative amounts)
- **Red** - Negative status, Debit Notes (positive amounts)

### Button Colors
- **Cyan** (`RGBA(141, 229, 250, 1)`) - View/Info actions
- **Green** (`RGBA(56, 178, 96, 1)`) - Positive actions (Mark Paid)
- **Orange** (`RGBA(255, 152, 0, 1)`) - Warning actions (Exclude)
- **Gray** (`RGBA(128, 128, 128, 1)`) - Neutral actions (Back, Refresh)

### Spacing
- **LayoutGap**: 10px (consistent across all AutoLayout containers)
- **Padding**: 10-15px for sections
- **Height Standards**:
  - Filter controls: 40px
  - Text labels: 30px
  - Buttons: 30-40px

---

## 📱 Screen Variables

### Initialized on OnVisible

```javascript
UpdateContext({currentScreen:"Transactions"});
UpdateContext({currentMode:"View"});
Set(_showMenu,false);
UpdateContext({ showConfirmationPopup: false });
UpdateContext({ dataSourceIdentifier: "" });
UpdateContext({ recordToDelete: Blank() });
UpdateContext({ recordPrimaryProperty: "" });
UpdateContext({currentSelectedTransaction:Blank()});
UpdateContext({transactionSearchText:""});
UpdateContext({filterProcessDate:Today()});
UpdateContext({filterCustomer:Blank()});
UpdateContext({filterRecordType:"Transaction"});
UpdateContext({filterExcludedOnly:false});
```

### Variable Reference

| Variable | Type | Purpose | Default |
|----------|------|---------|---------|
| `currentScreen` | Text | Screen identifier | "Transactions" |
| `currentMode` | Text | View mode toggle | "View" |
| `currentSelectedTransaction` | Record | Selected transaction | Blank() |
| `transactionSearchText` | Text | Search query | "" |
| `filterProcessDate` | Date | Date filter | Today() |
| `filterRecordType` | Text | Record type filter | "Transaction" |
| `filterExcludedOnly` | Boolean | Excluded toggle | false |

---

## 🧪 Testing Scenarios

### Test Case 1: Search Functionality
1. Enter document number in search box
2. Verify: Table shows only matching documents
3. Clear search box
4. Verify: All transactions shown

### Test Case 2: Date Filtering
1. Select yesterday's date
2. Verify: Only yesterday's transactions shown
3. Click "All Dates" button
4. Verify: All transactions shown regardless of date

### Test Case 3: Mark as Paid
1. Select a transaction
2. Click "Mark Paid" button
3. Verify: Transaction marked as excluded with reason "Manually marked as paid"
4. Toggle "Excluded Only" filter
5. Verify: Transaction now appears in excluded list

### Test Case 4: Detail View
1. Select a transaction
2. Click "View Details" button
3. Verify: Detail view shows all transaction information
4. Check amount color (green for negative, red for positive)
5. Click "Back to List" button
6. Verify: Returns to table view

### Test Case 5: Statistics
1. Apply filters to reduce transaction count
2. Verify: "Total" count matches visible rows
3. Verify: "Total Amount" matches sum of visible amounts
4. Clear filters
5. Verify: Statistics update to show all transactions

---

## 🚀 Implementation Steps

### Step 1: Import the YAML
1. Copy `snippets/scnTransactions.yaml` content
2. Open Power Apps Studio
3. Add new screen: **Insert** → **New screen** → **Blank**
4. Rename screen to `scnTransactions`
5. Paste YAML structure manually (build controls following YAML)

### Step 2: Configure Data Sources
1. Add data source: **Data** → **Add data** → Select `[THFinanceCashCollection]Transactions`
2. Add data source: **Data** → **Add data** → Select `[THFinanceCashCollection]Customers`
3. Verify connection established

### Step 3: Set Up Choice Fields
1. Verify choice field exists: `Transaction Record Type`
   - Values: Transaction, Summary, Header
2. Verify choice field exists: `Transaction Type`
   - Values: CN, DN

### Step 4: Test Filter Controls
1. Test search box with sample document number
2. Test date picker navigation
3. Test record type dropdown
4. Test excluded toggle

### Step 5: Configure Navigation
1. Add screen to Navigation collection (if not already present)
2. Set screen color in Navigation collection
3. Test hamburger menu navigation

---

## 🔧 Customization Options

### Add More Filters

**Customer Filter**:
```yaml
TransactionCustomerDropdown:
  Control: ComboBox@0.0.51
  Properties:
    Items: |-
      =Sort('[THFinanceCashCollection]Customers',
        cr7bb_customercode,
        SortOrder.Ascending)
    OnChange: =UpdateContext({filterCustomer:Self.Selected})
```

Add to filter formula:
```javascript
Or(
  IsBlank(filterCustomer),
  cr7bb_customer = filterCustomer.cr7bb_customerid
)
```

### Export to Excel

Add button:
```yaml
TransactionExportBtn:
  Control: Button@0.0.45
  Properties:
    Text: "Export to Excel"
    OnSelect: |-
      =Export(
        TransactionTableTbl.AllItems,
        "Transactions_" & Text(Now(), "yyyymmdd_hhmmss")
      )
```

### Bulk Operations

Add multi-select capability:
```yaml
# In Table control
Properties:
  EnableRangeSelection: ='PowerAppsOneGrid.EnableRangeSelection'.Enable
  SelectionType: Multiple

# Add bulk exclude button
BulkExcludeBtn:
  OnSelect: |-
    =ForAll(
      TransactionTableTbl.SelectedItems,
      Patch(
        '[THFinanceCashCollection]Transactions',
        ThisRecord,
        {
          cr7bb_isexcluded: true,
          cr7bb_excludereason: "Bulk excluded by user"
        }
      )
    );
    Notify(CountRows(TransactionTableTbl.SelectedItems) & " transactions excluded",
      NotificationType.Success);
```

---

## 🐛 Troubleshooting

### Issue: Table Shows No Data
**Cause**: Data source not connected or no data in Dataverse
**Solution**:
1. Check Data tab - ensure `[THFinanceCashCollection]Transactions` is connected
2. Run Power Automate import flow to populate data
3. Click Refresh button on screen

### Issue: Search Not Working
**Cause**: Field names incorrect or LookUp formula broken
**Solution**:
1. Verify field names use `cr7bb_` prefix
2. Check LookUp formula references correct customer table
3. Test search with exact document number first

### Issue: Date Filter Shows Wrong Data
**Cause**: Date format mismatch or timezone issue
**Solution**:
1. Ensure `cr7bb_processdate` is Date type (not DateTime)
2. Use exact match (`=`) not comparison (`<=`, `>=`)
3. Check date picker format matches database format

### Issue: Mark Paid Button Disabled
**Cause**: No transaction selected
**Solution**:
1. Click on a row in the table to select it
2. Verify `TransactionTableTbl.Selected` is not blank
3. Check button DisplayMode formula

### Issue: Customer Name Not Showing in Details
**Cause**: LookUp returning blank
**Solution**:
1. Verify `cr7bb_customer` field contains valid GUID
2. Check customer exists in Customers table
3. Test LookUp formula separately:
   ```
   LookUp('[THFinanceCashCollection]Customers',
     cr7bb_customerid = currentSelectedTransaction.cr7bb_customer)
     .cr7bb_customername
   ```

---

## 📊 Performance Considerations

### Optimization Tips

1. **Limit Data Retrieved**:
   - Default date filter to Today() reduces initial load
   - Use "Process Date" index in Dataverse

2. **Avoid Nested LookUps in Table**:
   - Customer name in detail view only (not in table)
   - Use customer GUID in table display

3. **Use Delegation-Friendly Formulas**:
   - `StartsWith()` is delegable
   - `Filter()` with `And()` is delegable
   - Avoid `Search()` for better performance

4. **Cache Customer Data**:
   ```javascript
   // On screen load
   ClearCollect(colCustomers, '[THFinanceCashCollection]Customers');

   // Use collection in LookUps
   LookUp(colCustomers, cr7bb_customerid = ...).cr7bb_customername
   ```

---

## 🎓 Key Learnings

### Power Apps Best Practices Applied

1. **AutoLayout Containers**: All sections use AutoLayout for responsive design
2. **LayoutGap**: Consistent 10px spacing prevents overlapping controls
3. **Field Name Consistency**: All fields use `cr7bb_` prefix (verified from FIELD_NAME_REFERENCE.md)
4. **Choice Field Handling**: Proper use of LookUp with Choices() for dropdown defaults
5. **Color Coding**: Visual indicators for status (excluded = red, paid = green)
6. **Context Variables**: Efficient state management with UpdateContext
7. **Patch Operations**: Single-responsibility buttons (Mark Paid vs Exclude)

### Reusable Patterns

- **Filter Bar Layout**: 3-row AutoLayout structure (reusable for other screens)
- **Stats Display**: Real-time count and sum formulas
- **Detail View Pattern**: Two-section layout with color coding
- **Button Groups**: Horizontal AutoLayout with consistent spacing

---

## 📚 Related Documentation

- [FIELD_NAME_REFERENCE.md](FIELD_NAME_REFERENCE.md) - Field naming guide
- [database_schema.md](database_schema.md) - Table structure
- [AI_ASSISTANT_RULES_SUMMARY.md](AI_ASSISTANT_RULES_SUMMARY.md) - Development rules
- [snippets/scnCustomer.yaml](snippets/scnCustomer.yaml) - Similar screen pattern

---

**Implementation Status**: ✅ Complete - Ready for Power Apps Studio
**Last Updated**: September 30, 2025
**Next Screen**: Dashboard (scnDashboard)