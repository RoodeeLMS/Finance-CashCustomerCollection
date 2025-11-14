# Power Automate Flow Modifications Guide
## Step-by-Step Instructions to Complete Your Flows

**Current Status**: You have flow skeletons with authenticated connections ✅
**Next Step**: Add business logic by modifying the JSON files

---

## Important Note About Flow JSON Editing

**Power Automate flows are complex JSON structures**. Rather than manually editing JSON (error-prone), I recommend these approaches:

### **Recommended Approach: Build in Designer** ⭐

Instead of JSON editing, let's use the Power Automate Designer to add the business logic step-by-step:

1. Open your existing flows in the designer
2. Add actions following the detailed specifications below
3. Save and test incrementally

This is **safer and faster** than JSON manipulation.

---

## Flow 1: SAP Transaction Import - Complete Action List

### Current Actions (Your Skeleton):
✅ Recurrence trigger
✅ Get files (SharePoint)
✅ List rows (Customers)
✅ List rows (Transactions)
✅ List rows (Process Logs)
✅ List rows present in a table (Excel)
✅ Send an email

### Actions to ADD in Designer:

#### 1. Initialize Variables (After Trigger, Before Get Files)

**Add 8 Initialize Variable actions:**

```
Variable 1:
Name: varProcessDate
Type: String
Value: formatDateTime(utcNow(), 'yyyy-MM-dd')

Variable 2:
Name: varBatchID
Type: String
Value: formatDateTime(utcNow(), 'yyyyMMdd_HHmmss')

Variable 3:
Name: varRowCounter
Type: Integer
Value: 0

Variable 4:
Name: varErrorCount
Type: Integer
Value: 0

Variable 5:
Name: varTransactionCount
Type: Integer
Value: 0

Variable 6:
Name: varProcessLogID
Type: String
Value: (leave empty)

Variable 7:
Name: varErrorMessages
Type: Array
Value: []

Variable 8:
Name: varFileName
Type: String
Value: (leave empty)
```

#### 2. Modify "Get files" Action

**Current**: Gets all files
**Change to**: Filter for latest file

```yaml
Filter Query: Modified ge '@{addDays(utcNow(), -1)}'
Order by: Modified descending
Top Count: 1
```

#### 3. Add "Set variable - varFileName" (After Get Files)

```yaml
Action: Set variable
Name: varFileName
Value: @{first(outputs('Get_files_(properties_only)')?['body/value'])?['DisplayName']}
```

#### 4. Replace "List rows (Process Logs)" with "Add a new row"

**Delete**: Current "List rows" for Process Logs
**Add**: Create a new row

```yaml
Action: Add a new row
Table: cr7bb_thfinancecashcollectionprocesslogs
Fields:
  cr7bb_processdate: @{variables('varProcessDate')}
  cr7bb_starttime: @{utcNow()}
  cr7bb_status: Running
  cr7bb_sapfilename: @{variables('varFileName')}
  cr7bb_processedby: @{workflow()?['tags']['xms-workflow-run-id']}
  cr7bb_totalcustomers: 0
  cr7bb_emailssent: 0
  cr7bb_emailsfailed: 0
  cr7bb_transactionsprocessed: 0
  cr7bb_transactionsexcluded: 0
```

**Then add**: Set variable for varProcessLogID

```yaml
Action: Set variable
Name: varProcessLogID
Value: @{outputs('Add_process_log')?['cr7bb_thfinancecashcollectionprocesslogid']}
```

#### 5. Modify "List rows present in a table" (Excel)

**Change**: Point to the actual SAP data file (not customer master)

```yaml
File: [Browse to your SAP export file in SharePoint]
Table: [Select the table in the SAP export Excel file]
```

**Or keep it dynamic** by using first file from Get Files:

```yaml
Action: Get file content (SharePoint)
Site Address: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions
File Identifier: @{first(outputs('Get_files_(properties_only)')?['body/value'])?['Id']}
```

