# Manual Build Quick Reference - Daily Control Center

**Purpose**: Quick reference guide when building scnDailyControlCenter manually in Power Apps Studio
**YAML Source**: [scnDailyControlCenter_v2_withDatePicker.yaml](scnDailyControlCenter_v2_withDatePicker.yaml)
**Full Guide**: See [POWER_APPS_IMPORT_NOTE.md](POWER_APPS_IMPORT_NOTE.md)

---

## 🎨 Nestlé Brand Colors (Copy-Paste Ready)

```
Primary Blue:    RGBA(0, 101, 161, 1)
Oak Brown:       RGBA(100, 81, 61, 1)
Pale Gray:       RGBA(243, 242, 241, 1)
Success Green:   RGBA(16, 124, 16, 1)
White:           RGBA(255, 255, 255, 1)
Black Overlay:   RGBA(0, 0, 0, 0.5)
```

---

## 📋 Build Order (Follow This Sequence)

### Step 1: Screen Properties
```
Fill: RGBA(243, 242, 241, 1)
LoadingSpinnerColor: RGBA(100, 81, 61, 1)
OnVisible: [See section below]
```

### Step 2: Header Container
```
Control: Group Container (Auto Layout)
Direction: Vertical
Fill: RGBA(0, 101, 161, 1)
Height: 120
Width: Parent.Width
Gap: 8
Min Height: 0
Min Width: 100
```

### Step 3: Date Navigation Row
```
Control: Group Container (Auto Layout)
Direction: Horizontal
Gap: 12
Min Height: 0
Min Width: 100
```

Add these buttons in order:
1. Previous Day Button
2. Today Button
3. Date Display Label
4. Next Day Button
5. Pick Date Button

### Step 4: Content Area
```
Control: Group Container (Auto Layout)
Direction: Vertical
Gap: 20
Padding: 20
Min Height: 0
Min Width: 100
```

Add these cards in order:
1. System Status Card
2. Quick Actions Card
3. Activity Summary Card

### Step 5: Calendar Picker Modal
```
Control: Group Container (overlay)
Fill: RGBA(0, 0, 0, 0.5)
Visible: _showDatePicker
ZIndex: 100
Height: Parent.Height
Width: Parent.Width
```

---

## 🔧 Critical Formulas (Copy-Paste)

### Screen OnVisible
```javascript
// Initialize selected date to today if not set
If(
    IsBlank(_selectedDate),
    Set(_selectedDate, Today())
);

// Refresh data sources
Refresh('[THFinanceCashCollection]ProcessLogs');
Refresh('[THFinanceCashCollection]EmailLogs');
Refresh('[THFinanceCashCollection]Transactions');
Refresh('[THFinanceCashCollection]Customers');

// Get process log for selected date (cr7bb_processdate is TEXT type)
Set(
    _selectedProcessLog,
    First(
        Filter(
            '[THFinanceCashCollection]ProcessLogs',
            cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")
        )
    )
);

// Calculate email statistics for selected date
Set(
    _emailStats,
    {
        Sent: CountRows(
            Filter(
                '[THFinanceCashCollection]EmailLogs',
                DateValue(cr7bb_sentdatetime) = _selectedDate &&
                cr7bb_sendstatus = "Sent"
            )
        ),
        Failed: CountRows(
            Filter(
                '[THFinanceCashCollection]EmailLogs',
                DateValue(cr7bb_sentdatetime) = _selectedDate &&
                cr7bb_sendstatus = "Failed"
            )
        ),
        Skipped: CountRows(
            Filter(
                '[THFinanceCashCollection]EmailLogs',
                DateValue(cr7bb_sentdatetime) = _selectedDate &&
                cr7bb_sendstatus = "Skipped"
            )
        )
    }
);

// Calculate transaction statistics for selected date
Set(
    _transactionStats,
    {
        TotalDue: Sum(
            Filter(
                '[THFinanceCashCollection]Transactions',
                DateValue(cr7bb_duedate) = _selectedDate
            ),
            cr7bb_amountinlocalcurrency
        ),
        CustomerCount: CountRows(
            Distinct(
                Filter(
                    '[THFinanceCashCollection]Transactions',
                    DateValue(cr7bb_duedate) = _selectedDate
                ),
                cr7bb_customercode
            )
        )
    }
);

// Populate activity summary gallery
ClearCollect(
    colRecentActivity,
    AddColumns(
        FirstN(
            Sort(
                Filter(
                    '[THFinanceCashCollection]EmailLogs',
                    DateValue(cr7bb_sentdatetime) = _selectedDate
                ),
                cr7bb_sentdatetime,
                SortOrder.Descending
            ),
            10
        ),
        "ActivityType", "Email",
        "ActivityTime", Text(cr7bb_sentdatetime, "hh:mm tt"),
        "ActivityDescription", cr7bb_customercode & " - " & cr7bb_sendstatus
    )
);
```

### Previous Day Button OnSelect
```javascript
Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
scnDailyControlCenter.OnVisible
```

### Next Day Button OnSelect
```javascript
Set(_selectedDate, DateAdd(_selectedDate, 1, TimeUnit.Days));
scnDailyControlCenter.OnVisible
```

### Today Button OnSelect
```javascript
Set(_selectedDate, Today());
scnDailyControlCenter.OnVisible
```

### Today Button Fill (Conditional Color)
```javascript
If(
    _selectedDate = Today(),
    RGBA(16, 124, 16, 1),      // Green when selected
    RGBA(0, 101, 161, 1)       // Blue otherwise
)
```

### Date Display Text
```javascript
Text(_selectedDate, "dddd, mmmm dd, yyyy")
```

