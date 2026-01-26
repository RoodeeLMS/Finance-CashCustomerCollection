# scnCalendar Implementation Guide

**Date**: January 26, 2026
**Purpose**: Complete missing implementations for Events_AddBtn and RecalcConfirm_ConfirmBtn

---

## Overview

The scnCalendar screen has two incomplete button implementations:

| Button | Current Status | Issue |
|--------|----------------|-------|
| `Events_AddBtn` | Sets `_showEventForm: true` | **No overlay form exists** |
| `RecalcConfirm_ConfirmBtn` | Flow call commented out | **Flow not connected** |

---

## Part 1: Event Form Overlay

### What We Need

A modal overlay form (similar to `Calendar_RecalcConfirmOverlay`) that allows users to add holidays/events with:
- Description input (required)
- Date pre-filled with `_dateSelected`
- Save button (patches to Dataverse)
- Cancel button

### Step-by-Step: Add Event Form Overlay

#### Step 1.1: Update OnVisible Variables

Add `_showEventForm` to the screen's `OnVisible` property.

**Location**: `scnCalendar.yaml` → `OnVisible` property

**Find this line** (around line 17):
```yaml
_lastRecalcDate: Blank()
```

**Add after it**:
```yaml
_showEventForm: false,
_eventMode: "New",
_selectedEvent: Blank()
```

**Result** (complete first UpdateContext):
```yaml
OnVisible: |-
  =UpdateContext({
      currentScreen: "Calendar",
      _showMenu: false,
      _refreshTrigger: true,
      _isLoading: true,
      _dateSelected: Today(),
      _firstDayOfMonth: DateAdd(Today(), 1 - Day(Today()), TimeUnit.Days),
      _showRecalcConfirm: false,
      _needsRecalc: false,
      _lastRecalcDate: Blank(),
      _showEventForm: false,
      _eventMode: "New",
      _selectedEvent: Blank()
  });
```

---

#### Step 1.2: Add Event Form Overlay Container

Add the overlay after `Calendar_RecalcConfirmOverlay` (after line 1079).

**YAML Code to Add** (insert after line 1079):

