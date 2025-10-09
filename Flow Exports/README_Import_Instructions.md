# Power Automate Flow Import Instructions

## Important Note About JSON Import

Power Automate flow JSON files are **extremely large and complex** (5000+ lines each). Direct JSON editing is error-prone and not recommended by Microsoft.

Instead, I'll provide you with:
1. **Critical expressions** for complex logic
2. **Step-by-step action configurations**
3. **A template approach** using your existing skeleton

---

## Recommended Approach: Build on Your Skeleton

You already have authenticated connections ✅. Now we'll add the business logic step-by-step.

---

## Flow 1: SAP Import - Action Builder Script

### Open Flow in Designer
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Open: `[THFinanceCashCollection] Daily SAP Transaction Import`
3. Click **Edit**

### Step-by-Step Actions to Add

#### STEP 1: Initialize Variables (Insert AFTER Recurrence, BEFORE Get Files)

Click **Insert a new step** → **Add an action** → Search "Initialize variable"

Add these 8 variables:

```javascript
// Variable 1
Name: varProcessDate
Type: String
Value: formatDateTime(utcNow(), 'yyyy-MM-dd')

// Variable 2
Name: varBatchID
Type: String
Value: formatDateTime(utcNow(), 'yyyyMMdd_HHmmss')

// Variable 3
Name: varRowCounter
Type: Integer
Value: 0

// Variable 4
Name: varErrorCount
Type: Integer
Value: 0

// Variable 5
Name: varTransactionCount
Type: Integer
Value: 0

// Variable 6
Name: varProcessLogID
Type: String
Value: (leave empty)

// Variable 7
Name: varErrorMessages
Type: Array
Value: []

// Variable 8
Name: varFileName
Type: String
Value: (leave empty)
```

#### STEP 2: Modify "Get files (properties only)"

Click on the action → Edit parameters:

```yaml
Folder: /Shared Documents/Cash Customer Collection/01-Daily-SAP-Data/Current
Filter Query: Modified ge '@{addDays(utcNow(), -1)}'
Order By: Modified desc
Top Count: 1
```

#### STEP 3: Add "Set varFileName" (After Get Files)

```yaml
Action: Set variable
Name: varFileName
Value: @{first(outputs('Get_files_(properties_only)')?['body/value'])?['Name']}
```

#### STEP 4: Add "Get Excel File Content" (Replace current Excel action)

**Delete**: Current "List rows present in a table"

**Add**:
```yaml
Action: Get file content
Site: https://nestle.sharepoint.com/teams/THFinancePowerPlatformSolutions
File Identifier: @{first(outputs('Get_files_(properties_only)')?['body/value'])?['Id']}
```

Then add:
```yaml
Action: Parse JSON
Content: @{body('Get_file_content')}
Schema: [Excel table schema - see below]
```

**Alternative (Simpler)**: Keep using Excel connector but make it dynamic:
```yaml
Action: List rows present in a table
Location: SharePoint Site
Document Library: [Your library]
File: [Use dynamic content from Get Files: 'Identifier']
Table: [Your table name, e.g., "Table1"]
```

#### STEP 5: Delete Dummy Actions

**Delete these test actions**:
- Current "List rows" (Customers) - we'll add proper lookup in loop
- Current "List rows" (Transactions) - not needed for import
- Current "List rows" (Process Logs) - we'll replace with Create
- Current "Send an email" - we'll add proper summary email

#### STEP 6: Add "Create Process Log" (After Set varFileName)

```yaml
Action: Add a new row
Table name: cr7bb_thfinancecashcollectionprocesslogs
Fields:
  cr7bb_processdate: @{variables('varProcessDate')}
  cr7bb_starttime: @{utcNow()}
  cr7bb_status: Running
  cr7bb_sapfilename: @{variables('varFileName')}
  cr7bb_processedby: @{workflow()?['run']?['name']}
  cr7bb_totalcustomers: 0
  cr7bb_emailssent: 0
  cr7bb_emailsfailed: 0
  cr7bb_transactionsprocessed: 0
  cr7bb_transactionsexcluded: 0
```

Then add:
```yaml
Action: Set variable
Name: varProcessLogID
Value: @{outputs('Create_process_log')?['cr7bb_thfinancecashcollectionprocesslogid']}
```

