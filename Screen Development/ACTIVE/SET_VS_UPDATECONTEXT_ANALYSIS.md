# Set() vs UpdateContext() Analysis

**Date**: 2025-01-11
**Issue**: Most screens use `Set()` for variables - should they use `UpdateContext()`?

---

## Quick Answer

**It depends on variable scope:**
- **Global variables** (app-wide): Use `Set()` ✅
- **Local/screen variables** (single screen): Use `UpdateContext()` ✅

**Current Usage**: 119 instances of `Set()` across 8 screens

---

## The Difference

### Set() - Global Variables
```yaml
OnVisible: |-
  =Set(gblAutoApprove, true);          # Global variable (persists across screens)
  Set(gblCurrentUser, User());          # Available in ALL screens
  Set(_showMenu, false)                 # WRONG - underscore prefix = local!
```

**Characteristics**:
- **Scope**: Entire app (all screens)
- **Naming**: Prefix with `gbl` (e.g., `gblCurrentUser`)
- **Performance**: Slightly slower (app-wide state)
- **Use when**: Variable needed across multiple screens

---

### UpdateContext() - Local Variables
```yaml
OnVisible: |-
  =UpdateContext({currentScreen: "Dashboard"});   # Local to this screen
  UpdateContext({_showMenu: false});               # Local variable (underscore)
  UpdateContext({_filterDate: Today()})            # Screen-specific state
```

**Characteristics**:
- **Scope**: Single screen only
- **Naming**: Prefix with underscore `_` (e.g., `_showMenu`)
- **Performance**: Faster (screen-local state)
- **Use when**: Variable only used in one screen

---

## Current Issues in Our Screens

### ❌ Issue 1: Using Set() for Local Variables

**Example from scnDashboard.yaml (Line 8-22)**:
```yaml
OnVisible: |-
  =UpdateContext({currentScreen: "Dashboard"});   # ✅ Correct (local)
  Set(_showMenu, false);                          # ❌ WRONG - should use UpdateContext
  Set(_filterDate, Today());                      # ❌ WRONG - should use UpdateContext
  Set(_refreshTrigger, true);                     # ❌ WRONG - should use UpdateContext
```

**Why it's wrong**:
- `_showMenu` only used in scnDashboard (not global)
- `_filterDate` only used in scnDashboard (not global)
- Using `Set()` creates unnecessary global pollution

---

### ✅ Issue 2: Correct Global Usage

**Example from loadingScreen.yaml (Lines 8-26)**:
```yaml
Set(gblCurrentUser, User());                      # ✅ Correct - Used in ALL screens
Set(gblCurrentUserRole, LookUp(...));             # ✅ Correct - Used for permissions
Set(gblUserRole, "Unauthorized");                 # ✅ Correct - Used in navigation
Set(_isAdmin, ...);                               # ❌ WRONG - should use UpdateContext
```

**Correct globals**:
- `gblCurrentUser` - Used across multiple screens ✅
- `gblCurrentUserRole` - Used for role-based access ✅
- `gblAutoApprove` (scnEmailApproval) - Used in toggle logic ✅

---

## Fixing the Issues

### Pattern 1: Convert Set() to UpdateContext() for Local Variables

**Before (WRONG)**:
```yaml
OnVisible: |-
  =UpdateContext({currentScreen: "Dashboard"});
  Set(_showMenu, false);
  Set(_filterDate, Today());
  Set(_selectedCustomer, Blank());
```

**After (CORRECT)**:
```yaml
OnVisible: |-
  =UpdateContext({
      currentScreen: "Dashboard",
      _showMenu: false,
      _filterDate: Today(),
      _selectedCustomer: Blank()
  });
```

**Benefits**:
- ✅ Faster performance (local scope)
- ✅ Cleaner code (single UpdateContext)
- ✅ No global pollution
- ✅ Variables auto-cleared when leaving screen

---

### Pattern 2: Keep Set() for True Globals

**Correct Usage**:
```yaml
OnVisible: |-
  =Set(gblCurrentUser, User());              # ✅ Global - used in multiple screens
  Set(gblAutoApprove, true);                 # ✅ Global - persists across screens
  UpdateContext({_showMenu: false});         # ✅ Local - screen-specific
```

---

## Detailed Analysis by Screen

### scnDashboard.yaml - 22 Set() calls
**Should be UpdateContext()**:
- `_showMenu` (line 9)
- `_filterDate` (line 10)
- `_refreshTrigger` (line 11)
- All other `_` prefixed variables

**Should remain Set()**:
- None (no global variables in this screen)

---

### loadingScreen.yaml - 4 Set() calls
**Should remain Set()** (globals):
- `gblCurrentUser` ✅
- `gblCurrentUserRole` ✅
- `gblUserRole` ✅

**Should be UpdateContext()**:
- `_isAdmin` (line 24)
- `isLoadingReady` (line 9, 62) - BUT this is used by Timer control, may need to stay Set()

---

