# Power Apps Control Version Compatibility

**Issue**: Control version mismatch between YAML and Power Apps Studio
**Date**: 2025-10-09
**Status**: Documented - use compatible versions or property names

---

## Error Analysis

Your Power Apps Studio has **older control versions** than what's in the YAML file:

| Control in YAML | Available in Studio | Issue |
|----------------|---------------------|-------|
| Button@0.0.45 | *Unknown* | `Fill` property not recognized |
| Icon@2.5.0 | Icon@0.0.7 | `Color` property not recognized |
| DatePicker@0.0.51 | DatePicker@0.0.46 | Newer version warning |
| Gallery@2.15.0 | *Unknown* | `galleryVertical` variant not recognized |

---

## Root Cause

**Modern Controls vs Classic Controls:**

The YAML uses **Modern Controls** (new versioning like @0.0.45, @0.0.51) but your Power Apps Studio may only have **Classic Controls** or older modern control versions.

**Control Property Differences:**

| Modern Control | Property | Classic Control | Property |
|---------------|----------|----------------|----------|
| Button@0.0.45 | `Fill` | Button (classic) | `Fill` |
| Icon@2.5.0 | `Color` | Icon (classic) | `Color` |

The errors suggest your environment is in a **transitional state** where:
- Modern controls are recognized but with older APIs
- Properties that should exist are not available

---

## Solution Options

### Option 1: Use Classic Controls (Recommended)

Replace modern controls with classic equivalents that are universally supported:

```yaml
# INSTEAD OF:
- MyButton:
    Control: Button@0.0.45
    Properties:
      Fill: =RGBA(0, 101, 161, 1)

# USE:
- MyButton:
    Control: Button
    Properties:
      Fill: =RGBA(0, 101, 161, 1)
```

### Option 2: Update Power Apps Studio

1. Check for Power Apps Studio updates
2. Go to **Settings** → **About** → Check version
3. Update to latest version if available
4. Restart Power Apps Studio

### Option 3: Enable Modern Controls

1. Open Power Apps Studio
2. Go to **Settings** → **Upcoming features** → **Experimental**
3. Enable **"Modern controls"** or **"Enhanced controls"**
4. Restart Power Apps Studio
5. Try paste again

---

## Classic Control Conversion Guide

If using Option 1, here's how to convert the screen to classic controls:

### Button Changes

**Modern (Not Working):**
```yaml
Control: Button@0.0.45
Properties:
  Fill: =RGBA(0, 101, 161, 1)
  FontColor: =RGBA(255, 255, 255, 1)
  Text: ="Click Me"
```

**Classic (Universal):**
```yaml
Control: Button
Properties:
  Fill: =RGBA(0, 101, 161, 1)
  Color: =RGBA(255, 255, 255, 1)  # FontColor → Color
  Text: ="Click Me"
```

**Key Difference**: `FontColor` becomes `Color` in classic Button

### Icon Changes

**Modern (Not Working):**
```yaml
Control: Icon@2.5.0
Properties:
  Icon: =Icon.CheckBadge
  Color: =RGBA(16, 124, 16, 1)
```

**Classic (Universal):**
```yaml
Control: Icon
Properties:
  Icon: =Icon.CheckBadge
  Color: =RGBA(16, 124, 16, 1)  # Same property name
```

**Key Difference**: Property name is the same, just use classic control version

### Text Changes

**Modern (Working):**
```yaml
Control: Text@0.0.51
Properties:
  Text: ="Label Text"
  FontColor: =RGBA(50, 49, 48, 1)
```

**Classic (Universal):**
```yaml
Control: Label
Properties:
  Text: ="Label Text"
  Color: =RGBA(50, 49, 48, 1)  # FontColor → Color
```

**Key Difference**: Control name changes from `Text` to `Label`, `FontColor` → `Color`

### Gallery Changes

**Modern (Not Working):**
```yaml
Control: Gallery@2.15.0
Variant: galleryVertical
Properties:
  Items: =colData
```

**Classic (Universal):**
```yaml
Control: Gallery
Properties:
  Items: =colData
  Layout: =Layout.Vertical  # Variant becomes property
```

### DatePicker Changes

**Modern (Partial Support):**
```yaml
Control: DatePicker@0.0.51
Properties:
  SelectedDate: =_selectedDate
```

**Classic (Universal):**
```yaml
Control: DatePicker
Properties:
  SelectedDate: =_selectedDate  # Same property
  DefaultDate: =_selectedDate   # Some versions use DefaultDate
```

### GroupContainer Changes

**Modern (Working):**
```yaml
Control: GroupContainer@1.3.0
Variant: AutoLayout
Properties:
  LayoutDirection: =LayoutDirection.Vertical
```

**Classic Alternative:**
```yaml
Control: Container
Properties:
  # Classic containers don't have AutoLayout
  # Use fixed positioning instead
```

---

## Complete Property Mapping

| Modern Property | Classic Property | Notes |
|----------------|------------------|-------|
| `FontColor` (Button) | `Color` | Button text color |
| `FontColor` (Text) | `Color` | Label text color |
| `Fill` (Button) | `Fill` | Same name, but check version |
| `Color` (Icon) | `Color` | Same name |
| `Weight` | `FontWeight` | Font weight (classic uses different enum) |
| `Size` | `Size` | Font size (same) |
| `Align` | `Align` | Text alignment (same) |

---

## Recommended Approach

**For maximum compatibility**, create a **classic controls version** of the screen:

1. Copy `scnDailyControlCenter_v2_withDatePicker.yaml` to `scnDailyControlCenter_classic.yaml`
2. Replace all control versions with classic versions
3. Update property names per mapping above
4. Test in Power Apps Studio
5. Once working, use as reference for manual build

---

## Version Detection

To check your Power Apps Studio version:

1. Open Power Apps Studio
2. Click **Settings** (gear icon)
3. Click **About**
4. Check **Version** number

**Versions with modern controls:**
- 3.24070+ (July 2024 and newer)

**If your version is older:**
- Use classic controls
- OR update Power Apps Studio

---

## Next Steps

**Immediate Fix:**
1. Create classic controls version of YAML
2. Test paste into Power Apps Studio
3. If working, continue with classic controls

**Long-term Fix:**
1. Update Power Apps Studio to latest version
2. Enable modern controls in experimental features
3. Use modern control versions for better UI/UX

---

**Last Updated**: 2025-10-09
**Status**: Pending - need to determine best approach based on your Power Apps environment
