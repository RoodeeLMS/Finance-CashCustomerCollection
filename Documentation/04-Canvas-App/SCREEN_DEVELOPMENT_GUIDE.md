# Screen Development Guide

**Project**: Nestlé Finance - Cash Customer Collection Automation
**Created**: 2025-10-09
**Last Updated**: 2025-10-09
**Status**: Active

---

## Purpose

This guide provides project-specific guidance for developing Canvas App screens for the Finance Cash Collection system. It complements the Nestlé Power Apps Universal Standards with project-specific requirements, field names, and patterns.

---

## 📚 Reading Order for AI Assistants

When creating or editing screens, read documents in this order:

### 1. Universal Standards (Core)
**Location**: `~/.claude/powerapp-standards/`
- `universal-powerapp-checklist.md` - Critical rules
- `nestle-brand-standards.md` - Colors, fonts
- `powerapp-control-reference.md` - Quick index

### 2. Project-Specific (Overrides)
**Location**: This project folder
- **`FIELD_NAME_REFERENCE.md`** - ⭐ PRIMARY SOURCE for field names
- **`REDESIGNED_SCREENS.md`** - Screen architecture decisions
- **This file** - Development workflow & patterns

### 3. Detailed References (As Needed)
- `dataverse-common-patterns.md` - Dataverse syntax
- `modern-controls-complete-reference.md` - Control details
- `powerapp-yaml-complete-guide.md` - YAML syntax

---

## 🚀 Development Workflow

### Screen Creation Process

```
1. Read universal standards (always)
   ↓
2. Read project-specific docs (this file, FIELD_NAME_REFERENCE.md)
   ↓
3. Create screen in templates/powerapps/
   ↓
4. Quick validation: `/quick-check <file>` (10-30 sec)
   ↓
5. Fix critical errors, repeat steps 3-4
   ↓
6. Full review: Say "review scnScreenName" or `/review-powerapp-screen <file>` (2-3 min)
   ↓
7. Fix all critical + standards issues
   ↓
8. Import to Power Apps Studio manually
   ↓
9. Test in Power Apps Studio
   ↓
10. Export to Powerapp screens-DO-NOT-EDIT/ (production reference)
```

### Folder Structure

```
Finance-CashCustomerCollection/
├── templates/powerapps/              # Working directory (EDITABLE)
│   ├── scnDailyControlCenter.yaml   # Latest: Daily Control Center
│   ├── scnCustomer.yaml             # Customer management
│   ├── scnTransactions.yaml         # Transaction inspector
│   └── ... (other screens)
│
├── Powerapp screens-DO-NOT-EDIT/    # Production exports (READ-ONLY)
│   ├── scnDashboard.yaml           # Deployed version
│   ├── scnCustomer.yaml            # Deployed version
│   └── ... (exported from Power Apps Studio)
│
└── FIELD_NAME_REFERENCE.md          # Field name source of truth
```

**Important**: Always work in `templates/powerapps/`, never edit `Powerapp screens-DO-NOT-EDIT/`

---

## 🎨 Screen Design Patterns

### Daily Control Center (Landing Page)

**Purpose**: Monitor today's automation at a glance

**Sections**:
1. **Header** - Nestlé Blue (RGBA(0, 101, 161, 1)) with title and refresh
2. **Status Card** - SAP Import and Email Engine status indicators
3. **Quick Actions** - Task-focused buttons (Review Emails, View Failed, etc.)
4. **Important Customers** - High balance or late payments with color-coded day counts
5. **Recent Activity** - Last 10 emails sent with status

**Key Patterns**:
- Card-based layout with DropShadow.Light
- Color-coded status indicators (Green/Yellow/Red)
- Scrollable main container (LayoutMinHeight=40 for scrolling)
- Real-time data refresh in OnVisible

**Reference**: `templates/powerapps/scnDailyControlCenter.yaml`

### Customer Hub (Future)

**Purpose**: Manage customer master data with email health focus

**Key Features**:
- Email health indicators
- Quick edit functionality
- Bulk operations
- QR code access

### Transaction Inspector (Future)

**Purpose**: Review system FIFO logic and make corrections

**Key Features**:
- Grouped by customer
- FIFO summary transparency
- Exclusion explanations
- Override options

---

## ⚠️ Critical Rules (Project-Specific)

### Field Names

**ALWAYS verify from FIELD_NAME_REFERENCE.md** - This is the PRIMARY SOURCE

**Common Fields**:

