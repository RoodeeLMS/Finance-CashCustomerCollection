# Screen Description: scnCustomer

**Created**: 2025-01-10
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-basic-screen.yaml (customize with table gallery + side panel)
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
Manage master data for ~100 cash customers including contact information, exclusion rules, and active status. Provides CRUD operations (Create, Read, Update, Delete) for customer records.

**Who uses it**:
- **AR Manager** - Add new customers, update contact info, manage exclusion rules
- **Admin** - Full CRUD access including delete

**User Goals**:
- Add new cash customers to the system
- Update email addresses and contact information
- Configure exclusion keywords (e.g., "Paid", "Bill credit 30 days")
- Activate/deactivate customers
- Search and filter customer list
- Export customer data

---

## 2. Design Mockup

**Visual Layout**:

```
┌─────────────────────────────────────────────────────────────────┐
│ [HEADER - GroupContainer@1.3.0, AutoLayout, H:55, Nestlé Blue] │
│ ◰  Customer Management                     [User Profile] 🚪    │
├─────────────────────────────────────────────────────────────────┤
│ [CONTENT - GroupContainer@1.3.0, ManualLayout]                  │
│                                                                  │
│ ┌────────────────── TOOLBAR (H:70) ─────────────────────┐      │
│ │ [+ New] [📥 Import] [📤 Export]                        │      │
│ │ Search: [____________] 🔍  [All ▼] Active: 103        │      │
│ └────────────────────────────────────────────────────────┘      │
│                                                                  │
│ ┌────────── CUSTOMER LIST (Gallery@2.15.0) ─────────────┐      │
│ │ Code │ Customer Name        │ Email          │ Status │      │
│ │──────┼──────────────────────┼────────────────┼────────│      │
│ │CP001 │Charoen Pokphand Foods│ar@cpf.co.th    │Active  │      │
│ │      │                      │                │ [Edit] │      │
│ │──────┼──────────────────────┼────────────────┼────────│      │
│ │TB002 │Thai Beverage PCL     │ap@thaibev.com  │Active  │      │
│ │      │                      │                │ [Edit] │      │
│ │──────┼──────────────────────┼────────────────┼────────│      │
│ │...   │                      │                │        │      │
│ └────────────────────────────────────────────────────────┘      │
│                                                                  │
│ [EDIT PANEL - Side overlay, conditional visibility]             │
│ ┌──────────── EDIT CUSTOMER (W:500, Right side) ────────┐      │
│ │ Edit Customer: Charoen Pokphand Foods                  │      │
│ │ ────────────────────────────────────────────────        │      │
│ │ Basic Information                                      │      │
│ │ Customer Code:  [CP001]        (Read-only)            │      │
│ │ Customer Name:  [Charoen Pokphand Foods PCL]          │      │
│ │ Region:         [Central ▼]                           │      │
│ │                                                        │      │
│ │ Contact Information                                    │      │
│ │ Customer Email 1: [ar@cpf.co.th]                      │      │
│ │ Customer Email 2: [finance@cpf.co.th]                 │      │
│ │ Sales Email 1:    [sales.rep@nestle.com]              │      │
│ │ AR Backup Email:  [ar.backup@nestle.com]              │      │
│ │                                                        │      │
│ │ Exclusion Rules                                        │      │
│ │ ☑ Skip if note contains: "Paid"                       │      │
│ │ ☑ Skip if note contains: "Partial Payment"            │      │
│ │ ☑ Skip if note contains: "รักษาตลาด"                  │      │
│ │ ☑ Skip if note contains: "Bill credit 30 days"        │      │
│ │                                                        │      │
│ │ Status: ● Active  ○ Inactive                          │      │
│ │ ────────────────────────────────────────────────        │      │
│ │ [💾 Save] [❌ Cancel] [🗑️ Delete]                     │      │
│ └────────────────────────────────────────────────────────┘      │
│                                                                  │
│ [NavigationMenu - Left slide-in, W:260]                        │
└─────────────────────────────────────────────────────────────────┘
```

**Component Breakdown**:

