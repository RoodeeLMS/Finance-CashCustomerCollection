# AI Assistant Rules Summary

**Purpose**: Sync rules across projects and AI assistants (Claude, Grok, Copilot, etc.)
**Created**: September 30, 2025
**Project**: Nestlé Finance - Cash Customer Collection Automation

---

## 🚨 Critical Rules - READ FIRST

### 1. Field Naming Convention ⚠️ MOST IMPORTANT

**ALWAYS verify field names from exported YAML files, NOT from documentation.**

| ❌ Documentation (Wrong) | ✅ Production (Correct) |
|-------------------------|------------------------|
| `nc_customercode` | `cr7bb_customercode` |
| `nc_customername` | `cr7bb_customername` |
| `nc_region` | `cr7bb_Region` (capital R) |
| `nc_customeremail1` | `cr7bb_customeremail1` |
| `nc_salesemail1` | `cr7bb_salesemail1` |
| `nc_arbackupemail1` | `cr7bb_arbackupemail1` |

**Rule**: All Dataverse fields use `cr7bb_` prefix (solution publisher prefix)

**Verification Sources** (in priority order):
1. 🥇 **[FIELD_NAME_REFERENCE.md](FIELD_NAME_REFERENCE.md)** - Production field reference
2. 🥈 **Exported YAML**: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
3. 🥉 **database_schema.md** - Conceptual schema (uses placeholder `nc_` prefix)

### 2. File Edit Policy

**Simple Rule**: Edit any file EXCEPT folders with `DO-NOT-EDIT` suffix

**✅ CAN EDIT**:
- All documentation files (*.md)
- Configuration files (*.json, *.yaml in root)
- Project planning files
- Files in `.cursor/rules/`
- Files in `.grok/`
- Any file NOT in a restricted folder

**❌ CANNOT EDIT**:
- `Powerapp components-DO-NOT-EDIT/` - Power Apps exports
- `Powerapp screens-DO-NOT-EDIT/` - Power Apps exports
- Any folder with `DO-NOT-EDIT` suffix

**Reason**: These are read-only exports. Always provide code snippets for manual implementation in Power Apps Studio.

---

## 📋 Power Apps Development Rules

### Choice Fields Special Handling

**Choice fields have TWO names**:

1. **Display Name** (for Table FieldName): `cr7bb_Region`
2. **Logical Name** (for Patch operations): `Region` (no prefix)

**Pattern to Follow**:

```yaml
# In Table control - use display name
CustomerRegion:
  Control: TableDataField@1.5.0
  Properties:
    FieldName: ="cr7bb_Region"  # Display name with prefix

# In ComboBox - reference choice definition
CustomerFormRegion:
  Control: ComboBox@0.0.51
  Properties:
    Items: =Choices('Region Choice')  # Direct choice reference
    DefaultSelectedItems: |-
      =If(
          IsBlank(currentRecord.Region),
          Blank(),
          LookUp(
              Choices('Region Choice'),
              Value = currentRecord.Region
          )
      )

# In Patch operation - use logical name
OnSelect: |-
  =Patch(
    '[THFinanceCashCollection]Customers',
    currentRecord,
    {
      Region: CustomerFormRegion.Selected.Value  # Logical name, no prefix
    }
  )
```

### AutoLayout Containers

**ALWAYS add `LayoutGap` for proper spacing**:

```yaml
Container:
  Control: GroupContainer@1.3.0
  Variant: AutoLayout
  Properties:
    LayoutDirection: =LayoutDirection.Vertical
    LayoutGap: =10  # ⚠️ REQUIRED - prevents controls from overlapping
```

### TextInput vs Value Property

**Use `.Value` property, not `.Text`**:

```yaml
# ✅ Correct
Value: =customerSearchText
OnChange: =UpdateContext({customerSearchText: Self.Value})

# ❌ Wrong
Text: =customerSearchText
OnChange: =UpdateContext({customerSearchText: Self.Text})
```

### Power Fx Formula Syntax

**ALL expressions must start with `=` symbol**:

```yaml
# ✅ Correct
Properties:
  Visible: =currentMode="View"
  Height: =Parent.Height-85

# ❌ Wrong
Properties:
  Visible: currentMode="View"
  Height: Parent.Height-85
```

### Gallery Control Best Practices

