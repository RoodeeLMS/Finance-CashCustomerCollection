# Step-by-Step: Phase 2 Flow Changes

**Date**: January 16, 2026
**Version**: v1.0.0.6 → v1.0.0.7
**Purpose**: Add Template D (MI document), Update Email Body, QR Inline Display
**Estimated Time**: 45 minutes

---

## Flow Inventory (v1.0.0.6)

### Import Flows

| Flow | Trigger | Data Source | WDN Integration | Status |
|------|---------|-------------|-----------------|--------|
| **DailySAPTransactionImport** | Daily 7:00 AM | Power BI | ✅ **YES** | **ACTIVE** |
| DailySAPTransactionImportEx | Daily 8:00 AM | SharePoint CSV | ❌ No | Backup/Legacy |

> **ACTIVE FLOW**: `THFinanceCashCollectionDailySAPTransactionImport` (Power BI source)
>
> This flow already includes WDN calculation:
> - `Get_Today_WDN` - Lookup today's Working Day Number
> - `Get_DueDate_WDN` - Lookup each transaction's due date WDN
> - `Calculated_ArrearDays = TodayWDN - DueDateWDN`
> - Both `cr7bb_arrearsdays` and `cr7bb_daycount` use calculated working days

### Other Flows

| Flow | Purpose | Status |
|------|---------|--------|
| **DailyCollectionsEmailEngine** | Process transactions, create email logs | ✅ FIFO + AR Alert done |
| **EmailSendingFlow** | Send approved emails | ✅ Working |
| **GenerateWorkingDayCalendar** | Generate WDN for date range | ✅ NEW |
| ManualSAPUpload | Manual file upload | Existing |
| ManualEmailResend | Resend failed emails | Existing |
| CustomerDataSync | Sync customer master | Existing |

---

## Overview

Based on solution export v1.0.0.6 analysis, the following changes are needed:

| Change | Flow | Description |
|--------|------|-------------|
| 1. Template D Logic | Email Engine | Check for MI document before day-based templates |
| 2. Email Body Update | Email Engine | Match Email_Template_Specification.md |
| 3. QR Inline Display | Email Engine | Use base64 encoding for QR in email body |

> **Note**: WDN integration is already complete in the Import flow. The Email Engine uses `cr7bb_daycount` which contains pre-calculated working day arrears.

---

## Current Template Selection Logic

```
Current (Line 464):
@if(lessOrEquals(outputs('Compose_Max_DayCount'), 2), 'Template_A',
   if(equals(outputs('Compose_Max_DayCount'), 3), 'Template_B', 'Template_C'))
```

**Problem**: Missing Template D for MI documents

**Required Logic** (from Email_Template_Specification.md):
```
Priority: Template D > C > B > A

1. Has MI Document? → Template D
2. MaxArrearDays ≥ 4? → Template C
3. MaxArrearDays = 3? → Template B
4. Else → Template A
```

---

## Part 1: Add Template D (MI Document Check)

**Location**: Inside `Check_Should_Send` (Yes branch) → After `Check_AR_Alert` → Before `Compose_Template_Selection`

> **Note**: We filter from `Sort_DN_FIFO` (not `Combine_DN_and_CN`) because MI documents are DN (positive amounts) and `Combine_DN_and_CN` runs AFTER template selection.

---

### Step 1.1: Add Filter_MI_Documents Action

1. Inside `Check_Should_Send` (Yes branch), click **+** after `Check_AR_Alert`
2. Search and select **Filter array** (Data Operations)
3. Configure:
   - **From**: `@outputs('Sort_DN_FIFO')`
   - Click **Edit in advanced mode**
   - **Condition**:
     ```
     @equals(item()?['cr7bb_documenttype'], 'MI')
     ```
4. Rename action to: `Filter_MI_Documents`

---

### Step 1.2: Add Check_Has_MI_Document

1. Click **+** after `Filter_MI_Documents`
2. Search and select **Compose**
3. Configure **Inputs**:
   ```
   @greater(length(body('Filter_MI_Documents')), 0)
   ```
4. Rename action to: `Check_Has_MI_Document`

---

### Step 1.3: Update Compose_Template_Selection

1. Click on `Compose_Template_Selection`
2. Update **Inputs** to:
   ```
   @if(outputs('Check_Has_MI_Document'), 'Template_D', if(greaterOrEquals(outputs('Compose_Max_DayCount'), 4), 'Template_C', if(equals(outputs('Compose_Max_DayCount'), 3), 'Template_B', 'Template_A')))
   ```
