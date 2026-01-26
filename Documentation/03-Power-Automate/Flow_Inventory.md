# Power Automate Flow Inventory

> **Version**: 1.0.0.10
> **Last Updated**: 2026-01-26
> **Total Flows**: 11

---

## Daily Scheduled Flows

### 1. Daily SAP Transaction Import
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionDailySAPTransactionImport` |
| **Trigger** | Recurrence |
| **Schedule** | Mon-Fri, 07:00 (SE Asia Time) |
| **Purpose** | Import SAP transaction data from Power BI dataset |
| **Connectors** | Dataverse, Power BI |

**What it does**:
1. Reads SAP FBL5N data from Power BI (data already filtered at source)
2. Gets Working Day Number for arrear calculation
3. Creates Transaction records in Dataverse
4. Creates ProcessLog record with status and counts

**Exclusion Note**: Exclusions (Paid, Partial Payment, etc.) are filtered at Power BI source level before import. Excluded transactions never enter the system.

---

### 2. Daily SAP Transaction Import Extended
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionDailySAPTransactionImportEx` |
| **Trigger** | Recurrence |
| **Schedule** | Daily, 08:00 (SE Asia Time) |
| **Purpose** | Extended import with additional processing |
| **Connectors** | Dataverse, SharePoint, Power BI |

**What it does**:
1. Extended version of daily import
2. Runs daily (including weekends for catch-up)
3. Additional data validation and enrichment

---

### 3. Daily Collections Email Engine
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionDailyCollectionsEmailEngine` |
| **Trigger** | Recurrence |
| **Schedule** | Mon-Fri, 07:30 (SE Asia Time) |
| **Purpose** | Process transactions and create email logs |
| **Connectors** | Dataverse, SharePoint, Office 365 Users |

**What it does**:
1. Verifies SAP Import completed (checks ProcessLog)
2. Gets all active customers with transactions
3. For each customer:
   - Filters non-excluded transactions (DN/CN)
   - Applies FIFO logic
   - Calculates net amount
   - Determines max day count (arrears)
   - Selects email template (A/B/C/D)
   - Creates HTML email body
   - Creates EmailLog record with:
     - **ApprovalStatus = Approved (676180001)** ← AUTO-APPROVED
     - **SendStatus = Pending (676180002)**
4. Updates transaction records as processed

**Template Selection** (Priority Order):
1. Template D: Has MI documents (`DocumentType = 'MI'`)
2. Template C: Day 4+ (MI warning)
3. Template B: Day 3 (cash discount warning)
4. Template A: Day 1-2 (standard)

**Important**: Emails are AUTO-APPROVED at creation. No manual approval workflow.

---

### 4. Email Sending Flow
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionEmailSendingFlow` |
| **Trigger** | Recurrence |
| **Schedule** | Mon-Fri, 08:00 (SE Asia Time) |
| **Purpose** | Send approved emails from EmailLog |
| **Connectors** | Dataverse, Office 365 |

**What it does**:
1. Queries EmailLog where:
   - ApprovalStatus = Approved
   - SendStatus = Pending
2. For each email log:
   - Sends email using Office 365
   - Updates SendStatus to Success/Failed
   - Updates SentDateTime

---

## Manual Flows (PowerApp Triggered)

### 5. Customer Data Sync
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionCustomerDataSync` |
| **Trigger** | PowerAppV2 (Manual) |
| **Parameters** | None |
| **Purpose** | Sync customer master data |
| **Connectors** | Dataverse, SharePoint |

**What it does**:
1. Reads customer data from SharePoint Excel
2. Updates Customer table in Dataverse
3. Creates sync log

---

### 6. Manual SAP Upload
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionManualSAPUpload` |
| **Trigger** | PowerAppV2 (Manual) |
| **Parameters** | `FilePath` (SharePoint path) |
| **Purpose** | Process manually uploaded SAP file |
| **Connectors** | Dataverse, SharePoint |

**What it does**:
1. Reads specified Excel file from SharePoint
2. Parses SAP transaction data
3. Creates Transaction records
4. Creates ProcessLog record

---

### 7. Manual Email Resend
| Property | Value |
|----------|-------|
| **File** | `THFinanceCashCollectionManualEmailResend` |
| **Trigger** | PowerAppV2 (Manual) |
| **Parameters** | `EmailLogID` (GUID) |
| **Purpose** | Resend a specific email |
| **Connectors** | Dataverse, Office 365 |