Then use Excel connector to parse it.

#### 6. Add "Apply to each" Loop (After Excel List Rows)

```yaml
Action: Apply to each
Select output: @{outputs('List_rows_present_in_a_table')?['body/value']}

Inside loop:
  - Increment varRowCounter
  - Determine Record Type (Condition)
  - If Transaction:
      - Lookup Customer
      - Check Exclusions
      - Create Transaction Record
      - Increment varTransactionCount
  - If Summary:
      - Store for validation
```

**Detailed loop structure in next section...**

---

## Detailed Loop Structure for SAP Import

### Step 6a: Increment Row Counter

```yaml
Action: Increment variable
Name: varRowCounter
Value: 1
```

### Step 6b: Determine Record Type

```yaml
Action: Condition
Condition: empty(item()?['Document Number'])
If yes (Summary row):
  - Compose: {"type": "Summary", "account": "@{item()?['Account']}", "amount": "@{item()?['Amount in Local Currency']}"}
  - Append to array (for validation later)

If no (Transaction row):
  - Continue to next step (Customer Lookup)
```

### Step 6c: Customer Lookup (Inside "If no" branch)

```yaml
Action: List rows (Dataverse)
Table: cr7bb_thfinancecashcollectioncustomers
Filter rows: cr7bb_customercode eq '@{item()?['Account']}'
Row count: 1
```

### Step 6d: Check if Customer Found

```yaml
Action: Condition
Condition: length(outputs('List_customer')?['value']) equals 0

If yes (Customer not found):
  - Append to varErrorMessages: "Row @{variables('varRowCounter')}: Customer @{item()?['Account']} not found"
  - Increment varErrorCount

If no (Customer found):
  - Continue to Create Transaction
```

### Step 6e: Check Exclusion Keywords (Inside "Customer found" branch)

```yaml
Action: Condition
Condition:
  @or(
    contains(toLower(item()?['Text']), 'paid'),
    contains(toLower(item()?['Text']), 'partial payment'),
    contains(toLower(item()?['Text']), 'exclude'),
    contains(item()?['Text'], 'รักษาตลาด'),
    contains(toLower(item()?['Text']), 'bill credit 30 days')
  )

Result: Set variable varIsExcluded (true/false)
```

### Step 6f: Create Transaction Record

```yaml
Action: Add a new row
Table: cr7bb_thfinancecashcollectiontransactions
Fields:
  _cr7bb_customer_value: @{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}
  cr7bb_recordtype: Transaction
  cr7bb_documentnumber: @{item()?['Document Number']}
  cr7bb_assignment: @{item()?['Assignment']}
  cr7bb_documenttype: @{item()?['Document Type']}
  cr7bb_documentdate: @{formatDateTime(item()?['Document Date'], 'yyyy-MM-dd')}
  cr7bb_netduedate: @{formatDateTime(item()?['Net Due Date'], 'yyyy-MM-dd')}
  cr7bb_arrearsdays: @{int(item()?['Arrears by Net Due Date'])}
  cr7bb_amountlocalcurrency: @{float(replace(replace(item()?['Amount in Local Currency'], ',', ''), '"', ''))}
  cr7bb_textfield: @{item()?['Text']}
  cr7bb_reference: @{item()?['Reference']}
  cr7bb_transactiontype: @{if(less(float(item()?['Amount in Local Currency']), 0), 'CN', 'DN')}
  cr7bb_isexcluded: @{variables('varIsExcluded')}
  cr7bb_excludereason: @{if(variables('varIsExcluded'), 'Keyword found', null)}
  cr7bb_daycount: @{int(item()?['Arrears by Net Due Date'])}
  cr7bb_processdate: @{variables('varProcessDate')}
  cr7bb_processbatch: @{variables('varBatchID')}
  cr7bb_rownumber: @{variables('varRowCounter')}
  cr7bb_isprocessed: false
  cr7bb_emailsent: false

Configure run after: (handle errors)
  - Add parallel action: Append error to varErrorMessages if failed
```

