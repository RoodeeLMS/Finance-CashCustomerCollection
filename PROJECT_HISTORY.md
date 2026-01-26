# Project History & Meeting Timeline

This document tracks the evolution of the **Finance Cash Customer Collection** project based on meeting transcripts and decision points.

## 📅 Timeline

### 1. Project Kickoff & Scope Definition
**Date:** September 25, 2025
**Source:** `Smart Collection (Legacy app modernization).pdf`
**Status:** ✅ Completed

**Key Discussions:**
- **Origin:** The project was born from the need to modernize a legacy "Smart Collection" web app that had browser compatibility issues.
- **Strategy:** Decided to split the modernization into two phases:
    1.  **Phase 1 (Priority):** Automate the daily "Cash Customer Collection" emails (Quick Win).
    2.  **Phase 2:** Build a comprehensive Canvas App for the broader collection workflow.
- **Tech Stack:** Confirmed Power Platform (Power Apps + Power Automate) as the replacement technology.

---

### 2. Initial Setup & Permissions
**Date:** October 8, 2025 
**Source:** `Finance - Cash Customer Collection (1).txt`
**Status:** ✅ Completed

**Key Discussions:**
- **Technical Blocker:** Addressed "Forbidden" errors in Power Automate when reading Excel files. Confirmed this was a specific permission issue with the developer account; the flow worked correctly when using a Business User's (Chalitda) connection reference.
- **Schedule:** Confirmed the automation schedule is **Monday–Friday**, excluding Bank Holidays.
- **Data Structure:** Finalized the column layouts for the Input Excel files (Files 1, 2, 3, 6, 7).
- **Environment:** Confirmed the move from Dev to Pre-prod environment.

---

### 3. Logic Refinement (Grouping)
**Date:** October 14, 2025
**Source:** `Finance - Cash Customer Collection.txt`
**Status:** ✅ Completed

**Key Discussions:**
- **Email Grouping Logic:** Major requirement solidified: The system must consolidate multiple invoices for the same customer into a **single email** containing a summary table. It should *not* send one email per invoice.
- **Exception Handling:** Discussed the "Customer Not Found" scenario (where the Excel Customer ID does not exist in the Master Data).
- **Action Items:** Developer to update the Power Automate flow to implement the "Group by Customer" loop.

---

### 4. Upstream Automation (SAP FBL5N)
**Date:** November 1, 2025
**Source:** `FBL5N Automation.pdf`
**Status:** 🟡 In Progress / Parallel Workstream

**Key Discussions:**
- **Context:** Discussed how the input Excel files are generated. Currently a manual process.
- **Solution:** IT (Nick) to implement **Power Automate Desktop** (RPA) to automate the SAP Login -> Run FBL5N Transaction -> Export to Excel -> Save to SharePoint workflow.
- **SLA:** Input files must be ready on SharePoint by **8:00 AM** daily for the Cloud Flow to pick up.

---

### 5. Final Polish & Scope Adjustment
**Date:** November 14, 2025
**Source:** `Cash Customer Collection - Update.txt` (and `.pdf`)
**Status:** 🟢 Production Ready (Pending Minor Fixes)

**Key Discussions:**
- **UI/UX Refinement:** Requested specific formatting for the Email Table:
    - Amounts must use commas and 2 decimal places (`#,##0.00`).
    - Amounts must be **Right-Aligned** for better readability.
- **Scope Change (QR Codes):** Decision made to **REMOVE** all QR code functionality. The system will no longer fetch or attach QR images to emails.
- **Business Logic:** Confirmed that Credit Notes (negative amounts) should be netted out in the total calculation.
- **Next Steps:** Proceed to Production deployment after applying the formatting fixes.

---

## ✅ Current State (Synthesis)
As of **November 14, 2025**, the project was functionally complete. The core logic for reading files, matching customers, and sending grouped emails was built. 

---

## 🔄 Project Resumption (January 2026)

**Status:** 🚀 Active
After a period of being on hold, the project is resuming with **significant new requirements** that supersede some previous decisions.

### 🆕 New Requirements & Changes
1.  **Data Input Changes:** 
    - The method for inputting data will change (previously Excel from SAP).
    - **Impact:** The Data Structure will be modified. The Power Automate flows that parse inputs will need major refactoring.

