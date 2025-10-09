# Fix: runAfter Dependency Errors

## ⚠️ Error

```
The inputs of template action 'Compose_Email_Body' at line '1' and column '7779' cannot reference action 'Get_AR_rep'.
Action 'Get_AR_rep' must either be in 'runAfter' path
```

**Cause**: "Compose_Email_Body" uses `outputs('Get_AR_rep')` but runs BEFORE "Get_AR_rep" executes.

---

## 🔧 Fix: Reorder Actions

### Current Order (Wrong):
1. Build_Transaction_Rows → Succeeded
2. **Compose_Email_Body** → uses Get_AR_rep ❌
3. Get_QR_Code → Succeeded
4. Get_AR_rep → Succeeded (too late!)

### Correct Order:
1. Build_Transaction_Rows → Succeeded
2. Get_QR_Code → Succeeded
3. **Get_AR_rep** → Succeeded
4. **Compose_Email_Body** → NOW can use Get_AR_rep ✅

---

## 📝 JSON Fix

Find these three actions in the Email Engine flow JSON and update their `runAfter`:

### 1. Update "Compose_Email_Body"

**Change from:**
```json
"Compose_Email_Body": {
  "type": "Compose",
  "inputs": "...",
  "runAfter": {
    "Build_Transaction_Rows": ["Succeeded"]
  }
}
```

**To:**
```json
"Compose_Email_Body": {
  "type": "Compose",
  "inputs": "...",
  "runAfter": {
    "Get_AR_rep": ["Succeeded", "Failed"]
  }
}
```

### 2. Update "Get_QR_Code"

**Change from:**
```json
"Get_QR_Code": {
  "type": "OpenApiConnection",
  "inputs": {...},
  "runAfter": {
    "Compose_Email_Body": ["Succeeded"]
  }
}
```

**To:**
```json
"Get_QR_Code": {
  "type": "OpenApiConnection",
  "inputs": {...},
  "runAfter": {
    "Build_Transaction_Rows": ["Succeeded"]
  }
}
```

### 3. Update "Get_AR_rep"

**Change from:**
```json
"Get_AR_rep": {
  "type": "OpenApiConnection",
  "inputs": {...},
  "runAfter": {
    "Get_QR_Code": ["Succeeded", "Failed"]
  }
}
```

**To:**
```json
"Get_AR_rep": {
  "type": "OpenApiConnection",
  "inputs": {...},
  "runAfter": {
    "Get_QR_Code": ["Succeeded", "Failed"]
  }
}
```
(This one stays the same - it already runs after Get_QR_Code)

---

## 🎯 Summary of Changes

**Action** | **Old runAfter** | **New runAfter**
-----------|------------------|------------------
Get_QR_Code | Compose_Email_Body | Build_Transaction_Rows
Get_AR_rep | Get_QR_Code | Get_QR_Code (no change)
Compose_Email_Body | Build_Transaction_Rows | Get_AR_rep

---

## ✅ Complete Fixed Actions

Copy these three action definitions to replace in your flow:

### Get_QR_Code (Fixed):
```json
"Get_QR_Code": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "dataset": "https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions",
      "id": "/Shared Documents/Cash Customer Collection/03-QR-Codes/@{outputs('Get_Customer')?['cr7bb_customercode']}.jpg",
      "inferContentType": true
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline",
      "operationId": "GetFileContent",
      "connectionName": "shared_sharepointonline"
    }
  },
  "runAfter": {
    "Build_Transaction_Rows": ["Succeeded"]
  }
}
```

### Get_AR_rep (No change needed):
```json
"Get_AR_rep": {
  "type": "OpenApiConnection",
  "inputs": {
    "parameters": {
      "id": "@outputs('Get_Customer')?['cr7bb_arbackupemail1']"
    },
    "host": {
      "apiId": "/providers/Microsoft.PowerApps/apis/shared_office365users",
      "operationId": "UserProfile_V2",
      "connectionName": "shared_office365users"
    }
  },
  "runAfter": {
    "Get_QR_Code": ["Succeeded", "Failed"]
  }
}
```

### Compose_Email_Body (Fixed):
```json
"Compose_Email_Body": {
  "type": "Compose",
  "inputs": "<html><body style=\"font-family: Arial, sans-serif;\"><p>เรียน คุณ @{outputs('Get_Customer')?['cr7bb_customername']}</p><p>ตามที่บริษัทได้ตรวจสอบยอดค้างชำระพบว่า ณ วันที่ @{formatDateTime(utcNow(), 'dd/MM/yyyy')} ท่านมียอดค้างชำระดังนี้</p><table border=\"1\" cellpadding=\"5\" style=\"border-collapse: collapse;\"><tr style=\"background-color: #0078D4; color: white;\"><th>เลขที่เอกสาร</th><th>วันที่เอกสาร</th><th>วันครบกำหนด</th><th>จำนวนวันค้าง</th><th>จำนวนเงิน (THB)</th></tr>@{join(outputs('Build_Transaction_Rows'), '')}</table><p><strong>รวมยอดค้างชำระทั้งสิ้น: @{formatNumber(outputs('Compose_Net_Amount'), 'N2')} บาท</strong></p><p>กรุณาชำระเงินผ่าน PromptPay QR Code ที่แนบมาพร้อมนี้</p>@{if(equals(outputs('Compose_Template_Selection'), 'Template_B'), '<p style=\"color: #D83B01; font-weight: bold;\">⚠️ หมายเหตุ: หากไม่ชำระภายในวันที่ @{formatDateTime(addDays(utcNow(), 1), 'dd/MM/yyyy')} ท่านจะสูญเสียสิทธิ์ส่วนลด Cash Discount</p>', '')}@{if(equals(outputs('Compose_Template_Selection'), 'Template_C'), '<p style=\"color: #A4262C; font-weight: bold;\">⚠️ การชำระล่าช้า: ท่านจะถูกเรียกเก็บค่า MI (ดอกเบี้ยเงินเฟ้อจากการชำระล่าช้า) กรุณาติดต่อ AR ทันที</p>', '')}<p>ขอบคุณค่ะ</p><p>@{coalesce(outputs('Get_AR_rep')?['displayName'], 'AR Team')}<br/>Accounts Receivable<br/>Email: @{coalesce(outputs('Get_AR_rep')?['mail'], outputs('Get_Customer')?['cr7bb_arbackupemail1'])}</p></body></html>",
  "runAfter": {
    "Get_AR_rep": ["Succeeded", "Failed"]
  }
}
```

---

## 🔧 How to Apply in Code View

1. **Open** Email Engine flow
2. Click **⋯** → **Peek code**
3. **Find** the "Compose_Email_Body" action
4. **Update** its `runAfter` section from:
```json
"runAfter": {
  "Build_Transaction_Rows": ["Succeeded"]
}
```
to:
```json
"runAfter": {
  "Get_AR_rep": ["Succeeded", "Failed"]
}
```

5. **Find** the "Get_QR_Code" action
6. **Update** its `runAfter` from:
```json
"runAfter": {
  "Compose_Email_Body": ["Succeeded"]
}
```
to:
```json
"runAfter": {
  "Build_Transaction_Rows": ["Succeeded"]
}
```

7. **Save**

---

This fixes the dependency chain so actions run in the correct order!