#### 7. Update Process Log (After Loop)

**Delete**: Current "Send an email" test action
**Add**: Update the process log

```yaml
Action: Update a row
Table: cr7bb_thfinancecashcollectionprocesslogs
Row ID: @{variables('varProcessLogID')}
Fields:
  cr7bb_endtime: @{utcNow()}
  cr7bb_status: @{if(greater(variables('varErrorCount'), 0), 'Completed with errors', 'Completed')}
  cr7bb_totalcustomers: [Calculate unique customer count]
  cr7bb_transactionsprocessed: @{variables('varTransactionCount')}
  cr7bb_errormessages: @{join(variables('varErrorMessages'), '; ')}
```

#### 8. Send Summary Email (After Update)

```yaml
Action: Send an email (V2)
To: [AR team email]
Subject: SAP Import - @{variables('varProcessDate')} - @{if(greater(variables('varErrorCount'), 0), '⚠️ Errors', '✅ Success')}
Body:
  <h2>SAP Import Summary</h2>
  <p>File: @{variables('varFileName')}</p>
  <p>Transactions: @{variables('varTransactionCount')}</p>
  <p>Errors: @{variables('varErrorCount')}</p>
  @{if(greater(variables('varErrorCount'), 0), concat('<h3>Errors:</h3><ul>', join(map(variables('varErrorMessages'), concat('<li>', item(), '</li>')), ''), '</ul>'), '')}
Importance: @{if(greater(variables('varErrorCount'), 0), 'High', 'Normal')}
```

---

## Flow 2: Email Engine - Complete Action List

### Current Actions (Your Skeleton):
✅ Recurrence trigger
✅ List rows (Transactions)
✅ List rows (Customers)
✅ List rows (Process Logs)
✅ Add a new row (Email Logs)
✅ Get file content (QR Code)
✅ Get user profile

### Actions to ADD:

#### 1. Initialize Variables (After Trigger)

```yaml
Variable 1: varProcessDate (String) = formatDateTime(utcNow(), 'yyyy-MM-dd')
Variable 2: varEmailsSent (Integer) = 0
Variable 3: varEmailsFailed (Integer) = 0
Variable 4: varCustomersProcessed (Integer) = 0
Variable 5: varErrorMessages (Array) = []
```

#### 2. Modify "List rows (Process Logs)"

**Add filter** to get today's completed import:

```yaml
Filter rows: cr7bb_processdate eq '@{variables('varProcessDate')}' and cr7bb_status eq 'Completed'
Order by: cr7bb_endtime desc
Row count: 1
```

#### 3. Add Validation Check (After List Process Logs)

```yaml
Action: Condition
Condition: length(outputs('List_process_logs')?['value']) equals 0

If yes (Import not completed):
  - Send error email to AR team
  - Terminate flow with Failed status

If no:
  - Continue to Get Transactions
```

#### 4. Modify "List rows (Transactions)"

**Add filter** for today's unprocessed transactions:

```yaml
Filter rows: cr7bb_processdate eq '@{variables('varProcessDate')}' and cr7bb_recordtype eq 'Transaction' and cr7bb_emailsent eq false
Select columns: cr7bb_thfinancecashcollectiontransactionid,_cr7bb_customer_value,cr7bb_documentnumber,cr7bb_documentdate,cr7bb_amountlocalcurrency,cr7bb_daycount,cr7bb_isexcluded,cr7bb_transactiontype,cr7bb_netduedate,cr7bb_documenttype
Row count: 5000
```

#### 5. Get Unique Customers (After List Transactions)

```yaml
Action: Select
From: @{outputs('List_transactions')?['value']}
Map: @{item()?['_cr7bb_customer_value']}

Then: Compose (deduplicate)
Inputs: @{union(outputs('Select'), outputs('Select'))}
```