2.  **Arrear Days Calculation Engine:**
    - **Goal:** Accurately calculate "Days Past Due" (Arrear Days).
    - **Logic:** `Current Date - Due Date` but **EXCLUDING** Weekends (Sat/Sun) and Holidays.
    - **Requirement:** A new dedicated logic/flow or function to handle this calculation.

3.  **Holiday Management System:**
    - **New Component:** A system (likely a SharePoint list or Dataverse table/App screen) is required for Business Users to input and manage **Public Holiday dates**.
    - **Purpose:** These dates will be used by the Arrear Days engine to exclude non-working days from the count.

4.  **QR Code Restoration:**
    - **Reversal:** The decision to remove QR codes (Nov 14) is **REVERSED**.
    - **Requirement:** QR Codes must be included "inside" the email (likely embedded/inline) for easier payment.

**Next Steps:**
- Define the new Data Structure schema.
- Create/Update the "Holiday Master" table/list.
- Design the algorithm for the specialized Arrear Day count.
- Verify SharePoint path for QR images and update Email Flow to embed them.

---

### 6. Working Day Calendar & Day Count Implementation
**Date:** January 16-21, 2026
**Source:** Solution exports v1.0.0.6 through v1.0.0.7
**Status:** ✅ Completed

**Key Implementations:**
1. **WorkingDayCalendar Table** (`nc_thfinancecashcollectionworkingdaycalendar`)
   - Pre-generated calendar with Working Day Numbers (WDN)
   - Excludes weekends (Saturday/Sunday) and holidays
   - Used for O(1) lookup of day count calculations

2. **Day Count Calculation Engine**
   - **Formula**: `DayCount = TodayWDN - DueDateWDN`
   - Calculates business days only (excludes weekends + holidays)
   - Implemented in SAP Import flow

3. **CalendarEvents Table** (`nc_thfinancecashcollectioncalendarevent`)
   - Holiday management for Thai public holidays
   - Triggers WDN recalculation when modified

4. **New Power Automate Flows**:
   - `[THFinance] Generate Working Day Calendar` - Creates WDN entries
   - `[THFinance] RecalculateWDN(PowerApps)` - Wrapper for app integration

---

### 7. QR Code Availability Check System
**Date:** January 26, 2026
**Source:** Solution export v1.0.0.10
**Status:** ✅ Completed

**Key Implementations:**
1. **QR Availability Field** (`cr7bb_qrcodeavailable`)
   - Added to Customer table
   - Boolean field indicating if QR file exists in SharePoint

2. **QR Check Flows**:
   - `[THFinance] Check QR Availability` - Main flow scanning SharePoint
   - `[THFinance] CheckQRAvailability(PowerApps)` - Wrapper for Canvas App

3. **Canvas App Integration**:
   - "Check QR" button on scnCustomer screen
   - "QR Folder" button to open SharePoint directly
   - QR status column in customer table

**SharePoint Location**:
`/Shared Documents/Cash Customer Collection/03-QR-Codes/QR Lot 1 ver .jpeg/`

**File Naming**: `{CustomerCode}.jpg`

---

### 8. Transaction Screen FIFO Preview Enhancement
**Date:** January 26, 2026
**Source:** Solution export v1.0.0.10
**Status:** ✅ Completed

**Key Implementations:**
1. **FIFO Calculation Preview**
   - Real-time DN Total, Applied CN, Net Owed calculation
   - Customer selection required before calculation runs
   - Removed unnecessary `isExcluded` filter (always false)

2. **Template Indicator**
   - Shows which email template will be used
   - Based on max day count and MI document presence

3. **Performance Optimization**
   - Queries Dataverse directly instead of hidden gallery
   - Uses `Coalesce()` for blank handling

---

## 📦 Solution Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 1.0.0.1 | Oct 5, 2025 | Initial solution structure |
| 1.0.0.2 | Oct 8, 2025 | Basic flows and tables |
| 1.0.0.3 | Oct 8, 2025 | Complete package |
| 1.0.0.4 | Oct 13, 2025 | Flow refinements |
| 1.0.0.5 | Nov 14, 2025 | Production-ready, all screens |
| 1.0.0.6 | Jan 16, 2026 | WorkingDayCalendar table added |
| 1.0.0.7 | Jan 21, 2026 | WDN calculation in flows |
| 1.0.0.10 | Jan 26, 2026 | QR availability check, FIFO improvements |
