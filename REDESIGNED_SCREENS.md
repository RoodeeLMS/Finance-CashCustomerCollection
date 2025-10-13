# Redesigned Screen Architecture: AR Control Center

**Design Date**: October 9, 2025
**Designed By**: Claude AI + Nick Chamnong
**Design Philosophy**: Task-focused, minimal clicks, daily workflow optimized

---

## 🎯 **Design Principles**

### **User**: AR Team (Changsalak, Panich, etc.)
**Daily Workflow**:
1. Morning: Upload SAP file, monitor processing
2. Mid-morning: Review sent emails, handle exceptions
3. Ongoing: Manage customer data as needed

### **Key Requirements**:
- ✅ **Fast**: 80% of tasks in 1-2 clicks
- ✅ **Focused**: One task per screen
- ✅ **Visible**: Critical info always on screen
- ✅ **Safe**: Confirm dangerous actions
- ✅ **Audit**: Full transparency on what system did

---

## 📱 **New Screen Structure** (5 Screens)

### **Comparison**:

| Old Design | New Design | Reason |
|------------|------------|--------|
| 7 screens | **5 screens** | Removed unnecessary screens |
| Generic names | **Task-focused names** | Clear purpose |
| Complex navigation | **Workflow-driven** | Follows daily tasks |
| Data-centric | **Action-centric** | What user needs to DO |

---

## 🏠 **Screen 1: Daily Control Center** ⭐ **LANDING PAGE**

### **Purpose**:
Monitor today's automated processing at a glance

### **User Question**:
> "Did the system run? Are emails sent? Any issues?"

### **Screen Layout**:
```
┌─────────────────────────────────────────────────────┐
│ Daily Control Center       [Upload SAP File]  🔄 ✓  │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ TODAY'S STATUS                               │   │
│ │                                              │   │
│ │ SAP Import:      ✓ Completed at 8:05 AM     │   │
│ │ Email Engine:    ✓ Completed at 8:35 AM     │   │
│ │                                              │   │
│ │ 📧 Emails Sent:     87 / 100 customers      │   │
│ │ ⚠️ Failed:          2  [View Details →]      │   │
│ │ ⏭️ Skipped:         11 (fully credited)      │   │
│ │                                              │   │
│ │ ⏱️ Processing Time: 28 minutes               │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ QUICK ACTIONS                                       │
│ ┌───────────────┐ ┌───────────────┐ ┌──────────┐  │
│ │ Review Emails │ │ View Failed   │ │ Customer │  │
│ │ Sent Today    │ │ Emails        │ │ Lookup   │  │
│ └───────────────┘ └───────────────┘ └──────────┘  │
│                                                     │
│ IMPORTANT CUSTOMERS (High Balances / Overdue)      │
│ ┌─────────────────────────────────────────────┐   │
│ │ 200120 - ABC Corp     ฿1,250,000  Day 5 🔴   │   │
│ │ 200345 - XYZ Ltd      ฿890,000    Day 3 🟡   │   │
│ │ 200567 - DEF Co       ฿650,000    Day 1      │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ RECENT ACTIVITY                                     │
│ ├─ 08:35 AM - 87 emails sent successfully         │
│ ├─ 08:05 AM - SAP file processed (234 transactions)│
│ └─ Yesterday - 92 emails sent                      │
└─────────────────────────────────────────────────────┘
```

### **Key Features**:

1. **Status Card** (Top Third)
   - ✅ Today's flow status (SAP Import, Email Engine)
   - ✅ Email stats (sent, failed, skipped)
   - ✅ Processing time
   - ✅ Visual indicators (✓/⚠️/🔄)

2. **Quick Actions** (Middle)
   - 🔵 "Review Emails Sent Today" → Navigate to Email Log
   - 🔴 "View Failed Emails" → Filter to failed only
   - 🔵 "Customer Lookup" → Quick search popup

