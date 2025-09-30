# Power Apps Field Binding Rules

## ⚠️ CRITICAL: Verify Actual Field Names Before Coding

**ALWAYS check the exported YAML files in `Powerapp screens-DO-NOT-EDIT/` for actual field names used in production.**

Common discrepancies:
- Documentation may use placeholder names (`nc_fieldname`)
- Actual Dataverse uses solution publisher prefix (`cr7bb_fieldname`)
- Display names vs. logical names can differ

## Critical Field Naming Conventions

### Dataverse Choice Fields
When working with Dataverse choice (option set) fields, use consistent naming:

**CORRECT Pattern:**
```yaml
# Table column reference (in Table control)
FieldName: ="cr7bb_Region"  # Use the actual column name

# Data source for Choices
Items: =Choices('Region Choice')  # Reference the choice definition directly

# Default selection binding
DefaultSelectedItems: |-
  =If(
      IsBlank(currentSelectedCustomer.Region),
      Blank(),
      LookUp(
          Choices('Region Choice'),
          Value = currentSelectedCustomer.Region
      )
  )

# Patch/Save operation
Region: CustomerFormRegion.Selected.Value  # Save the Value property
```

**INCORRECT Pattern (DO NOT USE):**
```yaml
# ❌ Wrong - mixed field names
FieldName: ="nc_region"  # Inconsistent with actual schema
Items: =Choices('[THFinanceCashCollection]Customers'.nc_region)
DefaultSelectedItems: =currentSelectedCustomer.nc_region
nc_region: CustomerFormRegion.Selected
```

## ComboBox Choice Field Binding

### Two Valid Patterns for Choices:

**Pattern 1: Global Choice Definition (Preferred when available)**
```yaml
# Use when a global choice exists (e.g., 'Region Choice')
Items: =Choices('Region Choice')

DefaultSelectedItems: |-
  =If(
    IsBlank(currentRecord.Region),
    Blank(),
    LookUp(Choices('Region Choice'), Value = currentRecord.Region)
  )

# In Patch
Region: ComboBox.Selected.Value
```

**Pattern 2: Table Column Choice (Use when no global choice exists)**
```yaml
# Reference the choice field directly on the table
Items: =Choices('[THFinanceCashCollection]Transactions'.cr7bb_recordtype)

DefaultSelectedItems: |-
  =If(
    IsBlank(filterRecordType),
    Blank(),
    LookUp(
      Choices('[THFinanceCashCollection]Transactions'.cr7bb_recordtype),
      Value = filterRecordType
    )
  )

# In Filter - compare directly without LookUp
Or(IsBlank(filterRecordType), cr7bb_recordtype = filterRecordType)

# In Patch
cr7bb_recordtype: ComboBox.Selected.Value
```

**Key Difference:**
- ✅ `Choices('ChoiceName')` - For global choices shared across tables
- ✅ `Choices('[TableName]'.fieldname)` - For local choices on specific table columns
- ❌ `Choices('Field Name')` - Will fail if the global choice doesn't exist

## AutoLayout Container Spacing

### Always add LayoutGap for proper spacing:
```yaml
CustomerFormContainer:
  Control: GroupContainer@1.3.0
  Variant: AutoLayout
  Properties:
    LayoutDirection: =LayoutDirection.Vertical
    LayoutGap: =10  # ⚠️ REQUIRED for visual spacing
    LayoutOverflowX: =LayoutOverflow.Scroll
    LayoutOverflowY: =LayoutOverflow.Scroll
```

## Choice Field Container Pattern

### Wrap ComboBox controls in container for proper layout:
```yaml
- CustomerFormRegionContainer:
    Control: GroupContainer@1.3.0
    Variant: AutoLayout
    Properties:
      LayoutDirection: =LayoutDirection.Vertical
      PaddingLeft: =10
    Children:
      - CustomerFormRegionLabel:
          Control: Text@0.0.51
          Properties:
            Height: =20
            Text: ="Region *"
            Weight: ='TextCanvas.Weight'.Semibold
      - CustomerFormRegion:
          Control: ComboBox@0.0.51
          Properties:
            DefaultSelectedItems: =If(IsBlank(...), Blank(), LookUp(...))
            Items: =Choices('Region Choice')
```

## Lookup Field References

### ⚠️ CRITICAL: Accessing Related Records via Lookup Fields

When a field is a **Lookup** (foreign key relationship), use the correct syntax to access the related record's GUID:

**CORRECT Pattern for Lookup Field GUID:**
```yaml
# Access the GUID value of a lookup field
currentSelectedTransaction.Customer.'[THFinanceCashCollection]Customer'
```

**Full Example - Looking up related customer data:**
```yaml
Text: |-
  ="Customer: " & LookUp(
    '[THFinanceCashCollection]Customers',
    cr7bb_thfinancecashcollectioncustomerid = currentSelectedTransaction.Customer.'[THFinanceCashCollection]Customer'
  ).cr7bb_customername & " (" & LookUp(
    '[THFinanceCashCollection]Customers',
    cr7bb_thfinancecashcollectioncustomerid = currentSelectedTransaction.Customer.'[THFinanceCashCollection]Customer'
  ).cr7bb_customercode & ")"
```

**Simplified Alternative (Direct Navigation - Preferred if it works):**
```yaml
# Power Apps may automatically expand lookup relationships
Text: |-
  ="Customer: " & currentSelectedTransaction.Customer.cr7bb_customername &
  " (" & currentSelectedTransaction.Customer.cr7bb_customercode & ")"
```

**Key Components:**
- `Customer` = The lookup field name (no prefix)
- `.'[THFinanceCashCollection]Customer'` = The actual GUID accessor for that lookup
- Use this GUID value in LookUp operations to match against primary key fields

**INCORRECT Patterns (DO NOT USE):**
```yaml
# ❌ Wrong - Using field internal name directly
cr7bb_customer = currentSelectedTransaction.cr7bb_customer

# ❌ Wrong - Missing the proper GUID accessor
currentSelectedTransaction.Customer
```

## Field Name Consistency Checklist

Before generating Power Apps YAML:
- [ ] **PRIMARY SOURCE**: Check exported YAML in `Powerapp screens-DO-NOT-EDIT/` for actual field names
- [ ] **SECONDARY**: Reference database_schema.md (may have placeholder names)
- [ ] Verify correct prefix for all fields (cr7bb_ is current, not nc_)
- [ ] Choice fields: Reference choice definition, not table.field
- [ ] Choice fields: Use logical name (e.g., `Region`) in Patch, display name in FieldName (e.g., `cr7bb_Region`)
- [ ] ComboBox: Always use `.Selected.Value` for Patch operations
- [ ] Lookup fields: Use `LookupField.'[TableName]Table'` to access GUID value
- [ ] Add LayoutGap to AutoLayout containers
- [ ] Wrap choice fields in container with label

## Common Mistakes to Avoid

1. ❌ Using table.field syntax for Choices()
2. ❌ Omitting LookUp() for DefaultSelectedItems on choice fields
3. ❌ Using `.Selected` instead of `.Selected.Value` in Patch
4. ❌ Forgetting LayoutGap in AutoLayout containers
5. ❌ Inconsistent field name prefixes across controls
6. ❌ Using lookup field internal name (cr7bb_fieldname) instead of display name + GUID accessor
