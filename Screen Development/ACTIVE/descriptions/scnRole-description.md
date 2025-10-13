# Screen Description: scnRole

**Created**: 2025-01-10
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-table-view.yaml
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
Manage user access by assigning roles (Admin, Manager, Analyst, Viewer) to users via their email addresses.

**Who uses it**:
- **Admin** - Full CRUD access for user roles

**User Goals**:
- Add new users to the system
- Assign roles to users
- Activate/deactivate user access
- View all users and their roles

---

## 2. Design Mockup

**Visual Layout**:

```
┌─────────────────────────────────────────────────────────────────┐
│ [HEADER - H:55]                                                 │
│ ◰  User Role Management                    [User Profile] 🚪    │
├─────────────────────────────────────────────────────────────────┤
│ [CONTENT - ManualLayout]                                        │
│                                                                  │
│ ┌────────── TOOLBAR (H:60) ────────────┐                       │
│ │ [+ New User]  Search: [_______] 🔍    │                       │
│ │ [Active ▼] Active Users: 8            │                       │
│ └────────────────────────────────────────┘                       │
│                                                                  │
│ ┌────────── USER LIST (Gallery) ──────────────┐                │
│ │ Email              │ Name    │ Role   │ Active│ Actions│     │
│ │────────────────────┼─────────┼────────┼───────┼────────│     │
│ │admin@nestle.com    │John Doe │Admin   │  ✓    │ [Edit] │     │
│ │analyst@nestle.com  │Jane Lee │Analyst │  ✓    │ [Edit] │     │
│ │manager@nestle.com  │Tom Smith│Manager │  ✓    │ [Edit] │     │
│ └────────────────────────────────────────────────────────┘       │
│                                                                  │
│ [EDIT PANEL - Side overlay, W:400]                             │
│ ┌──────── EDIT USER ─────────┐                                 │
│ │ User Email: [___________]  │                                 │
│ │ User Name:  [___________]  │                                 │
│ │ Role:       [Admin ▼]      │                                 │
│ │ Active:     ● Yes  ○ No    │                                 │
│ │ ───────────────────────     │                                 │
│ │ [💾 Save] [❌ Cancel]      │                                 │
│ └────────────────────────────┘                                 │
│                                                                  │
│ [NavigationMenu - W:260]                                        │
└─────────────────────────────────────────────────────────────────┘
```

**Template Base**: template-table-view.yaml

---

## 3. Database Schema

**Primary Entity**: `[THFinanceCashCollection]UserRoles`

**Fields**:
| Field | Logical Name | Type | Notes |
|-------|--------------|------|-------|
| User Email | cr7bb_useremail | Email | Unique, primary key |
| User Name | cr7bb_username | Text | Display name |
| Role | cr7bb_role | Choice | Admin/Manager/Analyst/Viewer |
| Active | cr7bb_active | Boolean | Enable/disable access |

**Filter**:
```powerfx
Filter(
    '[THFinanceCashCollection]UserRoles',
    (IsBlank(_searchText) ||
     cr7bb_useremail in _searchText ||
     cr7bb_username in _searchText) &&
    (_statusFilter = "All" ||
     (_statusFilter = "Active" && cr7bb_active = true) ||
     (_statusFilter = "Inactive" && cr7bb_active = false))
)
```

---

## 4. Key Features

### Toolbar
- New User button
- Search by email or name
- Status filter (All/Active/Inactive)
- Active user count

### User Gallery
- Email, Name, Role, Active status
- Edit button per row
- NEW PATTERN: Visible Edit button (NOT invisible overlay)

### Edit Panel
- User email input (read-only when editing)
- User name input
- Role dropdown (Admin/Manager/Analyst/Viewer)
- Active toggle
- Save/Cancel buttons

---

## 5. Variables

**Screen Variables**:
- `_searchText` (Text): Search filter
- `_statusFilter` (Text): "All", "Active", "Inactive"
- `_showEditPanel` (Boolean): Show/hide edit panel
- `_editMode` (Text): "New" or "Edit"
- `_selectedUser` (Record): Selected user record

---

## 6. Business Rules

### Role Hierarchy
1. **Admin**: Full app access + user management
2. **Manager**: Customers, transactions, settings (view-only)
3. **Analyst**: Dashboard, transactions, email monitor
4. **Viewer**: Dashboard view only

### Validation
- Email must be valid format
- Email must be unique
- Role must be selected
- Cannot delete own admin account

### Save Logic
```powerfx
OnSelect: |-
  =If(
      _editMode = "New",
      Patch(
          '[THFinanceCashCollection]UserRoles',
          Defaults('[THFinanceCashCollection]UserRoles'),
          {
              cr7bb_useremail: UserEmail_Input.Text,
              cr7bb_username: UserName_Input.Text,
              cr7bb_role: Role_Dropdown.Selected.Value,
              cr7bb_active: Active_Toggle.Value
          }
      ),
      Patch(
          '[THFinanceCashCollection]UserRoles',
          _selectedUser,
          {
              cr7bb_username: UserName_Input.Text,
              cr7bb_role: Role_Dropdown.Selected.Value,
              cr7bb_active: Active_Toggle.Value
          }
      )
  );
  Notify("User saved successfully", NotificationType.Success);
  Set(_showEditPanel, false);
  Refresh('[THFinanceCashCollection]UserRoles')
```

---

## 7. Navigation

**From**:
- scnDashboard (Admin only, nav menu)
- scnSettings (Admin only, nav menu)

**To**:
- scnDashboard (nav menu)
- scnSettings (nav menu)

---

## 8. Success Criteria

- ✅ New user creation works
- ✅ Edit user updates correctly
- ✅ Search and filter work
- ✅ Role dropdown populated
- ✅ Active toggle works
- ✅ Admin-only access enforced
- ✅ Email validation works

---

**READY FOR SUBAGENT CREATION** ✅