```yaml
            - Calendar_EventFormOverlay:
                Control: GroupContainer@1.4.0
                Variant: ManualLayout
                Properties:
                  Fill: =RGBA(0, 0, 0, 0.5)
                  Height: =Parent.Height
                  Visible: =_showEventForm
                  Width: =Parent.Width
                Children:
                  - EventForm_Box:
                      Control: GroupContainer@1.4.0
                      Variant: AutoLayout
                      Properties:
                        DropShadow: =DropShadow.Regular
                        Fill: =RGBA(255, 255, 255, 1)
                        LayoutDirection: =LayoutDirection.Vertical
                        LayoutGap: =15
                        LayoutMinHeight: =250
                        LayoutMinWidth: =380
                        PaddingBottom: =20
                        PaddingLeft: =20
                        PaddingRight: =20
                        PaddingTop: =20
                        RadiusBottomLeft: =10
                        RadiusBottomRight: =10
                        RadiusTopLeft: =10
                        RadiusTopRight: =10
                        Width: =400
                        X: =(Parent.Width - 400) / 2
                        Y: =(Parent.Height - 300) / 2
                      Children:
                        - EventForm_Title:
                            Control: Text@0.0.51
                            Properties:
                              Font: =Font.Lato
                              FontColor: =RGBA(0, 0, 0, 1)
                              Height: =30
                              Size: =18
                              Text: |-
                                =If(
                                    _eventMode = "New",
                                    "Add Holiday/Event",
                                    "Edit Holiday/Event"
                                )
                              Weight: ='TextCanvas.Weight'.Bold
                              Width: =360
                        - EventForm_DateLabel:
                            Control: Text@0.0.51
                            Properties:
                              Font: =Font.Lato
                              FontColor: =RGBA(100, 100, 100, 1)
                              Height: =20
                              Size: =12
                              Text: ="Date"
                              Width: =360
                        - EventForm_DateDisplay:
                            Control: Text@0.0.51
                            Properties:
                              Fill: =RGBA(248, 248, 248, 1)
                              Font: =Font.Lato
                              FontColor: =RGBA(0, 0, 0, 1)
                              Height: =35
                              PaddingLeft: =10
                              Size: =14
                              Text: =Text(_dateSelected, "dddd, mmmm d, yyyy")
                              VerticalAlign: =VerticalAlign.Middle
                              Weight: ='TextCanvas.Weight'.Semibold
                              Width: =360
                        - EventForm_DescLabel:
                            Control: Text@0.0.51
                            Properties:
                              Font: =Font.Lato
                              FontColor: =RGBA(100, 100, 100, 1)
                              Height: =20
                              Size: =12
                              Text: ="Description *"
                              Width: =360
                        - EventForm_DescInput:
                            Control: TextInput@0.0.53
                            Properties:
                              Height: =40
                              Mode: =TextMode.SingleLine
                              Placeholder: ="e.g., New Year's Day, Company Holiday"
                              Value: |-
                                =If(
                                    _eventMode = "New",
                                    "",
                                    _selectedEvent.Description
                                )
                              Width: =360
                        - EventForm_Buttons:
                            Control: GroupContainer@1.4.0
                            Variant: AutoLayout
                            Properties:
                              DropShadow: =DropShadow.None
                              LayoutDirection: =LayoutDirection.Horizontal
                              LayoutGap: =10
                              LayoutJustifyContent: =LayoutJustifyContent.End
                              LayoutMinHeight: =40
                              LayoutMinWidth: =100
                              Width: =360
                            Children:
                              - EventForm_CancelBtn:
                                  Control: Button@0.0.45
                                  Properties:
                                    BasePaletteColor: =RGBA(128, 128, 128, 1)
                                    Height: =35
                                    OnSelect: |-
                                      =Reset(EventForm_DescInput);
                                      UpdateContext({
                                          _showEventForm: false,
                                          _selectedEvent: Blank()
                                      })
                                    Text: ="Cancel"
                                    Width: =100
                              - EventForm_SaveBtn:
                                  Control: Button@0.0.45
                                  Properties:
                                    BasePaletteColor: =RGBA(0, 101, 161, 1)
                                    Disabled: =IsBlank(EventForm_DescInput.Value)
                                    Height: =35
                                    OnSelect: |-
                                      =// Create new calendar event
                                      Patch(
                                          ' [THFinanceCashCollection]CalendarEvents',
                                          Defaults(' [THFinanceCashCollection]CalendarEvents'),
                                          {
                                              'Event Date': _dateSelected,
                                              Description: EventForm_DescInput.Value
                                          }
                                      );

                                      // Refresh local collection
                                      ClearCollect(
                                          colCalendarEvents,
                                          Filter(
                                              ' [THFinanceCashCollection]CalendarEvents',
                                              'Event Date' >= DateAdd(_firstDayOfMonth, -7, TimeUnit.Days) &&
                                              'Event Date' <= DateAdd(_lastDayOfMonth, 7, TimeUnit.Days)
                                          )
                                      );

                                      // Reset form and close
                                      Reset(EventForm_DescInput);
                                      UpdateContext({
                                          _showEventForm: false,
                                          _needsRecalc: true
                                      });

                                      Notify(
                                          "Event added. WDN recalculation needed.",
                                          NotificationType.Warning
                                      )
                                    Text: ="Save"
                                    Width: =100
```

---

## Part 2: RecalculateWDN Flow Connection

### Analysis of Existing Flow

The solution export contains `THFinanceGenerateWorkingDayCalendar` flow:
- **Trigger**: Manual button (NOT Power Apps trigger)
- **Inputs**: StartYear (number), EndYear (number)
- **Purpose**: Generate/regenerate WDN for full year range

**Problem**: This flow uses "Manually trigger a flow" which cannot be called from Power Apps.

### Recommended Solution: Create New Power Apps Flow

Create a new flow specifically for Power Apps recalculation:
- Uses **PowerApps (V2) trigger**
- Accepts **StartYear** and **EndYear** parameters from app
- User selects year range in confirmation dialog

---

### Step-by-Step: Create RecalculateWDN Flow (Child Flow Pattern)