**Alternating row colors with GUIDs are inefficient**:

```yaml
# ❌ WRONG - GUID comparison is slow
Fill: |-
  =If(
      ThisItem.IsSelected,
      RGBA(0, 120, 215, 1),
      If(
          Mod(
              CountRows(Filter(colProcessLog, cr7bb_processlogid <= ThisItem.cr7bb_processlogid)),
              2
          ) = 0,
          RGBA(255, 255, 255, 1),
          RGBA(245, 245, 245, 1)
      )
  )

# ✅ CORRECT - Use simpler selection highlight only
Fill: |-
  =If(
      ThisItem.IsSelected,
      RGBA(0, 120, 215, 1),
      RGBA(255, 255, 255, 1)
  )
```

### Text Control Width Property

**Always specify Width to avoid 96px default**:

```yaml
# ❌ WRONG - Missing Width property
Text_ProcessDate:
  Control: Text@1.1.1
  Properties:
    Text: =Text(ThisItem.cr7bb_processdate, "yyyy-mm-dd")

# ✅ CORRECT - Explicit Width prevents issues
Text_ProcessDate:
  Control: Text@1.1.1
  Properties:
    Text: =Text(ThisItem.cr7bb_processdate, "yyyy-mm-dd")
    Width: =250
```

### Text Alignment for Numbers

**Use TextCanvas.Align.End for right-aligned numbers**:

```yaml
# ✅ Correct - Right-align numeric data
Text_TotalAmount:
  Control: Text@1.1.1
  Properties:
    Text: =Text(ThisItem.cr7bb_totalamount, "#,##0.00")
    Align: =TextCanvas.Align.End  # Right-aligned
    Width: =150
```

### Power Apps Enum Syntax

**Use correct TimeUnit and SortOrder syntax**:

```yaml
# ❌ WRONG - Old syntax
Filter: =Filter(colProcessLog, DateDiff(cr7bb_processdate, Now(), Minutes) <= 1440)
SortByColumns: =SortByColumns(colProcessLog, "cr7bb_processdate", Descending)

# ✅ CORRECT - Modern syntax
Filter: =Filter(colProcessLog, DateDiff(cr7bb_processdate, Now(), TimeUnit.Minutes) <= 1440)
SortByColumns: =SortByColumns(colProcessLog, "cr7bb_processdate", SortOrder.Descending)
```

---

## 🔄 Power Automate Rules

### Dataverse Table Names

**Use production table names with `cr7bb_` prefix**:

| ❌ Documentation | ✅ Production | Display Name |
|-----------------|--------------|--------------|
| `nc_customers` | `cr7bb_customers` | `[THFinanceCashCollection]Customers` |
| `nc_transactions` | `cr7bb_transactions` | `[THFinanceCashCollection]Transactions` |
| `nc_processlog` | `cr7bb_processlogs` | `Process Logs` |
| `nc_emaillog` | `cr7bb_emaillogs` | `Emaillogs` |

**Note**: Table names in YAML use display names (e.g., `'[THFinanceCashCollection]Customers'`), while Dataverse connectors use logical names (e.g., `cr7bb_customers`).

### Environment Configuration

**Don't hardcode `[ENVIRONMENT-NAME]`** - let Power Automate auto-configure:

1. Create/import flow
2. Open each Dataverse action
3. Select environment from dropdown
4. Power Automate generates correct path automatically

### OData Filter Queries

**Use correct field names in filters**:

```javascript
// ✅ Correct
"cr7bb_customercode eq '198609'"
"cr7bb_processdate eq '2025-09-29'"
"cr7bb_isexcluded eq false"

// ❌ Wrong
"nc_customercode eq '198609'"
"customercode eq '198609'"
```

---

## 📁 Project Structure

```
├── .cursor/rules/              # AI assistant rules (EDITABLE)
│   ├── edit_exceptions.md
│   ├── power-apps-field-binding.md
│   └── field-name-verification.md
├── .grok/                      # AI artifacts (EDITABLE)
├── Powerapp components-DO-NOT-EDIT/  # ❌ READ ONLY
├── Powerapp screens-DO-NOT-EDIT/     # ❌ READ ONLY
├── client docs/                # Client files (EDITABLE)
├── templates/                  # Templates (EDITABLE)
├── CLAUDE.md                   # Project instructions (EDITABLE)
├── FIELD_NAME_REFERENCE.md     # 🥇 PRIMARY FIELD REFERENCE
├── database_schema.md          # Conceptual schema (nc_ prefix)
└── PROJECT_STATUS.md           # Current status
```