#### STEP 7: Add "Apply to Each Row" Loop

```yaml
Action: Apply to each
Select output from previous steps: @{outputs('List_rows_present_in_a_table')?['body/value']}
Concurrency Control: Off (or 1 for sequential)
```

**Inside the loop, add these actions:**

##### 7.1: Increment Row Counter
```yaml
Action: Increment variable
Name: varRowCounter
Value: 1
```

##### 7.2: Check if Summary Row (Condition)
```yaml
Action: Condition
Expression: @empty(item()?['Document Number'])
```

**If YES (Summary row)**:
```yaml
Action: Compose
Inputs: {
  "type": "summary",
  "account": "@{item()?['Account']}",
  "amount": "@{item()?['Amount in Local Currency']}"
}
```

**If NO (Transaction row)** - Continue with these actions:

##### 7.3: Lookup Customer
```yaml
Action: List rows
Table: cr7bb_thfinancecashcollectioncustomers
Filter rows: cr7bb_customercode eq '@{item()?['Account']}'
Row count: 1
```

##### 7.4: Check Customer Found
```yaml
Action: Condition
Expression: @greater(length(outputs('List_customer')?['value']), 0)
```

**If NO (Not found)**:
```yaml
Action: Append to array variable
Name: varErrorMessages
Value: Row @{variables('varRowCounter')}: Customer @{item()?['Account']} not found

Action: Increment variable
Name: varErrorCount
Value: 1
```

**If YES (Customer found)** - Continue:

##### 7.5: Check Exclusion Keywords
```yaml
Action: Compose (isExcluded check)
Inputs: @or(
  contains(toLower(coalesce(item()?['Text'], '')), 'paid'),
  contains(toLower(coalesce(item()?['Text'], '')), 'partial payment'),
  contains(toLower(coalesce(item()?['Text'], '')), 'exclude'),
  contains(coalesce(item()?['Text'], ''), 'รักษาตลาด'),
  contains(toLower(coalesce(item()?['Text'], '')), 'bill credit 30 days')
)
```

##### 7.6: Parse Amount (Handle Commas)
```yaml
Action: Compose (ParsedAmount)
Inputs: @float(replace(replace(string(item()?['Amount in Local Currency']), ',', ''), '"', ''))
```

##### 7.7: Determine Transaction Type
```yaml
Action: Compose (TransactionType)
Inputs: @if(less(outputs('ParsedAmount'), 0), 'CN', 'DN')
```

##### 7.8: Create Transaction Record
```yaml
Action: Add a new row
Table: cr7bb_thfinancecashcollectiontransactions
Fields:
  _cr7bb_customer_value: @{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}
  cr7bb_recordtype: Transaction
  cr7bb_documentnumber: @{item()?['Document Number']}
  cr7bb_assignment: @{item()?['Assignment']}
  cr7bb_documenttype: @{item()?['Document Type']}
  cr7bb_documentdate: @{item()?['Document Date']}
  cr7bb_netduedate: @{item()?['Net Due Date']}
  cr7bb_arrearsdays: @{int(coalesce(item()?['Arrears by Net Due Date'], 0))}
  cr7bb_amountlocalcurrency: @{outputs('ParsedAmount')}
  cr7bb_textfield: @{item()?['Text']}
  cr7bb_reference: @{item()?['Reference']}
  cr7bb_transactiontype: @{outputs('TransactionType')}
  cr7bb_isexcluded: @{outputs('Compose_isExcluded')}
  cr7bb_excludereason: @{if(outputs('Compose_isExcluded'), 'Keyword found in text field', null)}
  cr7bb_daycount: @{int(coalesce(item()?['Arrears by Net Due Date'], 0))}
  cr7bb_processdate: @{variables('varProcessDate')}
  cr7bb_processbatch: @{variables('varBatchID')}
  cr7bb_rownumber: @{variables('varRowCounter')}
  cr7bb_isprocessed: false
  cr7bb_emailsent: false

Configure run after: Allow to continue on error
```

**If Create fails**, add parallel action:
```yaml
Action: Append to array variable
Name: varErrorMessages
Value: Row @{variables('varRowCounter')}: Failed to create transaction - @{outputs('Create_transaction')?['error']?['message']}

Action: Increment variable
Name: varErrorCount
Value: 1
```

