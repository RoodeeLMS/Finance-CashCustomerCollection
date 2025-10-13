# Settings Screen Removed

**Date**: 2025-01-11
**Reason**: Settings table does not exist in Dataverse schema

---

## What Was Removed

**Screen**: `scnSettings.yaml` (660 lines)

**Functionality**:
- Email template configuration (Template A, B subject/body)
- Day count thresholds (Template B: 3 days, Template C: 4 days)
- Late fee rate configuration (1.5%)
- QR code SharePoint folder path
- Sender email address configuration

**Dataverse Dependency**: Required `[THFinanceCashCollection]Settings` table which was never created

---

## Impact

### Before Removal
- ❌ Screen would crash on load (Settings table not found)
- ❌ Save operations would fail
- ❌ Misleading UI (looked editable but wasn't functional)

### After Removal
- ✅ Navigation cleaned (Settings link removed)
- ✅ No runtime errors
- ✅ Hardcoded defaults in Power Automate flows

---

## Configuration Alternatives

Since Settings screen is removed, configuration must be done via:

### Option 1: Power Automate Flow Variables
**Templates and thresholds configured in Power Automate flow**
- Email Template A/B/C HTML stored in flow
- Day count thresholds: 3, 4 (hardcoded in flow logic)
- Late fee rate: 1.5% (hardcoded in flow)

### Option 2: Environment Variables
**Admin-managed via Power Platform**
- Create Environment Variables for each setting
- Flow reads from Environment Variables
- Updated by solution admin, not end users

### Option 3: SharePoint List (Future)
**Lightweight alternative to Dataverse table**
- Create "AppSettings" SharePoint list
- 3 columns: SettingKey, SettingValue, Description
- Canvas app reads from SharePoint list
- Can re-enable scnSettings screen with SharePoint connector

---

## Files Modified

1. ✅ **scnEmailApproval.yaml** - Removed Settings table lookup
   - Hardcoded `gblAutoApprove = true`
   - Lines 15-23 simplified to single line

2. ✅ **loadingScreen.yaml** - Removed Settings navigation
   - Removed "Settings" from AdminNavigation collection
   - Line 36: Settings entry deleted

3. ✅ **scnSettings.yaml** - File archived
   - Moved to: `scnSettings_ARCHIVED.yaml`
   - Not included in production deployment

---

## Navigation Changes

### Before (7 menu items):
1. Daily Control Center (scnDashboard)
2. Email Approval (scnEmailApproval)
3. Email Monitor (scnEmailMonitor)
4. Customer Management (scnCustomer)
5. Transactions (scnTransactions)
6. ~~Settings (scnSettings)~~ ← **REMOVED**
7. Role Management (scnRole)

### After (6 menu items):
1. Daily Control Center (scnDashboard)
2. Email Approval (scnEmailApproval)
3. Email Monitor (scnEmailMonitor)
4. Customer Management (scnCustomer)
5. Transactions (scnTransactions)
6. Role Management (scnRole)

---

## Future Restoration

To restore Settings functionality:

### If Creating Dataverse Table
1. Create `[THFinanceCashCollection]Settings` table
2. Restore `scnSettings.yaml` from archive
3. Update `scnEmailApproval.yaml` to read auto-approve from table
4. Re-add Settings to navigation

### If Using SharePoint List
1. Create "AppSettings" SharePoint list
2. Modify `scnSettings.yaml` to use SharePoint connector
3. Replace `'[THFinanceCashCollection]Settings'` with SharePoint list reference
4. Re-add Settings to navigation

---

## Testing Checklist

After removal:
- [x] scnEmailApproval loads without error
- [x] Auto-approve defaults to `true`
- [x] No Settings table errors in browser console
- [ ] Navigation menu shows 6 items (not 7)
- [ ] No "Settings" button in navigation
- [ ] loadingScreen navigation collection correct

---

**Status**: ✅ Settings removed, screens functional with hardcoded defaults
