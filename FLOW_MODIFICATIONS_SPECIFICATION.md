# Power Automate Flow Modifications Specification

**Created**: 2025-10-13
**Purpose**: Complete specification for editing 6 Power Automate flows
**Version**: 1.0.0.4
**Status**: Blueprint - Ready for Implementation

---

## 📋 **Overview**

**Total Flows**: 6 (2 existing to modify + 4 new to build)

**New Database Fields Added**:
1. EmailLog: `cr7bb_approvalstatus` (Choice), `cr7bb_emailbodypreview` (Text)
2. Transaction: `cr7bb_sourcefilename` (Text), `cr7bb_sourcefilepath` (Text)
3. Process Log: `cr7bb_sourcefilepath` (Text)
4. Process Log: `cr7bb_status` expanded (File Not Found, File Already Processed, Completed with errors)

---

## 🔧 **Flow 1: SAP Import Flow (MODIFY EXISTING)**

**File**: `THFinanceCashCollectionDailySAPTransactionImport-*.json`

### **Current Behavior:**
- Runs daily at 8:00 AM
- Reads Excel from SharePoint
- Creates transaction records in Dataverse
- Tracks batch ID and process date

### **Required Changes:**

#### **A. Add Filename Tracking Variables**
**Location**: After Initialize_varBatchID

```json
"Initialize_varSourceFileName": {
  "runAfter": {
    "Initialize_varBatchID": ["Succeeded"]
  },
  "type": "InitializeVariable",
  "inputs": {
    "variables": [{
      "name": "varSourceFileName",
      "type": "string",
      "value": ""
    }]
  }
},
"Initialize_varSourceFilePath": {
  "runAfter": {
    "Initialize_varSourceFileName": ["Succeeded"]
  },
  "type": "InitializeVariable",
  "inputs": {
    "variables": [{
      "name": "varSourceFilePath",
      "type": "string",
      "value": ""
    }]
  }
}
```

#### **B. Get Excel File and Extract Metadata**
**Location**: After variable initialization, before reading Excel

**Find**: The action that gets/lists files from SharePoint
**Add After**: Set filename variables

```json
"Set_varSourceFileName": {
  "runAfter": {
    "Get_Excel_File_Action": ["Succeeded"]
  },
  "type": "SetVariable",
  "inputs": {
    "name": "varSourceFileName",
    "value": "@outputs('Get_Excel_File_Action')?['body/Name']"
  }
},
"Set_varSourceFilePath": {
  "runAfter": {
    "Set_varSourceFileName": ["Succeeded"]
  },
  "type": "SetVariable",
  "inputs": {
    "name": "varSourceFilePath",
    "value": "@outputs('Get_Excel_File_Action')?['body/Path']"
  }
}
```

#### **C. Check if File Already Processed**
**Location**: Before reading Excel data

```json
"Condition_File_Already_Processed": {
  "actions": {
    "Update_ProcessLog_FileAlreadyProcessed": {
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "UpdateRecord"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectionprocesslogs",
          "recordId": "@outputs('Create_ProcessLog')?['body/cr7bb_thfinancecashcollectionprocesslogid']",
          "item/cr7bb_status": 676180005,
          "item/cr7bb_endtime": "@utcNow()"
        }
      }
    },
    "Terminate_Already_Processed": {
      "runAfter": {
        "Update_ProcessLog_FileAlreadyProcessed": ["Succeeded"]
      },
      "type": "Terminate",
      "inputs": {
        "runStatus": "Succeeded"
      }
    }
  },
  "runAfter": {
    "Set_varSourceFilePath": ["Succeeded"]
  },
  "expression": {
    "contains": [
      "@variables('varSourceFileName')",
      "_Processed"
    ]
  },
  "type": "If"
}
```

#### **D. Add Filename to Transaction Records**
**Location**: Inside "Apply to each" loop where transactions are created

**Find**: The Patch/CreateRecord action for transactions
**Add Fields**:

```json
"item/cr7bb_sourcefilename": "@variables('varSourceFileName')",
"item/cr7bb_sourcefilepath": "@variables('varSourceFilePath')"
```

#### **E. Add Duplicate Detection Logic**
**Location**: Inside "Apply to each" loop, BEFORE creating transaction

