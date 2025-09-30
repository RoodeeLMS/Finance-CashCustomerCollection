# Power Apps YAML Best Practices

## Control Property Reference Strategy

### Problem
Power Apps control versions and properties change frequently, making it difficult to know the exact properties supported by each control version.

### Solution: User-Created Reference Controls

**BEST PRACTICE**: When uncertain about control properties or versions:

1. **User creates the control in Power Apps Studio**
   - Add the control (DatePicker, Toggle, Checkbox, etc.) to a screen
   - Configure it with the desired properties in the UI
   - Export the screen as YAML

2. **User shares the YAML back to AI**
   - Copy the exported YAML for just that control
   - Paste it back to the AI assistant as a reference
   - AI can then use the exact control version and properties

3. **Benefits**:
   - ✅ Guaranteed correct control version
   - ✅ Guaranteed correct property names
   - ✅ Guaranteed correct property syntax
   - ✅ No trial-and-error with parsing errors
   - ✅ Saves time for both user and AI

### Example Workflow

**User**: "I need a Toggle control but the YAML keeps giving errors. Let me create one in the editor and share the YAML with you."

**User creates Toggle in Power Apps Studio, exports YAML, then shares:**
```yaml
- MyToggle:
    Control: Toggle@1.1.5
    Properties:
      Height: =40
      Checked: =varFilterActive
      Width: =150
```

**AI**: "Perfect! I can see version 1.1.5 uses `Checked` property (not `Value` or `Default`). I'll update the Transaction screen with this pattern."

## YAML Syntax Rules

### String Quoting for Formulas

Power Fx formulas containing quotes must be wrapped:

```yaml
# ✅ CORRECT - Single quotes wrapping, double single-quotes to escape
Text: '="Customer: " & LookUp(''[THFinanceCashCollection]Customers'', id = current).name'

# ✅ CORRECT - Double quotes wrapping (for simple cases)
OnSelect: "=Refresh('[THFinanceCashCollection]Transactions')"

# ❌ WRONG - Unquoted formula with quotes
Text: ="Total: " & CountRows(table) & " items"
```

### Complex Formulas with Nested Quotes

**Problem**: Formulas with nested quotes (format strings like `"hh:mm AM/PM"` or `"#,##0"`) cause YAML parsing errors.

**Solution**: Use YAML multiline block scalar (`|`) for complex text concatenation:

```yaml
# ✅ CORRECT - Multiline block scalar for nested quotes
Text: |
  ="Start Time: " & If(CountRows(col)>0, Text(First(col).starttime, "hh:mm AM/PM"), "Not run")

# ✅ CORRECT - Also works for number formatting
Text: |
  ="Total: " & Text(Sum(col, amount), "#,##0.00")

# ❌ WRONG - Inline with nested quotes causes parsing error
Text: ="Start Time: " & If(CountRows(col)>0, Text(First(col).starttime, "hh:mm AM/PM"), "Not run")
```

**When to use `|` multiline**:
- Text() function with format strings (dates, numbers)
- Multiple nested quote levels
- String concatenation with formatted values
- Any formula where inline quotes cause PA1001 YamlInvalidSyntax error

**Note**: This is different from multi-line formulas (see below). Use `|` for complex single-line formulas with quote conflicts.

### Multi-line Formulas

**Rule**: Do NOT use YAML `|-` multi-line syntax for Power Fx formulas.

```yaml
# ❌ WRONG - Multi-line with |-
OnVisible: |-
  =UpdateContext({var1: "value"});
  UpdateContext({var2: "value"});
  Set(var3, true)

# ✅ CORRECT - Single line with semicolons
OnVisible: =UpdateContext({var1:"value", var2:"value"}); Set(var3,true)
```

### Control Version Guidelines

- Always use the version number reported in error messages
- If warning says "current version is X", use version X
- Example: `Control: DatePicker@0.0.46` not `@0.0.52`

### Gallery Alternating Row Colors