| Table | Field Name | Type | Example Value |
|-------|-----------|------|---------------|
| Customers | `cr7bb_customercode` | Text | "198609" |
| Customers | `cr7bb_customername` | Text | "ABC Company Ltd" |
| Customers | `cr7bb_customeremail` | Text | "customer@example.com" |
| Transactions | `cr7bb_amount` | Decimal | 50000.00 |
| Transactions | `cr7bb_daycount` | Number | 3 |
| Transactions | `cr7bb_processed` | Boolean | false |
| ProcessLogs | `cr7bb_processdate` | **TEXT** | "2025-10-09" |
| ProcessLogs | `cr7bb_status` | Text | "Completed" |
| ProcessLogs | `cr7bb_recordsprocessed` | Number | 150 |
| EmailLogs | `cr7bb_sentdatetime` | DateTime | 2025-10-09T08:30:00Z |
| EmailLogs | `cr7bb_sendstatus` | Text | "Sent" |
| EmailLogs | `cr7bb_customer` | Lookup | (Customer record) |

**⚠️ CRITICAL**: ProcessLogs uses TEXT for dates, EmailLogs uses DateTime

### Dataverse Table References

**Always use display names in YAML**:

```yaml
Items: ='[THFinanceCashCollection]Customers'
Items: ='[THFinanceCashCollection]Transactions'
Items: ='[THFinanceCashCollection]ProcessLogs'
Items: ='[THFinanceCashCollection]EmailLogs'
```

### Date Field Handling

**ProcessLogs (TEXT type)**:
```yaml
# Filter by today's date
Filter(
    '[THFinanceCashCollection]ProcessLogs',
    cr7bb_processdate = Text(Today(), "yyyy-mm-dd")
)

# Display date (convert TEXT to DateTime)
Text: =Text(DateTimeValue(_todayProcessLog.cr7bb_processdate), "[$-th-TH]hh:mm")
```

**EmailLogs (DateTime type)**:
```yaml
# Filter by today
Filter(
    '[THFinanceCashCollection]EmailLogs',
    DateValue(cr7bb_sentdatetime) = Today()
)

# Display date
Text: =Text(ThisItem.cr7bb_sentdatetime, "[$-th-TH]dd/mm/yyyy hh:mm")
```

### Lookup Field Access

**EmailLogs has lookup to Customer**:
```yaml
# ❌ WRONG - cr7bb_customercode doesn't exist on EmailLogs
Text: =LookUp(
    '[THFinanceCashCollection]Customers',
    cr7bb_customercode = ThisItem.cr7bb_customercode
).cr7bb_customername

# ✅ CORRECT - Use lookup field
Text: =ThisItem.cr7bb_customer.cr7bb_customername
```

---

## 🎨 Nestlé Brand Standards (Project Application)

### Colors

**Primary Colors**:
- **Nestlé Blue**: `RGBA(0, 101, 161, 1)` - Headers, primary buttons
- **Oak Brown**: `RGBA(100, 81, 61, 1)` - Secondary buttons
- **Nestlé Red**: `RGBA(212, 41, 57, 1)` - Error states, critical warnings

**Status Indicators**:
- **Success**: `RGBA(16, 124, 16, 1)` - Completed, Sent
- **Warning**: `RGBA(255, 185, 0, 1)` - Day 3, Failed (yellow)
- **Error**: `RGBA(168, 0, 0, 1)` - Day 4+, Failed (red)

**Backgrounds**:
- **Screen**: `RGBA(243, 242, 241, 1)` - Light gray
- **Cards**: `RGBA(255, 255, 255, 1)` - White
- **Gallery items**: `RGBA(250, 249, 248, 1)` - Off-white

### Fonts

**Primary Font** - Lato:
```yaml
# ❌ WRONG
Font: =Font.'Lato Black'

# ✅ CORRECT
Font: =Font.Lato
Weight: ='TextCanvas.Weight'.Bold
```

**Typography Scale**:
- **Screen Title**: Size 24, Weight.Bold
- **Section Headers**: Size 20, Weight.Bold
- **Body Text**: Size 14-16, Weight.Semibold or Regular
- **Labels**: Size 12-14, Regular
- **Small Text**: Size 11-12, Regular

---

## 🔧 Common Patterns

### AutoLayout Container Pattern

**ALWAYS set these properties** (dangerous defaults!):