| Area | Component | Type | Details |
|------|-----------|------|---------|
| Header | CustMgmt_Header | GroupContainer@1.3.0 AutoLayout | Standard Nestlé header |
| Toolbar | CustMgmt_Toolbar | GroupContainer@1.3.0 AutoLayout | Buttons + search + filter |
| Gallery | CustMgmt_CustomerGallery | Gallery@2.15.0 | Customer list with Edit buttons |
| Edit Panel | CustMgmt_EditPanel | GroupContainer@1.3.0 AutoLayout Vertical | Side panel form (scrollable) |
| Nav | CustMgmt_NavigationMenu | CanvasComponent | Standard navigation menu |

**Template Base**: template-basic-screen.yaml

**Component Patterns to Add**:
- component-gallery-pattern.yaml (customer list)
- component-form-pattern.yaml (edit panel)

**Custom Additions**:
- Side panel overlay (visible when _showEditPanel = true)
- Search and filter toolbar
- Exclusion rules checkboxes (4 standard + custom)
- Email validation

---

## 3. Database Schema

**Data Source**: Dataverse

**From**: `FIELD_NAME_REFERENCE.md`

### Primary Entity

**Name**: `[THFinanceCashCollection]Customers`

**Fields/Columns Used**:
| Field Display Name | Logical Name | Type | Notes |
|--------------------|--------------|------|-------|
| Customer Code | cr7bb_customercode | Text | Unique SAP code, read-only after creation |
| Customer Name | cr7bb_customername | Text | Full legal company name |
| Region | nc_region | Choice | NO, SO, NE, CE (North, South, Northeast, Central) |
| Customer Email 1 | cr7bb_customeremail1 | Email | Primary AP contact |
| Customer Email 2 | cr7bb_customeremail2 | Email | Secondary contact (optional) |
| Sales Email 1 | cr7bb_salesemail1 | Email | Sales rep to CC on emails |
| AR Backup Email 1 | cr7bb_arbackupemail1 | Email | AR backup contact |
| Exclusion Rules | cr7bb_exclusionrules | Text | JSON array of keywords |
| Is Active | cr7bb_isactive | Boolean | Active/Inactive status |
| QR Code Available | cr7bb_qrcodeavailable | Boolean | QR code file exists in SharePoint |

**Filter for Gallery**:
```powerfx
SortByColumns(
    Filter(
        '[THFinanceCashCollection]Customers',
        (IsBlank(_searchText) ||
         cr7bb_customercode in _searchText ||
         cr7bb_customername in _searchText) &&
        (_statusFilter = "All" ||
         (_statusFilter = "Active" && cr7bb_isactive = true) ||
         (_statusFilter = "Inactive" && cr7bb_isactive = false))
    ),
    "cr7bb_customername",
    SortOrder.Ascending
)
```

### Choice Field Syntax

**Region (Dataverse Choice)**:
```powerfx
// ✅ CORRECT - Note: Region uses nc_ prefix (different publisher)
nc_region = "NO"
Patch(..., {Region: "Central"})  // Use display name in Patch

// For dropdown Items
Choices('Region Choice')
```

### Exclusion Rules Format

**Stored as JSON in cr7bb_exclusionrules**:
```json
[
  {"keyword": "Paid", "enabled": true},
  {"keyword": "Partial Payment", "enabled": true},
  {"keyword": "รักษาตลาด", "enabled": true},
  {"keyword": "Bill credit 30 days", "enabled": true}
]
```

**Parse in OnVisible**:
```powerfx
// If field is blank, use default
If(
    IsBlank(_selectedCustomer.cr7bb_exclusionrules),
    ClearCollect(
        colExclusionRules,
        Table(
            {keyword: "Paid", enabled: true},
            {keyword: "Partial Payment", enabled: true},
            {keyword: "รักษาตลาด", enabled: true},
            {keyword: "Bill credit 30 days", enabled: true}
        )
    ),
    ClearCollect(colExclusionRules, ParseJSON(_selectedCustomer.cr7bb_exclusionrules))
)
```

---

## 4. Data & Collections

### Collections to Load

**OnVisible**:
```powerfx
=UpdateContext({currentScreen: "Customer Management"});
Set(_showMenu, false);
Set(_showEditPanel, false);
Set(_searchText, "");
Set(_statusFilter, "Active");
Set(_editMode, "");

// Refresh customer list
Refresh('[THFinanceCashCollection]Customers')
```

