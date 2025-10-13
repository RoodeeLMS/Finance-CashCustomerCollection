# Customer Management Screen Refactor - Description

## Overview
Refactor scnCustomer from Gallery-based pattern to Table-based pattern matching the template implementation in scnRole.

## Current Implementation Issues
- Uses Gallery@2.15.0 instead of modern Table@1.0.278
- Complex side panel editing with many controls
- Search and filter logic embedded in gallery
- Gallery selection pattern less intuitive than table

## Target Implementation (Based on scnRole Template)

### Architecture Pattern
```
┌─────────────────────────────────────┐
│ Header (Navigation + Title)         │
├─────────────────────────────────────┤
│ Content Container                   │
│ ┌─────────────────────────────────┐ │
│ │ Table View (Mode = "View")      │ │
│ │ ├─ Action Bar (Add/Edit/Delete) │ │
│ │ └─ Table@1.0.278                │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Form View (Mode = "New/Edit")   │ │
│ │ ├─ Form Fields                  │ │
│ │ └─ Action Bar (Save/Cancel)     │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Delete Confirmation Modal Overlay   │
└─────────────────────────────────────┘
```

## Data Source
- Table: `[THFinanceCashCollection]Customers`
- Direct Dataverse query (no collections)

## Fields to Display

### Table Columns
1. **Customer Code** (`cr7bb_customercode`) - Text
2. **Customer Name** (`cr7bb_customername`) - Text
3. **Region** (`cr7bb_Region`) - Choice
4. **Customer Email 1** (`cr7bb_customeremail1`) - Email
5. **Sales Email 1** (`cr7bb_salesemail1`) - Email
6. **AR Backup Email 1** (`cr7bb_arbackupemail1`) - Email

### Form Fields (New/Edit Mode)

#### Basic Information Section
1. **Customer Code** (TextInput) - Required, disabled in Edit mode
2. **Customer Name** (TextInput) - Required
3. **Region** (ComboBox) - Required
   - Items: `Choices('Region Choice')`
   - Values: NO, SO, NE, CE, etc.

#### Customer Email Section
4. **Customer Email 1** (TextInput) - Required
5. **Customer Email 2** (TextInput) - Optional
6. **Customer Email 3** (TextInput) - Optional
7. **Customer Email 4** (TextInput) - Optional

#### Sales Email Section
8. **Sales Email 1** (TextInput) - Required
9. **Sales Email 2** (TextInput) - Optional
10. **Sales Email 3** (TextInput) - Optional
11. **Sales Email 4** (TextInput) - Optional
12. **Sales Email 5** (TextInput) - Optional

#### AR Backup Email Section
13. **AR Backup Email 1** (TextInput) - Required
14. **AR Backup Email 2** (TextInput) - Optional
15. **AR Backup Email 3** (TextInput) - Optional
16. **AR Backup Email 4** (TextInput) - Optional

## Behavior

### OnVisible
```powerfx
UpdateContext({
    currentScreen: "Customer Management",
    _showMenu: false,
    _currentMode: "View",
    _showDeleteConfirmation: false,
    _selectedCustomer: Blank(),
    _customerToDelete: Blank()
});
```

### Mode Switching
- **View Mode**: Show table with Add/Edit/Delete buttons
- **New Mode**: Show form with blank values, Save button text = "Add"
- **Edit Mode**: Show form with selected customer values, Save button text = "Save"

### Table Control
- **Items**: Direct query to `'[THFinanceCashCollection]Customers'`
- **Selection**: Single row selection
- **Sorting**: Enabled on all columns
- **Filtering**: Built-in table search (remove custom search)

### Action Buttons (View Mode)

#### Add Button
```powerfx
UpdateContext({
    _currentMode: "New",
    _selectedCustomer: Blank()
})
```

#### Edit Button
- **DisplayMode**: Disabled if no row selected
```powerfx
UpdateContext({
    _currentMode: "Edit",
    _selectedCustomer: Customer_Table.Selected
})
```

