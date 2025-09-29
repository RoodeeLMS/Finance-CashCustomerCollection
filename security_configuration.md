# Security Configuration Guide

**Project:** Finance - Cash Customer Collection Automation
**Document:** Security Roles and Permissions Configuration
**Version:** 1.0
**Date:** September 29, 2025

## Overview

This document provides detailed instructions for configuring security roles, permissions, and access controls for the Nestlé Cash Customer Collection system in Microsoft Dataverse.

## Navigation Reference

```
Base URL: https://make.powerapps.com
Security Path: Settings (gear icon) > Advanced Settings > Settings > Security > Security Roles
Alternative: Admin Center > Environments > [Environment] > Settings > Users + permissions > Security roles
```

## Security Role Architecture

### Role Hierarchy
```
System Administrator
├── NC AR Administrator (Full system access)
├── NC AR User (Customer management + read-only processing)
├── NC System Service (Automation + bulk operations)
└── Basic User (View-only access)
```

## Security Role 1: NC AR Administrator

### Role Creation
```yaml
Navigate to: Security > Security Roles > + New

Basic Information:
  Role Name: "NC AR Administrator"
  Description: "Full administrative access to Cash Collection system"
  Business Unit: [Root Business Unit]

Copy from existing role: "System Customizer" (as starting point)
```

### Core Records Tab Permissions

#### Customer Management
```yaml
Table: nc_customers
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓

Table: nc_transactions
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓

Table: nc_emaillog
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓

Table: nc_processlog
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓
```

#### System Tables
```yaml
Table: User
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
  Append: Organization ✓
  Append To: Organization ✓
  Assign: None ✗
  Share: None ✗

Table: Team
Permissions:
  Create: Business Unit ✓
  Read: Organization ✓
  Write: Business Unit ✓
  Delete: Business Unit ✓
  Append: Business Unit ✓
  Append To: Business Unit ✓
  Assign: Business Unit ✓
  Share: Business Unit ✓

Table: Queue
Permissions:
  Create: Business Unit ✓
  Read: Organization ✓
  Write: Business Unit ✓
  Delete: Business Unit ✓
  Append: Business Unit ✓
  Append To: Business Unit ✓
  Assign: Business Unit ✓
  Share: Business Unit ✓
```

### Business Management Tab Permissions

#### SharePoint and Office Integration
```yaml
Table: SharePoint Site
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓

Table: SharePoint Document
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
  Append: Organization ✓
  Append To: Organization ✓

Table: Email Server Profile
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
```

#### Data Management
```yaml
Table: Data Import
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: Import Source File
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: Bulk Delete Operation
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
```

### Customization Tab Permissions

#### Solution Management
```yaml
Permission: Browse the Web
Access Level: Organization ✓

Permission: Bulk Edit
Access Level: Organization ✓

Permission: Export to Excel
Access Level: Organization ✓

Permission: Import Customizations
Access Level: Organization ✓

Permission: Export Customizations
Access Level: Organization ✓

Permission: Publish Customizations
Access Level: Organization ✓

Permission: Retrieve Multiple
Access Level: Organization ✓

Permission: Use Outlook Category
Access Level: Organization ✓
```

### Privacy Related Privileges

#### Data Export/Import
```yaml
Permission: Export to Excel
Access Level: Organization ✓

Permission: Print
Access Level: Organization ✓

Permission: Sync to Outlook
Access Level: Organization ✓

Permission: Use Internet Marketing module
Access Level: None ✗

Permission: View Audit History
Access Level: Organization ✓

Permission: View Audit Summary
Access Level: Organization ✓
```

## Security Role 2: NC AR User

### Role Creation
```yaml
Navigate to: Security > Security Roles > + New

Basic Information:
  Role Name: "NC AR User"
  Description: "Standard user access for AR team members"
  Business Unit: [Root Business Unit]

Copy from existing role: "Basic User" (as starting point)
```

### Core Records Tab Permissions

#### Customer Management (Full Access)
```yaml
Table: nc_customers
Permissions:
  Create: Business Unit ✓
  Read: Organization ✓
  Write: Business Unit ✓
  Delete: None ✗
  Append: Business Unit ✓
  Append To: Business Unit ✓
  Assign: Business Unit ✓
  Share: Business Unit ✓
```

