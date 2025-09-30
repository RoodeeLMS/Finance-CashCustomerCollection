# Transaction Screen - Complex Formulas Reference

**Note**: Some formulas are too complex for YAML parsing. Implement these manually in Power Apps Studio.

---

## Filter Formula for TransactionTableTbl.Items

**Location**: TransactionTableTbl → Properties → Items

**Formatted Formula** (copy this to Power Apps Studio):

```javascript
Filter(
    '[THFinanceCashCollection]Transactions',
    And(
        // Search filter - document number, reference, or customer code
        Or(
            IsBlank(transactionSearchText),
            StartsWith(Upper(cr7bb_documentnumber), Upper(transactionSearchText)),
            StartsWith(Upper(cr7bb_reference), Upper(transactionSearchText)),
            StartsWith(
                Upper(
                    LookUp(
                        '[THFinanceCashCollection]Customers',
                        cr7bb_customerid = cr7bb_customer
                    ).cr7bb_customercode
                ),
                Upper(transactionSearchText)
            )
        ),
        // Date filter
        Or(
            IsBlank(filterProcessDate),
            cr7bb_processdate = filterProcessDate
        ),
        // Record type filter
        Or(
            IsBlank(filterRecordType),
            cr7bb_recordtype = LookUp(
                Choices('Transaction Record Type'),
                Value = filterRecordType
            ).Value
        ),
        // Excluded filter
        Or(
            Not(filterExcludedOnly),
            cr7bb_isexcluded = true
        )
    )
)
```

**Single-Line Formula** (already in YAML, use if you need to paste):

```javascript
Filter('[THFinanceCashCollection]Transactions', And(Or(IsBlank(transactionSearchText), StartsWith(Upper(cr7bb_documentnumber), Upper(transactionSearchText)), StartsWith(Upper(cr7bb_reference), Upper(transactionSearchText))), Or(IsBlank(filterProcessDate), cr7bb_processdate = filterProcessDate), Or(IsBlank(filterRecordType), cr7bb_recordtype = LookUp(Choices('Transaction Record Type'), Value = filterRecordType).Value), Or(Not(filterExcludedOnly), cr7bb_isexcluded = true)))
```

**Note**: The single-line version excludes customer code search to avoid nesting issues. You can add it manually after pasting.

---

## ComboBox DefaultSelectedItems Formula

**Location**: TransactionRecordTypeDropdown → Properties → DefaultSelectedItems

**Formula**:

```javascript
If(
    IsBlank(filterRecordType),
    Blank(),
    LookUp(
        Choices('Transaction Record Type'),
        Value = filterRecordType
    )
)
```

---

## Statistics Formulas

### Transaction Count Label

**Location**: TransactionCountLabel → Properties → Text

```javascript
"Total: " & CountRows(TransactionTableTbl.AllItems) & " transactions"
```

### Transaction Amount Label

**Location**: TransactionAmountLabel → Properties → Text

```javascript
"Total Amount: " & Text(
    Sum(TransactionTableTbl.AllItems, cr7bb_amountlocalcurrency),
    "#,##0.00"
)
```

---

## Detail View Customer Lookup

**Location**: TransactionDetailsCustomerLabel → Properties → Text

**Formatted Formula**:

```javascript
"Customer: " &
LookUp(
    '[THFinanceCashCollection]Customers',
    cr7bb_customerid = currentSelectedTransaction.cr7bb_customer
).cr7bb_customername &
" (" &
LookUp(
    '[THFinanceCashCollection]Customers',
    cr7bb_customerid = currentSelectedTransaction.cr7bb_customer
).cr7bb_customercode &
")"
```

**Optimization Tip**: Use a variable to avoid double lookup:

```javascript
// In View Details button OnSelect, add:
UpdateContext({
    currentMode: "Details",
    currentSelectedTransaction: TransactionTableTbl.Selected,
    currentCustomer: LookUp(
        '[THFinanceCashCollection]Customers',
        cr7bb_customerid = TransactionTableTbl.Selected.cr7bb_customer
    )
});

// Then in label, use:
"Customer: " & currentCustomer.cr7bb_customername & " (" & currentCustomer.cr7bb_customercode & ")"
```

---

## Button Actions

### Mark Paid Button - OnSelect

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

### Exclude Button - OnSelect

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

### Refresh Button - OnSelect

```javascript
Refresh('[THFinanceCashCollection]Transactions')
```

### View Details Button - OnSelect

```javascript
UpdateContext({currentMode: "Details"});
UpdateContext({currentSelectedTransaction: TransactionTableTbl.Selected});
```

**Or combined**:

```javascript
UpdateContext({
    currentMode: "Details",
    currentSelectedTransaction: TransactionTableTbl.Selected
});
```

### Back to List Button - OnSelect

```javascript
UpdateContext({currentMode: "View"});
UpdateContext({currentSelectedTransaction: Blank()});
```

---

## Color Formulas

### Amount Color (in Detail View)

**Location**: TransactionDetailsAmountLabel → Properties → FontColor

```javascript
If(
    currentSelectedTransaction.cr7bb_amountlocalcurrency < 0,
    RGBA(0, 128, 0, 1),  // Green for negative (Credit Notes)
    RGBA(255, 0, 0, 1)   // Red for positive (Debit Notes)
)
```

### Excluded Status Color

**Location**: TransactionDetailsExcludedLabel → Properties → FontColor

```javascript
If(
    currentSelectedTransaction.cr7bb_isexcluded,
    RGBA(255, 0, 0, 1),  // Red for excluded
    RGBA(0, 128, 0, 1)   // Green for not excluded
)
```

---

## Implementation Order

When building the screen manually in Power Apps Studio:

1. ✅ Create screen structure (containers, header)
2. ✅ Add filter controls (search box, date picker, dropdown, toggle)
3. ✅ Add action buttons
4. ✅ Add statistics labels with formulas
5. ✅ Add table with columns
6. ⚠️ **LAST**: Add table Items formula (complex, may need adjustment)
7. ✅ Add detail view containers
8. ✅ Add detail view labels with lookups
9. ✅ Test all formulas

---

## Troubleshooting Formula Errors

### Error: "Invalid name"
**Cause**: Field name typo or wrong prefix
**Fix**: Verify all fields use `cr7bb_` prefix from FIELD_NAME_REFERENCE.md

### Error: "Incompatible types for comparison"
**Cause**: Comparing wrong data types (e.g., text to date)
**Fix**: Check data types, use Text() for currency/numbers, use DateValue() for dates

### Error: "The function 'LookUp' has some invalid arguments"
**Cause**: Table name or field name incorrect
**Fix**: Ensure table name in quotes: `'[THFinanceCashCollection]Transactions'`

### Error: "Name isn't valid"
**Cause**: Variable not initialized
**Fix**: Check OnVisible initializes all variables used in formulas

---

## Performance Tips

1. **Avoid nested LookUps in table Items**: Use collection cache
2. **Use delegation-friendly functions**: StartsWith(), Filter(), And(), Or()
3. **Limit initial data load**: Default date filter to Today()
4. **Cache customer data**: ClearCollect on screen load

**Example cache pattern**:

```javascript
// In OnVisible, add:
ClearCollect(colCustomers, '[THFinanceCashCollection]Customers');

// In LookUp formulas, replace:
LookUp('[THFinanceCashCollection]Customers', ...)

// With:
LookUp(colCustomers, ...)
```

---

**Last Updated**: September 30, 2025
**Status**: Ready for manual implementation in Power Apps Studio