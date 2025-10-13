# Audit Date Selection Pattern

**Pattern Type**: MANDATORY for all data screens
**Business Requirement**: AR team needs to audit historical data, not just today's data
**Created**: 2025-10-09
**Status**: Standard pattern - implement on ALL data screens

---

## Overview

The Audit Date Selection Pattern allows users to view historical data by selecting any date. This is CRITICAL for the AR Control Center because:

1. **Audit Trail**: AR team reviews past processes to verify email sends
2. **Troubleshooting**: Investigate issues from specific dates
3. **Reporting**: Generate reports for any date range
4. **Compliance**: Document exactly what happened on any given day

**Where to Apply**:
- ✅ Daily Control Center (implemented)
- ⏳ Email Monitor screen (pending)
- ⏳ Transaction Inspector screen (pending)
- ⏳ Any screen showing ProcessLogs, EmailLogs, or Transactions

---

## Pattern Components

The pattern has **6 core components**:

### 1. Date Variable Initialization
```yaml
OnVisible: |-
  =// Initialize selected date to today if not set
  If(
      IsBlank(_selectedDate),
      Set(_selectedDate, Today())
  );
```

**Why**:
- Default to today on first load
- Preserve date across screen navigation
- Local variable `_selectedDate` for screen-specific state

---

### 2. Date-Filtered Data Loading

For **TEXT date fields** (ProcessLogs):
```yaml
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

For **DateTime fields** (EmailLogs):
```yaml
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

**Critical Field Type Differences**:
- **ProcessLogs**: `cr7bb_processdate` is TEXT type → Use `Text(_selectedDate, "yyyy-mm-dd")`
- **EmailLogs**: `cr7bb_sentdatetime` is DateTime → Use `DateValue(field) = _selectedDate`
- **Transactions**: `cr7bb_duedate` is DateTime → Use `DateValue(field) = _selectedDate`

---

### 3. Date Navigation Controls

**Previous Day Button**:
```yaml
- PreviousDayButton:
    Control: Button@0.0.45
    Properties:
      Text: ="◄ Previous"
      OnSelect: |-
        =Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
        scnDailyControlCenter.OnVisible
```

**Next Day Button**:
```yaml
- NextDayButton:
    Control: Button@0.0.45
    Properties:
      Text: ="Next ►"
      OnSelect: |-
        =Set(_selectedDate, DateAdd(_selectedDate, 1, TimeUnit.Days));
        scnDailyControlCenter.OnVisible
```

**Today Button** (with visual feedback):
```yaml
- TodayButton:
    Control: Button@0.0.45
    Properties:
      Text: ="Today"
      Fill: |-
        =If(
            _selectedDate = Today(),
            RGBA(16, 124, 16, 1),      // Green when selected
            RGBA(0, 101, 161, 1)       // Nestlé Blue otherwise
        )
      OnSelect: |-
        =Set(_selectedDate, Today());
        scnDailyControlCenter.OnVisible
```

**Date Display**:
```yaml
- DateDisplayLabel:
    Control: Text@0.0.51
    Properties:
      Text: =Text(_selectedDate, "dddd, mmmm dd, yyyy")
      FontColor: =RGBA(255, 255, 255, 1)
      Size: =18
      Weight: =Weight.Bold
      Width: =300
```

---

### 4. Calendar Picker Modal

**Open Calendar Button**:
```yaml
- PickDateButton:
    Control: Button@0.0.45
    Properties:
      Text: ="📅 Pick Date"
      OnSelect: =Set(_showDatePicker, true)
```