#### Delete Button
- **Visible**: `_isAdmin` only
- **DisplayMode**: Disabled if no row selected
```powerfx
UpdateContext({
    _customerToDelete: Customer_Table.Selected,
    _showDeleteConfirmation: true
})
```

### Form Submission (New/Edit Mode)

#### Save Button OnSelect
```powerfx
If(
    _currentMode = "New",
    // Create new customer
    Patch(
        '[THFinanceCashCollection]Customers',
        Defaults('[THFinanceCashCollection]Customers'),
        {
            cr7bb_customercode: Customer_Form_CustomerCode.Value,
            cr7bb_customername: Customer_Form_CustomerName.Value,
            Region: Customer_Form_Region.Selected.Value,
            cr7bb_customeremail1: Customer_Form_CustomerEmail1.Value,
            cr7bb_customeremail2: Customer_Form_CustomerEmail2.Value,
            cr7bb_customeremail3: Customer_Form_CustomerEmail3.Value,
            cr7bb_customeremail4: Customer_Form_CustomerEmail4.Value,
            cr7bb_salesemail1: Customer_Form_SalesEmail1.Value,
            cr7bb_salesemail2: Customer_Form_SalesEmail2.Value,
            cr7bb_salesemail3: Customer_Form_SalesEmail3.Value,
            cr7bb_salesemail4: Customer_Form_SalesEmail4.Value,
            cr7bb_salesemail5: Customer_Form_SalesEmail5.Value,
            cr7bb_arbackupemail1: Customer_Form_ARBackupEmail1.Value,
            cr7bb_arbackupemail2: Customer_Form_ARBackupEmail2.Value,
            cr7bb_arbackupemail3: Customer_Form_ARBackupEmail3.Value,
            cr7bb_arbackupemail4: Customer_Form_ARBackupEmail4.Value
        }
    ),
    // Update existing customer
    Patch(
        '[THFinanceCashCollection]Customers',
        _selectedCustomer,
        {
            cr7bb_customername: Customer_Form_CustomerName.Value,
            Region: Customer_Form_Region.Selected.Value,
            cr7bb_customeremail1: Customer_Form_CustomerEmail1.Value,
            cr7bb_customeremail2: Customer_Form_CustomerEmail2.Value,
            cr7bb_customeremail3: Customer_Form_CustomerEmail3.Value,
            cr7bb_customeremail4: Customer_Form_CustomerEmail4.Value,
            cr7bb_salesemail1: Customer_Form_SalesEmail1.Value,
            cr7bb_salesemail2: Customer_Form_SalesEmail2.Value,
            cr7bb_salesemail3: Customer_Form_SalesEmail3.Value,
            cr7bb_salesemail4: Customer_Form_SalesEmail4.Value,
            cr7bb_salesemail5: Customer_Form_SalesEmail5.Value,
            cr7bb_arbackupemail1: Customer_Form_ARBackupEmail1.Value,
            cr7bb_arbackupemail2: Customer_Form_ARBackupEmail2.Value,
            cr7bb_arbackupemail3: Customer_Form_ARBackupEmail3.Value,
            cr7bb_arbackupemail4: Customer_Form_ARBackupEmail4.Value
        }
    )
);

// Check for errors and notify
If(
    IsEmpty(Errors('[THFinanceCashCollection]Customers')),
    Notify("Customer saved successfully", NotificationType.Success);
    UpdateContext({_currentMode: "View"}),
    Notify("Error saving customer: " & First(Errors('[THFinanceCashCollection]Customers')).Message, NotificationType.Error)
)
```

#### Cancel Button OnSelect
```powerfx
UpdateContext({_currentMode: "View"})
```

### Delete Confirmation Modal

#### Delete Confirm Button OnSelect
```powerfx
Remove('[THFinanceCashCollection]Customers', _customerToDelete);
Notify("Customer deleted successfully", NotificationType.Success);
UpdateContext({
    _showDeleteConfirmation: false,
    _customerToDelete: Blank()
});
Refresh('[THFinanceCashCollection]Customers')
```