---

## 🎯 Development Workflow

### Before Generating Any Code

**Checklist**:
- [ ] Check `FIELD_NAME_REFERENCE.md` for field names
- [ ] Verify in exported YAML: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
- [ ] Use `cr7bb_` prefix for all standard fields
- [ ] Use logical name (no prefix) for choice fields in Patch
- [ ] Use display name for choice fields in Table FieldName
- [ ] Add `LayoutGap` to AutoLayout containers
- [ ] Use `.Value` property for TextInput controls
- [ ] Start all formulas with `=`

### For Power Automate Flows

**Checklist**:
- [ ] Use `cr7bb_` prefix for all table names
- [ ] Reference production table names in paths
- [ ] Handle CSV formatting (comma separators in amounts)
- [ ] Parse dates from M/D/YYYY to ISO format
- [ ] Implement error handling with Try-Catch scopes
- [ ] Log errors to process log table
- [ ] Send email notifications for failures

---

## 🔍 Verification Commands

### Find Actual Field Names
```bash
# Search exported YAML for field patterns
grep -r "FieldName.*customer" "Powerapp screens-DO-NOT-EDIT/"
grep -r "cr7bb_" "Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml"
```

### Check Table References
```bash
# Find all table references in documentation
grep -r "nc_customers\|cr7bb_customers" .
```

---

## 🚨 Common Mistakes to Avoid

### 1. Using Documentation Field Names
```yaml
# ❌ WRONG - Using placeholder from database_schema.md
FieldName: ="nc_customercode"
nc_region: CustomerFormRegion.Selected

# ✅ CORRECT - Using production names
FieldName: ="cr7bb_customercode"
Region: CustomerFormRegion.Selected.Value
```

### 2. Missing Choice Field LookUp
```yaml
# ❌ WRONG - Direct assignment
DefaultSelectedItems: =currentRecord.nc_region

# ✅ CORRECT - LookUp with Choices
DefaultSelectedItems: |-
  =If(
      IsBlank(currentRecord.Region),
      Blank(),
      LookUp(Choices('Region Choice'), Value = currentRecord.Region)
  )
```

### 3. Table.Field Syntax for Choices
```yaml
# ❌ WRONG
Items: =Choices('[THFinanceCashCollection]Customers'.nc_region)

# ✅ CORRECT
Items: =Choices('Region Choice')
```

### 4. Forgetting LayoutGap
```yaml
# ❌ WRONG - Controls will overlap
Container:
  Variant: AutoLayout
  Properties:
    LayoutDirection: =LayoutDirection.Vertical

# ✅ CORRECT - Proper spacing
Container:
  Variant: AutoLayout
  Properties:
    LayoutDirection: =LayoutDirection.Vertical
    LayoutGap: =10
```

### 5. Text Field Type for Dates

```yaml
# ❌ WRONG - Using DateTime field type (causes Power Apps parsing errors)
cr7bb_processdate:
  Type: Edm.DateTimeOffset

# ✅ CORRECT - Use Text field, format as "yyyy-mm-dd"
cr7bb_processdate:
  Type: Edm.String  # Text field

# In Power Apps - format for display
Text: =Text(ThisItem.cr7bb_processdate, "yyyy-mm-dd")
```

### 6. Table Name Case Sensitivity

```yaml
# ❌ WRONG - Incorrect table name
Filter(ProcessLog, ...)  # No such table

# ✅ CORRECT - Use exact display name
Filter('[Process Logs]', ...)  # Space in name, plural
Filter(Emaillogs, ...)  # No space, lowercase second word
```

### 7. CSV Amount Parsing
```javascript
// ❌ WRONG - Doesn't handle commas
float(item()?['Amount in Local Currency'])

// ✅ CORRECT - Removes commas and quotes
float(replace(replace(item()?['Amount in Local Currency'], ',', ''), '"', ''))
```

---

## 📖 Reference Documentation