**What it does**:
1. Gets EmailLog by ID
2. Resends email
3. Updates SendStatus

---

### 8. Generate Working Day Calendar
| Property | Value |
|----------|-------|
| **File** | `THFinanceGenerateWorkingDayCalendar` |
| **Trigger** | Button (Manual) |
| **Parameters** | `StartYear`, `EndYear` |
| **Purpose** | Generate working day calendar for year range |
| **Connectors** | Dataverse |

**What it does**:
1. Generates dates for specified year range
2. Marks weekends as non-working
3. Creates WorkingDayCalendar records
4. Admin can then mark holidays manually

---

### 9. Recalculate WDN (PowerApps Wrapper)
| Property | Value |
|----------|-------|
| **File** | `THFinanceRecalculateWDNPowerApps` |
| **Trigger** | PowerAppV2 |
| **Parameters** | None |
| **Purpose** | Trigger WDN recalculation from Canvas App |
| **Connectors** | Dataverse |

**What it does**:
1. Called from scnCalendar screen after holiday changes
2. Triggers regeneration of WorkingDayCalendar
3. Returns status to Canvas App

---

### 10. Check QR Availability
| Property | Value |
|----------|-------|
| **File** | `THFinanceCheckQRAvailability` |
| **Trigger** | Manual (Child Flow) |
| **Parameters** | None |
| **Purpose** | Scan SharePoint for QR code files |
| **Connectors** | Dataverse, SharePoint |

**What it does**:
1. Lists all customers from Dataverse
2. For each customer (20 parallel):
   - Checks if `{CustomerCode}.jpg` exists in SharePoint QR folder
   - Updates `cr7bb_qrcodeavailable` field (true/false)
3. Returns found/not found counts

**SharePoint Path**: `/Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/`

---

### 11. Check QR Availability (PowerApps Wrapper)
| Property | Value |
|----------|-------|
| **File** | `THFinanceCheckQRAvailabilityPowerApps` |
| **Trigger** | PowerAppV2 |
| **Parameters** | None |
| **Purpose** | Call QR check from Canvas App |
| **Connectors** | (Calls child flow) |

**What it does**:
1. Called from "Check QR" button on scnCustomer
2. Runs child flow `THFinanceCheckQRAvailability`
3. Returns status (Success/Failed) to Canvas App

---

## Flow Execution Order (Daily)

```
07:00  ─── Daily SAP Transaction Import ───────────────────────┐
         - Creates ProcessLog record                            │
         - Imports transactions from Power BI                   │
                                                                │
07:30  ─── Daily Collections Email Engine ────────────────────┤ Sequential
         - Creates EmailLog records                             │
         - ApprovalStatus = Approved (AUTO-APPROVED)            │
         - SendStatus = Pending                                 │
                                                                │
08:00  ─── Email Sending Flow ────────────────────────────────┘
         - Filters: ApprovalStatus=Approved, SendStatus=Pending
         - Sends emails via Office 365
         - Updates SendStatus to Success/Failed
         - Updates SentDateTime
```

**Note**: There is no manual approval step. Emails are auto-approved by Email Engine.

---

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `nc_EmailMode` | Test/Production mode |
| `nc_SystemNotificationEmail` | Admin notification recipient |
| `nc_TestCustomerEmail` | Test mode email override |
| `nc_PACurrentEnvironmentMode` | Current environment |
| `nc_PATestNotificationEmail` | Test notification email |

---

## Tables Used

| Table | Used By |
|-------|---------|
| `Customers` | All flows, QR Check |
| `Transactions` | Import, Email Engine |
| `EmailLogs` | Email Engine, Sending, Resend |
| `ProcessLogs` | Import, Email Engine, QR Check |
| `WorkingDayCalendar` | Calendar Generator, SAP Import |
| `CalendarEvents` | Calendar screen, WDN Recalc |

---

## Documentation References

| Document | Purpose |
|----------|---------|
| `Flow_StepByStep_FIFO_EmailEngine.md` | Email engine logic details |
| `Flow_StepByStep_ArrearCalculation.md` | Day count calculation |
| `Flow_StepByStep_WorkingDayCalendar.md` | Calendar generation |
| `Flow_StepByStep_PowerBI_Import.md` | Power BI data import |
| `Flow_StepByStep_QRAvailabilityCheck.md` | QR code availability check |
| `Email_Template_Specification.md` | Email template details |
| `Flow_Modification_Checklist.md` | Change tracking |