#### Transaction Data (Read-Only)
```yaml
Table: nc_transactions
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
  Append: None ✗
  Append To: Organization ✓
  Assign: None ✗
  Share: None ✗

Table: nc_emaillog
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
  Append: None ✗
  Append To: Organization ✓
  Assign: None ✗
  Share: None ✗

Table: nc_processlog
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
  Append: None ✗
  Append To: Organization ✓
  Assign: None ✗
  Share: None ✗
```

### Business Management Tab Permissions

#### Limited Business Access
```yaml
Table: SharePoint Document
Permissions:
  Create: User ✓
  Read: Organization ✓
  Write: User ✓
  Delete: User ✓

Table: Queue
Permissions:
  Create: None ✗
  Read: Business Unit ✓
  Write: None ✗
  Delete: None ✗

Permission: Export to Excel
Access Level: Business Unit ✓

Permission: Print
Access Level: Organization ✓

Permission: Use Outlook Category
Access Level: User ✓
```

## Security Role 3: NC System Service

### Role Creation
```yaml
Navigate to: Security > Security Roles > + New

Basic Information:
  Role Name: "NC System Service"
  Description: "Service account for Power Automate and system processes"
  Business Unit: [Root Business Unit]

Copy from existing role: "System Customizer" (as starting point)
```

### Core Records Tab Permissions

#### Customer Data (Read + Append)
```yaml
Table: nc_customers
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
  Append: None ✗
  Append To: Organization ✓
  Assign: None ✗
  Share: None ✗
```

#### Transaction Processing (Full Access)
```yaml
Table: nc_transactions
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Business Unit ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓

Table: nc_emaillog
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Business Unit ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓

Table: nc_processlog
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Business Unit ✓
  Append: Organization ✓
  Append To: Organization ✓
  Assign: Organization ✓
  Share: Organization ✓
```

### Business Management Tab Permissions

#### System Operations
```yaml
Table: System Job
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: Bulk Delete Operation
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: Data Import
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: Import Source File
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓
```

#### Email and SharePoint Integration
```yaml
Table: Email
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: SharePoint Document
Permissions:
  Create: Organization ✓
  Read: Organization ✓
  Write: Organization ✓
  Delete: Organization ✓

Table: SharePoint Site
Permissions:
  Create: None ✗
  Read: Organization ✓
  Write: None ✗
  Delete: None ✗
```

### Privacy Related Privileges

#### Bulk Operations
```yaml
Permission: Bulk Edit
Access Level: Organization ✓

Permission: Bulk Delete
Access Level: Organization ✓

Permission: Export to Excel
Access Level: Organization ✓

Permission: Retrieve Multiple
Access Level: Organization ✓

Permission: Browse the Web
Access Level: Organization ✓
```

## User Assignment Configuration

### User Role Assignment Process
```yaml
Navigate to: Settings > Security > Users > [Select User] > Manage Roles

Assignment Matrix:
├── AR Team Members:
│   ├── Primary Role: "NC AR User"
│   └── Additional: "Basic User"
├── AR Managers:
│   ├── Primary Role: "NC AR Administrator"
│   └── Additional: "NC AR User", "Basic User"
├── Power Automate Service Account:
│   ├── Primary Role: "NC System Service"
│   └── Additional: "Basic User"
└── System Administrators:
    ├── Primary Role: "System Administrator"
    └── Additional: "NC AR Administrator"
```

### Service Account Configuration

#### Create Service Account
```yaml
Navigate to: Azure Active Directory > Users > + New user

User Details:
  User name: "svc-nestlecollection@[tenant].onmicrosoft.com"
  Name: "Nestle Collection Service"
  Password: [Generate secure password]
  Account enabled: Yes
  Roles: None (will be assigned in Power Platform)

Power Platform Assignment:
  Environment: [Collection Environment]
  Security Roles: "NC System Service", "Basic User"
  License: "Power Automate per user" or "Power Platform"
```

## Field-Level Security

### Enable Field Security
```yaml
Navigate to: Settings > Customization > Customize the System
Select: Entities > [Table] > Fields > [Field] > General tab

Enable Security: Yes

For sensitive fields:
├── nc_customers.nc_customeremail1 (Enable: Yes)
├── nc_customers.nc_salesemail1 (Enable: Yes)
├── nc_customers.nc_arbackupemail1 (Enable: Yes)
├── nc_emaillog.nc_recipientemails (Enable: Yes)
└── nc_emaillog.nc_ccemails (Enable: Yes)
```

