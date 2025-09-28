# ![][image1]

# 

# 

# Automated Customer Collection Email Power App 

**Prepared For**  
Pichayavadee (K.Bell) Sithinamsuwan  
Nestlé (Thai) Ltd.

**Prepared By**  
Nick Chamnong  
Vector Dynamics Co.,Ltd

# Table of Contents

[**Executive Summary	1**](#executive-summary)

[**Project Background	2**](#project-background)

[**User Roles and Access Requirements	2**](#user-roles-and-access-requirements)

[**Scope of Work	3**](#scope-of-work)

[Core Components	3](#core-components)

[**Project Timeline	4**](#project-timeline)

[Milestone Schedule	4](#milestone-schedule)

[**Resource Proposal	4**](#resource-proposal)

[**Support and Maintenance	5**](#support-and-maintenance)

# 

# Executive Summary {#executive-summary}

This proposal details the development of a focused **Automated Collections Power App**. The solution will be architected on the **Microsoft Power Platform**, leveraging a secure **Dataverse** database, a core **Power Automate** workflow engine, and a **Model-Driven Power App** as a control center for the Accounts Receivable (AR) team.

This application is designed to automate the daily process of sending payment reminders to cash customers. It will handle data ingestion, apply key business logic, and send customized email reminders. To focus resources on a stable and thoroughly tested rollout, all custom reporting and analytics (Power BI) have been removed from this project's scope.

The project timeline dedicates a significant two-week period to **User Acceptance Testing (UAT) and go-live support** to ensure the highest level of quality and user adoption. The total estimated effort is **25 mandays**. The proposal includes one year of support and maintenance.

---

# 

# Project Background {#project-background}

The Accounts Receivable (AR) department currently undertakes a time-consuming, manual, and error-prone process to manage daily collections for cash customers. This involves manually exporting data from SAP, cleaning it in Excel, calculating balances, and manually composing and sending individual emails.

The key objectives are to:

* Eliminate manual data processing and email generation to save significant daily operational hours.  
* Ensure the consistent and accurate application of business rules for collections.  
* Provide a full audit trail of all automated collection activities.  
* Create a scalable and maintainable solution that can adapt to future needs.

---

# User Roles and Access Requirements {#user-roles-and-access-requirements}

The system will primarily be managed by the AR team and IT, with two key roles:

1. **AR Team Member:** Uses the Model-Driven App to oversee the daily run, log manual payments or exceptions, review customer communication history, and manage customer contact details.  
2. **System Admin:** Has full access to the backend configuration, including the ability to modify email templates, manage user access, and troubleshoot the Power Automate flow.

---

# 

# Scope of Work {#scope-of-work}

#### **Core Components** {#core-components}

* **Core Platform & Dataverse Model: 5 days**  
    
  * Design and setup of a robust Dataverse model including tables for: Customers, Invoice Transactions, Manual Payments, Email Templates, and Automation Run Logs.  
  * Configuration of table relationships, security roles, and business rules.


* **The "Collections Engine" (Power Automate Flow): 5 days**  
    
  * Development of a scheduled cloud flow to serve as the core automation engine.  
  * **Logic includes:** Excel file ingestion, reconciliation, and the core logic for applying payments and sending templated emails.  
  * Standard error handling and logging for the automated run.


* **AR Control Center (Model-Driven App): 5 days**  
    
  * Development of a user-friendly Model-Driven App for the AR team.  
  * Includes dashboards to monitor daily runs, and views/forms to manage customer data and log manual payments.


* **UAT & Go-Live Support: 10 days**  
    
  * A dedicated two-week phase for supporting User Acceptance Testing (UAT). This includes providing guidance to testers, addressing user feedback, resolving any identified issues, and making necessary adjustments. This phase also covers support during the initial production rollout to monitor the first live automation runs and ensure a smooth transition.


* **Out of Scope:**  
    
  * All custom reporting and analytics dashboards (e.g., Power BI) are excluded from this project scope.

---

# Project Timeline {#project-timeline}

#### **Milestone Schedule** {#milestone-schedule}

* **Project Duration:** 25 business days / 5 weeks  
    
* **Weeks 1-3 (15 business days): Core Development Phase**  
    
  * This phase includes the project kickoff, requirements validation, and the complete build-out of all technical components:  
    * Dataverse Platform and Data Model Setup.  
    * Development of the Power Automate "Collections Engine."  
    * Development of the Model-Driven "AR Control Center."  
  * The phase concludes with internal testing and deployment to the UAT environment.


* **Weeks 4-5 (10 business days): UAT & Go-Live Support Phase**  
    
  * This phase is dedicated to ensuring the solution meets business requirements and is stable for production.  
  * The development team will actively support business users during UAT, manage feedback, and implement necessary fixes.  
  * Concludes with go-live support to ensure a successful launch.

---

# Resource Proposal {#resource-proposal}

This proposal assumes a standard project timeline.

* **Total Effort:** **25 mandays** *(15 days for development \+ 10 days for UAT & Go-Live Support)*

---

# 

# Support and Maintenance {#support-and-maintenance}

* **One-Year Support Package (Included in Base Estimate)**  
  * **Issue Resolution:** Bug fixes and troubleshooting for all features within the defined scope.  
  * **Configuration Support:** Minor adjustments and configuration changes (e.g., modifying email templates).  
  * **User Assistance:** Phone and email support during standard business hours for user queries related to application functionality.  
    

[image1]: <data:image/png;base64,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>