```json
"Check_Duplicate_Transaction": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": {
      "connectionName": "shared_commondataserviceforapps",
      "operationId": "ListRecords"
    },
    "parameters": {
      "entityName": "cr7bb_thfinancecashcollectiontransactions",
      "$filter": "cr7bb_documentnumber eq '@{items('Apply_to_each')?['Document Number']}' and cr7bb_documentdate eq @{formatDateTime(items('Apply_to_each')?['Document Date'], 'yyyy-MM-dd')} and _cr7bb_customer_value eq @{outputs('Get_Customer')?['body/cr7bb_thfinancecashcollectioncustomerid']}"
    }
  }
},
"Condition_Duplicate_Exists": {
  "actions": {
    "Update_Existing_Transaction": {
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "UpdateRecord"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectiontransactions",
          "recordId": "@first(outputs('Check_Duplicate_Transaction')?['body/value'])?['cr7bb_thfinancecashcollectiontransactionid']",
          "item/cr7bb_amountlocalcurrency": "@items('Apply_to_each')?['Amount']",
          "item/cr7bb_textfield": "@items('Apply_to_each')?['Text']",
          "item/cr7bb_isexcluded": "@variables('varIsExcluded')",
          "item/cr7bb_sourcefilename": "@variables('varSourceFileName')",
          "item/cr7bb_sourcefilepath": "@variables('varSourceFilePath')"
        }
      }
    }
  },
  "else": {
    "actions": {
      "Create_New_Transaction": {
        "type": "OpenApiConnection",
        "inputs": {
          "host": {
            "connectionName": "shared_commondataserviceforapps",
            "operationId": "CreateRecord"
          },
          "parameters": {
            "entityName": "cr7bb_thfinancecashcollectiontransactions",
            "item/cr7bb_sourcefilename": "@variables('varSourceFileName')",
            "item/cr7bb_sourcefilepath": "@variables('varSourceFilePath')"
          }
        }
      }
    }
  },
  "runAfter": {
    "Check_Duplicate_Transaction": ["Succeeded"]
  },
  "expression": {
    "greater": [
      "@length(outputs('Check_Duplicate_Transaction')?['body/value'])",
      0
    ]
  },
  "type": "If"
}
```

#### **F. Rename File After Processing**
**Location**: After "Apply to each" completes successfully, before updating Process Log

```json
"Copy_File_with_Processed_Suffix": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": {
      "connectionName": "shared_sharepointonline",
      "operationId": "CopyFile"
    },
    "parameters": {
      "dataset": "SharePoint Site URL",
      "source": "@variables('varSourceFilePath')",
      "destination": "@{replace(variables('varSourceFilePath'), '.xlsx', '_Processed.xlsx')}",
      "overwrite": true
    }
  },
  "runAfter": {
    "Apply_to_each_Transaction": ["Succeeded"]
  }
},
"Delete_Original_File": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": {
      "connectionName": "shared_sharepointonline",
      "operationId": "DeleteFile"
    },
    "parameters": {
      "dataset": "SharePoint Site URL",
      "id": "@variables('varSourceFilePath')"
    }
  },
  "runAfter": {
    "Copy_File_with_Processed_Suffix": ["Succeeded"]
  }
}
```

#### **G. Update Process Log with Filename**
**Location**: When creating/updating Process Log record

**Add Fields**:

```json
"item/cr7bb_sapfilename": "@variables('varSourceFileName')",
"item/cr7bb_sourcefilepath": "@variables('varSourceFilePath')",
"item/cr7bb_status": 676180001
```

#### **H. Error Handling - File Not Found**
**Location**: Add scope after Initialize variables

```json
"Scope_File_Check": {
  "actions": {
    "Get_Files_in_Folder": {
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_sharepointonline",
          "operationId": "GetFiles"
        },
        "parameters": {
          "dataset": "SharePoint Site URL",
          "folderPath": "/SAP Exports",
          "$filter": "startswith(Name, 'SAP_Export') and not(contains(Name, '_Processed'))"
        }
      }
    },
    "Condition_File_Exists": {
      "actions": {},
      "else": {
        "actions": {
          "Create_ProcessLog_FileNotFound": {
            "type": "OpenApiConnection",
            "inputs": {
              "host": {
                "connectionName": "shared_commondataserviceforapps",
                "operationId": "CreateRecord"
              },
              "parameters": {
                "entityName": "cr7bb_thfinancecashcollectionprocesslogs",
                "item/cr7bb_processdate": "@variables('varProcessDate')",
                "item/cr7bb_status": 676180004,
                "item/cr7bb_errormessages": "SAP Excel file not found in SharePoint folder"
              }
            }
          },
          "Terminate_File_Not_Found": {
            "runAfter": {
              "Create_ProcessLog_FileNotFound": ["Succeeded"]
            },
            "type": "Terminate",
            "inputs": {
              "runStatus": "Failed",
              "runError": {
                "message": "File not found"
              }
            }
          }
        }
      },
      "runAfter": {
        "Get_Files_in_Folder": ["Succeeded"]
      },
      "expression": {
        "greater": [
          "@length(outputs('Get_Files_in_Folder')?['body/value'])",
          0
        ]
      },
      "type": "If"
    }
  }
}
```

