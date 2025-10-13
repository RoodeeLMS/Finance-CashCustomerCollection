# Current Database Schema Analysis

**Analysis Date**: 2025-10-13
**Source**: Solution Export `extracted/customizations.xml`

---

## 📊 **Current Tables & Fields**

### **1. EmailLog Table** `[THFinanceCashCollection]Emaillogs`

**Current Fields**:
| Physical Name | Display Name | Type | Purpose |
|---------------|--------------|------|---------|
| `cr7bb_THFinanceCashCollectionEmaillogId` | EmailLog ID | GUID | Primary key |
| `cr7bb_Customer` | Customer | Lookup | Link to customer |
| `cr7bb_ProcessDate` | Process Date | DateTime | When email prepared |
| `cr7bb_EmailSubject` | Email Subject | Text | Email subject line |
| `cr7bb_EmailTemplate` | Email Template | Text | A/B/C/D |
| `cr7bb_TotalAmount` | Total Amount | Currency | Amount in email |
| `cr7bb_RecipientEmails` | Recipient Emails | Text | To addresses |
| `cr7bb_CCEmails` | CC Emails | Text | CC addresses |
| `cr7bb_MaxDayCount` | Max Day Count | Whole Number | Highest day count |
| `cr7bb_SendStatus` | Send Status | Text/Choice | Success/Failed/Pending |
| `cr7bb_SentDateTime` | Sent Date Time | DateTime | When actually sent |
| `cr7bb_QRCodeIncluded` | QR Code Included | Yes/No | Was QR attached |
| `cr7bb_ErrorMessage` | Error Message | Text | Error if failed |

**Missing Fields for Approval**:
| Field Needed | Type | Purpose |
|--------------|------|---------|
| ❌ `cr7bb_approvalstatus` | Choice | Pending/Approved/Rejected (extensible for future statuses) |
| ❌ `cr7bb_emailbodypreview` | Text (multiline) | Full email body for preview in Canvas App |

---

### **2. Transaction Table** `[THFinanceCashCollection]Transactions`

**Current Fields**:
| Physical Name | Display Name | Type | Purpose |
|---------------|--------------|------|---------|
| `cr7bb_THFinanceCashCollectionTransactionId` | Transaction ID | GUID | Primary key |
| `cr7bb_Customer` | Customer | Lookup | Link to customer |
| `cr7bb_RecordType` | Record Type | Choice | Transaction/Summary/Header |
| `cr7bb_TransactionType` | Transaction Type | Choice | CN/DN |
| `cr7bb_DocumentNumber` | Document Number | Text(50) | SAP doc number |
| `cr7bb_DocumentDate` | Document Date | Date | Transaction date |
| `cr7bb_NetDueDate` | Net Due Date | Date | Payment due date |
| `cr7bb_AmountLocalCurrency` | Amount | Currency | Transaction amount |
| `cr7bb_ArrearsDays` | Arrears Days | Whole Number | Days overdue |
| `cr7bb_DayCount` | Day Count | Whole Number | Notification day count |
| `cr7bb_Assignment` | Assignment | Text(100) | SAP assignment |
| `cr7bb_DocumentType` | Document Type | Text(10) | Doc type |
| `cr7bb_Textfield` | Text | Text(500) | For exclusion keywords |
| `cr7bb_ReferenceInformation` | Reference | Text(100) | Reference info |
| `cr7bb_IsExcluded` | Is Excluded | Yes/No | Exclusion flag |
| `cr7bb_ExcludeReason` | Exclude Reason | Text(100) | Why excluded |
| `cr7bb_TransactionProcessDate` | Process Date | Date | Date processed |
| `cr7bb_ProcessBatch` | Process Batch | Text(50) | Batch ID |
| `cr7bb_RowNumber` | Row Number | Whole Number | Excel row # |
| `cr7bb_IsProcessed` | Is Processed | Yes/No | Processed flag |
| `cr7bb_EmailSent` | Email Sent | Yes/No | Email sent flag |
| `cr7bb_ParentCustomerAmount` | Parent Amount | Currency | Parent customer amt |

