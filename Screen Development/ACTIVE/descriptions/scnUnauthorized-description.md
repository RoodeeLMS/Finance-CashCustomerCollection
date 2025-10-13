# Screen Description: scnUnauthorized

**Created**: 2025-01-10
**Status**: Ready for Implementation
**Data Source**: None (static screen)
**Template to Use**: Custom (minimal screen, no header/navigation)
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
Displays access denied message to users who are not in the UserRoles table or have invalid roles.

**Who uses it**:
- Unauthorized users - Anyone not granted access to the application

**User Goals**:
- Understand why they cannot access the app
- Know who to contact for access
- Exit gracefully

---

## 2. Design Mockup

**Visual Layout**:

```
┌──────────────────────────────────────────────────────┐
│                                                       │
│                                                       │
│                        ⚠️                             │
│                  Size 100, Center                     │
│                                                       │
│                  Access Denied                        │
│                 Size 32, Lato Bold                    │
│                                                       │
│    You do not have permission to access this app.    │
│        Please contact your administrator for          │
│                      access.                          │
│                   Size 16, Gray                       │
│                                                       │
│                Contact: ar.admin@nestle.com           │
│                   Size 14, Blue Link                  │
│                                                       │
│                     [Exit App]                        │
│                  Button, Gray color                   │
│                                                       │
│                                                       │
└──────────────────────────────────────────────────────┘
```

**Component Breakdown**:

| Area | Component | Type | Details |
|------|-----------|------|---------|
| Background | Screen Fill | Screen | RGBA(243, 242, 241, 1) |
| Icon | Unauth_Icon | Classic/Icon@2.5.0 | "BlockContact", Size 100, Red |
| Title | Unauth_Title | Text@0.0.51 | "Access Denied", 32px, Bold |
| Message | Unauth_Message | Text@0.0.51 | Multi-line message, 16px, Gray |
| Contact | Unauth_Contact | Text@0.0.51 | "Contact: ar.admin@nestle.com", Blue |
| Exit | Unauth_ExitBtn | Button@0.0.45 | "Exit App", Gray |

**Template Base**: Custom (no template)

---

## 3. Database Schema

**Data Source**: None

---

## 4. Data & Collections

**Collections**: None

**Variables**:
- Uses `gblUserRole` (set by loadingScreen)
- Uses `gblCurrentUser` (for display)

---

## 5. Screen Behavior

### OnVisible Logic

```powerfx
=// No collections to load
// Just display static content
UpdateContext({currentScreen: "Unauthorized"})
```

### User Interactions

**Exit Button**:
```powerfx
OnSelect: =Exit()
```

---

## 6. Navigation

### From

- loadingScreen (if gblUserRole = "Unauthorized")

### To

- None (exit app)

---

## 7. Styling & Branding

### Colors

- **Icon**: `RGBA(168, 0, 0, 1)` - Red (error)
- **Title**: `RGBA(0, 0, 0, 1)` - Black
- **Message**: `RGBA(100, 100, 100, 1)` - Gray
- **Contact**: `RGBA(0, 101, 161, 1)` - Nestlé Blue
- **Button**: `RGBA(128, 128, 128, 1)` - Gray

### Fonts

- **Title**: Lato Bold, Size 32
- **Message**: Lato Regular, Size 16
- **Contact**: Lato Semibold, Size 14

---

## 8. Control Specifications

### Control: Unauth_Icon

```yaml
Control: Classic/Icon@2.5.0
Properties:
  Icon: ="BlockContact"
  Color: =RGBA(168, 0, 0, 1)  # Red
  Width: =100
  Height: =100
  X: =(Parent.Width - Self.Width) / 2
  Y: =150
```

### Control: Unauth_Title

```yaml
Control: Text@0.0.51
Properties:
  Text: ="Access Denied"
  Font: =Font.Lato
  FontColor: =RGBA(0, 0, 0, 1)
  Size: =32
  Weight: ='TextCanvas.Weight'.Bold
  Align: ='TextCanvas.Align'.Center
  Width: =Parent.Width - 40
  X: =20
  Y: =270
```

### Control: Unauth_Message

```yaml
Control: Text@0.0.51
Properties:
  Text: |-
    ="You do not have permission to access this application." & Char(10) &
    "Please contact your administrator for access."
  Font: =Font.Lato
  FontColor: =RGBA(100, 100, 100, 1)
  Size: =16
  Align: ='TextCanvas.Align'.Center
  AutoHeight: =true
  Width: =Parent.Width - 80
  X: =40
  Y: =330
```

### Control: Unauth_Contact

```yaml
Control: Text@0.0.51
Properties:
  Text: |-
    ="Contact: ar.admin@nestle.com"
  Font: =Font.Lato
  FontColor: =RGBA(0, 101, 161, 1)  # Blue
  Size: =14
  Weight: ='TextCanvas.Weight'.Semibold
  Align: ='TextCanvas.Align'.Center
  Width: =Parent.Width - 40
  X: =20
  Y: =Unauth_Message.Y + Unauth_Message.Height + 20
```

### Control: Unauth_ExitBtn

```yaml
Control: Button@0.0.45
Properties:
  Text: ="Exit App"
  BasePaletteColor: =RGBA(128, 128, 128, 1)  # Gray
  Height: =40
  Width: =150
  X: =(Parent.Width - Self.Width) / 2
  Y: =Unauth_Contact.Y + Unauth_Contact.Height + 30
  OnSelect: =Exit()
```

---

## 9. Success Criteria

- ✅ Warning icon displays centered
- ✅ Access denied message is clear
- ✅ Contact email is visible
- ✅ Exit button works
- ✅ No navigation menu (dead-end screen)

---

**READY FOR SUBAGENT CREATION** ✅
