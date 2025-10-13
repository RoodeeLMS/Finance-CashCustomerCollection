# Audit Date Selection Pattern

**Purpose**: Standard pattern for adding date selection to all screens for historical data audit
**Created**: 2025-10-09
**Status**: **MANDATORY for all data screens**

---

## Business Requirement

> "User mostly use the app to audit what happened. So all data screens should be able to select date to view the info from the process on that date."

All screens that display ProcessLogs, EmailLogs, or Transactions data MUST include date selection capability to allow AR team to audit historical activity.

---

## Pattern Components

### 1. Date Variable (_selectedDate)

**Initialize in OnVisible**:
```yaml
OnVisible: |-
  =// Initialize selected date to today if not set
  If(
      IsBlank(_selectedDate),
      Set(_selectedDate, Today())
  );
```

**Behavior**:
- Defaults to Today() on first load
- Persists across screen refreshes
- Shared across navigation (use global `gblFilterDate` when navigating between screens)

---

### 2. Date Navigation Controls

**Location**: Header (2nd row below title)

**Components**:
1. **"View Date:" Label** - Fixed text
2. **◄ Previous Button** - Go back one day
3. **Date Display** - Shows selected date with "(Today)" indicator
4. **Next ► Button** - Go forward one day (disabled if date >= Today)
5. **Today Button** - Jump to today (green when selected)
6. **📅 Pick Date Button** - Open calendar picker modal

**Layout**:
```
┌──────────────────────────────────────────────────────────────────────────┐
│  AR Control Center - Audit View           [↻ Refresh]                    │
├──────────────────────────────────────────────────────────────────────────┤
│  View Date:  [◄ Previous] [  09/10/2025 (Today)  ] [Next ►] [Today] [📅]│
└──────────────────────────────────────────────────────────────────────────┘
```

---

### 3. Navigation Button Code

**Previous Day**:
```yaml
PreviousDayButton:
  Control: Button@0.0.45
  Properties:
    Text: ="◄ Previous"
    OnSelect: |-
      =Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
      scnDailyControlCenter.OnVisible
```

**Next Day** (with disable logic):
```yaml
NextDayButton:
  Control: Button@0.0.45
  Properties:
    Text: ="Next ►"
    DisplayMode: |-
      =If(
          _selectedDate >= Today(),
          DisplayMode.Disabled,
          DisplayMode.Edit
      )
    OnSelect: |-
      =Set(_selectedDate, DateAdd(_selectedDate, 1, TimeUnit.Days));
      scnDailyControlCenter.OnVisible
```

**Today Button** (with visual feedback):
```yaml
TodayButton:
  Control: Button@0.0.45
  Properties:
    Text: ="Today"
    Fill: |-
      =If(
          _selectedDate = Today(),
          RGBA(16, 124, 16, 1),    # Green when today
          RGBA(0, 101, 161, 1)     # Blue otherwise
      )
    OnSelect: |-
      =Set(_selectedDate, Today());
      scnDailyControlCenter.OnVisible
```

**Date Display**:
```yaml
SelectedDateDisplay:
  Control: Text@0.0.51
  Properties:
    Text: |-
      =Text(_selectedDate, "[$-th-TH]dd/mm/yyyy") &
      If(
          _selectedDate = Today(),
          " (Today)",
          ""
      )
    Fill: =RGBA(0, 86, 149, 1)
    Align: ='TextCanvas.Align'.Center
```

---

### 4. Calendar Picker Modal

**Trigger Button**:
```yaml
DatePickerButton:
  Control: Button@0.0.45
  Properties:
    Text: ="📅 Pick Date"
    OnSelect: =Set(_showDatePicker, !_showDatePicker)
```

**Modal Overlay** (full screen, semi-transparent):
```yaml
DatePickerOverlay:
  Control: GroupContainer@1.3.0
  Properties:
    Visible: =_showDatePicker
    Fill: =RGBA(0, 0, 0, 0.5)    # 50% transparent black
    X: =0
    Y: =0
    Width: =Parent.Width
    Height: =Parent.Height
    ZIndex: =100                  # Above all other controls
    LayoutJustifyContent: =LayoutJustifyContent.Center
    LayoutAlignItems: =LayoutAlignItems.Center
```

