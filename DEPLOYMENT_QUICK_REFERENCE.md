# Deployment Quick Reference - v1.0.0.5

**Quick access guide for deploying THFinanceCashCollection to your Power Platform environment.**

---

## 📦 What You Have

**Solution File**: `Powerapp solution Export/THFinanceCashCollection_1_0_0_5.zip` (4.0 MB)

**Includes**:
- ✅ Canvas App (10 screens)
- ✅ Power Automate Flows (6 workflows)
- ✅ Dataverse Tables (7 tables)
- ✅ Environment Variables (5)
- ✅ Choice Fields (7)

---

## 🚀 3-Step Quick Deploy

### Step 1: Prepare Environment (15 minutes)

```bash
# Create in your target Power Platform environment:
1. Dataverse Tables (auto-imported with solution)
   ✓ cr7bb_thfinancecashcollectioncustomer
   ✓ cr7bb_thfinancecashcollectiontransaction
   ✓ cr7bb_thfinancecashcollectionprocesslog
   ✓ cr7bb_thfinancecashcollectionemaillog
   ✓ cr7bb_thfinancecashcollectionrole
   ✓ cr7bb_thfinancecashcollectionroleassignment
   ✓ nc_thfinancecashcollectioncalendarevent

2. SharePoint Folder Structure:
   Site: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions

   Folders:
   ├── /Shared Documents/Cash Customer Collection/
   │   ├── 01-Daily-SAP-Data/
   │   │   └── Current/              ← SAP Excel files go here
   │   └── 03-QR-Codes/              ← QR code images go here

3. Test Data:
   - Create 2-3 customer records in Dataverse
   - Upload sample SAP Excel file (5-10 rows)
   - Upload QR code images (optional for testing)
```

### Step 2: Import Solution (5-10 minutes)

```
1. Go to make.powerapps.com
2. Select your environment
3. Click Solutions (left nav)
4. Click "Import solution"
5. Browse → Select THFinanceCashCollection_1_0_0_5.zip
6. Click "Next"
7. Review Details:
   - Name: THFinanceCashCollection
   - Version: 1.0.0.5
   - Publisher: NickChamnong
   - Components: 6 workflows, 7 tables, 7 choices, 1 app, 5 env vars
8. Click "Next"
9. Map Connection References:
   ✓ SharePoint
   ✓ Microsoft Dataverse
   ✓ Excel Online (Business)
   ✓ Office 365 Outlook
   ✓ Office 365 Users
10. Click "Import"
11. Wait 2-5 minutes for completion
12. Verify: "Solution imported successfully" ✅
```

### Step 3: Configure & Test (30 minutes)

```
1. FLOWS - Open each and verify:
   ✓ [THFinanceCashCollection] Daily SAP Transaction Import
   ✓ [THFinanceCashCollection] Daily Collections Email Engine

   Update:
   • Email recipients (from: Nick.Chamnong@th.nestle.com → your AR team)
   • SharePoint site paths
   • Excel file references

2. ENVIRONMENT VARIABLES - Set values:
   • nc_EmailMode: Production (or Test for initial)
   • nc_PACurrentEnvironmentMode: Production
   • nc_SystemNotificationEmail: your-email@company.com
   • nc_PATestNotificationEmail: test-email@company.com
   • nc_TestCustomerEmail: test-customer@company.com

3. TEST - Run Scenario 1 (Simple Import):
   a) Open Daily SAP Transaction Import flow
   b) Click "Test" → "Manually" → "Test"
   c) Monitor execution
   d) Verify:
      ✓ Transactions created in Dataverse
      ✓ Process log shows success
      ✓ Summary email received

4. CANVAS APP - Test screens:
   a) Open Canvas App: THFinanceCashCollection
   b) Navigate screens:
      ✓ Dashboard (main control center)
      ✓ Customer (customer list)
      ✓ Transactions (transaction viewer)
      ✓ Email Approval (approval workflow)
   c) Verify navigation works
   d) Test customer CRUD operations
```

---

## 📋 Pre-Flight Checklist

- [ ] SharePoint folders created & accessible
- [ ] Connection references mapped successfully
- [ ] Dataverse tables imported
- [ ] Test customer records created (min. 2)
- [ ] Sample SAP Excel uploaded
- [ ] Flow variables set correctly
- [ ] Email addresses updated
- [ ] Environment variables configured
- [ ] Scenario 1 tested successfully
- [ ] Canvas App opens without errors

---

## 🔧 Configuration Checklist

After import, update these required items:

### Email Recipients
**File**: Each flow → "Send Summary Email" action
```
From: ★ Update to actual SharePoint connection account
To: ★ Update to AR team distribution list
```