### Pick Date Button OnSelect
```javascript
Set(_showDatePicker, true)
```

### Calendar Select Button OnSelect
```javascript
Set(_selectedDate, DatePickerControl.SelectedDate);
Set(_showDatePicker, false);
scnDailyControlCenter.OnVisible
```

### Calendar Cancel Button OnSelect
```javascript
Set(_showDatePicker, false)
```

---

## 🎯 Control Properties Quick Reference

### Modern Button@0.0.45
```
Text: "Button Text"
Fill: RGBA(0, 101, 161, 1)
FontColor: RGBA(255, 255, 255, 1)
Font: Font.Lato
Weight: Weight.Semibold
Size: 14
Height: 40
Width: 140
OnSelect: [formula]
```

### Modern Text@0.0.51
```
Text: "Label Text"
FontColor: RGBA(255, 255, 255, 1)
Font: Font.Lato
Weight: Weight.Bold
Size: 18
Align: TextCanvas.Align.Center
VerticalAlign: VerticalAlign.Middle
Width: 300
Height: 40
```

### DatePicker@0.0.51
```
DefaultDate: _selectedDate
Height: 320
Width: 360
```

### GroupContainer@1.3.0 (Auto Layout)
```
LayoutMode: LayoutMode.Auto
LayoutDirection: LayoutDirection.Vertical (or Horizontal)
LayoutGap: 16
LayoutMinHeight: 0        // CRITICAL! Default is 100
LayoutMinWidth: 100       // CRITICAL! Default is 100
DropShadow: DropShadow.None
Fill: [color]
```

---

## ⚠️ Common Mistakes to Avoid

❌ **DON'T**: Forget to set LayoutMinHeight and LayoutMinWidth
✅ **DO**: Always set both to 0 and 100 respectively

❌ **DON'T**: Use `Color` property on Text@0.0.51
✅ **DO**: Use `FontColor` property

❌ **DON'T**: Use `FontWeight` property
✅ **DO**: Use `Weight` property with Weight.Bold, Weight.Semibold

❌ **DON'T**: Forget to call `.OnVisible` after date change
✅ **DO**: Always refresh screen after changing `_selectedDate`

❌ **DON'T**: Mix field types (TEXT vs DateTime) in filters
✅ **DO**: ProcessLogs uses `Text()`, EmailLogs uses `DateValue()`

---

## 🧪 Testing Checklist

After building each component, test:

### Date Navigation
- [ ] Previous button decreases date by 1 day
- [ ] Next button increases date by 1 day
- [ ] Today button jumps to today
- [ ] Today button turns green when today selected
- [ ] Date display updates correctly

### Calendar Picker
- [ ] Pick Date button opens modal
- [ ] Modal overlay covers entire screen
- [ ] Calendar shows correct default date
- [ ] Select button updates date and closes modal
- [ ] Cancel button closes modal without changing date

### Data Filtering
- [ ] Process status shows correct data for selected date
- [ ] Email statistics match selected date
- [ ] Activity summary shows emails from selected date
- [ ] "No data" message shows for dates with no data

### Screen Refresh
- [ ] Screen OnVisible runs after date change
- [ ] All statistics update correctly
- [ ] Gallery refreshes with new data

---

## 🔍 Debugging Tips

### If date navigation doesn't work:
1. Check `_selectedDate` variable in App → Variables
2. Verify OnSelect calls `scnDailyControlCenter.OnVisible`
3. Check for typos in TimeUnit.Days

### If data doesn't update:
1. Verify field names: `cr7bb_processdate`, `cr7bb_sentdatetime`
2. Check field type: ProcessLogs uses TEXT, EmailLogs uses DateTime
3. Verify filter syntax: `Text(_selectedDate, "yyyy-mm-dd")` vs `DateValue(field)`

### If Today button doesn't turn green:
1. Check Fill formula: `If(_selectedDate = Today(), green, blue)`
2. Verify color values are correct
3. Test by clicking Today button and checking color change

### If calendar picker doesn't show:
1. Check `_showDatePicker` variable value
2. Verify ZIndex: Should be 100 (above other controls)
3. Check Visible property: Should be `_showDatePicker`

---

## 📦 Variables Used

| Variable | Type | Scope | Purpose |
|----------|------|-------|---------|
| `_selectedDate` | Date | Screen | Currently selected date for filtering |
| `_showDatePicker` | Boolean | Screen | Controls calendar modal visibility |
| `_selectedProcessLog` | Record | Screen | Process log for selected date |
| `_emailStats` | Record | Screen | Email statistics for selected date |
| `_transactionStats` | Record | Screen | Transaction statistics for selected date |
| `colRecentActivity` | Collection | Screen | Recent activity gallery data |
| `gblFilterDate` | Date | Global | Passed to other screens for date persistence |

---

## 📚 Related Documentation

**Full Details**: See [scnDailyControlCenter_v2_withDatePicker.yaml](scnDailyControlCenter_v2_withDatePicker.yaml) (lines 1-840)

**Pattern Guide**: See [AUDIT_DATE_PATTERN.md](AUDIT_DATE_PATTERN.md)

**Import Workarounds**: See [POWER_APPS_IMPORT_NOTE.md](POWER_APPS_IMPORT_NOTE.md)

**Field Reference**: See [FIELD_NAME_REFERENCE.md](../../FIELD_NAME_REFERENCE.md)

**Universal Standards**: See `~/.claude/powerapp-standards/`

---

**Last Updated**: 2025-10-09
**Status**: Ready for manual build in Power Apps Studio