**Calendar Modal Overlay**:
```yaml
- DatePickerOverlay:
    Control: GroupContainer@1.3.0
    Properties:
      Fill: =RGBA(0, 0, 0, 0.5)     # Semi-transparent black overlay
      Height: =Parent.Height
      Width: =Parent.Width
      Visible: =_showDatePicker
      ZIndex: =100                   # Above all controls
    Children:
      - DatePickerCard:
          Control: GroupContainer@1.3.0
          Variant: AutoLayout
          Properties:
            Fill: =RGBA(255, 255, 255, 1)
            LayoutDirection: =LayoutDirection.Vertical
            LayoutGap: =16
            LayoutMinHeight: =0
            LayoutMinWidth: =100
            Width: =400
            X: =(Parent.Width - Self.Width) / 2
            Y: =(Parent.Height - Self.Height) / 2
          Children:
            - DatePickerTitle:
                Control: Text@0.0.51
                Properties:
                  Text: ="Select Date"
                  Size: =20
                  Weight: =Weight.Bold
                  Width: =Parent.Width

            - DatePickerControl:
                Control: DatePicker@0.0.51
                Properties:
                  DefaultDate: =_selectedDate
                  Height: =320
                  Width: =360

            - DatePickerSelectButton:
                Control: Button@0.0.45
                Properties:
                  Text: ="Select"
                  OnSelect: |-
                    =Set(_selectedDate, DatePickerControl.SelectedDate);
                    Set(_showDatePicker, false);
                    scnDailyControlCenter.OnVisible

            - DatePickerCancelButton:
                Control: Button@0.0.45
                Properties:
                  Text: ="Cancel"
                  OnSelect: =Set(_showDatePicker, false)
```

---

### 5. Cross-Screen Date Passing

**Global Variable for Navigation**:
```yaml
- ReviewEmailsButton:
    Control: Button@0.0.45
    Properties:
      Text: ="Review Emails"
      OnSelect: |-
        =Set(gblFilterDate, _selectedDate);
        Navigate(scnEmailMonitor)
```

**Target Screen Receives Date**:
```yaml
# In scnEmailMonitor.OnVisible:
OnVisible: |-
  =// Use passed date or default to today
  If(
      IsBlank(_selectedDate),
      If(
          IsBlank(gblFilterDate),
          Set(_selectedDate, Today()),
          Set(_selectedDate, gblFilterDate)
      )
  );
```

---

### 6. Data Refresh on Date Change

**Pattern**: Call screen's `OnVisible` after date change
```yaml
OnSelect: |-
  =Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
  scnDailyControlCenter.OnVisible    // Refresh all data
```