**Problem**: `ThisItem.Value` and `ThisItem.Index` don't exist in Power Apps galleries.

**Options**:

1. **Simple - Use uniform background** (Recommended for small galleries <20 items):
```yaml
Fill: =RGBA(255, 255, 255, 1)  # Single color
```

2. **Advanced - Use CountRows with text/number field** (Avoid GUID comparisons):
```yaml
# ✅ CORRECT - Use sortable text or number field
Fill: =If(
  Mod(
    CountRows(
      Filter(
        collection,
        text_or_number_field <= ThisItem.text_or_number_field
      )
    ),
    2
  ) = 0,
  RGBA(245, 250, 252, 1),  # Even rows
  RGBA(255, 255, 255, 1)    # Odd rows
)

# ❌ WRONG - GUID comparison is inefficient
Fill: =If(Mod(CountRows(Filter(col, guid_field <= ThisItem.guid_field)), 2) = 0, ...)

# ❌ WRONG - ThisItem.Value doesn't exist
Fill: =If(Mod(ThisItem.Value, 2) = 0, Color1, Color2)

# ❌ WRONG - ThisItem.Index doesn't exist
Fill: =If(Mod(ThisItem.Index, 2) = 0, Color1, Color2)
```

**Note**: For performance, avoid alternating colors in large galleries or use a numeric index field.

### Text Alignment Property

**Rule**: Use TextCanvas.Align enum with correct property names.

```yaml
# ✅ CORRECT - Enum syntax with End/Start/Center
Align: ='TextCanvas.Align'.End     # Right-aligned text
Align: ='TextCanvas.Align'.Start   # Left-aligned text
Align: ='TextCanvas.Align'.Center  # Center-aligned text

# ❌ WRONG - Using "Right" instead of "End"
Align: ='TextCanvas.Align'.Right
```

### Unique Control Names

**Rule**: Every control name must be unique within a screen.

**Error Example**:
```
(457,15) : error PA2110 : An entity with name 'DashboardTitle' already exists. Other definition located at (63,21).
```

**Solution**: Use descriptive prefixes or suffixes to differentiate controls with similar purposes:

```yaml
# ❌ WRONG - Duplicate names
Children:
  - DashboardTitle:  # Line 63 - content area
      Control: Text@0.0.51
      Text: ="AR Control Center"

  - DashboardTitle:  # Line 457 - header (ERROR!)
      Control: Text@0.0.51
      Text: =currentScreen

# ✅ CORRECT - Unique names with context
Children:
  - DashboardContentTitle:  # Clear it's in content area
      Control: Text@0.0.51
      Text: ="AR Control Center"

  - DashboardHeaderTitle:   # Clear it's in header
      Control: Text@0.0.51
      Text: =currentScreen
```

**Naming Convention**:
- Use functional prefixes: `{Section}{ControlType}`
- Examples: `HeaderTitle`, `FooterLogo`, `SidebarMenuButton`
- Avoid generic names like `Title`, `Label1`, `Button1`

## Common Control Property Patterns

### Documented After User Testing

#### CheckBox@0.0.30 (Confirmed 2025-09-30)

```yaml
- MyCheckbox:
    Control: CheckBox@0.0.30  # Note: Capital B in "CheckBox"
    Properties:
      Checked: =varBooleanValue           # Two-way binding property
      Height: =40
      OnCheck: =UpdateContext({var:true}) # Event when checked
      OnUncheck: =UpdateContext({var:false}) # Event when unchecked
      Width: =150
```

**Key Properties**:
- `Checked` - Boolean property for current state (supports two-way binding)
- `OnCheck` - Event triggered when user checks the box
- `OnUncheck` - Event triggered when user unchecks the box
- `CheckboxSize` - Optional size property
- `DisplayMode` - Optional (Edit/View/Disabled)
- `OnSelect` - Optional general click handler

**Note**: Do not assume property names for other controls. When in doubt, ask user to create reference control.