3. Update **Run after** to: `Check_Has_MI_Document`

---

### Step 1.4: Update Create_Email_Log Template Mapping

1. Click on `Create_Email_Log`
2. Find `cr7bb_emailtemplate` field
3. Update mapping:
   ```
   @if(equals(outputs('Compose_Template_Selection'), 'Template_A'), 676180000,
      if(equals(outputs('Compose_Template_Selection'), 'Template_B'), 676180001,
         if(equals(outputs('Compose_Template_Selection'), 'Template_C'), 676180002, 676180003)))
   ```

> **Note**: Template D maps to Choice value 676180003

---

## Part 2: Update Email Body to Match Specification

**Reference**: `Documentation/03-Power-Automate/Email_Template_Specification.md`

---

### Step 2.1: Add Compose_Warning_Text

1. Click **+** after `Compose_Template_Selection`
2. Search and select **Compose**
3. Configure **Inputs**:
   ```
   @if(equals(outputs('Compose_Template_Selection'), 'Template_A'), '', if(equals(outputs('Compose_Template_Selection'), 'Template_B'), '<p style="color: #D83B01; font-weight: bold;">หมายเหตุ – ถ้าลูกค้าชำระวันนี้ ก็จะไม่มีการ charge MI ค่ะ</p>', if(equals(outputs('Compose_Template_Selection'), 'Template_C'), '<p style="color: #D83B01; font-weight: bold;">ท่านจะมียอดค่าใช้จ่าย MI ที่ต้องชำระเพิ่มเติม ซึ่งยอดดังกล่าวจะยังไม่ปรากฏในขณะนี้ และจะปรากฏเมื่อระบบดำเนินการอัปเดตข้อมูลเรียบร้อยแล้ว (หากมีข้อสงสัยกรุณาติดต่อ ....)</p>', '<p style="color: #D83B01; font-weight: bold;">ยอด MI ที่ปรากฏ เป็นใบเพิ่มหนี้ที่ท่านชำระบิลล่าช้า หากมีข้อสงสัยกรุณาติดต่อ ....</p>')))
   ```
4. Rename action to: `Compose_Warning_Text`

---

### Step 2.2: Update Create_HTML_table Columns

1. Click on `Create_HTML_table`
2. Update **Columns** to match specification:
   ```json
   [
     {
       "header": "Account",
       "value": "@outputs('Get_Customer')?['body/cr7bb_customercode']"
     },
     {
       "header": "Name",
       "value": "@outputs('Get_Customer')?['body/cr7bb_customername']"
     },
     {
       "header": "Document Number",
       "value": "@item()?['cr7bb_documentnumber']"
     },
     {
       "header": "Assignment",
       "value": "@item()?['cr7bb_assignment']"
     },
     {
       "header": "Document Type",
       "value": "@item()?['cr7bb_documenttype']"
     },
     {
       "header": "Document Date",
       "value": "@formatDateTime(item()?['cr7bb_documentdate'], 'dd/MM/yyyy')"
     },
     {
       "header": "Amount in Local Currency",
       "value": "@formatNumber(item()?['cr7bb_amountlocalcurrency'], 'N2')"
     }
   ]
   ```

---

### Step 2.3: Add Get_QR_Code_Content Action

1. Click **+** after `Get_files_(properties_only)`
2. Search and select **Condition**
3. Configure condition:
   - **Left**: `@length(body('Get_files_(properties_only)')?['value'])`
   - **Operator**: `is greater than`
   - **Right**: `0`
4. Rename action to: `Check_QR_Available`

**Inside Check_QR_Available - If Yes:**

1. Click **Add an action**
2. Search and select **Get file content using path** (SharePoint)
3. Configure:
   - **Site Address**: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
   - **File Path**: `/Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/@{outputs('Get_Customer')?['body/cr7bb_customercode']}.jpg`
4. Rename action to: `Get_QR_Code_Content`

**Add: Compose_QR_Base64**

1. Click **+** after `Get_QR_Code_Content`
2. Search and select **Compose**
3. Configure **Inputs**:
   ```
   @base64(body('Get_QR_Code_Content'))
   ```
4. Rename action to: `Compose_QR_Base64`

---

### Step 2.4: Add Compose_QR_Section

