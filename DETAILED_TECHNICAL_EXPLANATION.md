# Detailed Technical Explanation - v1.0.0.5

**Purpose**: Answer key technical questions about system implementation
**Date**: November 14, 2025

---

## ❓ Question 1: How Do We Calculate Days Late?

### The Answer: `cr7bb_daycount` Field

The system uses a **pre-calculated field** in the transaction record, not a real-time calculation.

### How It Works

#### Step 1: Field in Dataverse (cr7bb_daycount)
```
Transaction Table: cr7bb_thfinancecashcollectiontransaction

Field: cr7bb_daycount
Type: Whole Number (integer)
Purpose: Store days between Today and Document Date
Example: If invoice is from 5 days ago, value = 5
```

#### Step 2: When Is It Calculated?

**During SAP Import (8:00 AM)**:
```
For each transaction row from Excel:
  DocDate = Extract from Excel (e.g., "2025-11-09")
  ProcessDate = Today (e.g., "2025-11-14")
  daycount = ProcessDate - DocDate

  Formula: TODAY() - DocDate = number of days

  Example:
    DocDate: 2025-11-09
    Today:   2025-11-14
    Diff:    5 days

    cr7bb_daycount = 5
```

#### Step 3: During Email Engine (8:30 AM)

The Email Engine reads the **pre-calculated** daycount:
```
1. Get all transactions for customer
2. For each transaction: Read cr7bb_daycount field
3. Find MAX daycount among all DN transactions
   varMaxDayCount = MAX(cr7bb_daycount values)

   Example:
     Transaction 1: daycount = 2 days
     Transaction 2: daycount = 5 days
     Transaction 3: daycount = 1 day

     varMaxDayCount = 5 (the maximum)

4. Use varMaxDayCount for template selection:
     If 5 ≤ 2: Template A
     If 5 = 3: Template B
     If 5 ≥ 4: Template C ✓ (selected)
```

### Key Points

✅ **Not real-time calculation**:
- Calculated ONCE when transaction imported
- Value stored in database
- Doesn't change throughout the day
- Same value used in all 10 customers processed

✅ **Timezone safe**:
- Uses TODAY() in SE Asia timezone (UTC+7)
- Consistent across all processing
- No timezone conversion issues

✅ **Example Timeline**:
```
Nov 9  (Invoice Date)     → DocDate = "2025-11-09"
Nov 10-13 (Weekend)       → daycount stays at 4, 5, 6 days
Nov 14 (Today, 8:00 AM)   → SAP Import calculates daycount = 5
Nov 14 (Today, 8:30 AM)   → Email Engine reads daycount = 5
```

### Where It's Stored

```
Database Field:
  Table: cr7bb_thfinancecashcollectiontransaction
  Field: cr7bb_daycount
  Value: Integer (0, 1, 2, 3, 4, 5, ... 365)

Visible in Canvas App:
  scnTransactions: Shows daycount column
  scnCustomerHistory: Shows invoice age
  scnEmailMonitor: Shows daycount in email log
```

### Formula Used in SAP Import

```powerfx
// In Dataverse
cr7bb_daycount = DaysValue(ProcessDate) - DaysValue(DocumentDate)

// In Power Automate
daycount = subtractFromTime(Today(), DocumentDate, 'Day')

// In Power Apps
daycount = DateDiff(DocumentDate, Today(), TimeUnit.Days)
```

---

## ❓ Question 2: How Do Email Templates Work?

### The Answer: Decision Logic + HTML Composition

The system doesn't have separate "template files" - instead it:
1. **Decides** which template to use (logic)
2. **Composes** HTML email with appropriate content (dynamic)

### Template Selection Decision Logic

#### Step 1: Decision Point
```
When: Customer has outstanding DNs
Where: In Email Engine flow
How: Compare varMaxDayCount to thresholds

Logic:
  IF varMaxDayCount ≤ 2 THEN
    templateType = "Template_A"
  ELSE IF varMaxDayCount = 3 THEN
    templateType = "Template_B"
  ELSE IF varMaxDayCount ≥ 4 THEN
    templateType = "Template_C"
  END IF
```

#### Step 2: Template Selection in Flow

```json
{
  "Compose_Template_Selection": {
    "inputs": "@if(lessOrEquals(outputs('Compose_Max_DayCount'), 2),
                   'Template_A',
                   if(equals(outputs('Compose_Max_DayCount'), 3),
                      'Template_B',
                      'Template_C'))"
  }
}
```

**Actual Flow Logic**:
```
varMaxDayCount ≤ 2  →  Output = 'Template_A'
varMaxDayCount = 3  →  Output = 'Template_B'
varMaxDayCount ≥ 4  →  Output = 'Template_C'
```

#### Step 3: Template Mapping

The selected template name is converted to a choice field value:
```
Template_A = 676180000 (choice value in Dataverse)
Template_B = 676180001 (choice value in Dataverse)
Template_C = 676180002 (choice value in Dataverse)
```

### Template Composition (HTML)