3. **Important Customers** (Middle)
   - Top 5 highest balances
   - Color coding by day count (🔴 5+, 🟡 3-4, ⚪ 1-2)
   - One-click to customer detail

4. **Recent Activity** (Bottom)
   - Timeline of system actions
   - Quick audit trail

### **AR User Actions**:
- ✅ **Upload SAP File** (button) - Manual trigger if needed
- ✅ **Refresh** (button) - Update status
- ✅ **Drill down** - Click on any number to see details
- ✅ **Quick lookup** - Search customer by code/name

**Result**: User sees **everything they need** in **3 seconds**

---

## 📧 **Screen 2: Email Monitor** (Replace "Dashboard")

### **Purpose**:
Review what the system sent to customers today

### **User Question**:
> "What emails went out? Can I see what customers received?"

### **Screen Layout**:
```
┌─────────────────────────────────────────────────────┐
│ Email Monitor - Today                 [Filter ▼]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Filters: [All] [Sent✓] [Failed⚠️] [Pending⏱️]       │
│ Search: [________] 🔍                               │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ Customer      Amount      Template   Status  │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 200120 ABC    ฿1.2M  Day5  Template C   ✓    │   │
│ │   Sent 8:32 AM │ To: finance@abc.com        │   │
│ │   [Preview Email] [Resend] [Mark Paid]      │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 200345 XYZ    ฿890K  Day3  Template B   ✓    │   │
│ │   Sent 8:33 AM │ To: ar@xyz.com             │   │
│ │   [Preview Email] [Resend] [Mark Paid]      │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 200456 DEF    ฿650K  Day1  Template A   ⚠️    │   │
│ │   Failed: Invalid email address            │   │
│ │   [Fix Email →] [Resend]                    │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ⬇️ Export to Excel                                  │
└─────────────────────────────────────────────────────┘
```

### **Key Features**:

1. **Email List** (Master-Detail)
   - Customer code + name
   - Amount owed (formatted, color-coded)
   - Template used (A/B/C/D)
   - Status (✓ Sent, ⚠️ Failed, ⏱️ Pending)
   - Timestamp
   - Recipient emails

2. **Actions Per Email** (Expandable Row)
   - 👁️ **Preview Email** - Popup showing actual email content
   - 🔄 **Resend** - Manual resend (if failed or needed)
   - ✅ **Mark Paid** - Mark as paid, exclude tomorrow
   - 🔧 **Fix Email** - Quick edit customer email address

3. **Filters** (Top Bar)
   - All / Sent / Failed / Pending
   - Search by customer code/name
   - Date picker (default: Today)

4. **Export** (Bottom)
   - Excel export of today's emails
   - For AR team records

### **AR User Actions**:
- ✅ **Preview email** - See what customer received
- ✅ **Resend** - If email bounced or customer requests
- ✅ **Mark paid** - Quick exclude if payment just received
- ✅ **Fix email** - Correct invalid address on the spot

**Result**: Complete transparency + quick fixes

---

## 👥 **Screen 3: Customer Hub** (Replace "Customers")

### **Purpose**:
Manage customer master data with focus on email accuracy

### **User Question**:
> "Is customer contact info correct? Can I quickly update?"

### **Screen Layout**:
```
┌─────────────────────────────────────────────────────┐
│ Customer Hub                          [+ Add New]   │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Search: [________] 🔍  Filter: [Region▼] [Active▼] │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ Code    Customer Name      Region   Emails  │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 200120  ABC Corporation    NO       ✉️✉️✉️    │   │
│ │   Customer: finance@abc.com (verified ✓)    │   │
│ │   Sales CC: sales@abc.com                   │   │
│ │   AR Owner: changsalak@nestle.com           │   │
│ │   [✏️ Edit] [View Transactions] [QR Code]    │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 200345  XYZ Limited        SO       ✉️✉️⚠️    │   │
│ │   Customer: ar@xyz.com (bounced! Fix→)      │   │
│ │   Sales CC: sales@xyz.com                   │   │
│ │   AR Owner: panich@nestle.com               │   │
│ │   [✏️ Edit] [View Transactions] [QR Code]    │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ Bulk Actions: [Import from Excel] [Export All]     │
└─────────────────────────────────────────────────────┘
```