1. Click **+** after `Check_QR_Available` (outside the condition)
2. Search and select **Compose**
3. Configure **Inputs**:
   ```
   @if(greater(length(body('Get_files_(properties_only)')?['value']), 0), concat('<table border="0" cellpadding="10" style="margin-top:20px;"><tr><td style="vertical-align:top;text-align:center;"><strong>Promptpay</strong><br/><img src="data:image/jpeg;base64,', outputs('Compose_QR_Base64'), '" alt="PromptPay QR Code" style="max-width:200px;" /><br/>', outputs('Get_Customer')?['body/cr7bb_customercode'], '</td><td style="vertical-align:top;"><strong>Bill payment</strong><br/><br/>รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้ด้วยนะคะ<br/><br/>Ref # 1: ', coalesce(outputs('Get_Customer')?['body/cr7bb_reference1'], ''), '<br/>Ref # 2: 999A', outputs('Get_Customer')?['body/cr7bb_customercode'], '</td></tr></table>'), concat('<div style="margin-top:20px;"><strong>Bill payment</strong><br/><br/>รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้ด้วยนะคะ<br/><br/>Ref # 1: ', coalesce(outputs('Get_Customer')?['body/cr7bb_reference1'], ''), '<br/>Ref # 2: 999A', outputs('Get_Customer')?['body/cr7bb_customercode'], '</div>'))
   ```
4. Rename action to: `Compose_QR_Section`

---

### Step 2.5: Add Compose_Footer_Notes

1. Click **+** after `Compose_QR_Section`
2. Search and select **Compose**
3. Configure **Inputs**:
   ```
   <p style="color: #D83B01; font-weight: bold; margin-top:20px;">หมายเหตุ</p><p>กรณีหากการชำระเงินล่าช้า (เกินเวลาที่กำหนด) บริษัทฯ จะดำเนินการออกใบเพิ่มหนี้ต่อไป<br/>การชำระเงินที่เคาน์เตอร์ธนาคาร (ธ.กรุงศรีอยุทธยา, ธ.ไทยพาณิชย์ และ ธ.กสิกรไทย) ก่อนเที่ยงของวันที่แจ้งยอด<br/>และรบกวนส่งสำเนาใบโอนเงิน กลับมาที่ Email เดิมด้วยนะคะ</p>
   ```
4. Rename action to: `Compose_Footer_Notes`

---

### Step 2.6: Update Compose_Email_Body

1. Click on `Compose_Email_Body`
2. **Replace entire Inputs** with:
   ```
   <html><body style="font-family: Arial, sans-serif;"><p>เรียนเจ้าของกิจการ</p><p>ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้</p>@{outputs('Compose_Warning_Text')}@{replace(replace(body('Create_HTML_table'), '<table>', '<table border="1" cellpadding="5" style="border-collapse: collapse;">'), '<thead>', '<thead style="background-color: #D83B01; color: white;">')}<tr style="font-weight:bold;"><td colspan="6" style="text-align:right;">@{outputs('Get_Customer')?['body/cr7bb_customercode']} @{outputs('Get_Customer')?['body/cr7bb_customername']}</td><td style="text-align:right;">@{formatNumber(outputs('Compose_Net_Amount'), 'N2')}</td></tr>@{outputs('Compose_QR_Section')}@{outputs('Compose_Footer_Notes')}</body></html>
   ```

3. Update **Run after** to include all new compose actions

---

## Part 3: Email Subject Line Update

### Step 3.1: Update Compose_Email_Subject

1. Click on `Compose_Email_Subject`
2. Update **Inputs** to match specification:
   ```
   @{outputs('Get_Customer')?['body/cr7bb_customercode']} @{outputs('Get_Customer')?['body/cr7bb_customername']} รายละเอียดบิลวันที่ @{formatDateTime(utcNow(), 'dd.MM.yyyy')}
   ```

---

## Updated Flow Structure

