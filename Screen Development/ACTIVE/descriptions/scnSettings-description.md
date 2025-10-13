# Screen Description: scnSettings

**Created**: 2025-01-10
**Status**: Ready for Implementation
**Data Source**: Dataverse
**Template to Use**: template-basic-screen.yaml (customize with tabs)
**Language**: English only

---

## 1. Purpose & Overview

**What this screen does**:
Configure system settings including email templates, thresholds, QR code mapping, and automation schedules.

**Who uses it**:
- **Admin** - Full configuration access

**User Goals**:
- Edit email templates (A/B/C/D)
- Configure day count thresholds
- Manage QR code file mappings
- View/edit automation schedules
- Test email delivery

---

## 2. Design Mockup

**Visual Layout**:

```
┌─────────────────────────────────────────────────────────────────┐
│ [HEADER - H:55]                                                 │
│ ◰  System Settings                         [User Profile] 🚪    │
├─────────────────────────────────────────────────────────────────┤
│ [CONTENT - ManualLayout]                                        │
│                                                                  │
│ ┌────────── TAB NAVIGATION (H:50) ────────────┐                │
│ │ [Templates] [Thresholds] [QR Codes] [System]│                │
│ └──────────────────────────────────────────────┘                │
│                                                                  │
│ [TAB CONTENT - Conditional by selected tab]                    │
│                                                                  │
│ ┌─────────── TEMPLATES TAB ────────────────┐                   │
│ │ Email Template A (Day 1-2):               │                   │
│ │ Subject: [Payment Reminder - Invoice...]  │                   │
│ │ Body: [HTML editor]                       │                   │
│ │ [Save] [Preview] [Test Email]             │                   │
│ │                                            │                   │
│ │ Email Template B (Day 3):                 │                   │
│ │ Subject: [Urgent: Cash Discount...]       │                   │
│ │ Body: [HTML editor]                       │                   │
│ │ [Save] [Preview] [Test Email]             │                   │
│ └────────────────────────────────────────────┘                   │
│                                                                  │
│ [NavigationMenu - W:260]                                        │
└─────────────────────────────────────────────────────────────────┘
```

**Template Base**: template-basic-screen.yaml

---

## 3. Database Schema

**Primary Entity**: `[THFinanceCashCollection]Settings`

**Fields**:
| Field | Type | Notes |
|-------|------|-------|
| Setting Name | Text | Key (unique) |
| Setting Value | Text | JSON or plain text |
| Setting Type | Choice | Template/Threshold/Schedule/QRCode |
| Modified By | Lookup | Last modifier |
| Modified Date | DateTime | Last update |

**Examples**:
```powerfx
// Email Template A
{name: "EmailTemplate_A_Subject", value: "Payment Reminder...", type: "Template"}
{name: "EmailTemplate_A_Body", value: "<html>...</html>", type: "Template"}

// Thresholds
{name: "DayCount_TemplateB", value: "3", type: "Threshold"}
{name: "DayCount_TemplateC", value: "4", type: "Threshold"}
{name: "LateFeeRate", value: "1.5", type: "Threshold"}
```

---

## 4. Key Features

### Tab 1: Email Templates
- Template A (Day 1-2)
- Template B (Day 3 - warning)
- Template C (Day 4+ - late fees)
- Template D (MI documents)
- Rich text editor for body
- Subject line input
- Test email button

### Tab 2: Thresholds
- Day count for Template B (default: 3)
- Day count for Template C (default: 4)
- Late fee percentage (default: 1.5%)
- Minimum amount threshold

### Tab 3: QR Codes
- Customer code → QR filename mapping
- Upload/download QR codes
- Verify QR code exists

### Tab 4: System
- Automation schedule times
- Email sender address
- Enable/disable automation
- View system logs

---

## 5. Variables

**Screen Variables**:
- `_selectedTab` (Text): "Templates", "Thresholds", "QRCodes", "System"
- `_isDirty` (Boolean): Unsaved changes flag

---

## 6. Success Criteria

- ✅ Tab navigation works
- ✅ Settings load correctly
- ✅ Save updates Dataverse
- ✅ Test email sends successfully
- ✅ Admin-only access enforced

---

**READY FOR SUBAGENT CREATION** ✅