**Missing Fields for File Tracking**:
| Field Needed | Type | Purpose |
|--------------|------|---------|
| ❌ `cr7bb_sourcefilename` | Text(255) | Excel filename (e.g., "SAP_Export_2025-10-13.xlsx") |
| ❌ `cr7bb_sourcefilepath` | Text(500) | Full SharePoint path |

---

### **3. Process Log Table** `[THFinanceCashCollection]Process Logs`

**Current Fields**:
| Physical Name | Display Name | Type | Purpose |
|---------------|--------------|------|---------|
| `cr7bb_THFinanceCashCollectionProcessLogId` | Process Log ID | GUID | Primary key |
| `cr7bb_ProcessDate` | Process Date | Text | "yyyy-mm-dd" (PRIMARY NAME) |
| `cr7bb_LogProcessDate` | Log Process Date | DateTime | Actual datetime |
| `cr7bb_StartTime` | Start Time | DateTime | Flow start |
| `cr7bb_EndTime` | End Time | DateTime | Flow end |
| `cr7bb_SAPFileName` | SAP File Name | Text | ✅ **ALREADY HAS FILE TRACKING!** |
| `cr7bb_TotalCustomers` | Total Customers | Whole Number | Customers processed |
| `cr7bb_TransactionsExcluded` | Transactions Excluded | Whole Number | Excluded count |
| `cr7bb_EmailsSent` | Emails Sent | Whole Number | Sent count |
| `cr7bb_EmailsFailed` | Emails Failed | Whole Number | Failed count |
| `cr7bb_Status` | Status | Text/Choice | Success/Failed/Running |
| `cr7bb_ProcessedBy` | Processed By | Text | User/System |
| `cr7bb_ErrorMessages` | Error Messages | Text | Error details |

**Missing Fields**:
| Field Needed | Type | Purpose |
|--------------|------|---------|
| ❌ `cr7bb_sourcefilepath` | Text(500) | Full SharePoint path to source file |
| ❌ `cr7bb_fileprocessedstatus` | Choice | Processed/Failed/Renamed |

---

### **4. Customer Table** `[THFinanceCashCollection]Customers`

**Current Fields**: ✅ **ALL REQUIRED FIELDS EXIST**
- Customer Code, Name, Region
- Customer Emails 1-4
- Sales Emails 1-5
- AR Backup Emails 1-4

---

## ✅ **Good News**

1. **Process Log ALREADY has `cr7bb_SAPFileName`** - File tracking partially implemented!
2. Most core fields exist
3. Structure is solid

---

## ⚠️ **Fields to Add**

### **High Priority** (for Approval & File Tracking):

#### **EmailLog Table** - Add 2 fields:
```sql
cr7bb_approvalstatus (Choice: Pending/Approved/Rejected, default: Pending)
cr7bb_emailbodypreview (Text multiline 10000)
```

#### **Transaction Table** - Add 2 fields:
```sql
cr7bb_sourcefilename (Text 255)
cr7bb_sourcefilepath (Text 500)
```

#### **Process Log Table** - Add 1 field + Expand existing Status:
```sql
cr7bb_sourcefilepath (Text 500)

Expand cr7bb_status choice with:
- File Not Found (676180004)
- File Already Processed (676180005)
```

---

## 📝 **Next Steps**

1. ✅ You create skeleton flows with permissions
2. ✅ You add missing fields to tables (5 new fields + expand 1 existing choice)
3. ✅ You export solution
4. ✅ I edit flows to:
   - Track source filename in transactions
   - Write approval status to EmailLog (Pending/Approved/Rejected)
   - Rename processed files
   - Handle duplicate transactions
   - Implement approval logic
5. ✅ You import edited solution

---

## 🔍 **Flow Analysis Needed**

Once you export skeleton flows, I'll check:
1. Does SAP Import already use `cr7bb_SAPFileName`?
2. Where are files stored in SharePoint?
3. How is `cr7bb_ProcessBatch` currently set?
4. Does Collections Engine write to EmailLog?