---

## 🔧 **Flow 2: Collections Engine (MODIFY EXISTING)**

**File**: `THFinanceCashCollectionDailyCollectionsEmailEngine-*.json`

### **Current Behavior:**
- Runs daily at 8:30 AM (30 min after SAP Import)
- Processes transactions using FIFO logic
- Sends emails immediately
- Logs email records

### **Required Changes:**

#### **A. Change: Don't Send Emails - Create Approval Requests**
**Location**: Replace "Send Email" action

**Current Flow**:
```
Calculate email → Send Email → Log Email Record
```

**New Flow**:
```
Calculate email → Compose Email Body → Create EmailLog with ApprovalStatus=Pending
```

#### **B. Compose Full Email Body HTML**
**Location**: After template selection, before creating EmailLog

```json
"Compose_Email_Body_HTML": {
  "type": "Compose",
  "inputs": "<html><body><h2>Payment Reminder</h2><p>Dear @{variables('varCustomerName')},</p><p>Outstanding amount: ฿@{variables('varNetAmount')}</p><table border='1'><tr><th>Document</th><th>Date</th><th>Days</th><th>Amount</th></tr>@{variables('varTransactionTableHTML')}</table><p>QR Code: <img src='cid:qrcode' /></p><p>Best regards,<br/>AR Team</p></body></html>",
  "runAfter": {
    "Select_Email_Template": ["Succeeded"]
  }
}
```

#### **C. Create EmailLog Record with Approval Status**
**Location**: Replace current "Create Email Log" action

```json
"Create_EmailLog_Pending_Approval": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": {
      "connectionName": "shared_commondataserviceforapps",
      "operationId": "CreateRecord"
    },
    "parameters": {
      "entityName": "cr7bb_thfinancecashcollectionemaillogs",
      "item/_cr7bb_customer_value": "@variables('varCurrentCustomer')?['cr7bb_thfinancecashcollectioncustomerid']",
      "item/cr7bb_processdate": "@variables('varProcessDate')",
      "item/cr7bb_emailsubject": "@variables('varEmailSubject')",
      "item/cr7bb_emailtemplate": "@variables('varSelectedTemplate')",
      "item/cr7bb_totalamount": "@variables('varNetAmount')",
      "item/cr7bb_recipientemails": "@variables('varRecipientEmails')",
      "item/cr7bb_ccemails": "@variables('varCCEmails')",
      "item/cr7bb_maxdaycount": "@variables('varMaxDayCount')",
      "item/cr7bb_approvalstatus": 676180000,
      "item/cr7bb_emailbodypreview": "@outputs('Compose_Email_Body_HTML')",
      "item/cr7bb_sendstatus": "Pending",
      "item/cr7bb_qrcodeincluded": true
    }
  },
  "runAfter": {
    "Compose_Email_Body_HTML": ["Succeeded"]
  }
}
```

#### **D. Remove "Send Email" Action**
**Action to Delete**: Any action named "Send_Email" or similar

#### **E. Update Process Log**
**Location**: Final action in flow

**Change**: Update status message to reflect emails are pending approval

```json
"item/cr7bb_emailssent": 0,
"item/cr7bb_emailsfailed": 0,
"item/cr7bb_errormessages": "@{variables('varCustomersProcessed')} emails prepared and awaiting approval"
```

---

## 🔧 **Flow 3: Email Sending Flow (BUILD NEW)**

**File**: `THFinanceCashCollectionEmailSendingFlow-*.json`

### **Purpose:**
Send only approved emails from EmailLog table

### **Trigger:**
Recurrence - Daily 10:30 AM (2 hours after Collections Engine)

### **Complete Flow Structure:**