### **Key Features**:

1. **Customer Card** (Expandable)
   - Customer code + name + region
   - **Email health indicator**: ✉️✉️✉️ (all valid) or ⚠️ (issues)
   - All email addresses visible
   - Last email sent date
   - Current balance

2. **Quick Actions Per Customer**
   - ✏️ **Edit** - Inline editing of emails/name/region
   - 📊 **View Transactions** - Jump to transaction screen filtered
   - 🔲 **QR Code** - View/download customer QR code
   - 🚫 **Deactivate** - Stop sending emails

3. **Email Validation** (Automatic)
   - ✓ Valid email format
   - ⚠️ Bounced recently
   - ❌ Invalid format

4. **Bulk Operations**
   - Import customers from Excel (bulk add/update)
   - Export all customers to Excel

### **AR User Actions**:
- ✅ **Quick edit** - Update email without opening form
- ✅ **Email validation** - See which emails are problematic
- ✅ **Bulk import** - Update 50+ customers from Excel
- ✅ **View QR code** - Check if customer QR exists

**Result**: Email accuracy maintained easily

---

## 📊 **Screen 4: Transaction Inspector** (Replace "Transactions")

### **Purpose**:
Review what the system processed and make quick corrections

### **User Question**:
> "What transactions came in today? Did the system get it right?"

### **Screen Layout**:
```
┌─────────────────────────────────────────────────────┐
│ Transaction Inspector              [Filters ▼]      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Date: [📅 Today ▼]  Customer: [All ▼]              │
│ Status: [All] [Included✓] [Excluded❌] [Manual✋]   │
│                                                     │
│ Customer: 200120 - ABC Corporation                  │
│ ┌─────────────────────────────────────────────┐   │
│ │ Doc #     Date      Type   Amount   Status  │   │
│ ├─────────────────────────────────────────────┤   │
│ │ 9001234   03/01    DN     ฿500K     ✓ Sent   │   │
│ │ 9001235   05/01    DN     ฿300K     ✓ Sent   │   │
│ │ 9001250   08/01    CN    (฿100K)    ✓ Sent   │   │
│ │ 9001251   09/01    DN     ฿200K     ❌ Paid   │   │
│ │   Text: "Partial Payment" → Auto-excluded    │   │
│ │   [✓ Correct] [Include in Email]             │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ Summary for ABC Corporation:                        │
│ • DN Total: ฿1,000,000                              │
│ • CN Total: (฿100,000)                              │
│ • Net Owed: ฿900,000                                │
│ • Email: ✓ Sent today (Template B - Day 3)         │
│                                                     │
│ [Mark All as Paid] [Exclude Customer Tomorrow]     │
└─────────────────────────────────────────────────────┘
```

### **Key Features**:

1. **Grouped by Customer**
   - All transactions for one customer together
   - Visual separation between customers
   - Collapsible customer groups

2. **Transaction Detail**
   - Document number, date, type (CN/DN)
   - Amount (color: green=CN/credit, black=DN/debit)
   - Status (✓ Included, ❌ Excluded, ✋ Manual)
   - Exclusion reason if applicable

3. **Smart Summary** (Per Customer)
   - Automatic FIFO calculation shown
   - Net amount owed
   - Email status (sent/skipped/failed)

4. **Quick Corrections**
   - ✓ **Correct** - Confirm exclusion is right
   - 🔄 **Include in Email** - Override exclusion
   - ✋ **Mark Paid** - Manual exclusion
   - 🚫 **Exclude Tomorrow** - Stop reminders

5. **Exclusion Explanation**
   - Show WHY transaction excluded
   - Text field excerpt displayed
   - Keyword match highlighted

