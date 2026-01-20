# Next Steps - Project Resumption (January 2026)
**Date:** January 8, 2026  
**Status:** 🚀 Active - Phase 2 Implementation  

---

## 📍 Current Context
The project has resumed with **significant new requirements** that supersede the November 2025 status.
**Major Update:** QR Code functionality, previously descoped, is **BACK IN SCOPE**.

---

## 🎯 Phase 2 Objectives

### 1. Data Input Refactoring
- **Task:** Adapt the cloud flow to a new Input Data Schema.
- **Why:** The upstream data source (SAP Excel) is changing.
- **Action:** Obtain new sample file & update Power Automate parsers.

### 2. Arrear Days Calculation Engine
- **Task:** Implement `Arrear Days = Today - Due Date` (excluding Weekends & Holidays).
- **Why:** Business requires accurate aging for collection prioritization.
- **Action:** Build logic (Child Flow) using `HolidayMaster`.

### 3. Holiday Management System
- **Task:** Create a system for Business Users to manage Holiday dates.
- **Why:** Required for Arrear Calculation.
- **Action:** Create `HolidayMaster` (SharePoint List) + Admin Screen.

### 4. QR Code Integration (Restored)
- **Task:** Ensure QR Codes are sent "inside" the email.
- **Current State:** Code exists to *attach* the file, but the SharePoint path seems suspicious (`/QR Lot 1 ver .jpeg/`).
- **Action:** 
    - Verify SharePoint Path.
    - Update logic to **Embed** the image (Inline) instead of just attaching, if "inside" implies visual visibility.

---

## ⚠️ Immediate Action Items
1.  **Holiday Master:** Create the SharePoint List & Fill with 2026 Data.
2.  **QR Code Path:** specific the correct folder name for QR images in SharePoint.
3.  **Input Schema:** Get the new Data Spec.

---

## 🗓️ Implementation Roadmap
| Step | Task | Status |
| :--- | :--- | :--- |
| 1 | Create `HolidayMaster` List & Data | 🟡 Ready |
| 2 | Prototype [Arrear Days] Logic | 🟡 Ready |
| 3 | **Fix QR Code Path & Embedding** | 🔴 Pending Info |
| 4 | Obtain New Input Data Sample | 🔴 Pending |
| 5 | Update Main Flow | 🔴 Pending |

---

**Next Action:** 
I will start with **Step 1 (Holiday Master)** and **Step 2 (Arrear Logic)** while waiting for the Data Sample and QR Path confirmation.
