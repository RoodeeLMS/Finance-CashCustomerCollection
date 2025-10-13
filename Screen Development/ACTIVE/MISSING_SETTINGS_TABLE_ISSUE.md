# Missing Settings Table Issue

**Date**: 2025-01-11
**Status**: ⚠️ CRITICAL - Missing Dataverse Table

---

## Problem Summary

Two screens reference `[THFinanceCashCollection]Settings` table which **does not exist** in the database schema:

1. **scnSettings.yaml** - Entire screen depends on Settings table (all functionality broken)
2. **scnEmailApproval.yaml** - Auto-approve toggle reads from Settings table (1 feature broken)

---

## Affected Screens

### 1. scnSettings.yaml ❌ COMPLETELY NON-FUNCTIONAL

**Purpose**: Configure email templates, thresholds, QR codes, and system settings

**Settings Referenced**:
- `EmailTemplate_A_Subject` - Email template A subject line
- `EmailTemplate_A_Body` - Email template A HTML body
- `EmailTemplate_B_Subject` - Email template B subject line
- `EmailTemplate_B_Body` - Email template B HTML body
- `DayCount_TemplateB` - Day count threshold for template B (default: 3)
- `DayCount_TemplateC` - Day count threshold for template C (default: 4)
- `LateFeeRate` - Late fee percentage rate (default: 1.5)
- `QRCode_SharePointFolder` - SharePoint folder path for QR codes
- `Email_SenderAddress` - Default sender email address

**Impact**: 🔴 **HIGH** - Settings screen will fail to load, cannot configure templates

---

### 2. scnEmailApproval.yaml ⚠️ PARTIALLY NON-FUNCTIONAL

**Purpose**: Review and approve draft emails before sending

**Settings Referenced** (Lines 18-22):
```yaml
Set(
    gblAutoApprove,
    If(
        IsBlank(LookUp('[THFinanceCashCollection]Settings', cr7bb_settingkey = "AutoApproveEmails").cr7bb_settingvalue),
        true,  # Default if not found
        Value(LookUp('[THFinanceCashCollection]Settings', cr7bb_settingkey = "AutoApproveEmails").cr7bb_settingvalue)
    )
);
```

**Impact**: 🟡 **MEDIUM** - Auto-approve defaults to `true`, manual toggle still works, but value not persisted

---

## Root Cause

Settings table was **designed but never created** in Dataverse:
- ✅ Documented in screen requirements
- ✅ Implemented in screens (scnSettings, scnEmailApproval)
- ❌ **NOT in DATABASE_SCHEMA.md**
- ❌ **NOT in FIELD_NAME_REFERENCE.md**
- ❌ **NOT created in Dataverse**

---

## Solution Options

### Option 1: Create Settings Table in Dataverse ⭐ RECOMMENDED

**Action**: Create Dataverse table `[THFinanceCashCollection]Settings`

**Schema**:
```
Table Name: [THFinanceCashCollection]Settings
Primary Key: cr7bb_thfinancecashcollectionsettingid (GUID)

Fields:
- cr7bb_settingkey (Text, 100, Required, Unique) - Setting identifier
- cr7bb_settingname (Text, 255, Required) - Display name
- cr7bb_settingvalue (Text, 2000, Optional) - Setting value
- cr7bb_settingtype (Choice, Required) - Text/Number/Boolean/DateTime
- cr7bb_category (Choice, Required) - Templates/Thresholds/QRCodes/System
- cr7bb_description (Text, 500, Optional) - Setting description
- cr7bb_isactive (Yes/No, Required, Default: true) - Setting enabled
```

**Initial Data** (9 settings):
```
1. EmailTemplate_A_Subject | Text | Templates | "Payment Reminder - Outstanding Balance"
2. EmailTemplate_A_Body | Text | Templates | "<html>...</html>"
3. EmailTemplate_B_Subject | Text | Templates | "URGENT: Payment Required - Cash Discount Expiring"
4. EmailTemplate_B_Body | Text | Templates | "<html>...</html>"
5. DayCount_TemplateB | Number | Thresholds | "3"
6. DayCount_TemplateC | Number | Thresholds | "4"
7. LateFeeRate | Number | Thresholds | "1.5"
8. QRCode_SharePointFolder | Text | QRCodes | "/sites/Finance/Shared Documents/QR Codes"
9. Email_SenderAddress | Text | System | "ar.team@nestle.co.th"
10. AutoApproveEmails | Boolean | System | "true"
```

**Pros**:
- ✅ Screens work as designed
- ✅ Settings persisted and editable via UI
- ✅ Clean separation of config from code
- ✅ No screen changes needed

