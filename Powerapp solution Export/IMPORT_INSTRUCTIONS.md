# Solution Import Instructions
## THFinanceCashCollection v1.0.0.10 - Complete with Working Day Calendar & QR Availability Check

**File**: `THFinanceCashCollection_1_0_0_10` (unmanaged folder)
**Updated**: January 26, 2026

---

## ✅ What's Included

This solution package contains **complete, production-ready** components:

### 📱 Canvas App (Updated v1.0.0.10)
**Screens Included**:
- ✅ **scnCustomer** - Customer management, CRUD, QR availability check
- ✅ **scnDashboard** - Daily control center & process monitoring
- ✅ **scnCustomerHistory** - Transaction history & filtering
- ✅ **scnEmailApproval** - Manual email approval & override
- ✅ **scnTransactions** - Transaction list, FIFO calculation preview
- ✅ **scnRole** - Role & permission management
- ✅ **scnCalendar** - Holiday/calendar management
- ✅ **scnUnauthorized** - Access denial screen
- ✅ **loadingScreen** - Initial loading experience

**Technologies**:
- Modern controls (Button@0.0.45, Text@0.0.51)
- Nestlé brand compliance (colors, fonts, layouts)
- Responsive design for web & tablet

### 🔄 Power Automate Flows (11 Total)

**Core Flows**:
1. **[THFinanceCashCollection] Daily SAP Transaction Import**
   - ✅ File detection & filtering
   - ✅ Excel parsing with FIFO sequencing
   - ✅ Customer lookup & validation
   - ✅ Exclusion keyword checking (Paid, Partial Payment, etc.)
   - ✅ Transaction record creation
   - ✅ Working Day Number (WDN) calculation for Day Count
   - ✅ Process logging
   - ✅ AR team summary email

2. **[THFinanceCashCollection] Daily SAP Transaction Import (Extended)**
   - ✅ Extended version with additional processing options

3. **[THFinanceCashCollection] Daily Collections Email Engine**
   - ✅ SAP import validation
   - ✅ Transaction filtering & sorting
   - ✅ FIFO CN/DN matching algorithm
   - ✅ Net amount calculation
   - ✅ Email template selection (Day 1-2, Day 3, Day 4+, MI)
   - ✅ QR code attachment from SharePoint
   - ✅ HTML email composition
   - ✅ Email logging & audit trail
   - ✅ Transaction marking as processed

**Support Flows**:
4. **[THFinanceCashCollection] Manual SAP Upload**
   - ✅ Manual file upload capability
   - ✅ Replaces automated import for ad-hoc uploads

5. **[THFinanceCashCollection] Email Sending Flow**
   - ✅ Reusable email composition
   - ✅ HTML template support

6. **[THFinanceCashCollection] Manual Email Resend**
   - ✅ Resend functionality from Canvas App
   - ✅ Error recovery support

7. **[THFinanceCashCollection] Customer Data Sync**
   - ✅ Customer master data synchronization
   - ✅ Data consistency maintenance

**🆕 New in v1.0.0.10 - Working Day Calendar**:
8. **[THFinance] Generate Working Day Calendar**
   - ✅ Generates WorkingDayCalendar table entries
   - ✅ Excludes weekends (Sat/Sun) and holidays
   - ✅ Assigns sequential Working Day Numbers (WDN)
   - ✅ Used for accurate arrear day calculation

9. **[THFinance] RecalculateWDN (PowerApps)**
   - ✅ Wrapper flow callable from Canvas App
   - ✅ Triggers calendar regeneration after holiday changes

**🆕 New in v1.0.0.10 - QR Code Management**:
10. **[THFinance] Check QR Availability**
    - ✅ Scans SharePoint for QR code files
    - ✅ Updates `cr7bb_qrcodeavailable` field on Customers
    - ✅ Concurrent processing (20 parallel)

11. **[THFinance] CheckQRAvailability (PowerApps)**
    - ✅ Wrapper flow callable from Canvas App
    - ✅ Returns status and count to caller

