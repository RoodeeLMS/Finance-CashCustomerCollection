# Power Automate Deployment Guide
## Finance - Cash Customer Collection Automation

**Project**: Nestlé AR Collections Automation
**Platform**: Microsoft Power Platform
**Version**: 1.0
**Last Updated**: September 30, 2025

---

## Overview

This guide provides step-by-step instructions for deploying two critical Power Automate flows:

1. **Daily SAP Data Import Flow** - Imports SAP transaction data into Dataverse
2. **Collections Email Engine Flow** - Processes transactions and sends payment reminders

---

## Prerequisites

### 1. Environment Setup

✅ **Required**:
- [ ] Microsoft Dataverse environment provisioned
- [ ] Power Automate Premium license (for Dataverse connector)
- [ ] Office 365 license (for email sending)
- [ ] SharePoint site created for document storage
- [ ] Service account created with appropriate permissions

✅ **Dataverse Tables Created**:
- [ ] `cr7bb_customers` (Customer Master Data)
- [ ] `cr7bb_transactions` (Transaction Line Items)
- [ ] `cr7bb_emaillogs` (Email Audit Trail)
- [ ] `cr7bb_processlogs` (System Processing Log)

### 2. SharePoint Folder Structure

```
SharePoint Site: [Your Site URL]
├── SAP Daily Exports/
│   └── Cash_Line_items_as of DD.MM.YYYY.xlsx
├── QR Codes/
│   ├── 198609.png
│   ├── 198709.png
│   └── [customer_code].png
└── Email Templates/ (Optional - for reference)
    ├── Template_A.html
    ├── Template_B.html
    ├── Template_C.html
    └── Template_D.html
```

### 3. Permissions Required

**Service Account Permissions**:
- Dataverse: Create, Read, Write on all `cr7bb_*` tables
- SharePoint: Read access to SAP Daily Exports and QR Codes folders
- Office 365: Send email on behalf of AR team
- Office 365 Users API: Read user profiles

---

## Flow 1: Daily SAP Data Import

### Deployment Steps

#### Step 1: Create New Flow