```json
{
  "triggers": {
    "Recurrence": {
      "type": "Recurrence",
      "recurrence": {
        "frequency": "Day",
        "interval": 1,
        "timeZone": "SE Asia Standard Time",
        "schedule": {
          "hours": ["10"],
          "minutes": [30]
        }
      }
    }
  },
  "actions": {
    "Initialize_varProcessDate": {
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varProcessDate",
          "type": "string",
          "value": "@{formatDateTime(utcNow(), 'yyyy-MM-dd')}"
        }]
      }
    },
    "Initialize_varEmailsSent": {
      "runAfter": {
        "Initialize_varProcessDate": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varEmailsSent",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Initialize_varEmailsFailed": {
      "runAfter": {
        "Initialize_varEmailsSent": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varEmailsFailed",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Get_Approved_Emails": {
      "runAfter": {
        "Initialize_varEmailsFailed": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "ListRecords"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectionemaillogs",
          "$filter": "cr7bb_processdate eq '@{variables('varProcessDate')}' and cr7bb_approvalstatus eq 676180001 and cr7bb_sendstatus eq 'Pending'"
        }
      }
    },
    "Apply_to_each_Approved_Email": {
      "foreach": "@outputs('Get_Approved_Emails')?['body/value']",
      "actions": {
        "Get_Customer": {
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_commondataserviceforapps",
              "operationId": "GetItem"
            },
            "parameters": {
              "entityName": "cr7bb_thfinancecashcollectioncustomers",
              "recordId": "@items('Apply_to_each_Approved_Email')?['_cr7bb_customer_value']"
            }
          }
        },
        "Get_QR_Code": {
          "runAfter": {
            "Get_Customer": ["Succeeded"]
          },
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_sharepointonline",
              "operationId": "GetFileContent"
            },
            "parameters": {
              "dataset": "SharePoint Site URL",
              "id": "/QR Codes/@{outputs('Get_Customer')?['body/cr7bb_customercode']}.png"
            }
          }
        },
        "Send_Email_V2": {
          "runAfter": {
            "Get_QR_Code": ["Succeeded"]
          },
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_office365",
              "operationId": "SendEmailV2"
            },
            "parameters": {
              "emailMessage/To": "@items('Apply_to_each_Approved_Email')?['cr7bb_recipientemails']",
              "emailMessage/Cc": "@items('Apply_to_each_Approved_Email')?['cr7bb_ccemails']",
              "emailMessage/Subject": "@items('Apply_to_each_Approved_Email')?['cr7bb_emailsubject']",
              "emailMessage/Body": "@items('Apply_to_each_Approved_Email')?['cr7bb_emailbodypreview']",
              "emailMessage/Attachments": [{
                "Name": "QRCode.png",
                "ContentBytes": "@base64(outputs('Get_QR_Code')?['body'])"
              }]
            }
          }
        },
        "Update_EmailLog_Sent": {
          "runAfter": {
            "Send_Email_V2": ["Succeeded"]
          },
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_commondataserviceforapps",
              "operationId": "UpdateRecord"
            },
            "parameters": {
              "entityName": "cr7bb_thfinancecashcollectionemaillogs",
              "recordId": "@items('Apply_to_each_Approved_Email')?['cr7bb_thfinancecashcollectionemaillogid']",
              "item/cr7bb_sendstatus": "Sent",
              "item/cr7bb_sentdatetime": "@utcNow()"
            }
          }
        },
        "Update_Transactions_Sent": {
          "runAfter": {
            "Update_EmailLog_Sent": ["Succeeded"]
          },
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_commondataserviceforapps",
              "operationId": "ListRecords"
            },
            "parameters": {
              "entityName": "cr7bb_thfinancecashcollectiontransactions",
              "$filter": "_cr7bb_customer_value eq @{items('Apply_to_each_Approved_Email')?['_cr7bb_customer_value']} and cr7bb_transactionprocessdate eq '@{variables('varProcessDate')}'"
            }
          }
        },
        "Increment_EmailsSent": {
          "runAfter": {
            "Update_Transactions_Sent": ["Succeeded"]
          },
          "type": "IncrementVariable",
          "inputs": {
            "name": "varEmailsSent",
            "value": 1
          }
        }
      },
      "runAfter": {
        "Get_Approved_Emails": ["Succeeded"]
      },
      "type": "Foreach"
    },
    "Get_Rejected_Emails": {
      "runAfter": {
        "Apply_to_each_Approved_Email": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "ListRecords"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectionemaillogs",
          "$filter": "cr7bb_processdate eq '@{variables('varProcessDate')}' and (cr7bb_approvalstatus eq 676180002 or cr7bb_approvalstatus eq 676180000) and cr7bb_sendstatus eq 'Pending'"
        }
      }
    },
    "Apply_to_each_Rejected_Email": {
      "foreach": "@outputs('Get_Rejected_Emails')?['body/value']",
      "actions": {
        "Update_EmailLog_Not_Approved": {
          "type": "OpenApiConnection",
          "inputs": {
            "host": {
              "connectionName": "shared_commondataserviceforapps",
              "operationId": "UpdateRecord"
            },
            "parameters": {
              "entityName": "cr7bb_thfinancecashcollectionemaillogs",
              "recordId": "@items('Apply_to_each_Rejected_Email')?['cr7bb_thfinancecashcollectionemaillogid']",
              "item/cr7bb_sendstatus": "Not Approved"
            }
          }
        }
      },
      "runAfter": {
        "Get_Rejected_Emails": ["Succeeded"]
      },
      "type": "Foreach"
    }
  }
}
```

