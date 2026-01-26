# Flow Modification: Email Engine Updates

**Date**: January 26, 2026
**Flow Name**: `[THFinance] Daily Collections Email Engine`
**Priority**: High
**Status**: Pending Implementation

---

## Overview

Two modifications requested for the email generation flow based on user feedback.

---

## Modification 1: Email Subject Date Range

### Current Implementation (Line 492)

```
Compose_Email_Subject:
"@{outputs('Get_Customer')?['body/cr7bb_customercode']} @{outputs('Get_Customer')?['body/cr7bb_customername']} รายละเอียดบิลวันที่ @{formatDateTime(utcNow(), 'dd.MM.yyyy')}"
```

**Current Output**: `12345678 CustomerName รายละเอียดบิลวันที่ 26.01.2026`

### Required Implementation

```
Compose_Email_Subject:
"@{outputs('Get_Customer')?['body/cr7bb_customercode']} @{outputs('Get_Customer')?['body/cr7bb_customername']} รายละเอียดบิลวันที่ @{formatDateTime(min(body('Select_Document_Date')), 'dd.MM.yyyy')}-@{formatDateTime(max(body('Select_Document_Date')), 'dd.MM.yyyy')}"
```

**Expected Output**: `12345678 CustomerName รายละเอียดบิลวันที่ 15.01.2026-26.01.2026`

### Implementation Steps

1. Open flow in Power Automate
2. Find `Compose_Email_Subject` action
3. Replace the expression with the date range version
4. Test with sample customer data

### Edge Cases

| Scenario | Handling |
|----------|----------|
| Single DN document | Same date appears twice: `26.01.2026-26.01.2026` |
| No DN documents | Flow should not reach this point (Check_Should_Send guards) |

---

## Modification 2: Email Table Column Alignment

### User Request

> "ทุกคอลัมน์ ชิดซ้าย แต่ขอตัวเลข amount ชิดขวาได้ไหมคะ"
> (All columns left-aligned, but amount numbers right-aligned)

### Current Implementation (Line 653-697)

```json
"Create_HTML_table": {
  "type": "Table",
  "inputs": {
    "from": "@outputs('Combine_DN_and_CN')",
    "format": "HTML",
    "columns": [
      {"header": "Account", "value": "..."},
      {"header": "Name", "value": "..."},
      {"header": "Document Number", "value": "..."},
      {"header": "Assignment", "value": "..."},
      {"header": "Document Type", "value": "..."},
      {"header": "Document Date", "value": "..."},
      {"header": "Amount in Local Currency", "value": "@formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')"}
    ]
  }
}
```

The table is styled in `Compose_Email_Body` (line 700):
```
@{replace(replace(replace(body('Create_HTML_table'), '<table>', '<table border=\"1\" cellpadding=\"5\" style=\"border-collapse: collapse;\">'), '<thead>', '<thead style=\"background-color: #D83B01; color: white;\">'), '</table>', ...)}
```

### Required Change

Add CSS styling to right-align the Amount column. Since Power Automate's Create HTML Table doesn't support per-column styling, we need to add a post-processing step.

### Option A: Add CSS Class (Recommended)

Add a `<style>` block and replace Amount column cells:

```
Compose_Email_Body (updated):
"<html>
<head>
<style>
  table { border-collapse: collapse; }
  th, td { text-align: left; padding: 5px; border: 1px solid #ddd; }
  td:last-child, th:last-child { text-align: right; }
</style>
</head>
<body>..."
```

### Option B: String Replace Approach

Add another replace() to target the Amount column:

```
@{replace(
    body('Create_HTML_table'),
    '<td>@{formatNumber(',
    '<td style=\"text-align:right;\">@{formatNumber('
)}
```

**Note**: This is fragile and may not work reliably.

### Option C: Custom HTML Table (Most Control)

Replace `Create_HTML_table` with a custom HTML compose action:

```
New Action: Compose_Custom_Table

<table border="1" cellpadding="5" style="border-collapse: collapse;">
  <thead style="background-color: #D83B01; color: white;">
    <tr>
      <th style="text-align:left;">Account</th>
      <th style="text-align:left;">Name</th>
      <th style="text-align:left;">Document Number</th>
      <th style="text-align:left;">Assignment</th>
      <th style="text-align:left;">Document Type</th>
      <th style="text-align:left;">Document Date</th>
      <th style="text-align:right;">Amount in Local Currency</th>
    </tr>
  </thead>
  <tbody>
    @{join(
      xpath(
        xml(concat('<root>', json(outputs('Combine_DN_and_CN')), '</root>')),
        '...'
      ),
      ''
    )}
  </tbody>
</table>
```

### Recommended Approach

**Use Option A** - Add CSS in `<style>` block targeting last column:

```css
td:last-child, th:last-child { text-align: right; }
```

This is clean, maintainable, and works with the existing Create HTML Table action.

---

## Implementation Checklist

- [ ] **Subject Date Range**
  - [ ] Modify `Compose_Email_Subject` expression
  - [ ] Test with customer having multiple DN documents
  - [ ] Test with customer having single DN document
  - [ ] Verify date format matches requirement (dd.MM.yyyy)

- [ ] **Table Alignment**
  - [ ] Add `<style>` block to email body
  - [ ] Set all columns left-aligned by default
  - [ ] Set Amount column (last column) right-aligned
  - [ ] Test email rendering in Outlook
  - [ ] Test email rendering in mobile

---

## Testing

### Test Case 1: Subject Date Range

| Customer | DN Dates | Expected Subject |
|----------|----------|------------------|
| 12345678 | 15.01, 20.01, 26.01 | `12345678 Name รายละเอียดบิลวันที่ 15.01.2026-26.01.2026` |
| 23456789 | 26.01 only | `23456789 Name รายละเอียดบิลวันที่ 26.01.2026-26.01.2026` |

### Test Case 2: Table Alignment

| Column | Expected Alignment |
|--------|-------------------|
| Account | Left |
| Name | Left |
| Document Number | Left |
| Assignment | Left |
| Document Type | Left |
| Document Date | Left |
| Amount in Local Currency | **Right** |

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-26 | Initial modification request documented |
