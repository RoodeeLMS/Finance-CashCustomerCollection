# Field Name Verification Protocol

## Critical Rule: Trust Exported Code Over Documentation

**When there's a conflict between documentation and exported code, ALWAYS trust the exported code.**

## Known Discrepancies

### Database Schema Documentation vs. Reality

**database_schema.md contains placeholder names that DO NOT match production:**

| Documentation Says | Actual Production Field |
|-------------------|-------------------------|
| `nc_customerid` | `cr7bb_customerid` |
| `nc_customercode` | `cr7bb_customercode` |
| `nc_customername` | `cr7bb_customername` |
| `nc_region` | `cr7bb_Region` (note capital R) |
| `nc_customeremail1` | `cr7bb_customeremail1` |
| `nc_salesemail1` | `cr7bb_salesemail1` |
| `nc_arbackupemail1` | `cr7bb_arbackupemail1` |

**Reason:** Documentation was written with conceptual names before actual Dataverse solution was created. The solution publisher prefix is `cr7bb_`.

### Correct Field Naming Pattern

**For Customer table:**
```yaml
# Standard fields
cr7bb_customercode      # Text field
cr7bb_customername      # Text field
cr7bb_Region           # Choice field (display name, capital R)
cr7bb_customeremail1    # Email field

# In Patch operations (logical names)
Region: value           # Logical name for choice field (no prefix)
cr7bb_customercode: value  # Logical name for standard field (with prefix)
```

## Verification Workflow

### Step 1: Check Production Exports
```
1. Navigate to: Powerapp screens-DO-NOT-EDIT/ or Powerapp components-DO-NOT-EDIT/
2. Find relevant YAML file
3. Search for FieldName: or Patch() operations
4. Document actual field names used
```

### Step 2: Cross-Reference with Dataverse
If available, check Power Apps Studio:
```
1. Open Power Apps Studio
2. Navigate to Data > Tables
3. Select '[THFinanceCashCollection]Customers'
4. View Columns > check Name and Display Name
```

### Step 3: Update Working Knowledge
Before generating new code:
- [ ] List all fields needed for the component
- [ ] Verify each field name from exported YAML
- [ ] Note any choice fields (special handling required)
- [ ] Document findings for future reference

## Quick Reference: Current Production Fields

### Customer Table (`[THFinanceCashCollection]Customers`)
**Prefix: `cr7bb_`**

**Basic Info:**
- `cr7bb_customercode` (Text)
- `cr7bb_customername` (Text)
- `cr7bb_Region` (Choice) → Patch as `Region: value`

**Customer Emails:**
- `cr7bb_customeremail1` through `cr7bb_customeremail4`

**Sales Emails:**
- `cr7bb_salesemail1` through `cr7bb_salesemail5`

**AR Backup Emails:**
- `cr7bb_arbackupemail1` through `cr7bb_arbackupemail4`

## Testing New Field Names

When uncertain about a field name:

1. **Read exported YAML** - Most reliable source
2. **Grep for patterns** - Find similar usage
   ```bash
   grep -r "FieldName.*customer" "Powerapp screens-DO-NOT-EDIT/"
   ```
3. **Check multiple files** - Consistency across components
4. **Ask user** - If still unclear, ask before generating code

## Why This Matters

**Power Apps will fail silently if field names are wrong:**
- Forms will show blank values
- Patch operations will succeed but not update correct fields
- Filters and searches will return empty results
- No error messages, just broken functionality

**Always verify, never assume.**

---

**Last Updated:** 2025-09-30
**Status:** Active - Critical for all Power Apps code generation