**colExclusionRules** (temporary):
- **Name**: `colExclusionRules`
- **Source**: Parsed from cr7bb_exclusionrules JSON field
- **Purpose**: Manage exclusion keywords in edit panel
- **Load Timing**: When Edit button clicked
- **Structure**: `{keyword: "text", enabled: true/false}`

### Variables to Set

**Screen-Level Variables**:
1. `_searchText` (Text): Search box value
2. `_statusFilter` (Text): "All", "Active", or "Inactive"
3. `_showEditPanel` (Boolean): Show/hide edit panel
4. `_editMode` (Text): "New" or "Edit"
5. `_selectedCustomer` (Record): Currently selected customer record

**Context Variables**:
- `currentScreen` (Text): "Customer Management" (for nav highlight)

---

## 5. Screen Behavior

### OnVisible Logic

```powerfx
=UpdateContext({currentScreen: "Customer Management"});
Set(_showMenu, false);
Set(_showEditPanel, false);
Set(_searchText, "");
Set(_statusFilter, "Active");
Set(_editMode, "");

// Refresh customer list
Refresh('[THFinanceCashCollection]Customers')
```

### User Interactions

**1. Search Box**:
```powerfx
OnChange: =Set(_searchText, CustMgmt_SearchBox.Text)
```

**2. Status Filter Dropdown**:
```powerfx
Items: =["All", "Active", "Inactive"]
DefaultSelectedItems: =["Active"]
OnChange: =Set(_statusFilter, CustMgmt_StatusFilter.Selected.Value)
```

**3. New Customer Button**:
```powerfx
OnSelect: |-
  =Set(_editMode, "New");
  Set(_selectedCustomer, Blank());
  ClearCollect(
      colExclusionRules,
      Table(
          {keyword: "Paid", enabled: true},
          {keyword: "Partial Payment", enabled: true},
          {keyword: "รักษาตลาด", enabled: true},
          {keyword: "Bill credit 30 days", enabled: true}
      )
  );
  Set(_showEditPanel, true)
```

**4. Edit Button (in Gallery)**:
```powerfx
OnSelect: |-
  =Set(_editMode, "Edit");
  Set(_selectedCustomer, ThisItem);
  If(
      IsBlank(ThisItem.cr7bb_exclusionrules),
      ClearCollect(
          colExclusionRules,
          Table(
              {keyword: "Paid", enabled: true},
              {keyword: "Partial Payment", enabled: true},
              {keyword: "รักษาตลาด", enabled: true},
              {keyword: "Bill credit 30 days", enabled: true}
          )
      ),
      ClearCollect(colExclusionRules, ParseJSON(ThisItem.cr7bb_exclusionrules))
  );
  Set(_showEditPanel, true)
```

**5. Save Button**:
```powerfx
OnSelect: |-
  =If(
      _editMode = "New",
      // Create new customer
      Patch(
          '[THFinanceCashCollection]Customers',
          Defaults('[THFinanceCashCollection]Customers'),
          {
              cr7bb_customercode: CustMgmt_CustomerCodeInput.Text,
              cr7bb_customername: CustMgmt_CustomerNameInput.Text,
              Region: CustMgmt_RegionDropdown.Selected.Value,
              cr7bb_customeremail1: CustMgmt_Email1Input.Text,
              cr7bb_customeremail2: CustMgmt_Email2Input.Text,
              cr7bb_salesemail1: CustMgmt_SalesEmailInput.Text,
              cr7bb_arbackupemail1: CustMgmt_ARBackupInput.Text,
              cr7bb_exclusionrules: JSON(colExclusionRules),
              cr7bb_isactive: CustMgmt_ActiveToggle.Value
          }
      ),
      // Update existing customer
      Patch(
          '[THFinanceCashCollection]Customers',
          _selectedCustomer,
          {
              cr7bb_customername: CustMgmt_CustomerNameInput.Text,
              Region: CustMgmt_RegionDropdown.Selected.Value,
              cr7bb_customeremail1: CustMgmt_Email1Input.Text,
              cr7bb_customeremail2: CustMgmt_Email2Input.Text,
              cr7bb_salesemail1: CustMgmt_SalesEmailInput.Text,
              cr7bb_arbackupemail1: CustMgmt_ARBackupInput.Text,
              cr7bb_exclusionrules: JSON(colExclusionRules),
              cr7bb_isactive: CustMgmt_ActiveToggle.Value
          }
      )
  );
  Notify("Customer saved successfully", NotificationType.Success);
  Set(_showEditPanel, false);
  Refresh('[THFinanceCashCollection]Customers')
```