#### Cancel Button OnSelect
```powerfx
UpdateContext({
    _showDeleteConfirmation: false,
    _customerToDelete: Blank()
})
```

## Removed Features (Simplification)

1. **Search TextInput** - Use Table built-in search instead
2. **Status Filter Dropdown** - Remove active/inactive filter (all customers shown)
3. **Side Panel Pattern** - Replace with full-screen form
4. **Gallery Card Layout** - Replace with Table rows
5. **colExclusionRules Collection** - Not needed for customer management

## Styling (Nestlé Brand Standards)

### Colors
- **Primary Blue**: `RGBA(0, 101, 161, 1)` - Header, primary buttons
- **Oak Brown**: `RGBA(100, 81, 61, 1)` - Edit button
- **Red**: `RGBA(191, 25, 34, 1)` - Delete button
- **Gray**: `RGBA(100, 100, 100, 1)` - Cancel button
- **White**: `RGBA(255, 255, 255, 1)` - Content background
- **Light Gray**: `RGBA(243, 242, 241, 1)` - Screen background

### Typography
- **Font**: Font.Lato
- **Header Size**: 25
- **Form Label Size**: 14-16
- **Weight**: Semibold for labels, Medium for headers

## Layout Specifications

### Table View
- **Action Bar Height**: 50px
- **Action Bar Buttons**: Height 35px
- **Table**: Full remaining height

### Form View
- **Form Padding**: 20px all sides
- **Form Gap**: 15px between fields
- **Label Height**: 25px
- **Input Height**: 40px
- **Action Bar Height**: 50px at bottom
- **Button Height**: 35px

## Validation Rules

### Required Fields
- Customer Code (New mode only)
- Customer Name
- Region
- Customer Email 1
- Sales Email 1
- AR Backup Email 1

### Field Constraints
- Customer Code: Must be unique, 6-7 digits
- All email fields: Valid email format
- Customer Code: Disabled in Edit mode (primary key)

## Navigation

### Menu Integration
- Uses `NavigationMenu` component
- Props:
  - `navItems`: `=Navigation` (from loadingScreen)
  - `navSelected`: `=currentScreen`
- Toggle: `_showMenu` variable

## Benefits of Refactor

1. ✅ **Better Performance**: Table control faster than Gallery
2. ✅ **Cleaner UX**: Full-screen form instead of side panel
3. ✅ **Simpler Logic**: Mode-based switching vs complex visibility
4. ✅ **Built-in Features**: Table sorting, filtering, selection
5. ✅ **Consistent Pattern**: Matches scnRole template
6. ✅ **Easier Maintenance**: Less custom code, more declarative

## Implementation Notes

### Control Versions
- Table: `Table@1.0.278`
- Button: `Button@0.0.45`
- TextInput: `TextInput@0.0.54`
- ComboBox: `ComboBox@0.0.51`
- Text: `Text@0.0.51`
- GroupContainer: `GroupContainer@1.3.0`

### YAML Syntax
- Use block scalar `|-` for all formulas with colons
- Use `Region` (no prefix) for Patch operations on choice fields
- Use `cr7bb_Region` (with prefix) for display in Table columns

## Testing Checklist

- [ ] View mode displays all customers in table
- [ ] Add button opens form with blank fields
- [ ] Save creates new customer successfully
- [ ] Edit button opens form with selected customer data
- [ ] Save updates existing customer successfully
- [ ] Delete button (Admin only) shows confirmation modal
- [ ] Delete removes customer successfully
- [ ] Cancel button returns to view mode
- [ ] Required field validation works
- [ ] Email format validation works
- [ ] Customer code uniqueness validation works
- [ ] Navigation menu works correctly

---

**Status**: Ready for Implementation
**Estimated Complexity**: Medium (similar to scnRole refactor)
**Estimated Time**: 30-45 minutes