#### 6. Add "Apply to each Customer" Loop

```yaml
Action: Apply to each
Select: @{outputs('Unique_customers')}
Concurrency: 1 (sequential processing)

Inside loop:
  - Get customer record
  - Filter transactions for this customer
  - Check if all excluded → Skip
  - Separate CN and DN
  - Sort by date (FIFO)
  - Calculate totals
  - If owes money → Send email
  - Log email record
```

**Detailed loop in next section...**

---

## Detailed Loop Structure for Email Engine

### Step 6a: Get Customer Record

```yaml
Action: Get a row by ID (Dataverse)
Table: cr7bb_thfinancecashcollectioncustomers
Row ID: @{item()}
```

### Step 6b: Filter Transactions for Customer

```yaml
Action: Filter array
From: @{outputs('List_transactions')?['value']}
Where: _cr7bb_customer_value eq '@{item()}'
```

### Step 6c: Check All Excluded

```yaml
Action: Filter array (Get non-excluded)
From: @{outputs('Customer_transactions')}
Where: cr7bb_isexcluded eq false

Action: Condition
Condition: length(outputs('Non_excluded_transactions')) equals 0
If yes: Continue to next customer (Skip action)
If no: Continue processing
```

### Step 6d: Separate CN and DN

```yaml
Action: Filter array (CN List)
From: @{outputs('Non_excluded_transactions')}
Where: less(cr7bb_amountlocalcurrency, 0)

Action: Filter array (DN List)
From: @{outputs('Non_excluded_transactions')}
Where: greater(cr7bb_amountlocalcurrency, 0)
```

### Step 6e: Calculate Totals

```yaml
Action: Compose (CN Total)
Inputs: @{sum(outputs('CN_list'), 'cr7bb_amountlocalcurrency')}

Action: Compose (DN Total)
Inputs: @{sum(outputs('DN_list'), 'cr7bb_amountlocalcurrency')}

Action: Compose (Net Amount)
Inputs: @{add(outputs('DN_total'), outputs('CN_total'))}
```

### Step 6f: Check if Should Send

```yaml
Action: Condition
Condition:
  @and(
    greater(length(outputs('DN_list')), 0),
    greater(outputs('Net_amount'), 0)
  )

If yes: Continue to email sending
If no: Skip customer
```

### Step 6g: Calculate Max Day Count

```yaml
Action: Compose
Inputs: @{max(map(outputs('DN_list'), item()?['cr7bb_daycount']))}
```

### Step 6h: Select Email Template

```yaml
Action: Compose
Inputs:
  @{if(
    lessOrEquals(outputs('Max_daycount'), 2),
    'Template_A',
    if(
      equals(outputs('Max_daycount'), 3),
      'Template_B',
      'Template_C'
    )
  )}

Check for MI documents and override if found
```

### Step 6i: Build Email HTML (Create 4 Compose actions for each template)

**This is complex - see detailed HTML templates in documentation**

### Step 6j: Get QR Code File

**Modify**: Current "Get file content" to be dynamic

```yaml
Action: Get file content
Site: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions
File: /Shared Documents/Cash Customer Collection/03-QR-Codes/@{outputs('Get_customer')?['cr7bb_customercode']}.jpg

Configure run after: Allow to continue on failure
```

### Step 6k: Get AR Representative

**Modify**: Current "Get user profile" to use customer's AR email

```yaml
Action: Get user profile (V2)
User (UPN): @{outputs('Get_customer')?['cr7bb_arbackupemail1']}
```

### Step 6l: Send Email with Attachment

```yaml
Action: Send an email (V2)
To: Filter and join customer emails
CC: Filter and join sales + AR emails
Subject: @{outputs('Email_subject')}
Body: @{outputs('Email_body_HTML')}
Attachments:
  Name: @{outputs('Get_customer')?['cr7bb_customercode']}_QRCode.jpg
  Content: @{body('Get_QR_code')}
Importance: @{if(greaterOrEquals(outputs('Max_daycount'), 3), 'High', 'Normal')}

Configure run after: Track success/failure
```