1. Navigate to [make.powerapps.com](https://make.powerapps.com)
2. Select your environment
3. Go to **Flows** → **+ New flow** → **Automated cloud flow**
4. Name: `Daily SAP Transaction Import`
5. Trigger: **Recurrence** (or skip for manual-only)

#### Step 2: Configure Trigger (Optional)

```yaml
Trigger: Recurrence
Frequency: Day
Interval: 1
Time zone: SE Asia Standard Time
At these hours: 8
At these minutes: 0
```

**Alternative**: Skip trigger for manual-only execution during testing

#### Step 3: Add Connections

**Required Connectors**:
1. **SharePoint**
   - Click **+ New step** → Search "SharePoint"
   - Action: **Get files (properties only)**
   - Sign in with service account
   - Authorize permissions

2. **Microsoft Dataverse**
   - Click **+ New step** → Search "Dataverse"
   - Action: **List rows**
   - Sign in with service account
   - Authorize permissions

3. **Office 365 Outlook** (for notifications)
   - Click **+ New step** → Search "Outlook"
   - Action: **Send an email (V2)**
   - Sign in with service account

#### Step 4: Build Flow Logic

Follow the detailed steps in [PowerAutomate_SAP_Data_Import_Flow.md](PowerAutomate_SAP_Data_Import_Flow.md):

**Key Actions**:
1. Initialize variables (varProcessDate, varBatchID, etc.)
2. Get latest SAP file from SharePoint
3. Create process log entry
4. Parse Excel rows using "List rows present in a table"
5. For each row:
   - Determine record type (Header/Transaction/Summary)
   - Lookup customer by code
   - Check exclusion keywords
   - Create transaction record in Dataverse
6. Process historical day count increments
7. Validate summary amounts
8. Update process log
9. Send summary email

#### Step 5: Configure Error Handling

**Add Scope Actions**:
```yaml
Scope: Try_Main_Processing
  - Add all main processing actions inside this scope

Scope: Catch_Errors
  Configure run after: Try_Main_Processing has failed
  Actions:
    - Update process log with error status
    - Send error notification
    - Terminate with failed status
```

**Configure Retry Policies**:
- Customer Lookup: Exponential, 3 retries, 10s interval
- Create Transaction: Fixed, 2 retries, 5s interval
- Update Process Log: No retry (fail fast)

#### Step 6: Testing

**Test Data**: Create a small CSV with 5-10 transactions

```csv
Account,Document Number,Assignment,Document Type,Document Date,Net Due Date,Arrears by Net Due Date,Amount in Local Currency,Text,Reference
198609,9974698958,9974698958,DG,9/26/2025,9/26/2025,3,"-30,213.31",,PR_GR09_406_ONNR
198609,,,,,,,"-30,213.31",,
```

**Test Steps**:
1. Upload test CSV to SharePoint
2. Run flow manually
3. Check Dataverse for created records
4. Verify process log entry
5. Confirm summary email received

**Validation Checklist**:
- [ ] Transaction records created with correct amounts
- [ ] Customer lookup successful
- [ ] Exclusion keywords detected
- [ ] Day count calculated correctly
- [ ] Summary row amounts match
- [ ] Process log shows correct statistics
- [ ] No error messages

#### Step 7: Production Deployment

1. **Save and test** flow multiple times
2. **Enable flow** (turn on)
3. **Set up monitoring**:
   - Flow analytics: Enabled
   - Email notifications: On failure
4. **Document flow URL** for AR team
5. **Schedule**: Enable recurrence trigger if disabled during testing

---

## Flow 2: Collections Email Engine

### Deployment Steps

#### Step 1: Create New Flow

1. Navigate to [make.powerapps.com](https://make.powerapps.com)
2. Select your environment
3. Go to **Flows** → **+ New flow** → **Automated cloud flow**
4. Name: `Daily Collections Email Engine`
5. Trigger: **Recurrence** or **Manual** (recommended: manual during testing)

#### Step 2: Configure Trigger

```yaml
Trigger: Recurrence (Optional)
Frequency: Day
Interval: 1
Time zone: SE Asia Standard Time
At these hours: 8
At these minutes: 30  # After SAP import at 08:00
```

#### Step 3: Add Connections

**Required Connectors**:
1. **Microsoft Dataverse** (already connected)
2. **SharePoint** (for QR codes)
3. **Office 365 Outlook** (for sending emails)
4. **Office 365 Users** (for AR representative profiles)

#### Step 4: Build Flow Logic

Follow the detailed steps in [PowerAutomate_Collections_Email_Engine.md](PowerAutomate_Collections_Email_Engine.md):

**Key Actions**:
1. Verify SAP import completed (check process log)
2. Get today's transactions
3. Group by customer
4. For each customer:
   - Check if all transactions excluded → skip
   - Separate CN and DN
   - Sort by document date (FIFO)
   - Calculate net amount
   - If customer owes money:
     - Calculate max day count
     - Select email template
     - Build email content
     - Get QR code file
     - Get AR representative signature
     - Send email
     - Log email record
     - Update transaction records
5. Update process log with email statistics
6. Send summary email to AR team

#### Step 5: Build Email Templates

**Template A (Day 1-2)**:
```html
<html>
<body style="font-family: Arial, sans-serif;">
  <p>เรียน คุณ @{outputs('Get_customer')?['cr7bb_customername']}</p>

  <p>ตามที่บริษัทได้ตรวจสอบยอดค้างชำระพบว่า ณ วันที่ @{formatDateTime(utcNow(), 'dd/MM/yyyy')} ท่านมียอดค้างชำระดังนี้</p>

  <!-- Transaction table here -->

  <p><strong>รวมยอดค้างชำระทั้งสิ้น: @{formatNumber(variables('varNetAmount'), 'N2')} บาท</strong></p>

  <p>กรุณาชำระเงินผ่าน PromptPay QR Code ที่แนบมาพร้อมนี้</p>

  <p>ขอบคุณค่ะ</p>

  <!-- AR signature here -->
</body>
</html>
```

**Add to flow using Compose actions** for easier template management

#### Step 6: Configure FIFO Logic

**Critical Expression**:
```javascript
// Sort transactions by document date (FIFO)
sort(
  filter(
    outputs('Get_customer_transactions'),
    and(
      greater(item()?['cr7bb_amountlocalcurrency'], 0),
      equals(item()?['cr7bb_isexcluded'], false)
    )
  ),
  'cr7bb_documentdate'
)
```

**Test FIFO Calculation**:
- Customer with multiple DN and CN
- Verify oldest documents processed first
- Confirm net amount calculation is correct

#### Step 7: Testing

**Test Scenarios**:

1. **Normal Case**: Customer with net positive amount
   - Expected: Email sent with correct template

2. **All Excluded**: All transactions have exclusion keywords
   - Expected: Skip customer, no email

3. **CN Exceeds DN**: Credits > Debits
   - Expected: Skip customer, no amount due

4. **Day 3**: Max day count = 3
   - Expected: Template B with warning

5. **Day 4+**: Max day count >= 4
   - Expected: Template C with late fee notice

6. **MI Documents**: Contains MI document type
   - Expected: Template D with MI explanation

7. **Missing QR Code**: Customer with no QR file
   - Expected: Email sent without attachment, warning logged

8. **Email Failure**: Invalid email address
   - Expected: Error logged, continue to next customer

**Validation Checklist**:
- [ ] FIFO calculation correct
- [ ] Template selection logic working
- [ ] Email formatting renders properly
- [ ] QR code attachments working
- [ ] AR representative signature populated
- [ ] Email log records created
- [ ] Transaction records updated
- [ ] Summary email sent to AR team

#### Step 8: Production Deployment

1. **Test with 5-10 customers** first
2. **Review email content** with AR team for approval
3. **Verify all email addresses** valid
4. **Enable flow** (turn on)
5. **Set up monitoring**:
   - Success rate tracking
   - Failed email alerts
   - Daily summary review
6. **Document manual trigger process** for AR team
7. **Schedule**: Enable recurrence after successful testing

---

## Post-Deployment Configuration

### 1. Set Up Monitoring Alerts

**Create Alert Flow** (recommended):
```yaml
Flow Name: Collections Engine Alert
Trigger: When Collections Email Engine fails
Actions:
  - Send email to: it-team@nestle.com, ar-team@nestle.com
  - Subject: "🚨 Collections Engine Failed"
  - Include: Error message, timestamp, flow run URL
```

### 2. Enable Flow Analytics

1. Navigate to flow details
2. Click **Analytics**
3. Enable **Run analytics**
4. Set up **success rate threshold** (e.g., alert if <95%)

### 3. Configure Connection References

**Best Practice**: Use service account for all connections
- Consistency in permissions
- Easier troubleshooting
- Centralized credential management

### 4. Set Up Data Retention Policies

**Recommended Retention**:
- Transaction data: 2 years
- Email logs: 3 years (compliance)
- Process logs: 1 year

**Create Archive Flow**:
```yaml
Flow Name: Monthly Data Archive
Trigger: Recurrence (Monthly, 1st day at 2 AM)
Actions:
  - Get records older than 2 years
  - Export to SharePoint CSV
  - Delete from Dataverse
  - Send confirmation email
```

---

## Troubleshooting Guide

### Common Issues

#### Issue 1: SAP Import Flow Fails

**Symptom**: Process log shows "Failed" status

**Possible Causes**:
1. Excel file not found in SharePoint
2. Customer code not found in Dataverse
3. Invalid date format
4. Malformed amount (e.g., comma separator issues)

**Resolution**:
1. Check SharePoint folder permissions
2. Verify customer master data is up to date
3. Review error messages in process log
4. Check Excel file format matches expected structure

#### Issue 2: Email Not Sending

**Symptom**: Email log shows "Failed" status

**Possible Causes**:
1. Invalid email address format
2. QR code file not found
3. Office 365 connector authentication expired
4. Email size exceeds limit (25 MB)

**Resolution**:
1. Validate customer email addresses
2. Check QR code folder for missing files
3. Re-authenticate Office 365 connection
4. Reduce email size (compress QR codes)

#### Issue 3: FIFO Calculation Incorrect

**Symptom**: Net amount doesn't match expected value

**Possible Causes**:
1. Transactions not sorted by document date
2. Exclusion logic not applied correctly
3. CN/DN classification wrong

**Resolution**:
1. Review sort expression in flow
2. Check exclusion keyword list
3. Verify DocumentType → TransactionType mapping
4. Test with manual calculation

#### Issue 4: Performance Degradation

**Symptom**: Flow takes longer than 30 minutes

**Possible Causes**:
1. Too many customer lookups
2. Large transaction volume
3. Inefficient filtering

**Resolution**:
1. Implement customer caching
2. Use pagination for large datasets
3. Optimize filter expressions
4. Consider parallel processing (with caution)

---

## Maintenance Schedule

### Daily Tasks
- [ ] Review process log for failures
- [ ] Check email success rate
- [ ] Monitor flow run duration

### Weekly Tasks
- [ ] Review error messages for patterns
- [ ] Validate QR code availability
- [ ] Check customer data completeness
- [ ] Analyze email bounce rates

### Monthly Tasks
- [ ] Archive old transaction data
- [ ] Review and optimize flow performance
- [ ] Update exclusion keyword list
- [ ] Review email template effectiveness
- [ ] Update AR representative assignments

### Quarterly Tasks
- [ ] Security audit of connections
- [ ] Compliance review of email logs
- [ ] Performance optimization review
- [ ] Business rule validation

---

## Rollback Procedure

**If Production Issues Occur**:

1. **Disable Flow Immediately**:
   - Navigate to flow details
   - Click **Turn off**

2. **Assess Impact**:
   - Check how many customers affected
   - Review email logs for sent/failed emails
   - Identify root cause

3. **Communicate to Stakeholders**:
   - Notify AR team
   - Explain issue and expected resolution time
   - Provide manual process fallback instructions

4. **Fix and Test**:
   - Make necessary corrections
   - Test thoroughly in dev/test environment
   - Get AR team approval

5. **Re-deploy**:
   - Enable flow
   - Monitor closely for first 24 hours
   - Confirm issue resolved

6. **Post-Mortem**:
   - Document what went wrong
   - Update deployment checklist
   - Improve testing procedures

---

## Success Metrics

### Flow Performance Targets

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| SAP Import Success Rate | 99% | <95% |
| Email Send Success Rate | 95% | <90% |
| SAP Import Duration | <10 min | >15 min |
| Email Engine Duration | <30 min | >45 min |
| FIFO Accuracy | 100% | <100% |
| QR Code Availability | 95% | <90% |

### Business Impact Metrics

| Metric | Baseline | Target |
|--------|----------|--------|
| AR Staff Time Saved | 2-3 hrs/day | <30 min/day |
| Manual Errors | Variable | 0 |
| Payment Response Time | Unknown | Track trend |
| Audit Compliance | 0% | 100% |

---

## Support Contacts

**Technical Issues**:
- Power Platform Admin: [admin@nestle.com]
- Flow Developer: Nick Chamnong
- Dataverse Support: [dataverse-support@nestle.com]

**Business Issues**:
- AR Team Lead: Changsalak Alisara
- Process Owner: Credit Management Team

**Escalation Path**:
1. AR Team → IT Finance
2. IT Finance → Power Platform Admin
3. Power Platform Admin → Microsoft Support

---

## Appendix

### A. Connection Reference Details

| Connector | Purpose | Service Account |
|-----------|---------|-----------------|
| Microsoft Dataverse | Read/Write tables | svc-powerauto@nestle.com |
| SharePoint | File access | svc-powerauto@nestle.com |
| Office 365 Outlook | Send emails | ar-noreply@nestle.com |
| Office 365 Users | Get user profiles | svc-powerauto@nestle.com |

### B. Flow URLs

**Production Environment**:
- SAP Import Flow: [Flow URL after deployment]
- Email Engine Flow: [Flow URL after deployment]

**Test Environment**:
- SAP Import Flow: [Test Flow URL]
- Email Engine Flow: [Test Flow URL]

### C. Dataverse Environment Details

- **Environment Name**: [Your Environment Name]
- **Environment URL**: [Your Environment URL]
- **Organization ID**: [Your Org ID]
- **Solution Name**: Finance Cash Collection Automation

### D. Change Log

| Date | Version | Change Description | Author |
|------|---------|-------------------|---------|
| 2025-09-30 | 1.0 | Initial deployment guide | Nick Chamnong |

---

**Document Status**: Ready for Use
**Last Review**: September 30, 2025
**Next Review**: After UAT Completion