**6. Delete Button** (Admin only):
```powerfx
Visible: =_editMode = "Edit" && gblUserRole = "Admin"

OnSelect: |-
  =If(
      Confirm("Are you sure you want to delete this customer? This action cannot be undone."),
      Remove('[THFinanceCashCollection]Customers', _selectedCustomer);
      Notify("Customer deleted successfully", NotificationType.Warning);
      Set(_showEditPanel, false);
      Refresh('[THFinanceCashCollection]Customers')
  )
```

---

## 6. Navigation

### From

- scnDashboard (Customers button or nav menu)
- scnTransactions (Customer drill-down)

### To

- scnDashboard (nav menu or back)
- scnTransactions (nav menu)
- scnSettings (nav menu, Admin only)

### Transition

- `ScreenTransition.None` (for nav menu)

---

## 7. Styling & Branding

### Colors (Nestlé Brand)

- **Header**: `RGBA(0, 101, 161, 1)` - Nestlé Blue
- **Edit Panel**: `RGBA(255, 255, 255, 1)` - White with DropShadow.Regular
- **Save Button**: `RGBA(0, 101, 161, 1)` - Nestlé Blue
- **Cancel Button**: `RGBA(128, 128, 128, 1)` - Gray
- **Delete Button**: `RGBA(191, 25, 34, 1)` - Nestlé Red
- **Active Badge**: `RGBA(16, 124, 16, 0.1)` background, `RGBA(16, 124, 16, 1)` text
- **Inactive Badge**: `RGBA(168, 0, 0, 0.1)` background, `RGBA(168, 0, 0, 1)` text

### Fonts

- **Header Title**: Lato Medium, Size 25
- **Section Titles**: Lato Bold, Size 18
- **Labels**: Lato Semibold, Size 14
- **Input Text**: Lato Regular, Size 14

### Layout

- **Header**: 55px height
- **Toolbar**: 70px height
- **Gallery Template**: 80px height
- **Edit Panel**: 500px width, right side overlay
- **Input fields**: 40px height
- **Buttons**: 40px height

---

## 8. Business Rules

### Validation Rules

**Required Fields**:
1. ✅ Customer Code (unique, no duplicates)
2. ✅ Customer Name
3. ✅ Region (must select from dropdown)
4. ✅ At least one email: Customer Email 1 OR AR Backup Email

**Email Validation**:
```powerfx
IsMatch(CustMgmt_Email1Input.Text, Email)
```

**Save Button Enable**:
```powerfx
DisplayMode: |-
  =If(
      !IsBlank(CustMgmt_CustomerCodeInput.Text) &&
      !IsBlank(CustMgmt_CustomerNameInput.Text) &&
      !IsBlank(CustMgmt_RegionDropdown.Selected) &&
      (IsMatch(CustMgmt_Email1Input.Text, Email) ||
       IsMatch(CustMgmt_ARBackupInput.Text, Email)),
      DisplayMode.Edit,
      DisplayMode.Disabled
  )
```

### Exclusion Rules Logic

**Standard Rules** (4 checkboxes):
1. "Paid"
2. "Partial Payment"
3. "รักษาตลาด" (Thai: maintain market)
4. "Bill credit 30 days"

**How Power Automate Uses**:
- Collections Engine reads cr7bb_exclusionrules JSON
- For each enabled keyword, checks transaction cr7bb_textfield
- If keyword found → Skip customer (no email sent)

### Security Rules

- **Manager role**: Can create, read, update
- **Admin role**: Can create, read, update, delete
- **Analyst role**: Read-only (redirect to Dashboard)

---

## 9. Error Handling

### Scenarios