### Step 6m: Create Email Log

**Modify**: Current "Add a new row" for email logs

```yaml
Action: Add a new row
Table: cr7bb_thfinancecashcollectionemaillogs
Fields:
  _cr7bb_customer_value: @{outputs('Get_customer')?['cr7bb_thfinancecashcollectioncustomerid']}
  cr7bb_processdate: @{variables('varProcessDate')}
  cr7bb_emailsubject: @{outputs('Email_subject')}
  cr7bb_emailtemplate: @{outputs('Template_selection')}
  cr7bb_maxdaycount: @{outputs('Max_daycount')}
  cr7bb_totalamount: @{outputs('Net_amount')}
  cr7bb_transactioncount: @{length(outputs('DN_list'))}
  cr7bb_recipientemails: [Joined emails]
  cr7bb_ccemails: [Joined emails]
  cr7bb_sentdatetime: @{utcNow()}
  cr7bb_sendstatus: @{if(equals(outputs('Send_email')?['statusCode'], 200), 'Success', 'Failed')}
  cr7bb_qrcodeincluded: @{not(empty(body('Get_QR_code')))}
```

### Step 6n: Update Transaction Records

```yaml
Action: Apply to each (DN Transactions)
From: @{outputs('DN_list')}

Inside:
  Action: Update a row
  Table: cr7bb_thfinancecashcollectiontransactions
  Row ID: @{item()?['cr7bb_thfinancecashcollectiontransactionid']}
  Fields:
    cr7bb_emailsent: true
    cr7bb_isprocessed: true
```

#### 7. Send Summary Email to AR Team (After Loop)

```yaml
Action: Send an email (V2)
To: [AR team]
Subject: Collections Summary - @{variables('varProcessDate')}
Body:
  <h2>Email Summary</h2>
  <p>Customers Processed: @{variables('varCustomersProcessed')}</p>
  <p>Emails Sent: @{variables('varEmailsSent')}</p>
  <p>Emails Failed: @{variables('varEmailsFailed')}</p>
```

---

## Recommended Implementation Approach

### Option 1: Build Incrementally in Designer ⭐ RECOMMENDED

1. **Week 1**: Complete SAP Import flow
   - Add variables
   - Modify Get Files
   - Create process log
   - Build Excel parsing loop
   - Test with small file (5-10 rows)

2. **Week 2**: Complete Email Engine flow
   - Add variables
   - Get transactions logic
   - Build customer loop (test with 1 customer first)
   - Add FIFO logic
   - Email sending
   - Test with 1-2 customers

3. **Week 3**: Testing & Refinement
   - Test with full dataset
   - Error handling
   - Performance optimization

### Option 2: I Provide Complete JSON Files

**Challenges**:
- Connection references need mapping
- Very large JSON files (hard to troubleshoot)
- One error breaks entire flow

**Better for**: Final deployment after testing individual components

---

## Next Steps - What Would You Prefer?

**Option A**: I create detailed step-by-step screenshots/guides for building each action in Designer

**Option B**: You build incrementally following this guide, I help troubleshoot

**Option C**: I provide complete JSON files for you to import (less flexible, harder to debug)

**Option D**: We do a hybrid - I provide JSON for complex expressions, you build structure in Designer

**Which approach works best for you?**

---

## Quick Win: Start with Variables

**Try this now** to validate the approach:

1. Open `[THFinanceCashCollection] Daily SAP Transaction Import` in Designer
2. Add one Initialize Variable action after the trigger:
   - Name: `varProcessDate`
   - Type: String
   - Value: `formatDateTime(utcNow(), 'yyyy-MM-dd')`
3. Save and test
4. Verify it works

If this works, we can proceed with the rest incrementally!

Let me know which option you prefer, and I'll provide the appropriate level of detail.
