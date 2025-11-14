# Power Automate Flow Setup Instructions
## Flow Skeleton Creation for Import/Export Workflow

**Purpose**: Create flow skeletons with authenticated connections, export, fill in logic, re-import

---

## Flow 1: Daily SAP Transaction Import

### Step 1: Create New Flow

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your environment
3. **Flows** → **+ New flow** → **Automated cloud flow**
4. Name: `[THFinanceCashCollection] Daily SAP Transaction Import`
5. Skip trigger selection (we'll add manually)
6. Click **Create**

### Step 2: Add Manual Trigger (for testing)

1. Click **+ New step**
2. Search: `manually trigger`
3. Select: **Manually trigger a flow**
4. No inputs needed for now

### Step 3: Add Required Connection Blocks

Add these actions to authenticate all required connectors:

#### 3.1 SharePoint Connection
```
Action: Get files (properties only)
Connector: SharePoint
Site Address: [Select your SharePoint site]
Library: [Select document library]
Folder: /SAP Daily Exports (or create dummy folder)
```
**Save** - This authenticates SharePoint connection

#### 3.2 Dataverse Connection - Customers
```
Action: List rows
Connector: Microsoft Dataverse
Table name: cr7bb_customers
Row count: 1
```
**Save** - This authenticates Dataverse connection

#### 3.3 Dataverse Connection - Transactions
```
Action: List rows
Connector: Microsoft Dataverse
Table name: cr7bb_transactions
Row count: 1
```

#### 3.4 Dataverse Connection - Process Logs
```
Action: Add a new row
Connector: Microsoft Dataverse
Table name: cr7bb_processlogs
Fields:
  cr7bb_processdate: [Leave empty - we'll fill later]
  cr7bb_status: Running
```

#### 3.5 Excel Online Connection
```
Action: List rows present in a table
Connector: Excel Online (Business)
Location: SharePoint Site
Document Library: [Your library]
File: [Select any Excel file with a table, or create dummy]
Table: Table1
```
**Save** - This authenticates Excel connector

#### 3.6 Email Connection
```
Action: Send an email (V2)
Connector: Office 365 Outlook
To: [Your email]
Subject: Test Connection
Body: Testing
```
**Save** - This authenticates Outlook connection

### Step 4: Save Flow

1. Click **Save** at top
2. Test flow by clicking **Test** → **Manually** → **Test**
3. Verify all actions run (they'll have dummy data, that's fine)

### Step 5: Add to Solution

1. Go to **Solutions** → Select your solution (or create new: "[THFinanceCashCollection] Finance Cash Collection")
2. Click **Add existing** → **Automation** → **Cloud flow**
3. Select `[THFinanceCashCollection] Daily SAP Transaction Import`
4. Click **Add**

### Step 6: Export Flow

1. In solution, select the flow
2. Click **Export**
3. Choose **Package (.zip)**
4. Export as **Unmanaged**
5. Save to: `E:\NestlePowerApp\Finance-CashCustomerCollection\Flow Exports\`
6. Filename: `SAP_Import_Flow_Skeleton.zip`

---

## Flow 2: Collections Email Engine

### Step 1: Create New Flow

1. **Flows** → **+ New flow** → **Automated cloud flow**
2. Name: `[THFinanceCashCollection] Daily Collections Email Engine`
3. Skip trigger, click **Create**

### Step 2: Add Manual Trigger

1. **Manually trigger a flow**

### Step 3: Add Required Connection Blocks

#### 3.1 Dataverse - Get Transactions
```
Action: List rows
Table name: cr7bb_transactions
Row count: 1
```

#### 3.2 Dataverse - Get Customers
```
Action: List rows
Table name: cr7bb_customers
Row count: 1
```

#### 3.3 Dataverse - Get Process Log
```
Action: List rows
Table name: cr7bb_processlogs
Row count: 1
```

#### 3.4 Dataverse - Create Email Log
```
Action: Add a new row
Table name: cr7bb_emaillogs
Fields:
  cr7bb_processdate: [Leave empty]
  cr7bb_sendstatus: Success
```

#### 3.5 SharePoint - Get QR Code File
```
Action: Get file content
Site Address: [Your SharePoint site]
File Identifier: [Browse to QR Codes folder and select any .png file]
```

#### 3.6 Office 365 Users - Get User Profile
```
Action: Get user profile (V2)
Connector: Office 365 Users
User (UPN): [Your email or AR team member email]
```

#### 3.7 Send Email with Attachment
```
Action: Send an email (V2)
To: [Your email]
Subject: Test Email with Attachment
Body: <p>Test HTML email</p>
Attachments Name - 1: test.png
Attachments Content - 1: [Click "Dynamic content" → select "File content" from SharePoint action]
```

### Step 4: Save and Test

1. **Save** flow
2. **Test** → **Manually** → **Test**
3. Verify all connections authenticated

### Step 5: Add to Solution

1. **Solutions** → Your solution ("[THFinanceCashCollection] Finance Cash Collection")
2. **Add existing** → **Cloud flow**
3. Select `[THFinanceCashCollection] Daily Collections Email Engine`

### Step 6: Export Flow

1. Select flow in solution
2. **Export** → **Package (.zip)** → **Unmanaged**
3. Save to: `E:\NestlePowerApp\Finance-CashCustomerCollection\Flow Exports\`
4. Filename: `Email_Engine_Flow_Skeleton.zip`

---

## What to Send Me

After you complete both flows, send me:

1. **Export files**:
   - `SAP_Import_Flow_Skeleton.zip`
   - `Email_Engine_Flow_Skeleton.zip`

2. **Connection Information** (so I know what's available):
   - SharePoint Site URL
   - Document library name
   - QR Code folder path
   - Dataverse table names (confirm cr7bb_ prefix)

---

## What I'll Do Next

1. **Extract your flow files**
2. **Modify the JSON** to add:
   - All variables
   - All business logic
   - Error handling
   - Loops and conditions
3. **Create new .zip files** with complete flows
4. **Provide import instructions**

---

## Alternative: Just Create Connections

If the above is too complex, you can also just create the **connections** without building flows:

### Create Connections Only

1. Go to **Data** → **Connections**
2. Click **+ New connection**
3. Create these connections:
   - **SharePoint** (authenticate)
   - **Microsoft Dataverse** (authenticate)
   - **Excel Online (Business)** (authenticate)
   - **Office 365 Outlook** (authenticate)
   - **Office 365 Users** (authenticate)

Then I can:
- Provide complete flow JSON files
- You import them
- Power Automate will prompt you to map to your existing connections

---

## Questions?

**Q: Do I need to create all those dummy actions?**
A: Yes - this authenticates each connector so they're available in the exported solution

**Q: Can I delete the dummy actions after export?**
A: No - I'll replace them with complete logic in the re-import

**Q: What if I don't have test data (Excel files, QR codes)?**
A: Create dummy files:
- Excel: Any .xlsx with a table named "Table1"
- QR Code: Any .png image in SharePoint

**Q: Should I use service account or my account?**
A: Your account for now - we can change connection references later in production

---

**Ready when you are!** Let me know when you've exported the flow skeletons or if you have questions.
