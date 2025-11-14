# Skeleton Flows Creation Guide

**Purpose**: Create minimal Power Automate flows with correct triggers and connections, then export for Claude to add business logic

**Created**: 2025-10-13
**For**: Nick Chamnong

---

## 🎯 **Overview**

You will create **4 new flows** as "skeletons" (minimal structure only), then export the solution. Claude will edit the exported JSON to add all business logic, then you'll import it back.

**Why this approach?**
- ✅ You set permissions and connections correctly
- ✅ Claude adds all business logic (avoids manual flow building)
- ✅ Faster than building flows step-by-step in UI

---

## 📋 **Prerequisites**

Before creating flows:

### **1. Add Missing Fields to Dataverse** (5 fields total)

#### **EmailLog Table** - Add 2 fields:

| Field Name | Display Name | Type | Required | Default | Description |
|------------|--------------|------|----------|---------|-------------|
| `cr7bb_approvalstatus` | Approval Status | Choice | Yes | Pending | Pending/Approved/Rejected (extensible for future statuses) |
| `cr7bb_emailbodypreview` | Email Body Preview | Multiple Lines Text (10000) | No | - | Full email HTML for preview in Canvas App |

**Choice Values for `cr7bb_approvalstatus`:**
- Pending (value: 676180000) - Default, waiting for AR review
- Approved (value: 676180001) - AR approved, ready to send
- Rejected (value: 676180002) - AR rejected, don't send
- *(Future: Hold, Escalated, Cancelled, etc.)*

#### **Transaction Table** - Add 2 fields:

| Field Name | Display Name | Type | Required | Default | Description |
|------------|--------------|------|----------|---------|-------------|
| `cr7bb_sourcefilename` | Source File Name | Single Line Text (255) | No | - | Excel filename (e.g., "SAP_Export_2025-10-13.xlsx") |
| `cr7bb_sourcefilepath` | Source File Path | Single Line Text (500) | No | - | Full SharePoint path to source file |

#### **Process Log Table** - Add 1 field + Expand existing Status:

| Field Name | Display Name | Type | Required | Default | Description |
|------------|--------------|------|----------|---------|-------------|
| `cr7bb_sourcefilepath` | Source File Path | Single Line Text (500) | No | - | Full SharePoint path to source file |

**Expand existing `cr7bb_status` Choice field** - Add these values:
- File Not Found (value: 676180004) - Excel file missing from SharePoint
- File Already Processed (value: 676180005) - File has "_Processed" suffix (skip)

---

## 🔧 **Flow 1: Customer Data Sync**

### **Flow Settings:**
- **Flow Name**: `[THFinanceCashCollection] Customer Data Sync`
- **Description**: Sync customer master data from Excel to Dataverse
- **Type**: Manual cloud flow

### **Step-by-Step:**

1. **Create new flow** → Instant cloud flow
2. **Trigger**: `PowerApps (V2)` or `Manually trigger a flow`
3. **Add action**: `Initialize variable`
   - Name: `varSyncStartTime`
   - Type: String
   - Value: (leave empty)
4. **Save as**: `[THFinanceCashCollection] Customer Data Sync`

### **Connections Needed:**
- ✅ Dataverse (Microsoft Dataverse connector)
- ✅ SharePoint (for reading Excel file)
- ✅ Excel Online (Business)

**That's it!** Claude will add:
- Excel file reading from SharePoint
- Row validation (customer email, region)
- Upsert logic (update if exists, create if new)
- Sync logging

---

## 🔧 **Flow 2: Email Sending Flow**

### **Flow Settings:**
- **Flow Name**: `[THFinanceCashCollection] Email Sending Flow`
- **Description**: Send approved emails from EmailLog table
- **Type**: Scheduled cloud flow

### **Step-by-Step:**

1. **Create new flow** → Scheduled cloud flow
2. **Trigger**: `Recurrence`
   - Repeat every: 1 Day
   - Time zone: SE Asia Standard Time
   - At these hours: 10 (10:00 AM - 2 hours after Collections Engine at 8:30 AM)
   - At these minutes: 30
3. **Add action**: `Initialize variable`
   - Name: `varProcessDate`
   - Type: String
   - Value: (leave empty)
4. **Save as**: `[THFinanceCashCollection] Email Sending Flow`

### **Connections Needed:**
- ✅ Dataverse (read EmailLog with approved=true)
- ✅ SharePoint (retrieve QR codes)
- ✅ Office 365 Outlook (send emails)

**Claude will add:**
- Get today's EmailLog records where `cr7bb_approved = true` and `cr7bb_sendstatus = "Pending"`
- For each approved email:
  - Retrieve customer and transaction data
  - Get QR code from SharePoint
  - Send email
  - Update EmailLog status to "Sent"
  - Mark transactions as processed
- Handle rejected/timeout emails (mark as "Not Approved")

---

## 🔧 **Flow 3: Manual SAP Upload**

### **Flow Settings:**
- **Flow Name**: `[THFinanceCashCollection] Manual SAP Upload`
- **Description**: Manual trigger to upload and process SAP file from Canvas App
- **Type**: PowerApps triggered flow

### **Step-by-Step:**

1. **Create new flow** → Instant cloud flow → PowerApps
2. **Trigger**: `PowerApps (V2)`
3. **Add action**: `Initialize variable`
   - Name: `varProcessDate`
   - Type: String
   - Value: (leave empty)
4. **Add action**: `Respond to PowerApps or flow`
   - Add output: `Status` (Text)
   - Add output: `Message` (Text)
   - Add output: `RowCount` (Number)
5. **Save as**: `[THFinanceCashCollection] Manual SAP Upload`