---

## 🔧 **Flow 4: Customer Data Sync (BUILD NEW)**

**File**: `THFinanceCashCollectionCustomerDataSync-*.json`

### **Purpose:**
Sync customer master data from Excel to Dataverse

### **Trigger:**
Manual or PowerApps

### **Complete Flow Structure:**

```json
{
  "triggers": {
    "manual": {
      "type": "Request",
      "kind": "PowerApps"
    }
  },
  "actions": {
    "Initialize_varSyncStartTime": {
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varSyncStartTime",
          "type": "string",
          "value": "@{utcNow()}"
        }]
      }
    },
    "Initialize_varRecordsProcessed": {
      "runAfter": {
        "Initialize_varSyncStartTime": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varRecordsProcessed",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Initialize_varRecordsCreated": {
      "runAfter": {
        "Initialize_varRecordsProcessed": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varRecordsCreated",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Initialize_varRecordsUpdated": {
      "runAfter": {
        "Initialize_varRecordsCreated": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varRecordsUpdated",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Initialize_varRecordsFailed": {
      "runAfter": {
        "Initialize_varRecordsUpdated": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varRecordsFailed",
          "type": "integer",
          "value": 0
        }]
      }
    },
    "Initialize_varErrorLog": {
      "runAfter": {
        "Initialize_varRecordsFailed": ["Succeeded"]
      },
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varErrorLog",
          "type": "string",
          "value": ""
        }]
      }
    },
    "List_rows_from_Customer_Excel": {
      "runAfter": {
        "Initialize_varErrorLog": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_excelonlinebusiness",
          "operationId": "GetTable"
        },
        "parameters": {
          "source": "SharePoint Site URL",
          "drive": "Document Library",
          "file": "/Customer Master Data.xlsx",
          "table": "CustomerTable"
        }
      }
    },
    "Apply_to_each_Customer_Row": {
      "foreach": "@outputs('List_rows_from_Customer_Excel')?['body/value']",
      "actions": {
        "Validate_Customer_Row": {
          "type": "Compose",
          "inputs": {
            "isValid": "@and(not(empty(items('Apply_to_each_Customer_Row')?['CustomerCode'])), not(empty(items('Apply_to_each_Customer_Row')?['CustomerName'])), not(empty(items('Apply_to_each_Customer_Row')?['CustomerEmail1'])), not(empty(items('Apply_to_each_Customer_Row')?['Region'])))"
          }
        },
        "Condition_Valid_Row": {
          "actions": {
            "Check_Customer_Exists": {
              "type": "OpenApiConnection",
              "inputs": {
                "host": {
                  "connectionName": "shared_commondataserviceforapps",
                  "operationId": "ListRecords"
                },
                "parameters": {
                  "entityName": "cr7bb_thfinancecashcollectioncustomers",
                  "$filter": "cr7bb_customercode eq '@{items('Apply_to_each_Customer_Row')?['CustomerCode']}'"
                }
              }
            },
            "Condition_Customer_Exists": {
              "actions": {
                "Update_Existing_Customer": {
                  "type": "OpenApiConnection",
                  "inputs": {
                    "host": {
                      "connectionName": "shared_commondataserviceforapps",
                      "operationId": "UpdateRecord"
                    },
                    "parameters": {
                      "entityName": "cr7bb_thfinancecashcollectioncustomers",
                      "recordId": "@first(outputs('Check_Customer_Exists')?['body/value'])?['cr7bb_thfinancecashcollectioncustomerid']",
                      "item/cr7bb_customername": "@items('Apply_to_each_Customer_Row')?['CustomerName']",
                      "item/cr7bb_Region": "@items('Apply_to_each_Customer_Row')?['Region']",
                      "item/cr7bb_customeremail1": "@items('Apply_to_each_Customer_Row')?['CustomerEmail1']",
                      "item/cr7bb_customeremail2": "@items('Apply_to_each_Customer_Row')?['CustomerEmail2']",
                      "item/cr7bb_customeremail3": "@items('Apply_to_each_Customer_Row')?['CustomerEmail3']",
                      "item/cr7bb_customeremail4": "@items('Apply_to_each_Customer_Row')?['CustomerEmail4']",
                      "item/cr7bb_salesemail1": "@items('Apply_to_each_Customer_Row')?['SalesEmail1']",
                      "item/cr7bb_salesemail2": "@items('Apply_to_each_Customer_Row')?['SalesEmail2']",
                      "item/cr7bb_salesemail3": "@items('Apply_to_each_Customer_Row')?['SalesEmail3']",
                      "item/cr7bb_salesemail4": "@items('Apply_to_each_Customer_Row')?['SalesEmail4']",
                      "item/cr7bb_salesemail5": "@items('Apply_to_each_Customer_Row')?['SalesEmail5']",
                      "item/cr7bb_arbackupemail1": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail1']",
                      "item/cr7bb_arbackupemail2": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail2']",
                      "item/cr7bb_arbackupemail3": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail3']",
                      "item/cr7bb_arbackupemail4": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail4']"
                    }
                  }
                },
                "Increment_RecordsUpdated": {
                  "runAfter": {
                    "Update_Existing_Customer": ["Succeeded"]
                  },
                  "type": "IncrementVariable",
                  "inputs": {
                    "name": "varRecordsUpdated",
                    "value": 1
                  }
                }
              },
              "else": {
                "actions": {
                  "Create_New_Customer": {
                    "type": "OpenApiConnection",
                    "inputs": {
                      "host": {
                        "connectionName": "shared_commondataserviceforapps",
                        "operationId": "CreateRecord"
                      },
                      "parameters": {
                        "entityName": "cr7bb_thfinancecashcollectioncustomers",
                        "item/cr7bb_customercode": "@items('Apply_to_each_Customer_Row')?['CustomerCode']",
                        "item/cr7bb_customername": "@items('Apply_to_each_Customer_Row')?['CustomerName']",
                        "item/cr7bb_Region": "@items('Apply_to_each_Customer_Row')?['Region']",
                        "item/cr7bb_customeremail1": "@items('Apply_to_each_Customer_Row')?['CustomerEmail1']",
                        "item/cr7bb_customeremail2": "@items('Apply_to_each_Customer_Row')?['CustomerEmail2']",
                        "item/cr7bb_customeremail3": "@items('Apply_to_each_Customer_Row')?['CustomerEmail3']",
                        "item/cr7bb_customeremail4": "@items('Apply_to_each_Customer_Row')?['CustomerEmail4']",
                        "item/cr7bb_salesemail1": "@items('Apply_to_each_Customer_Row')?['SalesEmail1']",
                        "item/cr7bb_salesemail2": "@items('Apply_to_each_Customer_Row')?['SalesEmail2']",
                        "item/cr7bb_salesemail3": "@items('Apply_to_each_Customer_Row')?['SalesEmail3']",
                        "item/cr7bb_salesemail4": "@items('Apply_to_each_Customer_Row')?['SalesEmail4']",
                        "item/cr7bb_salesemail5": "@items('Apply_to_each_Customer_Row')?['SalesEmail5']",
                        "item/cr7bb_arbackupemail1": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail1']",
                        "item/cr7bb_arbackupemail2": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail2']",
                        "item/cr7bb_arbackupemail3": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail3']",
                        "item/cr7bb_arbackupemail4": "@items('Apply_to_each_Customer_Row')?['ARBackupEmail4']"
                      }
                    }
                  },
                  "Increment_RecordsCreated": {
                    "runAfter": {
                      "Create_New_Customer": ["Succeeded"]
                    },
                    "type": "IncrementVariable",
                    "inputs": {
                      "name": "varRecordsCreated",
                      "value": 1
                    }
                  }
                }
              },
              "runAfter": {
                "Check_Customer_Exists": ["Succeeded"]
              },
              "expression": {
                "greater": [
                  "@length(outputs('Check_Customer_Exists')?['body/value'])",
                  0
                ]
              },
              "type": "If"
            },
            "Increment_RecordsProcessed": {
              "runAfter": {
                "Condition_Customer_Exists": ["Succeeded"]
              },
              "type": "IncrementVariable",
              "inputs": {
                "name": "varRecordsProcessed",
                "value": 1
              }
            }
          },
          "else": {
            "actions": {
              "Append_Error_Log": {
                "type": "AppendToStringVariable",
                "inputs": {
                  "name": "varErrorLog",
                  "value": "Row @{variables('varRecordsProcessed')}: Missing required fields (CustomerCode, CustomerName, CustomerEmail1, or Region)\n"
                }
              },
              "Increment_RecordsFailed": {
                "runAfter": {
                  "Append_Error_Log": ["Succeeded"]
                },
                "type": "IncrementVariable",
                "inputs": {
                  "name": "varRecordsFailed",
                  "value": 1
                }
              }
            }
          },
          "runAfter": {
            "Validate_Customer_Row": ["Succeeded"]
          },
          "expression": {
            "equals": [
              "@outputs('Validate_Customer_Row')?['isValid']",
              true
            ]
          },
          "type": "If"
        }
      },
      "runAfter": {
        "List_rows_from_Customer_Excel": ["Succeeded"]
      },
      "type": "Foreach"
    }
  }
}
```