### 🗄️ Dataverse Tables (8 Total)
- ✅ `cr7bb_thfinancecashcollectioncustomer` - Customer master (+ QR availability field)
- ✅ `cr7bb_thfinancecashcollectiontransaction` - Transaction line items
- ✅ `cr7bb_thfinancecashcollectionprocesslog` - Process execution logs
- ✅ `cr7bb_thfinancecashcollectionemaillog` - Email audit trail
- ✅ `cr7bb_thfinancecashcollectionrole` - Role definitions
- ✅ `cr7bb_thfinancecashcollectionroleassignment` - User role mappings
- ✅ `nc_thfinancecashcollectioncalendarevent` - Calendar events (holidays)
- 🆕 `nc_thfinancecashcollectionworkingdaycalendar` - Working Day Calendar (WDN lookup)

### ⚙️ Choice Fields (7 Total)
- ✅ `cr7bb_approvalstatuschoice` - Approval workflow states
- ✅ `cr7bb_emailtemplatechoice` - Template selection
- ✅ `cr7bb_recordtypechoice` - Record categorization
- ✅ `cr7bb_sendstatuschoice` - Send status tracking
- ✅ `cr7bb_statuschoice` - General status
- ✅ `cr7bb_transactiontypechoice` - Transaction categorization (CN/DN)
- ✅ `nc_regionchoice` - Geographic regions

### 🔐 Environment Variables (5 Total)
- ✅ `nc_EmailMode` - Production/test mode toggle
- ✅ `nc_PACurrentEnvironmentMode` - Power Automate environment setting
- ✅ `nc_PATestNotificationEmail` - Test notification recipient
- ✅ `nc_SystemNotificationEmail` - System notification recipient
- ✅ `nc_TestCustomerEmail` - Test customer email

---

## 📋 Pre-Import Checklist

Before importing, ensure you have:

### 1. Dataverse Tables Created
- ✅ `cr7bb_thfinancecashcollectioncustomers`
- ✅ `cr7bb_thfinancecashcollectiontransactions`
- ✅ `cr7bb_thfinancecashcollectionprocesslogs`
- ✅ `cr7bb_thfinancecashcollectionemaillogs`

### 2. SharePoint Folder Structure
- ✅ `/Shared Documents/Cash Customer Collection/01-Daily-SAP-Data/Current`
- ✅ `/Shared Documents/Cash Customer Collection/03-QR-Codes/`

### 3. Sample Data
- ✅ Excel file with SAP transaction data in `/01-Daily-SAP-Data/Current`
- ✅ QR code images in `/03-QR-Codes/` (filename = customer_code.jpg)

### 4. Test Customers in Dataverse
- ✅ At least 1-2 customer records with valid email addresses

---

## 🚀 Import Steps

### Step 1: Go to Power Platform Admin Center

