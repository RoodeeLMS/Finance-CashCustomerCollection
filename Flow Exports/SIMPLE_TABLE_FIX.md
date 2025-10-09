# Simplest Fix: Build Transaction Rows Without JSON Issues

## The Problem

Power Automate's designer sometimes has issues with complex HTML strings in Select actions when imported from JSON.

## ✅ Simplest Solution: Use Compose Instead of Select

Instead of using a **Select** action to build HTML rows, use multiple **Compose** actions. This avoids JSON parsing issues entirely.

---

## 🔧 How to Fix

### Step 1: Delete "Build_Transaction_Rows" Action

1. Open Email Engine flow
2. Find the **Build_Transaction_Rows** (Select) action
3. Click **⋯** → **Delete**

### Step 2: Add a "Create HTML table" Action Instead

1. Click **+ New step** (where Build_Transaction_Rows was)
2. Search for: **Create HTML table**
3. Select **Data Operations - Create HTML table**
4. Configure:
   - **From**: Select `body('Filter_DN_List')` from Dynamic content
   - **Columns**: Automatic

This creates a basic HTML table automatically.

### Step 3: Update "Compose_Email_Body" to Use the Table

Find the line:
```
@{join(outputs('Build_Transaction_Rows'), '')}
```

Replace with:
```
@{body('Create_HTML_table')}
```

---

## 🎨 Alternative: Manual HTML Building (No Select)

If you want custom HTML formatting, use this approach:

### Replace "Build_Transaction_Rows" with Multiple Actions:

#### Action 1: Initialize HTML Variable
```
Action: Initialize variable
Name: varTableRows
Type: String
Value: (leave empty)
```

#### Action 2: Apply to Each (Build Rows)
```
Action: Apply to each
Select: body('Filter_DN_List')

Inside loop:
  Action: Append to string variable
  Name: varTableRows
  Value: <tr><td>@{item()?['cr7bb_documentnumber']}</td><td>@{formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')}</td><td>@{formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy')}</td><td>@{item()?['cr7bb_daycount']}</td><td>@{formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')}</td></tr>
```

#### Action 3: Use in Email
In "Compose_Email_Body", replace:
```
@{join(outputs('Build_Transaction_Rows'), '')}
```

With:
```
@{variables('varTableRows')}
```

---

## 🚀 Quickest Fix: Just Type It In Designer

**Don't edit JSON. Do this:**

1. **Open** Email Engine flow in Designer
2. **Find** "Build_Transaction_Rows" action
3. **Click** on the action to expand it
4. **Click** in the **Map** field (the big text box)
5. **Press Ctrl+A** to select all
6. **Delete** everything
7. **Type manually** (or paste this):

```
<tr><td>
```

8. **Click** "Add dynamic content"
9. **Select** `cr7bb_documentnumber` from Filter_DN_List
10. **Type**: `</td><td>`
11. **Click** "Add dynamic content"
12. **Type** in Expression tab:
```
formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')
```
13. Click OK
14. **Type**: `</td><td>`
15. **Repeat** for remaining fields

This way, Power Automate builds the expression correctly without JSON parsing issues.

---

## 📋 Even Simpler: Use Plain Text Instead

If HTML table is causing too many issues, create a plain text email:

**Replace the entire email body with:**

```
เรียน คุณ @{outputs('Get_Customer')?['cr7bb_customername']}

ตามที่บริษัทได้ตรวจสอบยอดค้างชำระพบว่า ณ วันที่ @{formatDateTime(utcNow(), 'dd/MM/yyyy')} ท่านมียอดค้างชำระดังนี้

เลขที่เอกสาร | วันที่เอกสาร | วันครบกำหนด | จำนวนวันค้าง | จำนวนเงิน (THB)
----------------|--------------|--------------|---------------|------------------
@{join(
  map(
    body('Filter_DN_List'),
    concat(
      item()?['cr7bb_documentnumber'], ' | ',
      formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy'), ' | ',
      formatDateTime(item()?['cr7bb_netduedate'], 'dd/MM/yyyy'), ' | ',
      item()?['cr7bb_daycount'], ' | ',
      formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')
    )
  ),
  '\n'
)}

รวมยอดค้างชำระทั้งสิ้น: @{formatNumber(outputs('Compose_Net_Amount'), 'N2')} บาท

กรุณาชำระเงินผ่าน PromptPay QR Code ที่แนบมาพร้อมนี้

ขอบคุณค่ะ
```

This creates a text table without HTML, avoiding all JSON escaping issues.

---

## ❓ What Specific Error Are You Seeing?

Can you share:
1. The exact error message text?
2. Which action is showing the error?
3. Is it in the JSON editor or when saving the flow?

This will help me give you the exact fix!

---

**Try the "Create HTML table" action first** - it's the simplest and most reliable solution! ✅