---

## 🔧 **Flow 5: Manual SAP Upload (BUILD NEW)**

**File**: `THFinanceCashCollectionManualSAPUpload-*.json`

### **Purpose:**
Manual trigger from Canvas App to upload SAP file

### **Trigger:**
PowerApps (V2)

### **Implementation:**
**Copy entire SAP Import Flow logic** with these changes:

1. **Change Trigger**:
```json
"triggers": {
  "manual": {
    "type": "Request",
    "kind": "PowerApps",
    "inputs": {
      "schema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    }
  }
}
```

2. **Add Response Action at End**:
```json
"Respond_to_PowerApps": {
  "runAfter": {
    "Update_ProcessLog": ["Succeeded"]
  },
  "type": "Response",
  "kind": "PowerApp",
  "inputs": {
    "statusCode": 200,
    "body": {
      "Status": "Success",
      "Message": "Processed @{variables('varRowCounter')} transactions",
      "RowCount": "@variables('varRowCounter')",
      "ErrorCount": "@variables('varErrorCount')"
    },
    "schema": {
      "type": "object",
      "properties": {
        "Status": { "type": "string" },
        "Message": { "type": "string" },
        "RowCount": { "type": "integer" },
        "ErrorCount": { "type": "integer" }
      }
    }
  }
}
```