### **AR User Actions**:
- ✅ **Verify system logic** - See FIFO calculation
- ✅ **Override exclusions** - Include if keyword wrong
- ✅ **Mark paid** - Quick update when payment received
- ✅ **Audit trail** - See what system decided

**Result**: Full transparency + easy corrections

---

## ⚙️ **Screen 5: System Settings** (Simplified)

### **Purpose**:
Configure system behavior (AR + Admin)

### **User Question**:
> "Can I change email templates? Add exclusion keywords?"

### **Screen Layout**:
```
┌─────────────────────────────────────────────────────┐
│ System Settings                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│ TABS: [Exclusion Keywords] [Email Templates]       │
│       [Admin: Roles] [Admin: Flow Config]          │
│                                                     │
│ ═══ EXCLUSION KEYWORDS ═══════════════════════════  │
│                                                     │
│ Current Keywords (5):                               │
│ ┌─────────────────────────────────────────────┐   │
│ │ ✓ "Paid"                          [Remove]  │   │
│ │ ✓ "Partial Payment"               [Remove]  │   │
│ │ ✓ "รักษาตลาด"                      [Remove]  │   │
│ │ ✓ "Bill credit 30 days"           [Remove]  │   │
│ │ ✓ "Exclude"                       [Remove]  │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ Add New Keyword:                                    │
│ [_________________________] [+ Add]                 │
│                                                     │
│ ⚠️ Changes take effect tomorrow's run               │
│                                                     │
│ ═══ EMAIL TEMPLATES ══════════════════════════════  │
│                                                     │
│ Template A (Day 1-2): Standard Reminder             │
│ [Edit Content →]                                    │
│                                                     │
│ Template B (Day 3): Cash Discount Warning           │
│ [Edit Content →]                                    │
│                                                     │
│ Template C (Day 4+): Late Fee Notice                │
│ [Edit Content →]                                    │
│                                                     │
│ [Preview All Templates]                             │
└─────────────────────────────────────────────────────┘
```

### **Key Features**:

#### **Tab 1: Exclusion Keywords** (AR Users)
1. **Current Keywords List**
   - Visual list of active keywords
   - Remove button per keyword
   - Case-insensitive note

2. **Add New Keyword**
   - Simple text input
   - Immediate add
   - Warning: Takes effect tomorrow

#### **Tab 2: Email Templates** (AR Users)
1. **Template Management**
   - Edit Template A/B/C/D content
   - Rich text editor
   - Variables available: {CustomerName}, {Amount}, {Date}, etc.

2. **Preview**
   - See how email will look
   - Test with sample data

#### **Tab 3: Roles** (Admin Only)
1. **User Management**
   - Add/remove AR users
   - Assign Admin role

#### **Tab 4: Flow Configuration** (Admin Only)
1. **Automation Settings**
   - Scheduled trigger times
   - Test mode toggle (send to AR only)
   - File upload folder path
   - QR code folder path

### **AR User Actions**:
- ✅ **Add keyword** - New exclusion reason
- ✅ **Edit templates** - Update email wording
- ✅ **Preview** - See customer view

### **Admin Actions**:
- ✅ **Manage users** - Add/remove AR team
- ✅ **Configure flows** - Change schedule
- ✅ **Set paths** - Update folder locations

**Result**: Self-service configuration

---

## 🗑️ **Screens REMOVED**

| Old Screen | Reason Removed | Functionality Moved To |
|------------|----------------|------------------------|
| **scnDashboard** (generic) | Too generic | → Daily Control Center (focused) |
| **scnRole** (separate) | Admin-only, rarely used | → Settings Tab 3 (Admin) |
| **scnUnauthorized** | Environment security handles | N/A |
| **loadingScreen** | Keep simplified version | Keep (role detection only) |

---

## 🎯 **Screen Comparison**

### **Old vs New**:

| Aspect | Old Design | New Design |
|--------|------------|------------|
| **Screens** | 7 screens | 5 screens |
| **Landing** | Generic dashboard | Daily Control Center |
| **Focus** | Data viewing | Action-oriented |
| **Clicks to task** | 3-5 clicks | 1-2 clicks |
| **Email review** | No dedicated screen | Email Monitor (detailed) |
| **Transaction review** | Basic list | Transaction Inspector (smart) |
| **Customer mgmt** | Basic CRUD | Hub with email health |
| **Settings** | Generic | Tabbed by user type |
| **Admin access** | Separate screen | Settings tab |

---

## 🚀 **User Flow** (Daily Workflow)

### **Morning Routine** (8:00 AM):
```
1. Open app → Daily Control Center
   • See status: "Processing..." or "Completed ✓"
   • Wait if processing, or review if done

2. Review results (on same screen)
   • 87 emails sent ✓
   • 2 failed ⚠️
   • 11 skipped

3. Click "View Failed Emails"
   → Email Monitor (filtered to failed)

4. Fix failed emails (1-2 minutes)
   • Click "Fix Email" on failed row
   • Update email address
   • Click "Resend"
   • Done ✓
```

### **Customer Inquiry** (Ad-hoc):
```
Customer calls: "Did you send me a reminder?"

1. Daily Control Center
2. "Customer Lookup" button
3. Type customer code
4. See: ✓ Email sent 8:32 AM today
5. Click "Preview Email"
6. Read email content to customer
7. Done (30 seconds)
```

### **Manual Correction** (As needed):
```
Customer says: "I paid that bill yesterday!"

1. Navigate to Transaction Inspector
2. Filter to customer
3. Find transaction
4. Click "Mark Paid"
5. Confirm
6. Done ✓ (won't email tomorrow)
```

---

## 📊 **Screen Priority**

### **Screen 1: Daily Control Center** 🔥 **CRITICAL**
- **Usage**: Daily, 100% of AR users
- **Time**: 90% of time spent here
- **Build Priority**: **#1 - Build this first**

### **Screen 2: Email Monitor** 🔥 **HIGH**
- **Usage**: Daily, when reviewing results
- **Time**: 5% of time
- **Build Priority**: **#2**

### **Screen 3: Customer Hub** 🟡 **MEDIUM**
- **Usage**: Weekly, when updating customer info
- **Time**: 3% of time
- **Build Priority**: **#3**

### **Screen 4: Transaction Inspector** 🟡 **MEDIUM**
- **Usage**: Ad-hoc, when customer questions arise
- **Time**: 1% of time
- **Build Priority**: **#4**

### **Screen 5: System Settings** 🔵 **LOW**
- **Usage**: Monthly, configuration changes
- **Time**: <1% of time
- **Build Priority**: **#5**

---

## ✅ **Benefits of Redesign**

### **For AR Users**:
- ✅ **Faster**: 80% of tasks in 1-2 clicks (vs 3-5)
- ✅ **Clearer**: Purpose obvious from screen name
- ✅ **Confident**: See exactly what system did
- ✅ **Empowered**: Fix issues without IT help
- ✅ **Efficient**: Daily workflow optimized

### **For IT/Admin**:
- ✅ **Fewer tickets**: Self-service for common tasks
- ✅ **Better audit**: Full transparency on decisions
- ✅ **Easy training**: Intuitive screen flow
- ✅ **Less maintenance**: 5 screens vs 7

### **For Business**:
- ✅ **Faster adoption**: Intuitive design
- ✅ **Higher accuracy**: Easy to verify system logic
- ✅ **Better service**: Quick response to customer inquiries
- ✅ **Scalable**: Efficient workflow handles growth

---

## 🎯 **Implementation Roadmap**

### **Phase 1: MVP** (Week 1-2)
Build these 3 screens first:
1. ✅ Daily Control Center (landing)
2. ✅ Email Monitor (review results)
3. ✅ Customer Hub (basic CRUD)

**Result**: Core daily workflow working