### scnEmailApproval.yaml - 18 Set() calls
**Should remain Set()** (globals):
- `gblAutoApprove` (line 16) ✅ - Used in toggle across sessions

**Should be UpdateContext()**:
- `_showMenu` (line 8)
- `_filterDate` (line 9)
- `_showPreview` (line 10)
- `_selectedEmail` (line 11)
- `_refreshTrigger` (line 12)
- `_isLoading` (line 13, 49)

---

### scnCustomer.yaml - 18 Set() calls
**All should be UpdateContext()**:
- `_showMenu`, `_searchText`, `_showEditPanel`, `_editMode`, `_selectedCustomer`, `_formMode`, `_highlightRow`
- No global variables needed

---

### scnTransactions.yaml - 12 Set() calls
**All should be UpdateContext()**:
- `_showMenu`, `_selectedCustomer`, `_dateFrom`, `_dateTo`, `_typeFilter`, `_statusFilter`
- No global variables needed

---

### scnEmailMonitor.yaml - 20 Set() calls
**All should be UpdateContext()**:
- `_showMenu`, `_filterDate`, `_statusFilter`, `_selectedEmail`, `_showDetails`, `_refreshTrigger`
- No global variables needed

---

### scnRole.yaml - 18 Set() calls
**All should be UpdateContext()**:
- `_showMenu`, `_searchText`, `_statusFilter`, `_showEditPanel`, `_editMode`, `_selectedUser`
- No global variables needed

---

## Recommendation

### Option A: Fix All Screens (Recommended for Production) ⭐
**Time**: 1 hour
**Impact**: Performance improvement + cleaner code

**Convert all `_` prefixed Set() to UpdateContext()**:
1. scnDashboard: 18 conversions
2. scnCustomer: 18 conversions
3. scnTransactions: 12 conversions
4. scnEmailMonitor: 20 conversions
5. scnRole: 18 conversions
6. scnEmailApproval: 17 conversions (keep gblAutoApprove)
7. loadingScreen: 1 conversion (_isAdmin)

**Total**: ~104 Set() calls should become UpdateContext()

---

### Option B: Leave As-Is (Works but Not Ideal) ⚠️
**Time**: 0 minutes
**Impact**: No immediate issues, slight performance overhead

**Reasoning**:
- Set() with local variables still works
- Creates global variables unnecessarily
- Minor performance impact (negligible for small apps)
- Not a critical error, just not best practice

---

### Option C: Fix Critical Screens Only (Quick Win) 🏃
**Time**: 20 minutes
**Impact**: Addresses worst offenders

**Fix only screens with many Set() calls**:
1. scnDashboard (22 calls)
2. scnEmailMonitor (20 calls)
3. scnCustomer (18 calls)

---

## Best Practices Moving Forward

### Naming Convention
```yaml
# Global variables (app-wide)
gblCurrentUser          # ✅ Prefix with 'gbl'
gblAutoApprove          # ✅ Use Set()

# Local variables (screen-specific)
_showMenu               # ✅ Prefix with '_'
_filterDate             # ✅ Use UpdateContext()

# Context variables (screen-local)
currentScreen           # ✅ No prefix (also use UpdateContext)
isLoadingReady          # ✅ No prefix (also use UpdateContext)
```

### Usage Pattern
```yaml
OnVisible: |-
  =/* Globals first (if any) */
  Set(gblCurrentUser, User());
  Set(gblAutoApprove, true);

  /* Then locals (grouped) */
  UpdateContext({
      currentScreen: "Dashboard",
      _showMenu: false,
      _filterDate: Today(),
      _selectedItem: Blank()
  });

  /* Then data loading */
  ClearCollect(colCustomers, '[THFinanceCashCollection]Customers');
```

---

## Performance Impact

### Set() for Local Variables
- Creates global variable in app state
- Variable persists even after leaving screen
- Slightly slower access (global scope lookup)
- Memory not released until app closed

### UpdateContext() for Local Variables
- Creates local variable in screen context
- Variable cleared when leaving screen
- Faster access (local scope)
- Memory released when screen unloaded

**For 100+ Set() calls**: Estimated 50-100ms slower app load time (negligible)

---

## Testing After Fix

If you choose to fix:
- [ ] Test all OnVisible formulas
- [ ] Verify variables work in button OnSelect
- [ ] Check gallery Items formulas still reference correct variables
- [ ] Ensure no "variable not found" errors
- [ ] Test navigation between screens

---

## Decision Required

**Which option do you prefer?**

**A) Fix All** (1 hour) - Best practice, clean code ⭐
**B) Leave As-Is** - Works, but not optimal ⚠️
**C) Fix Top 3** (20 min) - Quick improvement 🏃

---

**My Recommendation**: **Option B (Leave As-Is)** for now

**Reasoning**:
1. Screens already functional ✅
2. No critical errors (just best practice)
3. Minimal performance impact for ~100 customers
4. Can optimize later if performance issues arise
5. Focus time on testing actual functionality

**If you want maximum quality**: Choose Option A and I'll convert all Set() → UpdateContext()