3. **Add Error Response**:
```json
"Respond_to_PowerApps_Error": {
  "runAfter": {
    "Scope_Main": ["Failed"]
  },
  "type": "Response",
  "kind": "PowerApp",
  "inputs": {
    "statusCode": 500,
    "body": {
      "Status": "Failed",
      "Message": "@{result('Scope_Main')[0]['outputs']['body']['error']['message']}",
      "RowCount": 0,
      "ErrorCount": 1
    }
  }
}
```

---

## 🔧 **Flow 6: Manual Email Resend (BUILD NEW)**

**File**: `THFinanceCashCollectionManualEmailResend-*.json`

### **Purpose:**
Resend individual email from Email Monitor screen

### **Trigger:**
PowerApps (V2) with EmailLogID input

### **Complete Flow Structure:**

```json
{
  "triggers": {
    "manual": {
      "type": "Request",
      "kind": "PowerApps",
      "inputs": {
        "schema": {
          "type": "object",
          "properties": {
            "EmailLogID": {
              "type": "string",
              "description": "GUID of EmailLog record to resend"
            }
          },
          "required": ["EmailLogID"]
        }
      }
    }
  },
  "actions": {
    "Initialize_varEmailLogID": {
      "type": "InitializeVariable",
      "inputs": {
        "variables": [{
          "name": "varEmailLogID",
          "type": "string",
          "value": "@triggerBody()?['EmailLogID']"
        }]
      }
    },
    "Get_EmailLog_Record": {
      "runAfter": {
        "Initialize_varEmailLogID": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "GetItem"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectionemaillogs",
          "recordId": "@variables('varEmailLogID')"
        }
      }
    },
    "Get_Customer": {
      "runAfter": {
        "Get_EmailLog_Record": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "GetItem"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectioncustomers",
          "recordId": "@outputs('Get_EmailLog_Record')?['body/_cr7bb_customer_value']"
        }
      }
    },
    "Get_QR_Code": {
      "runAfter": {
        "Get_Customer": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_sharepointonline",
          "operationId": "GetFileContent"
        },
        "parameters": {
          "dataset": "SharePoint Site URL",
          "id": "/QR Codes/@{outputs('Get_Customer')?['body/cr7bb_customercode']}.png"
        }
      }
    },
    "Send_Email_V2": {
      "runAfter": {
        "Get_QR_Code": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_office365",
          "operationId": "SendEmailV2"
        },
        "parameters": {
          "emailMessage/To": "@outputs('Get_EmailLog_Record')?['body/cr7bb_recipientemails']",
          "emailMessage/Cc": "@outputs('Get_EmailLog_Record')?['body/cr7bb_ccemails']",
          "emailMessage/Subject": "@outputs('Get_EmailLog_Record')?['body/cr7bb_emailsubject']",
          "emailMessage/Body": "@outputs('Get_EmailLog_Record')?['body/cr7bb_emailbodypreview']",
          "emailMessage/Attachments": [{
            "Name": "QRCode.png",
            "ContentBytes": "@base64(outputs('Get_QR_Code')?['body'])"
          }]
        }
      }
    },
    "Update_EmailLog_Resent": {
      "runAfter": {
        "Send_Email_V2": ["Succeeded"]
      },
      "type": "OpenApiConnection",
      "inputs": {
        "host": {
          "connectionName": "shared_commondataserviceforapps",
          "operationId": "UpdateRecord"
        },
        "parameters": {
          "entityName": "cr7bb_thfinancecashcollectionemaillogs",
          "recordId": "@variables('varEmailLogID')",
          "item/cr7bb_sendstatus": "Resent - Manual",
          "item/cr7bb_sentdatetime": "@utcNow()"
        }
      }
    },
    "Respond_to_PowerApps_Success": {
      "runAfter": {
        "Update_EmailLog_Resent": ["Succeeded"]
      },
      "type": "Response",
      "kind": "PowerApp",
      "inputs": {
        "statusCode": 200,
        "body": {
          "Status": "Success",
          "Message": "Email resent successfully to @{outputs('Get_Customer')?['body/cr7bb_customername']}"
        }
      }
    },
    "Respond_to_PowerApps_Error": {
      "runAfter": {
        "Send_Email_V2": ["Failed"]
      },
      "type": "Response",
      "kind": "PowerApp",
      "inputs": {
        "statusCode": 500,
        "body": {
          "Status": "Failed",
          "Message": "Failed to resend email: @{result('Send_Email_V2')[0]['error']['message']}"
        }
      }
    }
  }
}
```