```yaml
Container:
  Control: GroupContainer@1.3.0
  Variant: AutoLayout
  Properties:
    LayoutMode: =LayoutMode.Auto
    LayoutDirection: =LayoutDirection.Vertical  # or Horizontal
    LayoutGap: =16                              # Spacing between children
    LayoutMinHeight: =0                         # REQUIRED! Default is 100
    LayoutMinWidth: =100                        # REQUIRED! Default is 100
    DropShadow: =DropShadow.None               # REQUIRED! Explicit shadow
    PaddingTop: =20
    PaddingLeft: =20
    PaddingRight: =20
    PaddingBottom: =20
```

**For Scrollable Containers**:
```yaml
MainScrollContainer:
  Properties:
    LayoutMode: =LayoutMode.Auto
    LayoutDirection: =LayoutDirection.Vertical
    LayoutOverflowY: =LayoutOverflow.Scroll    # Enable scrolling
    LayoutMinHeight: =40                        # LOW value for scrolling
    LayoutMinWidth: =100
    LayoutGap: =24
```

### Status Card Pattern

```yaml
StatusCard:
  Control: GroupContainer@1.3.0
  Variant: AutoLayout
  Properties:
    Fill: =RGBA(255, 255, 255, 1)
    DropShadow: =DropShadow.Light              # Cards have shadows
    LayoutMinHeight: =0                         # Explicit height
    LayoutMinWidth: =1000                       # Min width for cards
    LayoutMode: =LayoutMode.Auto
    LayoutDirection: =LayoutDirection.Vertical
    LayoutGap: =16
    PaddingTop: =20
    PaddingLeft: =20
    PaddingRight: =20
    PaddingBottom: =20
```

### Color-Coded Status Icon Pattern

```yaml
StatusIcon:
  Control: Icon@2.5.0
  Properties:
    Icon: =If(
        _status = "Completed",
        Icon.CheckBadge,
        If(
            _status = "Failed",
            Icon.CancelBadge,
            Icon.Clock
        )
    )
    Color: =If(
        _status = "Completed",
        RGBA(16, 124, 16, 1),    # Green
        If(
            _status = "Failed",
            RGBA(168, 0, 0, 1),   # Red
            RGBA(255, 185, 0, 1)  # Yellow
        )
    )
    Width: =64
    Height: =64
```

### Gallery with Calculated Columns Pattern

```yaml
OnVisible: |-
  =ClearCollect(
      colImportantCustomers,
      Filter(
          AddColumns(
              '[THFinanceCashCollection]Customers',
              TotalDue,                          # NO QUOTES!
              Sum(...),
              MaxDayCount,                       # NO QUOTES!
              Max(...)
          ),
          TotalDue > 100000 || MaxDayCount >= 3
      )
  );
```

**Key Points**:
- AddColumns column names are **unquoted**
- Filter can reference added columns
- Use in OnVisible for performance

### Quick Actions Button Pattern

```yaml
QuickActionButton:
  Control: Button@0.0.45
  Properties:
    Text: ="📧 Action Name"
    Fill: =RGBA(0, 101, 161, 1)              # Nestlé Blue
    FontColor: =RGBA(255, 255, 255, 1)       # White text
    Height: =50
    Width: =240
    OnSelect: =Navigate(scnTargetScreen)
```

### Day Count Color-Coded Badge Pattern

```yaml
DayCountBadge:
  Control: GroupContainer@1.3.0
  Properties:
    Fill: =If(
        ThisItem.MaxDayCount >= 4,
        RGBA(168, 0, 0, 1),        # Red (late)
        If(
            ThisItem.MaxDayCount = 3,
            RGBA(255, 185, 0, 1),   # Yellow (warning)
            RGBA(16, 124, 16, 1)    # Green (ok)
        )
    )
    Width: =60
    Height: =60
    LayoutMode: =LayoutMode.Auto
    LayoutJustifyContent: =LayoutJustifyContent.Center
    LayoutAlignItems: =LayoutAlignItems.Center
```

---

## 🚨 Common Errors to Avoid

### 1. Missing LayoutMinHeight/LayoutMinWidth

**Error**: Controls overlap or have 100px default height

**Fix**: Always add to GroupContainer@1.3.0:
```yaml
LayoutMinHeight: =0      # or LOW value for scrolling
LayoutMinWidth: =100
```

### 2. Missing DropShadow Property

**Error**: Unwanted shadows appear

**Fix**: Explicitly set on all containers:
```yaml
DropShadow: =DropShadow.None    # For nested containers
DropShadow: =DropShadow.Light   # For cards
```

### 3. Wrong Control Versions

**Error**: Icon@0.0.50 or Gallery@0.0.52 not documented

