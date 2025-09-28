# Development Plan: Automated Customer Collection Email System

**Project:** Finance - Cash Customer Collection Automation  
**Total Duration:** 25 business days (5 weeks)  
**Developer:** Nick Chamnong, Vector Dynamics Co., Ltd  
**Created:** September 26, 2025  

## Project Task Breakdown - 25 Days Development Plan

### **Week 1: Foundation & Setup (Days 1-5)**
**Focus: Environment setup, data collection, and architectural decisions**

#### Environment Setup (Days 1-2)
- ✅ **[NICK]** Set up development environment - SharePoint site and permissions (COMPLETED)
- 🔄 **[CLIENT/NICK]** Provision Dataverse environment and verify licensing (IN PROGRESS)
- ✅ **[NICK]** Create SharePoint folder for daily file sharing (COMPLETED)

#### Data Collection (Days 2-3) - **CLIENT TEAM RESPONSIBILITY**
- ⏳ **[CLIENT]** Collect customer master data samples (cleaned/anonymized)
- ⏳ **[CLIENT]** Obtain multiple days of SAP extract samples
- ⏳ **[CLIENT]** Get QR code folder access and analyze naming conventions
- ⏳ **[CLIENT]** Collect email template examples (PowerPoint/Word)

#### Architecture & Design (Days 4-5)
- ⏳ **[CLIENT/NICK]** Finalize data maintenance strategy with stakeholders
- ⏳ **[NICK]** Design Dataverse schema (customers, transactions, audit)
- ⏳ **[NICK]** Design Power Automate flow architecture

### **Week 2: Core Development - Data Platform (Days 6-10)**
**Focus: Dataverse implementation and core business logic**

#### Database Development (Days 6-7)
- ⏳ **[NICK]** Create Dataverse tables (Customer Master, Transaction Data, Audit Log)
- ⏳ **[NICK]** Configure security roles and business rules for validation

#### Core Business Logic (Days 8-10)
- ⏳ **[NICK]** Build Excel file ingestion flow for SAP data processing
- ⏳ **[NICK]** Implement exclude keyword detection and filtering logic
- ⏳ **[NICK]** Build CN/DN categorization and FIFO sorting algorithms
- ⏳ **[NICK]** Implement day counting system for notification tracking

### **Week 3: Advanced Logic & Email Engine (Days 11-15)**
**Focus: Email processing and delivery system**

#### Decision Logic & Templates (Days 11-12)
- ✅ Create send/don't send decision logic
- ✅ Build dynamic email template selection engine

#### Email Integration (Days 13-15)
- ✅ Implement QR code lookup and attachment functionality
- ✅ Build Office 365 integration for AR contact signatures
- ✅ Create email composition and sending flow with error handling

### **Week 4: User Interface & Testing (Days 16-20)**
**Focus: Model-Driven App and comprehensive testing**

#### App Development (Days 16-17)
- ✅ Create Model-Driven App solution and navigation
- ✅ Build AR Control Center dashboard
- ✅ Create customer data management forms and views

#### Testing Preparation (Days 18-20)
- ✅ Implement manual payment logging interface
- ✅ Add audit trail viewing and reporting capabilities
- ✅ Create comprehensive test data set with edge cases
- ✅ Develop UAT test cases and scenarios documentation

### **Week 5: UAT & Go-Live Support (Days 21-25)**
**Focus: User acceptance testing and production deployment**

#### Testing & Validation (Days 21-22)
- ✅ Set up testing environment with sample data
- ✅ Conduct unit testing of business logic components
- ✅ Execute integration testing of complete workflow
- ✅ Perform email delivery testing to AR team accounts

#### Deployment & Training (Days 23-25)
- ✅ Prepare production environment and security configuration
- ✅ Deploy solution to production Dataverse environment
- ✅ Configure production data connections and permissions
- ✅ Execute go-live with first production run monitoring

### **Ongoing Documentation & Training Tasks**
**To be completed in parallel throughout development**

#### Documentation Package
- ✅ Create user guides for AR team daily operations
- ✅ Write administrative procedures for IT support team
- ✅ Develop troubleshooting guide for common issues
- ✅ Create technical documentation for future maintenance

#### Knowledge Transfer
- ✅ Conduct AR team training on new system operations
- ✅ Train IT support team on system administration
- ✅ Create knowledge transfer sessions for key stakeholders

## **Task Details by Category**

### **Setup & Architecture Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| setup-001 | Set up development environment - SharePoint site creation and permissions configuration | 1 | Critical |
| setup-002 | Provision Dataverse environment and verify Power Platform licensing | 1 | Critical |
| setup-003 | Create SharePoint folder for daily file sharing with AR team access | 1 | High |
| arch-001 | Finalize data maintenance strategy decision (Excel vs Database) with stakeholders | 1 | Critical |
| arch-002 | Design Dataverse schema for customers, transactions, and audit tables | 1 | Critical |
| arch-003 | Design Power Automate flow architecture and error handling strategy | 1 | Critical |

### **Data Collection Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| data-001 | Collect and analyze customer master data samples (cleaned/anonymized) | 1 | Critical |
| data-002 | Obtain multiple days of SAP extract samples for testing | 1 | Critical |
| data-003 | Get access to QR code folder and analyze file naming conventions | 1 | High |
| data-004 | Collect email template examples (PowerPoint/Word formats) | 1 | High |