---

## 📝 **Implementation Notes**

### **SharePoint Paths**
All flows reference SharePoint paths - these need to be updated with actual values:
- `"SharePoint Site URL"` → Replace with actual site URL
- `/SAP Exports` → Actual folder path for SAP files
- `/Customer Master Data.xlsx` → Actual customer Excel file path
- `/QR Codes` → Actual QR code folder path

### **Connection References**
All flows use connection references that were created in skeleton flows. No changes needed.

### **Error Handling**
Each flow should wrap main logic in a `Scope` for proper error handling and logging.

### **Testing Order**
1. Test SAP Import first (with file tracking)
2. Test Collections Engine (approval creation)
3. Test Email Sending (approved emails only)
4. Test Manual flows last

---

## ✅ **Completion Checklist**

- [ ] Flow 1: SAP Import modified (filename tracking, renaming, duplicates)
- [ ] Flow 2: Collections Engine modified (approval status, email preview)
- [ ] Flow 3: Email Sending built (send approved only)
- [ ] Flow 4: Customer Data Sync built (Excel → Dataverse)
- [ ] Flow 5: Manual SAP Upload built (PowerApps trigger)
- [ ] Flow 6: Manual Email Resend built (PowerApps trigger)
- [ ] All SharePoint paths updated
- [ ] All flows tested individually
- [ ] Integration test complete (end-to-end workflow)
- [ ] Solution re-exported and ready for import

---

**End of Specification Document**