After deciding WHICH template, the system **dynamically composes HTML**:

#### Template A (Standard - Days 1-2)
```html
<html>
  <body style="font-family: Arial, sans-serif;">
    <p>เรียน คุณ {CustomerName}</p>

    <p>ตามที่บริษัทได้ตรวจสอบยอดค้างชำระพบว่า
       ณ วันที่ {Today} ท่านมียอดค้างชำระดังนี้</p>

    <!-- Transaction Table -->
    <table border="1">
      <thead style="background-color: #0078d4; color: white;">
        <tr>
          <th>เลขที่เอกสาร</th>
          <th>วันที่</th>
          <th>จำนวนเงิน</th>
        </tr>
      </thead>
      <tbody>
        <!-- Rows: {DocNumber}, {DocDate}, {Amount} บาท -->
      </tbody>
    </table>

    <p><strong>รวมยอดค้างชำระทั้งสิ้น: {NetAmount} บาท</strong></p>

    <p>กรุณาชำระเงินผ่านบัญชีธนาคาร...</p>

    <p>ขอบคุณค่ะ</p>
  </body>
</html>
```

#### Template B (Day 3 - Discount Warning)
```html
<!-- Same as Template A, plus: -->

<p style="color: #D83B01; font-weight: bold;">
  ⚠️ หมายเหตุ: หากไม่ชำระภายในวันที่ {Tomorrow}
  ท่านจะสูญเสียสิทธิ์ส่วนลด Cash Discount
</p>
```

#### Template C (Day 4+ - Late Fee Warning)
```html
<!-- Same as Template A, plus: -->

<p style="color: #A4262C; font-weight: bold;">
  ⚠️ การชำระล่าช้า: ท่านจะถูกเรียกเก็บค่า MI
  กรุณาติดต่อ AR ทันที
</p>
```

### Step-by-Step Email Composition Process

```
1. Decide Template Type
   ↓
   (Based on varMaxDayCount)

2. Get Customer Details
   ↓
   (Name, email, AR rep)

3. Get Transactions for Customer
   ↓
   (Filtered from Dataverse)

4. Build Transaction Table Rows
   ↓
   (Create HTML table: DocNumber | Date | Amount บาท)

5. Calculate Net Amount
   ↓
   (Sum DN - Sum CN = {NetAmount} บาท)

6. Get Template-Specific Content
   ↓
   If Template A: Just standard message
   If Template B: Add discount deadline warning
   If Template C: Add late fee warning

7. Compose Full HTML Email
   ↓
   (Header + Table + Total + Warning + Footer)

8. Send via Outlook
```

### Where Templates Are Defined

**NOT in separate files** - Instead:
1. **Logic** in Email Engine flow (if/else statements)
2. **HTML** in "Compose_Email_Body" action (dynamic text)
3. **Choice values** in Dataverse (676180000, 676180001, 676180002)
4. **Names** in Canvas App (Display Names like "Template A")

### Example: Dynamic Content Insertion

```html
<!-- Compose action creates this: -->

Subject:
  @if(equals(outputs('Compose_Template_Selection'), 'Template_A'),
    'Payment Reminder - {CustomerName}',
    if(equals(outputs('Compose_Template_Selection'), 'Template_B'),
      'Payment Reminder - Urgent {CustomerName}',
      'URGENT: Outstanding Payment {CustomerName}'))

Body:
  <html>...
    <p>เรียน คุณ @{outputs('Get_Customer')?['body/cr7bb_customername']}</p>
    ...
    <p><strong>@{formatNumber(outputs('Compose_Net_Amount'), '#,##0.00')} บาท</strong></p>
    ...
    @{if(equals(outputs('Compose_Template_Selection'), 'Template_B'),
      '<p>⚠️ หมายเหตุ: หากไม่ชำระ...</p>', '')}
    ...
  </html>
```

---

## ❓ Question 3: How Is QR Image Inserted in Email Layout?

### The Answer: CURRENTLY NOT USED (Per Your Decision)

Based on your clarification **"just don't show it"**, QR codes are **NOT** inserted.

However, let me explain how it WAS structured (for reference):

### Previous QR Code Logic (Now Removed)

#### Step 1: Get QR Code File
```
Location: SharePoint
Path: /Shared Documents/Cash Customer Collection/03-QR-Codes/
Filename: {CustomerCode}.jpg
Example: 198609.jpg

Flow Action: Get files (properties only)
Input: CustomerCode from customer record
Output: File metadata (name, size, URL)
```

#### Step 2: Check If File Exists
```
IF FileFound = true THEN
  varQRCodePath = {FileURL}
  varQRCodeIncluded = true
ELSE
  varQRCodeIncluded = false
  // Continue without QR
END IF
```

#### Step 3: Email HTML Composition (Old Way)
```html
<!-- If QR found: -->
<img src="{QRCodeURL}"
     alt="PromptPay QR Code"
     width="200"
     height="200" />

<!-- If QR not found: -->
<!-- Just text instructions, no image -->
```

### Current Implementation (After Your Decision)