### **Phase 2: Full Features** (Week 3)
Add remaining screens:
4. ✅ Transaction Inspector (verify logic)
5. ✅ System Settings (configuration)

**Result**: Complete system

### **Phase 3: Polish** (Week 4)
Enhance UX:
- ✅ Add quick actions
- ✅ Improve filters
- ✅ Add export functions
- ✅ Mobile responsive

**Result**: Production-ready

---

## 📋 **Design Validation**

### **Does it solve the problem?**

| Original Pain Point | Solution |
|---------------------|----------|
| "2-3 hours daily email composition" | ✅ Automated (Daily Control Center shows status) |
| "Manual calculation errors" | ✅ Transaction Inspector shows FIFO logic |
| "No audit trail" | ✅ Email Monitor shows all communications |
| "Inconsistent email formats" | ✅ Template system (Settings) |
| "Can't verify system behavior" | ✅ Transaction Inspector explains decisions |

### **Does it match user workflow?**

| Daily Task | Screen | Clicks |
|------------|--------|--------|
| "Check if emails sent" | Daily Control Center | 0 (landing page) |
| "Review what was sent" | Email Monitor | 1 |
| "Fix failed email" | Email Monitor → Fix Email | 2 |
| "Look up customer" | Customer Hub (search) | 1 |
| "Mark transaction paid" | Transaction Inspector | 2 |
| "Add exclusion keyword" | Settings | 2 |

**Average: 1-2 clicks per task** ✅

---

## 🎨 **Visual Design Notes**

### **Color Coding**:
- 🔴 Red: Urgent (Day 5+, Failed emails)
- 🟡 Yellow: Warning (Day 3-4, Attention needed)
- 🟢 Green: Good (Credits, Completed tasks)
- ⚪ Gray: Normal (Day 1-2, Standard status)

### **Icons**:
- ✓ Success/Sent
- ⚠️ Warning/Failed
- 🔄 Processing/Refresh
- 📧 Email
- 🔲 QR Code
- 🔍 Search
- ✏️ Edit
- 🚫 Exclude/Deactivate

### **Layout**:
- **Header**: Screen name + primary action button (right)
- **Body**: Content area (scrollable)
- **Navigation**: Sidebar (desktop) or hamburger (mobile)
- **Quick Actions**: Always visible (no scrolling to find)

---

## 🎯 **Success Metrics**

### **Quantitative**:
- ⏱️ **Time to check status**: < 5 seconds (was: 30 seconds)
- 🖱️ **Clicks to fix failed email**: 2 clicks (was: 5+ clicks)
- 🔍 **Time to look up customer**: 10 seconds (was: 1 minute)
- ⚙️ **Self-service config**: 90% (was: 0% - needed IT)

### **Qualitative**:
- ✅ AR users can explain what system did
- ✅ AR users confident in system accuracy
- ✅ No "where do I find X?" questions
- ✅ Positive UAT feedback

---

## 🎉 **Summary**

### **New Screen Structure**:
1. **Daily Control Center** - Morning landing page ⭐
2. **Email Monitor** - Review what was sent
3. **Customer Hub** - Manage customer data
4. **Transaction Inspector** - Verify system logic
5. **System Settings** - Configure behavior

### **Design Philosophy**:
- ✅ Task-focused (not data-focused)
- ✅ Workflow-driven (follows daily routine)
- ✅ Action-oriented (what can I DO here?)
- ✅ Transparent (always show WHY)
- ✅ Empowering (self-service fixes)

### **Key Improvements**:
- ✅ 5 screens (was 7) - simpler
- ✅ 1-2 clicks per task (was 3-5) - faster
- ✅ Focused purpose per screen - clearer
- ✅ 90% self-service - less IT dependency
- ✅ Full transparency - more confidence

**Status**: ✅ **Ready to Build**

---

**Next Step**: Start with Daily Control Center (Screen 1) - it's the foundation for everything else! 🚀