This approach creates a lightweight wrapper flow that calls the existing Generate flow.

#### Step 2.1: Enable Child Flow on Existing Flow

1. Open `THFinanceGenerateWorkingDayCalendar` in **make.powerautomate.com**
2. Click on the trigger → **Settings** (⚙️)
3. Find "**This flow can be used as a child flow**"
4. Toggle **ON**
5. **Save** the flow

---

#### Step 2.2: Create Wrapper Flow

1. Go to **make.powerautomate.com**
2. Click **+ Create** → **Instant cloud flow**
3. Name: `[THFinance] RecalculateWDN (PowerApps)`
4. Trigger: **PowerApps (V2)**
5. Click **Create**

---

#### Step 2.3: Add Trigger Inputs

Click on the **PowerApps (V2)** trigger and add inputs:

**Input 1: StartYear**
```
Type: Number
Name: StartYear
Description: Start year for recalculation (e.g., 2026)
```

**Input 2: EndYear**
```
Type: Number
Name: EndYear
Description: End year for recalculation (e.g., 2027)
```

---

#### Step 2.4: Add "Run a Child Flow" Action

1. Click **+ New step**
2. Search for **"Run a Child Flow"**
3. Select: `THFinanceGenerateWorkingDayCalendar`
4. Map inputs:
   ```
   StartYear: @{triggerBody()?['number']}
   EndYear: @{triggerBody()?['number_1']}
   ```

Rename to: `Run_a_Child_Flow`

---

#### Step 2.5: Return Status

**Action**: Respond to a PowerApp or flow (V2)
```
Output name: Status
Value: Success - Recalculated WDN for @{triggerBody()?['number']} to @{triggerBody()?['number_1']}
RunAfter: Run_a_Child_Flow [Succeeded]
```

---

#### Step 2.6: Save and Test

1. Save the flow
2. Test with StartYear=2026, EndYear=2027
3. Verify WDN updates in Dataverse

---

### Complete Flow Structure

```json
{
  "trigger": "PowerAppV2",
  "inputs": {
    "number": "StartYear",
    "number_1": "EndYear"
  },
  "actions": [
    {
      "Run_a_Child_Flow": {
        "type": "Workflow",
        "inputs": {
          "workflowReferenceName": "THFinanceGenerateWorkingDayCalendar",
          "body": {
            "number": "@triggerBody()['number']",
            "number_1": "@triggerBody()['number_1']"
          }
        }
      }
    },
    {
      "Respond_to_a_Power_App_or_flow": {
        "type": "Response",
        "inputs": {
          "body": {
            "status": "Success - Recalculated WDN..."
          }
        },
        "runAfter": { "Run_a_Child_Flow": ["Succeeded"] }
      }
    }
  ]
}
```

**Benefits of Child Flow Pattern**:
- Only 3 actions (vs 20+ duplicated actions)
- Single source of truth for WDN logic
- Easier maintenance - update one flow
- Automatic sync between manual and app triggers

---

### Step-by-Step: Connect Flow to Power Apps

#### Step 2.10: Add Power Automate Connection

1. Open **Power Apps Studio**
2. Go to **Data** panel → **Add data**
3. Search for your flow: `[THFinance] RecalculateWDN (PowerApps)`
4. Add to app

---

#### Step 2.11: Update RecalcConfirm Dialog with Year Pickers

Add year selection dropdowns to the confirmation dialog. Update `Calendar_RecalcConfirmOverlay` in scnCalendar.yaml.

**Replace the entire `RecalcConfirm_Box` children** with:

```yaml
Children:
  - RecalcConfirm_Title:
      Control: Text@0.0.51
      Properties:
        Font: =Font.Lato
        FontColor: =RGBA(0, 0, 0, 1)
        Height: =30
        Size: =18
        Text: ="Recalculate Working Day Numbers"
        Weight: ='TextCanvas.Weight'.Bold
        Width: =360
  - RecalcConfirm_Message:
      Control: Text@0.0.51
      Properties:
        AutoHeight: =true
        Font: =Font.Lato
        FontColor: =RGBA(100, 100, 100, 1)
        Size: =13
        Text: ="Select the year range to recalculate WDN values."
        Width: =360
  - RecalcConfirm_YearRow:
      Control: GroupContainer@1.4.0
      Variant: AutoLayout
      Properties:
        DropShadow: =DropShadow.None
        LayoutAlignItems: =LayoutAlignItems.Center
        LayoutDirection: =LayoutDirection.Horizontal
        LayoutGap: =15
        LayoutMinHeight: =70
        LayoutMinWidth: =100
        Width: =360
      Children:
        - RecalcConfirm_StartYearGroup:
            Control: GroupContainer@1.4.0
            Variant: AutoLayout
            Properties:
              DropShadow: =DropShadow.None
              FillPortions: =1
              LayoutDirection: =LayoutDirection.Vertical
              LayoutGap: =5
              LayoutMinHeight: =60
              LayoutMinWidth: =80
            Children:
              - RecalcConfirm_StartYearLabel:
                  Control: Text@0.0.51
                  Properties:
                    Font: =Font.Lato
                    FontColor: =RGBA(100, 100, 100, 1)
                    Height: =20
                    Size: =12
                    Text: ="Start Year"
                    Width: =150
              - RecalcConfirm_StartYearDropdown:
                  Control: ComboBox@0.0.51
                  Properties:
                    Height: =38
                    Items: =[Year(Today()) - 1, Year(Today()), Year(Today()) + 1, Year(Today()) + 2]
                    DefaultSelectedItems: =[Year(Today())]
                    Width: =150
        - RecalcConfirm_EndYearGroup:
            Control: GroupContainer@1.4.0
            Variant: AutoLayout
            Properties:
              DropShadow: =DropShadow.None
              FillPortions: =1
              LayoutDirection: =LayoutDirection.Vertical
              LayoutGap: =5
              LayoutMinHeight: =60
              LayoutMinWidth: =80
            Children:
              - RecalcConfirm_EndYearLabel:
                  Control: Text@0.0.51
                  Properties:
                    Font: =Font.Lato
                    FontColor: =RGBA(100, 100, 100, 1)
                    Height: =20
                    Size: =12
                    Text: ="End Year"
                    Width: =150
              - RecalcConfirm_EndYearDropdown:
                  Control: ComboBox@0.0.51
                  Properties:
                    Height: =38
                    Items: =[Year(Today()), Year(Today()) + 1, Year(Today()) + 2, Year(Today()) + 3]
                    DefaultSelectedItems: =[Year(Today()) + 1]
                    Width: =150
  - RecalcConfirm_ValidationMsg:
      Control: Text@0.0.51
      Properties:
        Font: =Font.Lato
        FontColor: =RGBA(212, 41, 57, 1)
        Height: =20
        Size: =11
        Text: ="End year must be >= Start year"
        Visible: =RecalcConfirm_EndYearDropdown.Selected.Value < RecalcConfirm_StartYearDropdown.Selected.Value
        Width: =360
  - RecalcConfirm_Info:
      Control: Text@0.0.51
      Properties:
        Font: =Font.Lato
        FontColor: =RGBA(100, 100, 100, 1)
        Height: =40
        Size: =11
        Text: ="This will update WDN for all dates in the selected range. Process may take 1-5 minutes depending on range."
        Width: =360
  - RecalcConfirm_Buttons:
      Control: GroupContainer@1.4.0
      Variant: AutoLayout
      Properties:
        DropShadow: =DropShadow.None
        LayoutDirection: =LayoutDirection.Horizontal
        LayoutGap: =10
        LayoutJustifyContent: =LayoutJustifyContent.End
        LayoutMinHeight: =40
        LayoutMinWidth: =100
        Width: =360
      Children:
        - RecalcConfirm_CancelBtn:
            Control: Button@0.0.45
            Properties:
              BasePaletteColor: =RGBA(128, 128, 128, 1)
              Height: =35
              OnSelect: |-
                =UpdateContext({_showRecalcConfirm: false})
              Text: ="Cancel"
              Width: =100
        - RecalcConfirm_ConfirmBtn:
            Control: Button@0.0.45
            Properties:
              BasePaletteColor: =RGBA(0, 101, 161, 1)
              Disabled: =RecalcConfirm_EndYearDropdown.Selected.Value < RecalcConfirm_StartYearDropdown.Selected.Value
              Height: =35
              OnSelect: |-
                =// Show loading state
                UpdateContext({_isRecalculating: true});

                // Call Power Automate flow with year parameters
                Set(
                    _recalcResult,
                    '[THFinance]RecalculateWDN(PowerApps)'.Run(
                        RecalcConfirm_StartYearDropdown.Selected.Value,
                        RecalcConfirm_EndYearDropdown.Selected.Value
                    )
                );

                // Refresh local WDN collection
                ClearCollect(
                    colWorkingDayCalendar,
                    Filter(
                        '[THFinanceCashCollection]WorkingDayCalendars',
                        'Calendar Date' >= DateAdd(_firstDayOfMonth, -7, TimeUnit.Days) &&
                        'Calendar Date' <= DateAdd(_lastDayOfMonth, 7, TimeUnit.Days)
                    )
                );

                // Update UI state
                UpdateContext({
                    _isRecalculating: false,
                    _needsRecalc: false,
                    _lastRecalcDate: Now(),
                    _showRecalcConfirm: false
                });

                Notify(
                    "WDN recalculation complete for " & RecalcConfirm_StartYearDropdown.Selected.Value & "-" & RecalcConfirm_EndYearDropdown.Selected.Value & "!",
                    NotificationType.Success
                )
              Text: ="Recalculate"
              Width: =120
```