### Primary Sources (Always Trust These)
1. **FIELD_NAME_REFERENCE.md** - Production field names with examples
2. **Exported YAML files** - `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
3. **PowerAutomate_SAP_Data_Import_Flow.md** - Flow implementation guide

### Secondary Sources (Conceptual Only)
1. **database_schema.md** - Schema design (uses `nc_` placeholder prefix)
2. **CLAUDE.md** - General project guidance
3. **development_plan.md** - Timeline and milestones

### Rule Files
1. **.cursor/rules/edit_exceptions.md** - What files can be edited
2. **.cursor/rules/power-apps-field-binding.md** - Choice field binding rules
3. **.cursor/rules/field-name-verification.md** - Verification protocol

---

## 🤝 Syncing with Other AI Assistants

### If Using Grok, Copilot, or Other AI
1. Share this file: `AI_ASSISTANT_RULES_SUMMARY.md`
2. Point to `FIELD_NAME_REFERENCE.md` for field names
3. Emphasize: **Always verify field names from exported YAML**
4. Remind: **DO NOT edit files in `DO-NOT-EDIT` folders**

### Quick Sync Command
```bash
# Copy rules to project root for visibility
cp .cursor/rules/*.md ./rules-backup/
```

---

## 📊 Project Context

### Platform
- **Microsoft Power Platform** (Dataverse + Power Automate + Power Apps)
- **Model-Driven App** (primary) + Canvas App components (secondary)
- **Solution Publisher Prefix**: `cr7bb_`

### Core Tables
- **Customers**: `cr7bb_customers` → Display: `[THFinanceCashCollection]Customers`
- **Transactions**: `cr7bb_transactions` → Display: `[THFinanceCashCollection]Transactions`
- **Process Log**: `cr7bb_processlogs` → Display: `Process Logs` (note plural, space)
- **Email Log**: `cr7bb_emaillogs` → Display: `Emaillogs` (note plural, no space)

### Business Logic
- **Exclusion Keywords**: "Paid", "Partial Payment", "รักษาตลาด", "Bill credit 30 days", "PTP", "exclude"
- **Transaction Types**: DG→CN (Credit Note), DR→DN (Debit Note), DZ→CN
- **FIFO Processing**: Sort by document date, oldest first
- **Day Counting**: Track notification frequency per bill

---

## 🎓 Learning from This Project

### Key Lesson: Documentation vs. Reality
**Problem**: Documentation used placeholder field names (`nc_` prefix) but production used solution publisher prefix (`cr7bb_`)

**Solution**: Always verify actual field names from exported code before generating new code

**Prevention**: Created `FIELD_NAME_REFERENCE.md` as single source of truth

### Why This Matters
Power Apps will fail silently with wrong field names:
- Forms show blank values
- Patch operations don't update fields
- Filters return empty results
- No error messages - just broken functionality

**Takeaway**: Trust deployed code over design documentation

---

## ✅ Final Checklist for AI Assistants

Before starting work on this project:
- [ ] Read this file completely
- [ ] Bookmark `FIELD_NAME_REFERENCE.md`
- [ ] Verify you understand `cr7bb_` vs `nc_` prefix issue
- [ ] Know the difference between DO-NOT-EDIT and editable folders
- [ ] Understand choice field display name vs logical name
- [ ] Review Power Apps field binding rules
- [ ] Check Power Automate table naming conventions

---

## 📞 Questions or Issues?

If you encounter field name issues or rule conflicts:
1. Check `FIELD_NAME_REFERENCE.md` first
2. Verify in exported YAML: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
3. Review `.cursor/rules/field-name-verification.md`
4. Update this file with lessons learned

---

**Last Updated**: September 30, 2025 (Dashboard implementation updates)
**Status**: Active - All rules verified and tested
**Maintainer**: AI assistants working on this project

---

## 🆕 Recent Updates (Sept 30, 2025)

### Dashboard Implementation Learnings
1. **Table name verification**: `Process Logs` (space) vs `Emaillogs` (no space)
2. **Field type corrections**: Use Text fields for dates (avoid DateTime parsing issues)
3. **Gallery performance**: Removed inefficient alternating row colors with GUID comparisons
4. **Enum syntax**: Updated to `TimeUnit.Minutes` and `SortOrder.Descending`
5. **Text control defaults**: Always specify Width to avoid 96px default
6. **Field name fixes**: `cr7bb_sendstatus`, `cr7bb_processdate` validated from YAML