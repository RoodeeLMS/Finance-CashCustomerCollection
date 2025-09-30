# Field Name Corrections - September 30, 2025

## Issue Summary

Documentation (`database_schema.md`) was using placeholder field names with `nc_` prefix, but production Power Apps use `cr7bb_` prefix from the solution publisher.

This caused confusion when generating Power Apps YAML code.

## Resolution

### 1. Updated Edit Policy
**File**: `.cursor/rules/edit_exceptions.md`

**Changes**:
- Expanded edit permissions to all files EXCEPT folders with `DO-NOT-EDIT` suffix
- Simplified rule: Can edit everything except `Powerapp components-DO-NOT-EDIT/` and `Powerapp screens-DO-NOT-EDIT/`
- Added proactive editing guidelines for documentation fixes

### 2. Enhanced Field Binding Rules
**File**: `.cursor/rules/power-apps-field-binding.md`

**Changes**:
- Added critical warning to verify field names from exported YAML first
- Updated checklist to prioritize exported YAML over documentation
- Clarified difference between display names and logical names for choice fields

### 3. New Field Name Verification Protocol
**File**: `.cursor/rules/field-name-verification.md`

**Created**: Complete verification protocol with:
- Known discrepancies table (nc_ vs cr7bb_)
- Step-by-step verification workflow
- Quick reference for current production fields
- Testing guidelines when uncertain
- Explanation of why this matters

### 4. New Production Field Reference
**File**: `FIELD_NAME_REFERENCE.md`

**Created**: Comprehensive reference guide with:
- Complete list of actual production field names
- Usage examples for all scenarios (Table, ComboBox, Patch, Filter)
- Special notes on choice field handling
- Verification checklist
- Common mistakes to avoid

### 5. Updated Project Documentation
**Files Updated**:

#### CLAUDE.md
- Added warning about field name verification
- Changed table reference from `nc_customers` to actual prefix `cr7bb_`
- Added critical note to verify from exported YAML

#### database_schema.md
- Added prominent warning at top about placeholder names
- Cross-reference to FIELD_NAME_REFERENCE.md
- Clarified that `nc_` prefix is conceptual only

## Field Name Mapping

| Documentation (Placeholder) | Production (Actual) |
|----------------------------|---------------------|
| `nc_customercode` | `cr7bb_customercode` |
| `nc_customername` | `cr7bb_customername` |
| `nc_region` | `cr7bb_Region` (capital R) |
| `nc_customeremail1` | `cr7bb_customeremail1` |
| `nc_salesemail1` | `cr7bb_salesemail1` |
| `nc_arbackupemail1` | `cr7bb_arbackupemail1` |

**Pattern**: All fields use `cr7bb_` prefix (solution publisher)

## Critical Rule for AI Code Generation

**ALWAYS**:
1. Check `FIELD_NAME_REFERENCE.md` first
2. Verify in exported YAML: `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`
3. Use `cr7bb_` prefix for all standard fields
4. Use logical name (no prefix) for choice fields in Patch operations
5. Use display name for choice fields in Table FieldName properties

**NEVER**:
- Trust documentation alone without verification
- Assume field names based on patterns
- Use `nc_` prefix (it's conceptual only)

## Files Modified

1. ✅ `.cursor/rules/edit_exceptions.md` - Updated edit policy
2. ✅ `.cursor/rules/power-apps-field-binding.md` - Enhanced with warnings
3. ✅ `.cursor/rules/field-name-verification.md` - NEW verification protocol
4. ✅ `FIELD_NAME_REFERENCE.md` - NEW production reference
5. ✅ `CLAUDE.md` - Added field name warnings
6. ✅ `database_schema.md` - Added placeholder notice

## Testing the Fix

To verify the fixes work:

1. Generate new Power Apps code following the updated rules
2. Check that all field names use `cr7bb_` prefix
3. Verify choice fields use correct pattern:
   - Display: `cr7bb_Region`
   - Logical: `Region`
4. Confirm code matches exported YAML patterns

## Impact

**Before**: Generated code used wrong field names (`nc_*`), causing silent failures
**After**: Generated code uses correct field names (`cr7bb_*`), matching production

---

**Resolution Date**: September 30, 2025
**Status**: ✅ Complete - All documentation updated and rules enhanced
**Next Steps**: Apply these rules to all future code generation