**Date Picker Card** (centered):
```yaml
DatePickerCard:
  Control: GroupContainer@1.3.0
  Properties:
    Fill: =RGBA(255, 255, 255, 1)
    DropShadow: =DropShadow.Light
    Width: =400
    Height: =450
  Children:
    - DatePickerHeader:
        Text: ="Select Audit Date"
    - DatePickerControl:
        Control: DatePicker@0.0.51
        Properties:
          DefaultDate: =_selectedDate
          Height: =320
          Width: =360
    - DatePickerSelectButton:
        Text: ="Select Date"
        OnSelect: |-
          =Set(_selectedDate, DatePickerControl.SelectedDate);
          Set(_showDatePicker, false);
          scnDailyControlCenter.OnVisible
    - DatePickerCancelButton:
        Text: ="Cancel"
        OnSelect: =Set(_showDatePicker, false)
```

---

### 5. Data Filtering by Selected Date

**ProcessLogs** (TEXT date field):
```yaml
// Filter ProcessLogs by selected date
Set(
    _selectedProcessLog,
    First(
        Filter(
            '[THFinanceCashCollection]ProcessLogs',
            cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")
        )
    )
);
```

**EmailLogs** (DateTime field):
```yaml
// Filter EmailLogs by selected date
Set(
    _emailStats,
    {
        Sent: CountRows(
            Filter(
                '[THFinanceCashCollection]EmailLogs',
                DateValue(cr7bb_sentdatetime) = _selectedDate &&
                cr7bb_sendstatus = "Sent"
            )
        )
    }
);
```

**Transactions** (can use either pattern):
```yaml
// Filter Transactions by selected date
ClearCollect(
    colDailyTransactions,
    Filter(
        '[THFinanceCashCollection]Transactions',
        DateValue(cr7bb_importdate) = _selectedDate
    )
);
```

---

### 6. Global Date Variable for Navigation

**Set global when navigating** (so other screens use same date):
```yaml
ReviewEmailsButton:
  OnSelect: |-
    =Set(gblFilterDate, _selectedDate);
    Navigate(scnEmailMonitor)
```

**Use global on target screen**:
```yaml
scnEmailMonitor:
  OnVisible: |-
    =// Use global date if passed from another screen
    If(
        !IsBlank(gblFilterDate),
        Set(_selectedDate, gblFilterDate),
        If(
            IsBlank(_selectedDate),
            Set(_selectedDate, Today())
        )
    );
```

---

## Screen-Specific Adaptations

### Daily Control Center
- **Removed**: Important Customers section (not date-specific)
- **Changed**: "Recent Activity" → "Activity for selected date"
- **Added**: Activity count in header ("15 emails sent")

### Email Monitor (Future)
- **Must have**: Date selection with same navigation pattern
- **Filter**: All email galleries by `_selectedDate`
- **Feature**: Email preview with date context

### Transaction Inspector (Future)
- **Must have**: Date selection
- **Filter**: Show only transactions imported on `_selectedDate`
- **Feature**: FIFO calculation results for that date