**If Create succeeds**:
```yaml
Action: Increment variable
Name: varTransactionCount
Value: 1
```

#### STEP 8: Update Process Log (After Loop)

```yaml
Action: Update a row
Table: cr7bb_thfinancecashcollectionprocesslogs
Row ID: @{variables('varProcessLogID')}
Fields:
  cr7bb_endtime: @{utcNow()}
  cr7bb_status: @{if(greater(variables('varErrorCount'), 0), 'Completed with errors', 'Completed')}
  cr7bb_transactionsprocessed: @{variables('varTransactionCount')}
  cr7bb_errormessages: @{join(variables('varErrorMessages'), '; ')}
```

#### STEP 9: Send Summary Email

```yaml
Action: Send an email (V2)
To: Nick.Chamnong@th.nestle.com
Subject: SAP Import @{variables('varProcessDate')} - @{if(greater(variables('varErrorCount'), 0), '⚠️ Errors', '✅ Success')}
Body: <html>
<body>
  <h2>SAP Data Import Summary</h2>
  <p><strong>Date:</strong> @{formatDateTime(utcNow(), 'dd/MM/yyyy HH:mm')}</p>
  <p><strong>File:</strong> @{variables('varFileName')}</p>
  <p><strong>Batch ID:</strong> @{variables('varBatchID')}</p>

  <h3>Statistics</h3>
  <ul>
    <li>Total Rows: @{variables('varRowCounter')}</li>
    <li>Transactions Created: @{variables('varTransactionCount')}</li>
    <li>Errors: @{variables('varErrorCount')}</li>
  </ul>

  @{if(greater(variables('varErrorCount'), 0),
    concat('<h3 style="color: red;">Errors:</h3><ul>',
      join(map(variables('varErrorMessages'), concat('<li>', item(), '</li>')), ''),
      '</ul>'),
    '')}

  <p><a href="https://make.powerapps.com">View in Power Automate</a></p>
</body>
</html>
Importance: @{if(greater(variables('varErrorCount'), 0), 'High', 'Normal')}
```

---

## Critical Expressions Reference

### Date Parsing (Excel Date Serial Numbers)
```javascript
// If Excel gives serial numbers like 45200
@formatDateTime(addDays('1900-01-01', int(item()?['Document Date'])), 'yyyy-MM-dd')

// If Excel gives text dates like "9/26/2025"
@item()?['Document Date']  // Use as-is, Dataverse will convert
```

### Amount Parsing (Handles Commas)
```javascript
@float(replace(replace(string(item()?['Amount in Local Currency']), ',', ''), '"', ''))
```

### Exclusion Check (All Keywords)
```javascript
@or(
  contains(toLower(coalesce(item()?['Text'], '')), 'paid'),
  contains(toLower(coalesce(item()?['Text'], '')), 'partial payment'),
  contains(toLower(coalesce(item()?['Text'], '')), 'exclude'),
  contains(coalesce(item()?['Text'], ''), 'รักษาตลาด'),
  contains(toLower(coalesce(item()?['Text'], '')), 'bill credit 30 days'),
  contains(toLower(coalesce(item()?['Text'], '')), 'ptp')
)
```

### Transaction Type (CN vs DN)
```javascript
@if(less(float(item()?['Amount']), 0), 'CN', 'DN')
```

---

## Save and Test

1. **Save** the flow
2. **Test** with a small Excel file (5-10 rows)
3. Check Dataverse for created records
4. Review process log
5. Check summary email

---

## Troubleshooting Tips

### Common Issues:

**Issue**: "Document Number" column not found
- **Fix**: Check Excel table column names match exactly

**Issue**: Amount parsing error
- **Fix**: Ensure Amount column is Number type in Excel

**Issue**: Date format error
- **Fix**: Use `@item()?['Document Date']` directly if Excel dates are formatted

**Issue**: Customer not found
- **Fix**: Verify `cr7bb_customercode` matches Account numbers exactly

---

## Next: Flow 2 (Email Engine)

Once Flow 1 is working, I'll provide the same step-by-step for the Email Engine.

**Ready to build?** Start with Step 1 (variables) and let me know if you hit any issues!
