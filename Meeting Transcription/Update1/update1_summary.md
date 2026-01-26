# Meeting Summary: Project Resumption (Phase 2)

**Date:** January 2026  
**Status:** Active  
**Focus:** Handling new requirements for Data Input, Arrear Calculations, and Holiday Management.

## 1. Executive Summary
The "Cash Customer Collection" project is resuming after a hold period. The core email automation is functional, but the business logic and data ingestion methods are undergoing significant changes. The previous specific logic for "Input Excel from SAP" is being deprecated in favor of a new data structure. Additionally, more sophisticated date logic (Arrear Days) is required.

## 2. Key Changes & Requirements

### A. Data Input Refactoring
- **Change:** The current process (Power Automate Desktop fetching FBL5N Excel) is being replaced or heavily modified.
- **Impact:** 
    - The "Input Excel" format will change.
    - Cloud Flows parsing the Excel files must be updated to match the new schema.
    - Need to define the new "Source of Truth" for the collection data.

### B. Arrear Days Calculation Engine
- **Requirement:** Calculate "Days Past Due" more accurately than a simple `DateDiff`.
- **Logic:** `Arrear Days = Current Date - Due Date`
- **Exclusions:** The calculation **MUST** exclude:
    - Weekends (Saturday, Sunday)
    - Public Holidays (Dynamic list)
- **Implementation:** Likely requires a dedicated Power Automate Child Flow or a Custom Function (if using Power Apps).

### C. Holiday Management System
- **New Feature:** A user-friendly interface for managing the "Public Holiday" dates used by the Arrear Days engine.
- **Components:**
    - **Back-end:** SharePoint List or Dataverse Table (Name: `HolidayMaster`).
    - **Front-end:** A Power App screen or a simple SharePoint grid for Business Users (e.g., Credit Management team) to Add/Remove holidays.

## 3. Action Plan
1.  **Define Schema:** Obtain/Designing the new Input File column structure.
2.  **Create Holiday Master:** Set up the `HolidayMaster` SharePoint list.
3.  **Develop Arrear Logic:** Build the flow logic to iterate days and check against Weekends/Holidays.
4.  **Update Main Flow:** Integrate the new input parsing and arrear calculation into the main "Cash Customer Collection" Cloud Flow.