### **Connections Needed:**
- ✅ Dataverse
- ✅ SharePoint
- ✅ Excel Online (Business)

**Claude will add:**
- Same logic as existing SAP Import Flow
- But returns status to Canvas App (success/failure/row count)
- Tracks source filename in transactions

---

## 🔧 **Flow 4: Manual Email Resend**

### **Flow Settings:**
- **Flow Name**: `[THFinanceCashCollection] Manual Email Resend`
- **Description**: Resend individual email from Email Monitor screen
- **Type**: PowerApps triggered flow

### **Step-by-Step:**

1. **Create new flow** → Instant cloud flow → PowerApps
2. **Trigger**: `PowerApps (V2)`
3. **Add action**: `Ask in PowerApps` (or use PowerApps trigger input)
   - Input name: `EmailLogID`
   - Input type: Text
   - Description: "GUID of EmailLog record to resend"
4. **Add action**: `Initialize variable`
   - Name: `varEmailLogID`
   - Type: String
   - Value: (leave empty)
5. **Add action**: `Respond to PowerApps or flow`
   - Add output: `Status` (Text)
   - Add output: `Message` (Text)
6. **Save as**: `[THFinanceCashCollection] Manual Email Resend`

### **Connections Needed:**
- ✅ Dataverse
- ✅ SharePoint (for QR codes)
- ✅ Office 365 Outlook

**Claude will add:**
- Get EmailLog record by ID
- Get customer from EmailLog
- Get transactions for that customer
- Regenerate email
- Send email
- Update EmailLog status
- Mark transactions as sent

---

## 📤 **Export Solution**

After creating all 4 skeleton flows:

1. Go to **Solutions** → `THFinanceCashCollection`
2. Click **Export**
3. Choose **Unmanaged**
4. Wait for export to complete
5. Download ZIP file
6. Extract ZIP to: `E:\NestlePowerApp\Finance-CashCustomerCollection\Powerapp solution Export\extracted_v2\`

**Important**: Keep the old `extracted` folder intact for reference!

---

## 📁 **Expected File Structure After Export**

```
Powerapp solution Export/
├── extracted/                    # OLD export (keep for reference)
├── extracted_v2/                 # NEW export with skeleton flows
│   ├── [Content_Types].xml
│   ├── customizations.xml        # Updated with new fields
│   ├── solution.xml
│   ├── Workflows/
│   │   ├── [THFinanceCashCollection]CustomerDataSync-*.json
│   │   ├── [THFinanceCashCollection]EmailSendingFlow-*.json
│   │   ├── [THFinanceCashCollection]ManualSAPUpload-*.json
│   │   └── [THFinanceCashCollection]ManualEmailResend-*.json
└── THFinanceCashCollection_1_0_0_4.zip  # New version
```

---

## ✅ **Checklist Before Exporting**

- [ ] Added 4 fields to EmailLog table
- [ ] Added 2 fields to Transaction table
- [ ] Added 2 fields to Process Log table
- [ ] Created Customer Data Sync flow (Manual trigger)
- [ ] Created Email Sending Flow flow (Scheduled 10:30 AM)
- [ ] Created Manual SAP Upload flow (PowerApps trigger)
- [ ] Created Manual Email Resend flow (PowerApps trigger)
- [ ] All flows have correct connections configured
- [ ] All flows are in the solution
- [ ] Solution exported as unmanaged ZIP

---

## 📬 **After Export**

1. Extract ZIP to `extracted_v2` folder
2. Share the folder path with Claude
3. Claude will:
   - Read skeleton flow JSON files
   - Add all business logic
   - Update connections/actions
   - Save edited JSON files back
4. You import the edited solution

---

## 🎯 **Connection Reference Names**

Make sure these connectors are added to flows (even if not used yet):

| Connector | Reference Name (example) |
|-----------|--------------------------|
| Dataverse | `shared_commondataserviceforapps` |
| SharePoint | `shared_sharepointonline` |
| Excel Online | `shared_excelonlinebusiness` |
| Office 365 Outlook | `shared_office365` |
| Office 365 Users | `shared_office365users` |

**Note**: Actual reference names will be auto-generated by Power Platform

---

## 💡 **Tips**

1. **Don't add logic** - Just create the trigger and 1-2 simple actions (Initialize Variable). Claude will add everything else.

2. **Test connections** - Make sure all connectors work before exporting (green checkmarks)

3. **Use consistent naming** - Start all flow names with `[THFinanceCashCollection]` for easy identification

4. **Version control** - Each export should be a new folder (`extracted_v2`, `extracted_v3`, etc.)

5. **Keep backups** - Never delete old exports, they're useful for comparing changes

---

## ❓ **FAQ**

**Q: Do I need to add all the Excel/SharePoint actions?**
A: No! Just the trigger and 1 initialization action. Claude will add all the business logic.

**Q: What if connections fail?**
A: Make sure you have permissions to:
- Read/Write Dataverse tables
- Read/Write SharePoint site (for SAP files and QR codes)
- Read Excel files in SharePoint
- Send emails via Office 365

**Q: Should I test the skeleton flows?**
A: No need to test. They won't do anything useful yet. Just make sure they save without errors.

**Q: Can I modify existing flows (SAP Import, Collections Engine)?**
A: No need to create skeletons for those. Claude will edit them directly from the current export.

---

## 🚀 **Ready to Build!**

Once you complete this guide, you'll have:
- ✅ 8 new fields in Dataverse
- ✅ 4 skeleton flows with correct triggers
- ✅ Exported solution ready for Claude to edit
- ✅ All connections and permissions configured

**Estimated Time**: 30-45 minutes

**Next Step**: Export solution and share `extracted_v2` folder path with Claude! 🎉