### SharePoint Paths
**File**: Flows → SharePoint actions
```
Current: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions
Update: Your actual SharePoint site URL
```

### Excel File Reference
**File**: SAP Import flow → "List rows present in a table"
```
File: ★ Point to your uploaded SAP file
Table: ★ Point to your Excel table name
```

### Environment Variables
**Location**: Power Platform Admin Center → Environments → Variables
```
☐ nc_EmailMode = "Production"
☐ nc_PACurrentEnvironmentMode = "Production"
☐ nc_SystemNotificationEmail = "your-team@company.com"
☐ nc_PATestNotificationEmail = "your-email@company.com"
☐ nc_TestCustomerEmail = "test@company.com"
```

---

## ⏰ Scheduling

Once tested, enable automatic execution:

### Flow 1: Daily SAP Transaction Import
```
Trigger: Recurrence (Scheduled)
Frequency: Daily
Time: 8:00 AM
Timezone: Asia/Bangkok (UTC+7)
```

### Flow 2: Daily Collections Email Engine
```
Trigger: Recurrence (Scheduled)
Frequency: Daily
Time: 8:30 AM (after SAP import completes)
Timezone: Asia/Bangkok (UTC+7)
```

---

## 🧪 Test Scenarios

Run these in order to validate functionality:

### Scenario 1: Simple Transaction Import (5 min)
✅ **Setup**: 1 customer, 1 Excel row with transaction
✅ **Expected**: Transaction created, process log success, summary email

### Scenario 2: Exclusion Keywords (5 min)
✅ **Setup**: Excel row with "Paid" in text field
✅ **Expected**: Transaction marked as excluded, skipped in email engine

### Scenario 3: FIFO Email Sending (10 min)
✅ **Setup**: 1 customer with 2 DN (1000, 2000) and 1 CN (-500)
✅ **Expected**: Email sent with net amount 2500, all DN listed

### Scenario 4: Template Selection (10 min)
✅ **Setup**: Transactions with different day counts (1, 3, 5)
✅ **Expected**: Template A (day 1-2), B (day 3), C (day 4+) selected correctly

---

## 📞 Support Matrix

| Issue | Check | Location |
|-------|-------|----------|
| Flows fail to start | Connection references | IMPORT_INSTRUCTIONS.md § Troubleshooting |
| Tables not found | Dataverse tables exist | Power Platform Admin Center → Tables |
| Excel not found | File path correct | SAP Import flow → List rows action |
| Emails not sent | Outlook connection valid | Data → Connections |
| QR codes missing | Optional - continue without | Email logs show warning only |

**Full Troubleshooting Guide**: `Powerapp solution Export/IMPORT_INSTRUCTIONS.md`

---

## 📚 Complete Documentation

| Document | Purpose | Location |
|----------|---------|----------|
| **IMPORT_INSTRUCTIONS.md** | Complete step-by-step guide | `Powerapp solution Export/` |
| **SOLUTION_ANALYSIS_V1_0_0_5.md** | Technical analysis & contents | Root folder |
| **PROJECT_STATUS.md** | Current project phase | `Documentation/01-Project-Overview/` |
| **FIELD_NAME_REFERENCE.md** | All Dataverse field names | `Documentation/02-Database-Schema/` |
| **README.md** | Project overview & quick links | Root folder |

---

## ✅ Success Criteria

**Your deployment is successful when**:

1. ✅ Solution imports without errors
2. ✅ All 6 flows show "Off" status initially
3. ✅ Scenario 1 completes successfully
4. ✅ Canvas App opens all 10 screens
5. ✅ Customer CRUD operations work
6. ✅ Test emails send correctly
7. ✅ Dataverse tables show created records
8. ✅ Process logs record all actions

---

## 🎯 Timeline

| Phase | Time | Activity |
|-------|------|----------|
| **Prepare** | 15 min | Setup SharePoint, create test data |
| **Import** | 5-10 min | Import solution |
| **Configure** | 20 min | Update emails, paths, variables |
| **Test** | 30 min | Run test scenarios |
| **Schedule** | 5 min | Enable flow triggers |
| **Monitor** | 1 week | Watch first automated runs |

**Total Time**: ~90 minutes from start to first automated run

---

## 🚀 You're Ready!

This solution will automate your daily AR collection emails, reducing manual work from 2-3 hours to 15 minutes while ensuring 100% adherence to business rules.

**Next Step**: Start with "Prepare Environment" section above.

Questions? See full documentation in `Powerapp solution Export/IMPORT_INSTRUCTIONS.md`

---

**Version**: v1.0.0.5
**Status**: ✅ Production Ready
**Date**: November 14, 2025