1. **Duplicate Customer Code**:
   - Patch will fail with Dataverse error
   - Show: `Notify("Customer code already exists. Please use a unique code.", NotificationType.Error)`

2. **Invalid Email Format**:
   - Disable Save button
   - Show red border on input: `BorderColor: =If(!IsMatch(Text, Email) && !IsBlank(Text), RGBA(168, 0, 0, 1), RGBA(200, 198, 196, 1))`

3. **Dataverse Connection Failure**:
   - Power Apps shows automatic error
   - User should retry or contact admin

4. **Delete Active Customer with Pending Transactions**:
   - Consider adding validation to prevent deletion
   - Or soft delete (set cr7bb_isactive = false instead)

---

## 10. Control Specifications

### Gallery Template (Per Item)

**NEW PATTERN (v1.5.0)**: Use visible Edit button inside AutoLayout card

```yaml
- CustMgmt_CustomerGalleryTemplate:
    Control: GroupContainer@1.3.0
    Variant: AutoLayout
    Properties:
      LayoutDirection: =LayoutDirection.Horizontal
      LayoutGap: =10
      LayoutMinHeight: =80
      LayoutMinWidth: =100
      Width: =Parent.TemplateWidth - 20
      Fill: =RGBA(255, 255, 255, 1)
      DropShadow: =DropShadow.Light
    Children:
      - CustCode_Text:
          Control: Text@0.0.51
          Properties:
            Text: =ThisItem.cr7bb_customercode
            Width: =100

      - CustName_Text:
          Control: Text@0.0.51
          Properties:
            Text: =ThisItem.cr7bb_customername
            Width: =300
            AutoHeight: =true

      - Email_Text:
          Control: Text@0.0.51
          Properties:
            Text: =ThisItem.cr7bb_customeremail1
            Width: =250

      - Status_Badge:
          Control: Text@0.0.51
          Properties:
            Text: |-
              =If(ThisItem.cr7bb_isactive, "Active", "Inactive")
            Fill: |-
              =If(ThisItem.cr7bb_isactive,
                  RGBA(16, 124, 16, 0.1),
                  RGBA(168, 0, 0, 0.1))
            FontColor: |-
              =If(ThisItem.cr7bb_isactive,
                  RGBA(16, 124, 16, 1),
                  RGBA(168, 0, 0, 1))
            Width: =80
            Align: ='TextCanvas.Align'.Center

      - Edit_Button:
          Control: Button@0.0.45
          Properties:
            Text: ="Edit"
            BasePaletteColor: =RGBA(0, 101, 161, 1)
            Height: =32
            Width: =80
            OnSelect: |-
              =Set(_editMode, "Edit");
              Set(_selectedCustomer, ThisItem);
              Set(_showEditPanel, true)
```

---

## 11. Performance Considerations

- **Gallery delegation**: Filter and SortByColumns are delegable for Dataverse
- **Customer count**: ~100 records, no pagination needed
- **Search**: Uses `in` operator (delegable for Dataverse Text fields)
- **Edit panel**: Only loads when user clicks Edit (lazy loading)

---

## 12. Testing Checklist

**Functional**:
- [ ] New customer creation works
- [ ] Edit customer updates correctly
- [ ] Delete customer works (Admin only)
- [ ] Search filters list correctly
- [ ] Status filter (All/Active/Inactive) works
- [ ] Email validation blocks invalid emails
- [ ] Exclusion rules save as JSON
- [ ] Required field validation works

**Visual**:
- [ ] Gallery displays correctly with 4 columns
- [ ] Edit panel slides in from right
- [ ] Active/Inactive badges show correct colors
- [ ] Edit button visible in each row

**Security**:
- [ ] Manager can create/edit
- [ ] Admin can delete
- [ ] Analyst redirected to Dashboard

---

## 13. Success Criteria

Screen is complete when:
- ✅ Customer list loads and displays correctly
- ✅ Search and filter work
- ✅ New customer creation works
- ✅ Edit customer updates successfully
- ✅ Delete works (Admin only)
- ✅ Email validation prevents invalid emails
- ✅ Exclusion rules save as JSON
- ✅ Edit panel opens/closes smoothly
- ✅ No critical errors in Power Apps checker

---

**READY FOR SUBAGENT CREATION** ✅