### Customer Hub (Future)
- **Optional**: Date selection (customers don't change by date)
- **Use case**: Show customer status as of specific date (advanced)

---

## Implementation Checklist

For each data screen:

- [ ] Add date variable initialization in OnVisible
- [ ] Add Date Navigation Row to header (below title)
  - [ ] "View Date:" label
  - [ ] Previous Day button
  - [ ] Date Display with "(Today)" indicator
  - [ ] Next Day button (with disable logic)
  - [ ] Today button (with green highlight)
  - [ ] Pick Date button
- [ ] Add Date Picker Modal overlay
  - [ ] Semi-transparent background
  - [ ] Centered white card
  - [ ] DatePicker control
  - [ ] Select and Cancel buttons
- [ ] Update ALL data filters to use `_selectedDate`
- [ ] Update section headers to show selected date
- [ ] Add global variable support for navigation
- [ ] Test navigation between dates
- [ ] Test calendar picker
- [ ] Verify "No data" messages for empty dates

---

## Visual Standards

### Header Height
- **Without date**: 80px
- **With date controls**: 120px (increase by 40px)

### Colors
- **Today button (when selected)**: Green RGBA(16, 124, 16, 1)
- **Today button (not selected)**: Nestlé Blue RGBA(0, 101, 161, 1)
- **Date Display background**: Darker blue RGBA(0, 86, 149, 1)
- **Modal overlay**: Black 50% transparent RGBA(0, 0, 0, 0.5)

### Typography
- **"View Date:" label**: Size 16, Semibold
- **Date display**: Size 18, Bold
- **Buttons**: Standard button font

---

## Error Handling

### No Data for Selected Date
```yaml
Text: |-
  =If(
      IsBlank(_selectedProcessLog),
      "No run recorded",  # Show friendly message
      _selectedProcessLog.cr7bb_status
  )
```

### Future Dates
- Next button disabled when `_selectedDate >= Today()`
- User can still pick future dates from calendar (but no data will show)

### Invalid Dates
- DatePicker control handles validation automatically
- Power Apps prevents invalid date selection

---

## Performance Considerations

### Re-Query on Date Change
Every date change triggers `OnVisible` which refreshes all data:
```yaml
OnSelect: |-
  =Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
  scnDailyControlCenter.OnVisible  # Triggers full refresh
```

### Optimization Tips
1. **Don't use Refresh()** on every date change (data already loaded)
2. **Use Filter()** on existing collections when possible
3. **Limit galleries** to 10-20 items per date
4. **Consider caching** frequently accessed dates (advanced)

---

## Testing Scenarios

### Date Navigation
- [ ] Previous button goes back one day
- [ ] Next button goes forward one day
- [ ] Next button disabled when viewing today
- [ ] Today button jumps to today
- [ ] Today button shows green when today selected
- [ ] Date display shows correct Thai format
- [ ] Date display shows "(Today)" when applicable

### Calendar Picker
- [ ] Click "📅 Pick Date" opens modal
- [ ] Modal dims background
- [ ] Calendar shows correct default date
- [ ] Select Date closes modal and refreshes data
- [ ] Cancel closes modal without changes
- [ ] Click outside modal does NOT close (by design)

### Data Filtering
- [ ] All data updates when date changes
- [ ] Correct data shown for selected date
- [ ] "No data" messages when date has no records
- [ ] Count displays match actual data (e.g., "15 emails")

### Navigation Between Screens
- [ ] Date persists when navigating away and back
- [ ] Global date passed to other screens
- [ ] Other screens respect passed date

---

## Example Screens

### ✅ Implemented
- **Daily Control Center v2** - Full pattern with date picker and navigation
  - Location: `Screen Development/ACTIVE/scnDailyControlCenter_v2_withDatePicker.yaml`

### 📋 To Implement
- **Email Monitor** - MUST include date selection
- **Transaction Inspector** - MUST include date selection
- **Customer Hub** - Optional (customers don't change by date)

---

## Code Snippet Library

### Complete Header with Date Controls
See `scnDailyControlCenter_v2_withDatePicker.yaml` lines 104-258

### Date Picker Modal
See `scnDailyControlCenter_v2_withDatePicker.yaml` lines 260-348

### Date-Filtered Data Loading
See `scnDailyControlCenter_v2_withDatePicker.yaml` lines 6-101

---

## Related Documentation

- **SCREEN_DEVELOPMENT_GUIDE.md** - Overall development workflow
- **REDESIGNED_SCREENS.md** - Screen architecture decisions
- **FIELD_NAME_REFERENCE.md** - Date field names and types

---

**Last Updated**: 2025-10-09
**Pattern Version**: 1.0
**Mandatory**: YES - All data screens must implement this pattern