```
[THFinance] Daily Collections Email Engine v1.0.0.7
│
├── Initialize Variables (existing)
│   ├── varProcessDate
│   ├── varEmailsSent / varEmailsFailed
│   ├── varCustomersProcessed / varErrorMessages
│   ├── varCNTotal / varDNTotal
│   ├── varAppliedCNTotal / varCNIndex / varStopFIFO
│   ├── varARAlertCustomers / varAppliedCNList / varTableRows
│
├── List_Process_Logs
├── Check_Import_Completed
├── List_Transactions
├── Select_Customer_IDs / Get_Unique_Customers
│
├── ═══ Apply_to_each_Customer ═══
│   ├── Get_Customer
│   ├── Filter_Customer_Transactions
│   ├── Filter_Non_Excluded
│   ├── Check_All_Excluded
│   │   └── Else (Has Transactions):
│   │       ├── Filter_CN_List / Filter_DN_List
│   │       ├── Sort_CN_FIFO / Sort_DN_FIFO
│   │       ├── Reset variables
│   │       ├── Check_Has_CNs → FIFO_CN_Loop
│   │       ├── Compose_Net_Amount
│   │       ├── Check_Should_Send
│   │       │   └── Yes:
│   │       │       ├── Select_Day_Counts / Select_Document_Date
│   │       │       ├── Compose_Max_DayCount
│   │       │       ├── Check_AR_Alert
│   │       │       ├── Check_Has_MI_Document           ⭐ NEW
│   │       │       ├── Compose_Template_Selection      🔄 UPDATED
│   │       │       ├── Compose_Warning_Text            ⭐ NEW
│   │       │       ├── Compose_Email_Subject           🔄 UPDATED
│   │       │       ├── Combine_DN_and_CN
│   │       │       ├── Create_HTML_table               🔄 UPDATED
│   │       │       ├── Get_files_(properties_only)
│   │       │       ├── Check_QR_Available              ⭐ NEW
│   │       │       │   └── Yes: Get_QR_Code_Content → Compose_QR_Base64
│   │       │       ├── Compose_QR_Section              ⭐ NEW
│   │       │       ├── Compose_Footer_Notes            ⭐ NEW
│   │       │       ├── Get_AR_rep
│   │       │       ├── Compose_Email_Body              🔄 UPDATED
│   │       │       ├── Compose_All_Recipient_Emails
│   │       │       ├── Compose_All_CC_Emails
│   │       │       ├── Filter_Recipient/CC_Emails
│   │       │       ├── Compose_Recipient/CC_Emails
│   │       │       ├── Create_Email_Log                🔄 UPDATED (Template D)
│   │       │       └── Update_Transaction_Records
│
├── Check_Has_AR_Alerts → Send_AR_Alert_Email
└── Send_Summary_Email_to_AR
```

---

## Testing Checklist

### Template Selection Tests

| Scenario | Expected Template | Test Data |
|----------|------------------|-----------|
| Day 1-2, No MI | Template A | MaxDayCount=1, No MI docs |
| Day 3, No MI | Template B | MaxDayCount=3, No MI docs |
| Day 4+, No MI | Template C | MaxDayCount=5, No MI docs |
| Has MI doc | Template D | Any day count with MI doc |

### Email Body Tests

- [ ] Subject line format: `[CustomerCode] [CustomerName] รายละเอียดบิลวันที่ [dd.MM.yyyy]`
- [ ] Greeting: `เรียนเจ้าของกิจการ`
- [ ] Body intro: `ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้`
- [ ] Warning text appears before table (RED, bold)
- [ ] Table headers: Orange (#D83B01), white text
- [ ] Table columns match specification (7 columns)
- [ ] No row highlighting (even for MI)
- [ ] Total row shows customer code, name, and total amount
- [ ] QR section shows when QR available
- [ ] Bill Payment section always shows (with/without QR)
- [ ] Footer หมายเหตุ always present

### QR Code Tests

- [ ] QR inline as base64 image
- [ ] Customer code displayed below QR
- [ ] Bill Payment shows Ref #1 and Ref #2
- [ ] Ref #2 format: `999A[CustomerCode]`

---

## Rollback Plan

If issues occur:

1. **Revert to v1.0.0.6**: Import previous solution version
2. **Disable new actions**: Turn off new Compose actions
3. **Test incrementally**: Enable one change at a time

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-16 | Initial Phase 2 guide created |
| 2026-01-16 | Added Template D logic (MI document check) |
| 2026-01-16 | Added email body update to match specification |
| 2026-01-16 | Added QR inline display with base64 |
| 2026-01-16 | Removed WDN integration - **already implemented in Import flow** |
| 2026-01-16 | Added Flow Inventory section documenting active import flow |

---

**Status**: Ready for implementation
**Dependencies**: Email_Template_Specification.md, WorkingDayCalendar populated
**Note**: WDN calculation is handled by `DailySAPTransactionImport` flow (Power BI source)