> **Note**: Replace `'[THFinance]RecalculateWDN(PowerApps)'` with the actual flow name as it appears in Power Apps after adding the connection.

---

---

## Alternative: Use Existing Flow (Manual Approach)

If you prefer not to create a new flow, users can:

1. Click "Recalculate" in Power Apps
2. App shows notification: "Please run the recalculation flow manually"
3. User goes to Power Automate and runs `[THFinance] Generate WorkingDayCalendar`
4. User enters StartYear (current year) and EndYear (current year + 2)

This approach is simpler but requires manual intervention.

---

## Testing Checklist

### Event Form Overlay
- [ ] Click "Add" button shows overlay
- [ ] Date displays `_dateSelected`
- [ ] Description input validates (Save disabled when empty)
- [ ] Cancel closes form without saving
- [ ] Save creates record in Dataverse
- [ ] Collection refreshes after save
- [ ] `_needsRecalc` flag sets to true
- [ ] Warning notification appears

### RecalculateWDN Flow
- [ ] Flow runs without errors
- [ ] WDN updates correctly in Dataverse
- [ ] Power Apps can call flow with year parameters
- [ ] Year dropdowns show correct range (previous year to +3 years)
- [ ] Validation prevents EndYear < StartYear
- [ ] UI shows loading state during recalc
- [ ] Collection refreshes after recalc
- [ ] `_needsRecalc` resets to false
- [ ] Success notification shows selected year range

---

## Summary of Changes

| File | Change |
|------|--------|
| `scnCalendar.yaml` | Add `_showEventForm`, `_eventMode`, `_selectedEvent` to OnVisible |
| `scnCalendar.yaml` | Add `Calendar_EventFormOverlay` container (after line 1079) |
| `scnCalendar.yaml` | Replace `RecalcConfirm_Box` children with year picker dialog |
| Power Automate | Enable child flow on `THFinanceGenerateWorkingDayCalendar` |
| Power Automate | Create wrapper `[THFinance] RecalculateWDN (PowerApps)` (3 actions only) |

---

## CalendarEvents Table Reference

**Table Name**: `' [THFinanceCashCollection]CalendarEvents'` (note space before bracket)

| Field | Logical Name | Type |
|-------|--------------|------|
| Event Date | `nc_eventdate` | Date Only |
| Description | `nc_description` | Text |
| Name (Primary) | `nc_name` | Text (auto-generated) |

> **Warning**: This table uses `nc_` prefix, not `cr7bb_` like other tables.

---

**Status**: Ready for implementation