1. Navigate to [https://make.powerapps.com](https://make.powerapps.com)
2. Select your environment
3. Click **Solutions** in left navigation

### Step 2: Import Solution

1. Click **Import solution**
2. Click **Browse**
3. Select: `THFinanceCashCollection_1_0_0_10 (folder)`
4. Click **Next**

### Step 3: Review Solution Details

You'll see:
- **Name**: THFinanceCashCollection
- **Version**: 1.0.0.10
- **Publisher**: NickChamnong
- **Components**: 11 workflows, 8 tables, 7 choice options, 1 canvas app, 5 environment variables

Click **Next**

### Step 4: Configure Connections

Power Platform will ask you to map connection references:

#### Required Connections:

**For SAP Import Flow:**
1. **SharePoint** → Select your existing SharePoint connection
2. **Microsoft Dataverse** → Select your existing Dataverse connection
3. **Excel Online (Business)** → Select your existing Excel connection
4. **Office 365 Outlook** → Select your existing Outlook connection

**For Email Engine Flow:**
1. **Microsoft Dataverse** → Same as above
2. **SharePoint** → Same as above
3. **Office 365 Users** → Select your existing Office 365 Users connection
4. **Office 365 Outlook** → Same as above

**If you don't have connections**, create them:
- Click **+ New connection**
- Search for the connector
- Click **Create**
- Authenticate with your account
- Return to import and select the new connection

### Step 5: Import

1. Verify all connections are mapped
2. Click **Import**
3. Wait 2-5 minutes for import to complete
4. You'll see "Solution imported successfully" ✅

---

## ⚙️ Post-Import Configuration

### Step 1: Verify Flows Imported

1. Go to **Flows** (left navigation)
2. You should see:
   - `[THFinanceCashCollection] Daily SAP Transaction Import`
   - `[THFinanceCashCollection] Daily Collections Email Engine`
3. Both should show **Off** status initially

### Step 2: Update Email Addresses

**Both flows currently send emails to**: `Nick.Chamnong@th.nestle.com`

**To change**:
1. Open each flow in **Edit** mode
2. Find "Send Summary Email" actions
3. Update "To" field to your AR team email

### Step 3: Verify SharePoint Paths

The flows are configured for:
- **SharePoint Site**: `https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`
- **SAP Folder**: `/Shared Documents/Cash Customer Collection/01-Daily-SAP-Data/Current`
- **QR Folder**: `/Shared Documents/Cash Customer Collection/03-QR-Codes/`

**If your paths are different**, update in flow designer:
1. Open flow → Edit
2. Find SharePoint actions
3. Update folder paths

### Step 4: Configure Excel File Reference

The SAP Import flow currently points to a specific Excel file. You need to update it:

1. Open `[THFinanceCashCollection] Daily SAP Transaction Import`
2. Find action: **List rows present in a table**
3. Change **File** to your SAP export Excel file
4. Change **Table** to your table name (usually "Table1")

**Or make it dynamic** (recommended):
- Use the "Get files" action output
- Point to the first file in the folder

### Step 5: Test Flows

#### Test SAP Import Flow:

1. Upload a small test Excel file to SharePoint (5-10 rows)
2. Open the flow
3. Click **Test** → **Manually** → **Test**
4. Monitor the run
5. Verify:
   - ✅ Transactions created in Dataverse
   - ✅ Process log created
   - ✅ Summary email received

#### Test Email Engine Flow:

**Prerequisites**: SAP Import must complete successfully first

1. Open the flow
2. Click **Test** → **Manually** → **Test**
3. Monitor the run
4. Verify:
   - ✅ Checks that SAP import completed
   - ✅ Gets transactions from Dataverse
   - ✅ Processes at least one customer
   - ✅ Sends email (check inbox)
   - ✅ Email log created
   - ✅ Transactions marked as processed

---

## 🔍 Troubleshooting

### Issue: "Connection reference not found"

**Solution**: You didn't map all required connections during import.

**Fix**:
1. Open the flow
2. Click on any action showing an error
3. Select the connection from dropdown
4. Save the flow

### Issue: "Table 'cr7bb_thfinancecashcollectioncustomers' not found"

**Solution**: Dataverse tables don't exist in your environment.

**Fix**: The tables should have been imported with the solution. Check:
1. Go to **Tables** (left navigation)
2. Search for `cr7bb_thfinancecashcollection`
3. If not found, the solution didn't import properly
4. Try re-importing or create tables manually

### Issue: "Excel file not found"

**Solution**: The flow is pointing to a specific Excel file that doesn't exist in your environment.

**Fix**: Update the Excel action as described in Post-Import Step 4

### Issue: "Customer not found" errors in process log

**Solution**: No customer records in Dataverse.

**Fix**: Add at least one customer record:
1. Go to your Model-Driven App
2. Navigate to Customers
3. Click **+ New**
4. Fill required fields (customer code, email addresses)
5. Save

### Issue: Flow runs but emails not sent

**Solution**: Check connection authentication.

**Fix**:
1. Go to **Data** → **Connections**
2. Find Office 365 Outlook connection
3. If showing error, click **Fix connection**
4. Re-authenticate

### Issue: "QR code not found" warnings

**Solution**: QR code files don't exist in SharePoint.

**Fix**:
- Upload QR code images to `/03-QR-Codes/` folder
- Filename must match customer code (e.g., `198609.jpg`)
- Or disable QR code attachment temporarily for testing

---

## 📊 Solution Composition

### Version History
| Version | Date | Updates |
|---------|------|---------|
| v1.0.0.1 | Oct 5 | Initial setup & table structure |
| v1.0.0.2 | Oct 8 | SAP import flow with business logic |
| v1.0.0.3 | Oct 8 | Complete flows + email engine |
| v1.0.0.4 | Oct 13 | Environment variables & configuration |
| **v1.0.0.10** | **Nov 14** | **Updated Canvas App with 10 screens, modern controls, Nestlé brand compliance** |

### Canvas App Improvements (v1.0.0.10)
- **scnCustomerHistory** (NEW) - Complete transaction history with date/type filtering
- **scnCalendar** (NEW) - Calendar date picker component
- **scnDashboard** - Redesigned to Customer Management view
- **scnEmailApproval** - Updated with new approval workflow
- **scnEmailMonitor** - Enhanced email log monitoring
- **Modern Control Versions**: Button@0.0.45, Text@0.0.51, GroupContainer@1.3.0
- **Nestlé Brand Compliance**: RGBA colors, Lato font, proper spacing

---

## 🧪 Test Scenarios

### Scenario 1: Simple Transaction Import

**Setup**:
- 1 customer in Dataverse (code: 198609)
- 1 Excel row with Account: 198609, Amount: 1000

**Expected**:
- 1 transaction created
- Process log shows 1 transaction processed
- Summary email sent

### Scenario 2: Exclusion Keyword

**Setup**:
- Excel row with Text field containing "Paid"

**Expected**:
- Transaction created with `cr7bb_isexcluded = true`
- Email engine skips this transaction

### Scenario 3: FIFO Email Sending

**Setup**:
- 1 customer with 2 DN (1000, 2000) and 1 CN (-500)
- Net amount = 2500

**Expected**:
- Email sent to customer
- Email shows all 2 DN transactions
- Total amount: 2,500 THB

### Scenario 4: Template Selection

**Setup**:
- Transaction with daycount = 1 → Template A
- Transaction with daycount = 3 → Template B
- Transaction with daycount = 5 → Template C

**Expected**:
- Correct email template selected
- Template B shows cash discount warning
- Template C shows late fee notice

---

## 📊 Monitoring

### Daily Checklist:

**Morning (8:00 AM)**:
1. Check SAP Import flow run history
2. Verify process log in Dataverse
3. Check summary email

**Mid-morning (8:30 AM)**:
1. Check Email Engine flow run history
2. Verify email logs in Dataverse
3. Spot-check customer received emails

### Weekly Tasks:

- Review error rates
- Check for failed emails
- Validate QR code availability
- Review excluded transactions

---

## 🔄 Updating the Flows

If you need to modify the flows:

1. **Minor changes** (email addresses, thresholds):
   - Edit directly in Power Automate designer
   - Test and save

2. **Major changes** (new business logic):
   - Create a new solution version
   - Export with new version number
   - Import as upgrade

---

## 📞 Support

**Technical Issues**: Check flow run history for detailed error messages

**Business Logic Questions**: Review documentation:
- [PowerAutomate_SAP_Data_Import_Flow.md](../PowerAutomate_SAP_Data_Import_Flow.md)
- [PowerAutomate_Collections_Email_Engine.md](../PowerAutomate_Collections_Email_Engine.md)

---

## ✅ Success Criteria

The solution is working correctly when:

1. ✅ SAP Import runs daily at 8:00 AM automatically
2. ✅ Transactions are created in Dataverse
3. ✅ Email Engine runs at 8:30 AM automatically
4. ✅ Customers receive payment reminder emails
5. ✅ Email logs are created for audit trail
6. ✅ AR team receives summary emails
7. ✅ No critical errors in process logs

---

## 📝 Notes & Known Issues

### Important Configuration
- **Email Recipients**: Update from `Nick.Chamnong@th.nestle.com` to your AR team distribution list
- **SharePoint Site**: Ensure path matches your environment (`https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions`)
- **Environment Variables**: Configure test email addresses before running in production

### Known Limitations
- QR codes are optional (process continues if not found)
- Manual SAP upload overrides scheduled import
- Email templates are in English (ready for localization)

### Recommended Post-Import Tasks
1. **Configure SharePoint folders** - Map to your document locations
2. **Set up scheduled flows** - Configure daily triggers
3. **Test with sample data** - 5-10 customer records recommended
4. **Update branding** - Customize email templates if needed
5. **Role setup** - Assign users to AR team role

---

**Solution Version**: 1.0.0.10
**Last Updated**: November 14, 2025
**Package File**: THFinanceCashCollection_1_0_0_10 (folder)
**Status**: ✅ Ready for Import
**Size**: 4.0 MB (Canvas App + 6 Flows + Dataverse Tables + Configuration)

**Good luck with your import! 🚀**
