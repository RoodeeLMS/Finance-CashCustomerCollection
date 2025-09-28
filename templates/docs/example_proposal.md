

# Automated Payment Approval Proposal 


# Executive Summary {#executive-summary}

This proposal details the development of an **Automated Payment Approval Workflow**. To provide maximum flexibility, we are presenting two distinct solution paths: a **Core Automation Engine** that automates the backend process and uses PDF attachments for approvals, and a **Full Application Suite** that includes a dedicated Power App for comprehensive monitoring and control.

Both solutions will be built on the Microsoft Power Platform, leveraging **Microsoft SharePoint** as the central data repository and **Microsoft Power Automate** as the orchestration engine, in line with the decisions made during the project meeting.

This new system will replace the current manual process, digitizing the workflow to ensure data integrity and create a compliant audit trail. The "Core Automation" path includes the generation of static PDF documents for approvers, while the "Full Application" path leverages dynamic links to a live portal for a more modern experience.

The total estimated effort ranges from **18 to 22 mandays**, depending on the final combination of options selected. Each path is followed by one year of comprehensive support and maintenance.

---

### 

# Project Background {#project-background}

The Sales and Trade Operations teams require a single, reliable, and efficient platform to manage the payment approval process for visibility and display incentives. The current process is manual and fragmented, relying on passing Excel files between teams. This leads to data integrity issues, makes tracking approval statuses difficult, and creates an inefficient loop of reminders and follow-ups.

Furthermore, the existing process lacks a centralized, easily auditable trail, which is a critical requirement for Finance, the Controller, and internal audit teams.

The key objectives are to:

* Develop an automated application to manage the distribution and collection of payment approval requests.  
* Establish a stable, auditable single source of truth for all payment and approval data on SharePoint.  
* Automate all handoffs between the Trade Ops team, regional reviewers (RFOEs), the final approver, and Accounts Receivable (AR).  
* Provide a compliant audit repository for all decisions, comments, and timestamps.

# User Roles and Access Requirements {#user-roles-and-access-requirements}

The application will support the following key user roles:

1. **Trade Ops Admin:** Initiates the monthly process, monitors the workflow, and manages any exceptions.  
2. **Regional Manager (RFOE \- Reviewer):** Receives automated notifications to review and approve/reject payment data for their specific region.  
3. **Senior Manager (Final Approver):** Receives a final approval request after all regional managers have approved.  
4. **Accounts Receivable / Controller (Auditor):** Has read-only access to the final, approved data and the comprehensive audit log in SharePoint.

---

### 

# Proposed Solution Paths {#proposed-solution-paths}

We propose two primary options for the user interface and workflow management, built upon a common technical foundation.

|  | Option 1: Core Automation Engine | Option 2: Full Application Suite (Recommended) |
| :---- | :---- | :---- |
| **User Experience** | A "headless" automation. Users interact through **Microsoft Teams/Email**. Approvers receive a **static PDF attachment** to review and approve/reject directly from the notification. | A **dedicated Canvas Power App** serves as the "Mission Control." Approvers receive a **dynamic link** to the app to review live data. |
| **Monitoring & Control** | Monitoring is done by viewing the SharePoint list's status column. There are **no built-in administrative controls** for managing the workflow. | Admins have a **real-time dashboard** in the Power App to monitor all approvals. They have controls to **reassign or cancel tasks**, providing critical exception handling. |
| **Best For** | Closely replicating the current document-based process while achieving full automation and auditability at the lowest cost. | A more robust, user-friendly, and scalable solution that provides superior visibility and control, creating a true business application. |

---

### 

# Scope of Work {#scope-of-work}

**Part A: Core Foundation (Required for Both Options)**

* **SharePoint Data Foundation (3 days):** Design and setup of SharePoint Lists for Payment Data, Approval Tasks, and Audit History.  
* **Power BI Integration (3 days):** Reconfigure the existing Power BI report to connect to the new SharePoint List data source.  
* **Core Orchestration Engine (5 days):** Development of the foundational Power Automate flow for managing the approval state, handling parallel approvals, and logging all actions to SharePoint.

**Part B: User Interface Options (Choose One)**

* **Option 1 \- Core Automation with PDF Generation (3 days):**  
    
  * Development of rich Adaptive Cards for notifications in Microsoft Teams and Email.  
  * The workflow will automatically generate a unique, filtered **PDF for each regional approver**, which will be attached to their notification email for review.


* **Option 2 \- Full Power App (5 days):**  
    
  * Development of a Canvas Power App with an **Admin Dashboard** for monitoring/control and a **"My Tasks" view** for approvers. Approvers will use a dynamic link to review live, filtered data within the app.

---

### 

# Project Timeline {#project-timeline}

The project duration will depend on the option selected:

* **Core Automation Engine:** Approximately **4-5 weeks**.  
* **Full Application Suite:** Approximately **5 weeks**.

The final week of either timeline will be dedicated to User Acceptance Testing (UAT) and Go-Live Support.

# Resource Proposal {#resource-proposal}

The final effort is calculated by combining the Core Foundation with your selected UI option.

| Component | Mandays |
| :---- | :---- |
| **Part A: Core Foundation (Fixed)** | **11** |
| **Part B: User Interface (Choose One)** |  |
|     Option 1: Core Automation with PDF | \+3 |
|     Option 2: Full Power App | \+5 |
| **UAT & Go-Live Support (Fixed)** | **4** |

**Final Scenarios:**

* **Path 1 \- Core Automation Engine:** Core Foundation (11) \+ Core UI with PDF (3) \+ UAT (4) \= **18 mandays**  
* **Path 2 \- Full Application Suite:** Core Foundation (11) \+ Full App (5) \+ UAT (4) \= **20 mandays**

**Optional Add-on for Path 2:**

* If PDF attachments for approvers are also desired in the Full App solution, this can be added for an additional **2 mandays**, bringing the Path 2 total to **22 mandays**.

---

# Support and Maintenance {#support-and-maintenance}

* **One-Year Support Package (Included in Base Estimate)**  
  * **Issue Resolution:** Bug fixes and troubleshooting for all features within the defined scope.  
  * **Configuration Support:** Minor adjustments and configuration changes.  
  * **User Assistance:** Phone and email support during standard business hours.