### **Core Development Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| dev-001 | Create Dataverse tables - Customer Master, Transaction Data, Audit Log | 2 | Critical |
| dev-002 | Configure security roles and business rules for data validation | 2 | Critical |
| dev-003 | Build Excel file ingestion flow for daily SAP data processing | 2 | Critical |
| dev-004 | Implement exclude keyword detection and filtering logic | 2 | Critical |
| dev-005 | Build CN/DN categorization and FIFO sorting algorithms | 2 | Critical |
| dev-006 | Implement day counting system for tracking notification frequency | 2 | Critical |
| dev-007 | Create send/don't send decision logic based on business rules | 3 | Critical |
| dev-008 | Build dynamic email template selection engine | 3 | Critical |
| dev-009 | Implement QR code lookup and attachment functionality | 3 | High |
| dev-010 | Build Office 365 integration for AR contact signatures | 3 | High |
| dev-011 | Create email composition and sending flow with error handling | 3 | Critical |

### **Application Development Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| app-001 | Create Model-Driven App solution and configure navigation | 4 | High |
| app-002 | Build AR Control Center dashboard for monitoring daily runs | 4 | High |
| app-003 | Create customer data management forms and views | 4 | High |
| app-004 | Implement manual payment logging interface | 4 | Medium |
| app-005 | Add audit trail viewing and reporting capabilities | 4 | Medium |

### **Testing Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| test-001 | Create comprehensive test data set with edge cases | 4 | Critical |
| test-002 | Develop UAT test cases and scenarios documentation | 4 | Critical |
| test-003 | Set up testing environment with sample customer data | 5 | Critical |
| test-004 | Conduct unit testing of business logic components | 5 | Critical |
| test-005 | Execute integration testing of complete workflow | 5 | Critical |
| test-006 | Perform email delivery testing to AR team accounts | 5 | Critical |

### **Deployment Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| deploy-001 | Prepare production environment and security configuration | 5 | Critical |
| deploy-002 | Deploy solution to production Dataverse environment | 5 | Critical |
| deploy-003 | Configure production data connections and permissions | 5 | Critical |
| deploy-004 | Execute go-live with first production run monitoring | 5 | Critical |

### **Documentation Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| doc-001 | Create user guides for AR team - daily operations | 1-5 | High |
| doc-002 | Write administrative procedures for IT support team | 1-5 | High |
| doc-003 | Develop troubleshooting guide for common issues | 1-5 | Medium |
| doc-004 | Create technical documentation for future maintenance | 1-5 | Medium |

### **Training Tasks**
| Task ID | Description | Week | Priority |
|---------|-------------|------|----------|
| train-001 | Conduct AR team training on new system operations | 5 | Critical |
| train-002 | Train IT support team on system administration | 5 | High |
| train-003 | Create knowledge transfer sessions for key stakeholders | 5 | High |

## **Critical Path Dependencies**

### Must Complete Before Week 2:
- Data maintenance strategy decision (Excel vs Database)
- Sample data collection and analysis
- Dataverse environment provisioning

### Must Complete Before Week 3:
- Core business logic validation
- FIFO and exclusion logic testing
- Day counting system verification

### Must Complete Before Week 4:
- Email template engine completion
- QR code integration working
- Complete workflow integration testing

### Must Complete Before Week 5:
- Model-Driven App user interface
- All UAT test cases prepared
- Production environment configured

## **Risk Mitigation Built Into Plan**

1. **Week 1 buffer**: Extra time for stakeholder decisions and data collection
2. **Parallel documentation**: Documentation tasks run throughout development
3. **Testing emphasis**: Full week dedicated to UAT and go-live support
4. **Incremental validation**: Each week builds on validated components from previous week

## **Success Criteria by Week**

- **Week 1**: All environments ready, all sample data collected, architecture approved
- **Week 2**: Core business logic working with test data
- **Week 3**: Complete email generation and sending capability
- **Week 4**: Full user interface and comprehensive testing completed
- **Week 5**: Production system deployed and AR team trained

## **Daily Standup Questions**

### For Developer (Nick):
1. What did I complete yesterday?
2. What am I working on today?
3. Are there any blockers preventing progress?
4. Do I need stakeholder input or decisions?

### For Stakeholders (AR Team):
1. What feedback/decisions are needed from our side?
2. Are sample data and access ready as committed?
3. Any changes to business requirements?
4. Are we on track for UAT availability in Week 5?

## **Deliverable Checklist**

### Week 1 Deliverables:
- [ ] Development environment configured and accessible
- [ ] All sample data collected and analyzed
- [ ] Dataverse schema design document approved
- [ ] Data maintenance strategy decision documented

### Week 2 Deliverables:
- [ ] Dataverse tables created and configured
- [ ] Excel ingestion flow operational
- [ ] Core business logic implemented and unit tested
- [ ] Day counting algorithm validated

### Week 3 Deliverables:
- [ ] Complete email generation workflow
- [ ] QR code integration functional
- [ ] Template selection engine operational
- [ ] End-to-end flow working in development

### Week 4 Deliverables:
- [ ] Model-Driven App deployed to test environment
- [ ] All user interfaces completed
- [ ] Comprehensive test data prepared
- [ ] UAT test cases documented

### Week 5 Deliverables:
- [ ] Production system deployed and operational
- [ ] All testing completed and signed off
- [ ] User training completed
- [ ] Go-live support provided
- [ ] Technical documentation delivered

## **Change Management Process**

### Scope Changes:
1. Document requested change with business justification
2. Assess impact on timeline and deliverables
3. Get stakeholder approval for timeline adjustments
4. Update project plan and communicate changes

### Issue Escalation:
1. **Level 1**: Developer → Business Sponsor (Changsalak Alisara)
2. **Level 2**: Business Sponsor → IT Finance (Arayasomboon Chalitda)
3. **Level 3**: IT Finance → Credit Management (Nawawitrattana Siri)

---

**Document Version:** 1.0  
**Last Updated:** September 26, 2025  
**Next Review:** End of Week 1 (October 3, 2025)  
**Approved By:** [Pending stakeholder approval]