```
✗ Don't retrieve QR from SharePoint
✗ Don't include image in HTML
✗ Don't show attachment
✓ Use text-based payment instructions only
```

**New Email Body**:
```html
<p>กรุณาชำระเงินผ่านบัญชี:</p>

<p>
  ธนาคาร: กสิกรไทย<br/>
  บัญชี: 123-4567890<br/>
  ชื่อบัญชี: บจก. เนสเล่ (ประเทศไทย)<br/>
  PromptPay: 1234567890<br/>
</p>

<p>ขอบคุณค่ะ</p>
```

### Why Previous Method Was Problematic

1. **Slow**: File lookup adds 2-3 seconds per email
2. **Complex**: Multiple SharePoint API calls
3. **Fragile**: Breaks if file missing
4. **Storage**: Requires maintaining 100+ QR files
5. **Email Size**: Increases email size significantly

### Your Decision Is Better Because

✅ **Faster**: No file retrieval delays
✅ **Simpler**: Text-only, no file logic needed
✅ **Reliable**: Works even if SharePoint down
✅ **Cleaner**: Email focuses on transaction data
✅ **Modern**: Banking customers have own QR in app anyway

---

## ❓ Question 4: Is There a System That Checks QR Images for Each Client?

### The Answer: NO - Not Implemented

There is **NO system** that automatically checks QR code availability.

### What Would Be Needed (For Reference)

If we WERE to check QR codes, it would look like:

#### Option 1: Pre-Check (Before Email Sending)
```
1. Get Customer List
2. For each customer:
   - Check SharePoint: /03-QR-Codes/{CustomerCode}.jpg
   - If missing: Flag in dashboard
   - Alert: "QR code missing for customer 198609"
3. Generate report
```

#### Option 2: Log What Was Checked
```
Email Log Fields:
  - cr7bb_qrcodeincluded: true/false (was it found?)
  - cr7bb_qrfilelocation: "path/to/file"
  - cr7bb_qrcheckstatus: "found" / "not_found"
```

#### Option 3: Dashboard Alert
```
Canvas App: scnEmailMonitor
Column: QR Attached (Yes/No)
Filter: Show only "No" to highlight missing
Alert: "12 customers missing QR codes"
```

### Current Situation (After Your Decision)

```
✗ No QR retrieval
✗ No QR checking
✗ No QR alerts
✗ No QR reporting

This simplifies everything!
Emails send with text instructions only.
```

### If You Ever Need QR Checking Later

The system structure allows adding it back:
1. Create a separate flow: "Check QR Code Availability"
2. Run daily, list all customers
3. Check /03-QR-Codes/ folder
4. Report missing files
5. Store results in process log

---

## 📊 Summary Table

| Question | Implementation | Status |
|----------|-----------------|--------|
| **Days Late Calculation** | Stored in `cr7bb_daycount` field | ✅ Implemented |
| | Calculated during SAP Import (8 AM) | ✅ Running |
| | Updated from PreCalculated value | ✅ Working |
| **Email Templates** | Decision logic in flow (if/else) | ✅ Implemented |
| | Dynamic HTML composition | ✅ Implemented |
| | 3 template types (A, B, C) | ✅ Implemented |
| | Choice field mapping | ✅ Implemented |
| **QR Images in Email** | REMOVED per your decision | ✅ Cleaned up |
| | Text-based instructions instead | ✅ Simplified |
| **QR Availability Check** | NOT implemented | ✅ Correct (not needed) |
| | No daily QR checking system | ✅ Simplified |

---

## 🎯 Key Takeaways

### 1. Days Late Calculation
- **Pre-calculated** during SAP import
- **Stored** in transaction record
- **Used** for template selection
- **Not real-time** (set once, doesn't change)

### 2. Email Templates
- **Not separate files** (logic + dynamic HTML)
- **Selected** based on max invoice age
- **Composed** dynamically per customer
- **Customized** with warnings based on template type

### 3. QR in Emails
- **Previously** retrieved from SharePoint
- **Now** NOT retrieved (your decision)
- **Simplified** to text-only instructions
- **Faster** email sending process

### 4. QR Checking System
- **Not implemented** at all
- **Not needed** for your use case
- **Can be added later** if required
- **System designed for flexibility**

---

## 🔍 Technical Files References

If you want to see the actual code:

1. **Day Count Calculation**:
   - File: `Workflows/THFinanceCashCollectionDailySAPTransactionImport-*.json`
   - Look for: `cr7bb_daycount` field assignment

2. **Template Selection**:
   - File: `Workflows/THFinanceCashCollectionDailyCollectionsEmailEngine-*.json`
   - Look for: `Compose_Template_Selection` action

3. **Email Composition**:
   - Same file as above
   - Look for: `Compose_Email_Body` action

4. **QR Logic (Removed)**:
   - Previously: `Get_files_(properties_only)` action
   - Now: DELETED per your decision

---

**Status**: ✅ **All technical questions explained**

Any other technical details you'd like me to clarify?
