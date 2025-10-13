# Header & Navigation Pattern Analysis

**Date:** 2025-01-09
**Source:** Template screens (scnDashboard, scnPositionLibrary, scnRole)
**Target:** scnDailyControlCenter_v2_withDatePicker.yaml

---

## Standard Template Pattern

### 1. Screen Structure

```
Screen (Parent.Height, Parent.Width)
├── MainContainer (ManualLayout, full screen)
│   ├── Header (AutoLayout, 55px height, top: 10px)
│   │   ├── MenuIcon (Hamburger, 50x50px)
│   │   └── Title (Text@0.0.51, 25px font)
│   ├── Content (ManualLayout, height: Parent.Height - 85, top: 75px)
│   │   └── [Screen-specific content]
│   └── NavigationMenu (CanvasComponent, sidebar)
```

### 2. Header Component Pattern

**Container:**
```yaml
- [ScreenPrefix]_Header:
    Control: GroupContainer@1.3.0
    Variant: AutoLayout
    Properties:
      DropShadow: =DropShadow.Regular
      Fill: =RGBA(0, 101, 161, 1)  # Nestlé Blue
      Height: =55
      LayoutAlignItems: =LayoutAlignItems.Center
      LayoutDirection: =LayoutDirection.Horizontal
      LayoutGap: =10
      PaddingLeft: =15
      RadiusBottomLeft: =8
      RadiusBottomRight: =8
      RadiusTopLeft: =8
      RadiusTopRight: =8
      Width: =Parent.Width - 20
      X: =10
      Y: =10
```

**Menu Icon:**
```yaml
- [ScreenPrefix]_MenuIcon:
    Control: Classic/Icon@2.5.0
    Properties:
      Color: =RGBA(255, 255, 255, 1)
      Height: =50
      Icon: =Icon.Hamburger
      OnSelect: =Set(_showMenu, !_showMenu)
      PaddingBottom: =10
      PaddingLeft: =10
      PaddingRight: =10
      PaddingTop: =10
      Width: =50
```

**Title:**
```yaml
- [ScreenPrefix]_Title:
    Control: Text@0.0.51
    Properties:
      Font: =Font.Lato
      FontColor: =Color.White
      Height: =50
      PaddingLeft: =20
      Size: =25
      Text: ="[Screen Title]"
      VerticalAlign: =VerticalAlign.Middle
      Weight: ='TextCanvas.Weight'.Medium
      Width: =400  # Or: Parent.Width - MenuIcon.Width - 40
```

### 3. Navigation Menu Component

**Pattern A (scnDashboard, scnPositionLibrary):**
```yaml
- [ScreenPrefix]_NavigationMenu:
    Control: CanvasComponent
    ComponentName: NavigationMenu
    Properties:
      Fill: =RGBA(255, 255, 255, 0.5)
      Height: =Parent.Height - 70
      Visible: =If(_showMenu, true, false)
      Width: =260
      Y: =70
      navItems: =Navigation
      navSelected: =currentScreen
```

**Pattern B (scnRole - Responsive):**
```yaml
- RoleNavigationMenu:
    Control: CanvasComponent
    ComponentName: NavigationMenu
    Properties:
      Fill: =RGBA(255, 255, 255, 0.5)
      Height: =Parent.Height - 70
      Visible: =If(App.ActiveScreen.Size>=ScreenSize.ExtraLarge||_showMenu,true,false)
      Width: =260
      Y: =70
      navItems: =Navigation
      navSelected: =currentScreen
```

### 4. OnVisible Initialization

**Required Variables:**
```powerfx
Set(_showMenu, false);  # Initialize menu as closed
UpdateContext({currentScreen: "[ScreenName]"});  # Set current screen name
```

### 5. Content Container Positioning

**When header exists:**
```yaml
Height: =Parent.Height - 85  # Parent.Height - (Header.Height + Header.Y + spacing)
Y: =75  # Header.Y + Header.Height + spacing
```

---

## Current Implementation Issues (scnDailyControlCenter)

### ❌ Missing Components

1. **No Hamburger Menu Icon**
   - Header exists but lacks menu toggle
   - Users cannot access navigation

2. **No NavigationMenu Component**
   - Cannot navigate to other screens
   - Breaks app-wide navigation pattern

3. **Missing OnVisible Initialization**
   - No `_showMenu` variable
   - No `currentScreen` context

### ⚠️ Header Differences

**Current Header (Custom):**
```yaml
- HeaderContainer:
    Height: =170  # Taller than standard 55px
    Contains:
      - HeaderTitle
      - DateNavigationRow (custom date picker UI)
```

**Standard Header:**
```yaml
- Header:
    Height: =55px
    Contains:
      - MenuIcon (Hamburger)
      - Title (Text)
```