### Create Field Security Profiles
```yaml
Navigate to: Settings > Security > Field Security Profiles > + New

Profile 1: "Email Access Profile"
Description: "Access to customer and email fields"

Add Teams/Users:
├── AR Administrator Team
├── AR User Team
└── System Service Account

Secured Fields:
├── Customer Email 1: Read ✓, Update ✓
├── Sales Email 1: Read ✓, Update ✓
├── AR Backup Email 1: Read ✓, Update ✓
├── Recipient Emails: Read ✓, Update ✗
└── CC Emails: Read ✓, Update ✗
```

## Data Loss Prevention (DLP) Policy

### Create DLP Policy
```yaml
Navigate to: Power Platform Admin Center > Data policies > + New policy

Policy Configuration:
  Name: "Nestle Finance Collection DLP"
  Description: "Data protection for customer collection system"
  Scope: "Add environments" > [Select Collection Environment]

Connector Classification:
Business Data Group:
├── Microsoft Dataverse
├── SharePoint
├── Office 365 Outlook
├── Excel Online (Business)
├── Office 365 Users
└── Approvals

Non-Business Data Group:
├── [All other connectors]

Blocked Connectors:
├── Facebook
├── Twitter
├── Instagram
├── Any file sharing services (except SharePoint)
└── Public cloud storage services
```

## Audit Configuration

### Enable Auditing
```yaml
Navigate to: Settings > Auditing > Global Audit Settings

Enable Auditing For:
├── Start Auditing: Yes ✓
├── Audit user access: Yes ✓
├── Log access in Microsoft 365: Yes ✓

Entity-Level Auditing:
├── nc_customers: Yes ✓
├── nc_transactions: Yes ✓
├── nc_emaillog: Yes ✓
├── nc_processlog: Yes ✓
├── User: Yes ✓
└── Security Role: Yes ✓

Attribute-Level Auditing:
├── All email fields: Yes ✓
├── Amount fields: Yes ✓
├── Status fields: Yes ✓
└── Created/Modified fields: Yes ✓
```

## Testing Security Configuration

### Security Test Cases

#### Test Case 1: AR User Access
```yaml
Test User: AR User account
Expected Results:
├── Can create/edit customers: ✓
├── Can view transactions (read-only): ✓
├── Cannot delete transactions: ✗
├── Can view email logs: ✓
├── Cannot modify system settings: ✗
└── Can export customer data: ✓
```

#### Test Case 2: System Service Access
```yaml
Test User: Service account
Expected Results:
├── Can create transactions: ✓
├── Can create email logs: ✓
├── Can read customer data: ✓
├── Cannot modify customers: ✗
├── Can perform bulk operations: ✓
└── Can access SharePoint: ✓
```

#### Test Case 3: Field-Level Security
```yaml
Test User: Basic User (no email access)
Expected Results:
├── Can view customer names: ✓
├── Cannot view email addresses: ✗
├── Cannot edit any customer data: ✗
├── Can view transaction amounts: ✓
└── Cannot view email logs: ✗
```

## Security Maintenance

### Regular Security Reviews

#### Monthly Tasks
```yaml
Review Checklist:
├── User access review (joiners/leavers)
├── Role assignment verification
├── Failed login analysis
├── Data access pattern review
└── DLP policy compliance check
```

#### Quarterly Tasks
```yaml
Comprehensive Review:
├── Security role permission audit
├── Field-level security review
├── Service account credential rotation
├── Audit log analysis
└── Penetration testing (if required)
```

### Emergency Procedures

#### Security Incident Response
```yaml
Immediate Actions:
├── Disable affected user accounts
├── Review audit logs for unauthorized access
├── Change service account credentials
├── Notify stakeholders
└── Document incident details

Investigation Steps:
├── Export relevant audit data
├── Analyze access patterns
├── Review email logs for data exfiltration
├── Check for unauthorized downloads
└── Coordinate with IT security team
```

---

**Security Status:** Ready for Implementation
**Estimated Time:** 2-3 hours for complete security setup
**Dependencies:** Dataverse environment, user accounts, team structure