**Cons**:
- ⏱️ Requires Dataverse admin access
- ⏱️ 30-60 minutes to create table + seed data

**Time Estimate**: 1 hour

---

### Option 2: Hardcode Settings in Screens ⚠️ TEMPORARY FIX

**Action**: Replace LookUp calls with hardcoded values in both screens

**Changes Required**:

#### scnSettings.yaml - Convert to Display-Only
- Remove all Patch operations
- Show hardcoded values in read-only TextInput controls
- Add warning message: "Settings are hardcoded. Contact admin to update."

#### scnEmailApproval.yaml - Hardcode Auto-Approve
```yaml
# Before (BROKEN):
Set(gblAutoApprove, LookUp(...).cr7bb_settingvalue)

# After (HARDCODED):
Set(gblAutoApprove, true)  # Always default to auto-approve
```

**Pros**:
- ✅ Quick fix (30 minutes)
- ✅ No Dataverse changes needed
- ✅ Screens functional immediately

**Cons**:
- ❌ Settings not editable via UI
- ❌ Requires code changes to update settings
- ❌ scnSettings screen misleading (looks editable but isn't)
- ❌ Technical debt

**Time Estimate**: 30 minutes

---

### Option 3: Use Power Automate Environment Variables ⚠️ ALTERNATIVE

**Action**: Store settings as Environment Variables, read via Power Automate

**Implementation**:
- Create Environment Variables for each setting
- Power Automate reads variables and passes to Canvas App
- Canvas App receives settings via collection/context variable

**Pros**:
- ✅ No Dataverse table needed
- ✅ Settings managed by admins
- ✅ Standard Power Platform pattern

**Cons**:
- ❌ Cannot edit settings from Canvas App UI
- ❌ scnSettings screen still unusable
- ❌ Requires Power Automate flow changes
- ❌ More complex architecture

**Time Estimate**: 2 hours

---

## Recommended Action Plan

### Phase 1: Immediate Fix (30 minutes)
**Use Option 2 (Hardcode) to unblock development**

1. Update scnEmailApproval.yaml:
   - Hardcode `gblAutoApprove = true`
   - Remove Settings table lookup

2. Update scnSettings.yaml:
   - Convert to display-only
   - Add "Coming Soon" message
   - Hide Save buttons

3. Update FIELD_NAME_REFERENCE.md:
   - Document Settings table as "Planned"

### Phase 2: Permanent Solution (1 hour)
**Use Option 1 (Create Table) for production**

1. Create Settings table in Dataverse
2. Seed initial data
3. Revert scnSettings and scnEmailApproval to original design
4. Test both screens

---

## Decision Required

**Question**: Do you want to:

**A) Quick Fix (30 min)** - Hardcode settings, unblock development
- Screens work but not editable
- Can deploy immediately

**B) Proper Fix (1 hour)** - Create Settings table in Dataverse
- Screens fully functional
- Requires Dataverse admin access
- Best for production

**C) Both** - Quick fix now, proper fix later
- Deploy hardcoded version immediately
- Create table when admin available
- Switch screens back to table version

---

## Impact if Not Fixed

### scnSettings.yaml
- ❌ Screen will crash on load (table not found error)
- ❌ Cannot configure email templates
- ❌ Cannot adjust day count thresholds
- ❌ Cannot set QR code folder path

### scnEmailApproval.yaml
- ⚠️ Auto-approve always defaults to `true`
- ⚠️ Toggle works within session but not persisted
- ⚠️ Value resets to `true` on each screen load

---

## Files to Update

### If Hardcoding (Option 2):
1. `scnSettings.yaml` - Convert to read-only display
2. `scnEmailApproval.yaml` - Remove Settings lookup
3. `FIELD_NAME_REFERENCE.md` - Document hardcoded values

### If Creating Table (Option 1):
1. Create table in Dataverse solution
2. `DATABASE_SCHEMA.md` - Add Settings table schema
3. `FIELD_NAME_REFERENCE.md` - Add Settings field reference
4. Seed initial data via Excel/manual entry

---

## Testing Checklist

After fix applied:
- [ ] scnSettings loads without error
- [ ] Email templates display (hardcoded or from table)
- [ ] Save buttons work (Option 1) or hidden (Option 2)
- [ ] scnEmailApproval loads without error
- [ ] Auto-approve toggle works
- [ ] Auto-approve value persists (Option 1 only)
- [ ] No console errors referencing Settings table

---

**Status**: ⏸️ AWAITING DECISION - Choose Option A, B, or C above