---

## Recommended Fixes

### Option 1: Adopt Standard Pattern (Recommended)

**Benefits:**
- ✅ Consistent with all other screens
- ✅ Users get familiar navigation
- ✅ Easy maintenance

**Changes Required:**
1. Replace current `HeaderContainer` with standard header (55px)
2. Move date picker to content area (separate section)
3. Add hamburger menu icon
4. Add NavigationMenu component
5. Update OnVisible with required variables

**New Structure:**
```
Screen
├── MainContainer
│   ├── Header (55px, Hamburger + Title)
│   ├── Content (starts at Y=75)
│   │   ├── DatePickerSection (custom date navigation)
│   │   ├── StatusCards
│   │   ├── QuickActions
│   │   └── ActivityGallery
│   └── NavigationMenu (sidebar)
```

### Option 2: Hybrid Approach

**Benefits:**
- ✅ Keep custom date picker in header
- ✅ Add navigation capability

**Changes Required:**
1. Add hamburger menu icon to current header (left side)
2. Add NavigationMenu component
3. Update header to 65-70px height (accommodate menu icon)
4. Adjust content Y position

---

## Code Templates

### Standard Header Implementation

```yaml
# Add to OnVisible (line 6-7):
OnVisible: |-
  =Set(_showMenu, false);
  UpdateContext({currentScreen: "Daily Control Center"});

  // [Existing initialization code...]
```

```yaml
# Replace HeaderContainer with:
- DCC_Header:
    Control: GroupContainer@1.3.0
    Variant: AutoLayout
    Properties:
      DropShadow: =DropShadow.Regular
      Fill: =RGBA(0, 101, 161, 1)
      Height: =55
      LayoutAlignItems: =LayoutAlignItems.Center
      LayoutDirection: =LayoutDirection.Horizontal
      LayoutGap: =10
      PaddingLeft: =15
      RadiusBottomLeft: =8
      RadiusBottomRight: =8
      RadiusTopLeft: =8
      RadiusTopRight: =8
      Width: =Parent.Width - 20
      X: =10
      Y: =10
    Children:
      - DCC_MenuIcon:
          Control: Classic/Icon@2.5.0
          Properties:
            Color: =RGBA(255, 255, 255, 1)
            Height: =50
            Icon: =Icon.Hamburger
            OnSelect: =Set(_showMenu, !_showMenu)
            PaddingBottom: =10
            PaddingLeft: =10
            PaddingRight: =10
            PaddingTop: =10
            Width: =50
      - DCC_Title:
          Control: Text@0.0.51
          Properties:
            Font: =Font.Lato
            FontColor: =Color.White
            Height: =50
            PaddingLeft: =20
            Size: =25
            Text: ="Daily Control Center"
            VerticalAlign: =VerticalAlign.Middle
            Weight: ='TextCanvas.Weight'.Medium
            Width: =400
```

```yaml
# Move date picker to content area:
- DatePickerSection:
    Control: GroupContainer@1.3.0
    Variant: AutoLayout
    Properties:
      # [Same properties as current DateNavigationRow]
      Y: =10  # Top of content area
```

```yaml
# Add navigation menu (last child of MainContainer):
- DCC_NavigationMenu:
    Control: CanvasComponent
    ComponentName: NavigationMenu
    Properties:
      Fill: =RGBA(255, 255, 255, 0.5)
      Height: =Parent.Height - 70
      Visible: =If(_showMenu, true, false)
      Width: =260
      Y: =70
      navItems: =Navigation
      navSelected: =currentScreen
```

---

## Design Considerations

### Pros of Standard Pattern
- **Consistency**: All screens look the same
- **Familiarity**: Users know where to find navigation
- **Maintainability**: Standard pattern = less code
- **Accessibility**: Hamburger menu is recognizable

### Cons of Custom Header
- **Inconsistency**: Only this screen looks different
- **Confusion**: Users expect hamburger menu
- **Maintenance**: Custom code = more bugs
- **Navigation**: No way to navigate to other screens

---

## Recommendation

**Adopt Option 1 (Standard Pattern)** for the following reasons:

1. **User Experience**: Consistent navigation across all screens
2. **Maintainability**: One pattern to maintain, not two
3. **Flexibility**: Date picker can be just as effective in content area
4. **Standards Compliance**: Follows Nestlé app conventions

The date picker can be a prominent card at the top of the content area, providing the same functionality while maintaining navigation consistency.

---

## Next Steps

1. ✅ Review this analysis with stakeholders
2. ⬜ Choose Option 1 or Option 2
3. ⬜ Implement header changes
4. ⬜ Add NavigationMenu component
5. ⬜ Test navigation flow
6. ⬜ Update documentation