**Why**:
- Reloads all filtered data
- Updates all statistics
- Refreshes galleries
- Keeps code DRY (Don't Repeat Yourself)

---

## Screen-Specific Adaptations

### Daily Control Center
**Data Sources**: ProcessLogs (TEXT), EmailLogs (DateTime)
**Key Metrics**: Process status, email counts, activity summary
**Date Display**: Full format with day name

### Email Monitor Screen
**Data Sources**: EmailLogs (DateTime)
**Key Metrics**: Sent/Failed/Skipped counts, customer list
**Date Display**: Short format for compact layout
**Gallery Filter**:
```yaml
Items: |-
  =Filter(
      '[THFinanceCashCollection]EmailLogs',
      DateValue(cr7bb_sentdatetime) = _selectedDate
  )
```

### Transaction Inspector Screen
**Data Sources**: Transactions (DateTime)
**Key Metrics**: Transaction totals, customer breakdown
**Date Display**: Include totals in header
**Gallery Filter**:
```yaml
Items: |-
  =Filter(
      '[THFinanceCashCollection]Transactions',
      DateValue(cr7bb_duedate) = _selectedDate
  )
```

---

## Implementation Checklist

When adding audit date pattern to a screen:

- [ ] **Step 1**: Add date variable initialization to `OnVisible`
- [ ] **Step 2**: Identify all data sources and their date field types (TEXT vs DateTime)
- [ ] **Step 3**: Update all data loading to filter by `_selectedDate`
- [ ] **Step 4**: Add date navigation buttons (Previous/Next/Today)
- [ ] **Step 5**: Add date display label with current date
- [ ] **Step 6**: Add calendar picker modal
- [ ] **Step 7**: Update all button `OnSelect` to refresh screen after date change
- [ ] **Step 8**: Add global variable passing for navigation buttons
- [ ] **Step 9**: Test date navigation (Previous/Next/Today/Calendar)
- [ ] **Step 10**: Test data filtering (verify correct data for each date)
- [ ] **Step 11**: Test cross-screen navigation (verify date persists)
- [ ] **Step 12**: Test edge cases (future dates, very old dates, no data)

---

## Testing Scenarios

### Scenario 1: Basic Navigation
1. Load screen → Should show today's data
2. Click Previous → Should show yesterday's data
3. Click Next → Should return to today
4. Click Today → Button turns green, confirms today selected

### Scenario 2: Calendar Selection
1. Click "📅 Pick Date" → Modal opens
2. Select date 1 week ago → Data updates to that date
3. Click Cancel → Date unchanged

### Scenario 3: Date Persistence
1. Select date 3 days ago on Daily Control Center
2. Navigate to Email Monitor → Should show same date
3. Return to Daily Control Center → Date preserved

### Scenario 4: No Data Handling
1. Select future date → Show "No data for this date"
2. Select very old date → Show "No data for this date"
3. Verify no errors, just empty state

### Scenario 5: Date Field Type Handling
1. ProcessLogs (TEXT): Verify `Text(_selectedDate, "yyyy-mm-dd")` works
2. EmailLogs (DateTime): Verify `DateValue(field) = _selectedDate` works
3. Mixed queries: Both filters work simultaneously

---

## Common Pitfalls

### ❌ Wrong: Using same filter for different field types
```yaml
# DON'T DO THIS - ProcessLogs uses TEXT date
Filter(
    '[THFinanceCashCollection]ProcessLogs',
    DateValue(cr7bb_processdate) = _selectedDate    // ERROR!
)
```

### ✅ Right: Match filter to field type
```yaml
# ProcessLogs uses TEXT date
Filter(
    '[THFinanceCashCollection]ProcessLogs',
    cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")
)

# EmailLogs uses DateTime
Filter(
    '[THFinanceCashCollection]EmailLogs',
    DateValue(cr7bb_sentdatetime) = _selectedDate
)
```

---

### ❌ Wrong: Not refreshing after date change
```yaml
OnSelect: =Set(_selectedDate, DateAdd(_selectedDate, -1))
// Data not refreshed! User sees old data!
```

### ✅ Right: Always refresh after date change
```yaml
OnSelect: |-
  =Set(_selectedDate, DateAdd(_selectedDate, -1, TimeUnit.Days));
  scnDailyControlCenter.OnVisible    // Refresh all data
```

---

### ❌ Wrong: Forgetting to initialize date variable
```yaml
OnVisible: |-
  =// Missing date initialization!
  Refresh('[THFinanceCashCollection]ProcessLogs');
```

### ✅ Right: Always initialize date first
```yaml
OnVisible: |-
  =If(IsBlank(_selectedDate), Set(_selectedDate, Today()));
  Refresh('[THFinanceCashCollection]ProcessLogs');
```

---

## Performance Considerations

### Data Volume
- **ProcessLogs**: 1 record per day → Fast filtering
- **EmailLogs**: ~100 records per day → Use delegation-friendly filters
- **Transactions**: ~500 records per day → Consider gallery pagination

### Delegation
All filters use `=` operator which is delegation-friendly for Dataverse:
```yaml
# Delegable (good)
cr7bb_processdate = Text(_selectedDate, "yyyy-mm-dd")
DateValue(cr7bb_sentdatetime) = _selectedDate

# Not delegable (avoid)
StartsWith(cr7bb_processdate, "2025")
```

### Loading Performance
Use `Concurrent()` for parallel data loading:
```yaml
OnVisible: |-
  =If(IsBlank(_selectedDate), Set(_selectedDate, Today()));

  Concurrent(
      Set(_selectedProcessLog, First(Filter('[THFinanceCashCollection]ProcessLogs', ...))),
      Set(_emailStats, {...}),
      Set(_transactionSummary, {...})
  );
```

---

## Related Documentation

- **SCREEN_DEVELOPMENT_GUIDE.md** - Overall screen development workflow
- **FIELD_NAME_REFERENCE.md** - Verify field names and types
- **POWER_APPS_IMPORT_NOTE.md** - How to import YAML to Power Apps Studio
- **nestle-brand-standards.md** - Button colors and fonts

---

## Questions?

If you need to adapt this pattern:
1. Check field types in FIELD_NAME_REFERENCE.md
2. Test filter syntax in Power Apps Studio formula bar
3. Use Quick Check to validate YAML syntax
4. Review this guide for examples

---

**Last Updated**: 2025-10-09
**Author**: Claude Code
**Status**: Standard pattern - mandatory for all data screens