**Fix**: Use standard versions:
```yaml
Icon@2.5.0      # Classic icon
Gallery@2.15.0  # Classic gallery
```

### 4. Quoted AddColumns Names

**Error**: AddColumns syntax error

**Fix**: Remove quotes from column names:
```yaml
# ❌ WRONG
AddColumns(table, "ColumnName", expression)

# ✅ CORRECT
AddColumns(table, ColumnName, expression)
```

### 5. Wrong Font Property

**Error**: Font.'Lato Black' instead of Font.Lato + Weight

**Fix**:
```yaml
# ❌ WRONG
Font: =Font.'Lato Black'

# ✅ CORRECT
Font: =Font.Lato
Weight: ='TextCanvas.Weight'.Bold
```

### 6. Missing Width on Text Controls

**Error**: Text controls default to 96px

**Fix**: Always specify Width:
```yaml
Text@0.0.51:
  Properties:
    Text: ="Some text"
    Width: =300    # Always specify!
```

### 7. TextWeight Enum Syntax

**Error**: TextWeight.Semibold instead of 'TextCanvas.Weight'.Semibold

**Fix**:
```yaml
# ❌ WRONG
Weight: =TextWeight.Semibold

# ✅ CORRECT
Weight: ='TextCanvas.Weight'.Semibold
```

### 8. Formulas with Colons Missing Block Scalar

**Error**: YAML parser fails on colons in formulas

**Fix**: Use block scalar `|-` for formulas containing colons:
```yaml
# ❌ WRONG
Text: ="Date: " & Text(Today())

# ✅ CORRECT
Text: |-
  ="Date: " & Text(Today())
```

### 9. Wrong IconFill Property

**Error**: IconFill doesn't exist on Icon@2.5.0

**Fix**: Use Color property for classic icons:
```yaml
# ❌ WRONG
IconFill: =RGBA(...)

# ✅ CORRECT
Color: =RGBA(...)
```

### 10. Wrong Date Field Type

**Error**: Using DateValue on TEXT field

**Fix**: Check FIELD_NAME_REFERENCE.md:
```yaml
# ProcessLogs (TEXT type)
cr7bb_processdate = Text(Today(), "yyyy-mm-dd")

# EmailLogs (DateTime type)
DateValue(cr7bb_sentdatetime) = Today()
```

---

## ✅ Pre-Submission Checklist

Before saying "review scnScreenName":

- [ ] Read universal-powerapp-checklist.md
- [ ] Read nestle-brand-standards.md
- [ ] Verified field names from FIELD_NAME_REFERENCE.md
- [ ] All GroupContainer@1.3.0 have LayoutMinHeight and LayoutMinWidth
- [ ] All GroupContainer@1.3.0 have explicit DropShadow
- [ ] All Text@0.0.51 controls have Width property
- [ ] Using correct control versions (Icon@2.5.0, Gallery@2.15.0)
- [ ] Using Nestlé Blue (0, 101, 161) for headers and primary buttons
- [ ] Using Font.Lato with Weight property (not Font.'Lato Black')
- [ ] Using 'TextCanvas.Weight'.Semibold (not TextWeight.Semibold)
- [ ] AddColumns uses unquoted column names
- [ ] Formulas with colons use block scalar `|-`
- [ ] Icon controls use Color property (not IconFill)
- [ ] All formulas start with `=` symbol

---

## 📖 Reference Documentation

### Primary Sources (Always Trust)
1. **FIELD_NAME_REFERENCE.md** - Field names with cr7bb_ prefix
2. **Universal Standards** - `~/.claude/powerapp-standards/`
3. **Exported YAML** - `Powerapp screens-DO-NOT-EDIT/scnCustomer.yaml`

### Project-Specific Docs
1. **REDESIGNED_SCREENS.md** - Screen architecture decisions
2. **AI_ASSISTANT_RULES_SUMMARY.md** - Project rules
3. **This file** - Development workflow

### Secondary Sources (Conceptual)
1. **database_schema.md** - Schema design (uses nc_ placeholder)
2. **CLAUDE.md** - General project guidance

---

## 🎯 Success Metrics

Track screen quality:

- **First-time pass rate**: Target >70%
- **Critical errors per screen**: Target <3
- **Standards compliance**: Target 100%
- **Time to production**: Target <1 day per screen

---

## 📝 Change Log

### 2025-10-09
- Initial version created
- Added Daily Control Center patterns
- Documented all critical fixes from review
- Added comprehensive error prevention guide

---

**Last Updated**: 2025-10-09
**Status**: Active
**Maintainer**: AI assistants working on this project
