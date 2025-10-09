# Fix: HTML Table Building - Quote Escaping Issue

## ⚠️ Error in "Build_Transaction_Rows" Action

**Current (Broken)**:
```json
{
  "select": "<tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td style=\"text-align: center;\">@{item()?['cr7bb_daycount']}</td><td style=\"text-align: right;\">@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>"
}
```

**Problem**: The `\"` escaped quotes inside the HTML break JSON parsing in Power Automate.

---

## ✅ Solution: Remove Inline Styles

Since the email already has CSS styling in the header, we can remove the inline `style=""` attributes:

**Fixed Version**:
```json
{
  "type": "Select",
  "inputs": {
    "from": "@body('Filter_DN_List')",
    "select": "<tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td>@{item()?['cr7bb_daycount']}</td><td>@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>"
  },
  "runAfter": {
    "Compose_Email_Subject": [
      "Succeeded"
    ]
  }
}
```

**What changed**: Removed `style=\"text-align: center;\"` and `style=\"text-align: right;\"`

---

## 🔧 How to Fix in Designer

### Method 1: Edit the Action (Recommended)

1. **Open Email Engine flow** in Edit mode
2. **Find "Build_Transaction_Rows"** action (it's a Select action)
3. **Click on the action** to expand
4. In the **Map** field, you'll see the HTML template
5. **Replace entire content** with:

```
<tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td>@{item()?['cr7bb_daycount']}</td><td>@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>
```

6. **Save**

---

## 🎨 Alternative: Add Styling to Email Template

If you want to keep the text alignment, add CSS to the email body instead:

### Update "Compose_Email_Body" Action

**Find the table tag** and add style:

**From:**
```html
<table border="1" cellpadding="5" style="border-collapse: collapse;">
```

**To:**
```html
<table border="1" cellpadding="5" style="border-collapse: collapse;">
<style>
  table td:nth-child(4) { text-align: center; }
  table td:nth-child(5) { text-align: right; }
</style>
```

This styles:
- 4th column (Day Count) → center aligned
- 5th column (Amount) → right aligned

---

## 📋 Complete Fixed "Build_Transaction_Rows" Action

**In Designer:**

**Action**: Select
**From**: `body('Filter_DN_List')` (from Dynamic content)
**Map**:
```
<tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td>@{item()?['cr7bb_daycount']}</td><td>@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>
```

**Run after**: Compose_Email_Subject (Succeeded)

---

## 🧪 Test the Fix

After fixing:

1. **Save** the flow
2. **Test** with a customer that has transactions
3. **Check the email** received:
   - Table should render correctly ✅
   - All columns display ✅
   - Formatting looks good ✅

---

## 💡 Why This Happened

Power Automate's JSON parser doesn't handle escaped quotes (`\"`) well inside expression strings. The designer usually handles this automatically, but when importing raw JSON, these escaping issues surface.

**Best practice**: Avoid inline `style=""` attributes in Power Automate expressions. Use:
1. External CSS in email header
2. HTML attributes without quotes (e.g., `align=center` instead of `style="text-align: center"`)
3. Simple HTML without complex styling

---

## ✅ Quick Summary

**Action**: Build_Transaction_Rows (Select action)

**Replace the Map field with** (no inline styles):
```
<tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td>@{item()?['cr7bb_daycount']}</td><td>@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>
```

**Save and test!** ✅
