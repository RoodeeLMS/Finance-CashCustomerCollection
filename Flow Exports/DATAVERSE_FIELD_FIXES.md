# Dataverse Field Fixes for Flows

## Issue: Lookup Field Syntax Errors

After importing, you're getting errors like:
```
'Item.item/_cr7bb_customer_value' is no longer present in the operation schema
```

This happens because **Dataverse lookup fields** have changed syntax in newer versions of the connector.

---

## ⚠️ Fields That Need Fixing

### In **Email Engine Flow**:

#### 1. Create Email Log Action
**Current (Broken)**:
```json
"item/_cr7bb_customer_value": "@outputs('Get_Customer')?['cr7bb_thfinancecashcollectioncustomerid']"
```

**Fix - Use one of these formats**:

**Option A: OData Bind (Recommended)**
```json
"item/cr7bb_customer@odata.bind": "/cr7bb_thfinancecashcollectioncustomers(@{outputs('Get_Customer')?['cr7bb_thfinancecashcollectioncustomerid']})"
```

**Option B: Direct Lookup Field**
```json
"item/cr7bb_customer": "@outputs('Get_Customer')?['cr7bb_thfinancecashcollectioncustomerid']"
```

Try **Option B first** (simpler). If it doesn't work, use **Option A**.

---

### In **SAP Import Flow**:

#### 2. Create Transaction Record Action
**Current (Broken)**:
```json
"item/_cr7bb_customer_value": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}"
```

**Fix - Use**:
```json
"item/cr7bb_customer@odata.bind": "/cr7bb_thfinancecashcollectioncustomers(@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']})"
```

**Or simpler**:
```json
"item/cr7bb_customer": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}"
```

---

## 🔧 How to Fix in Power Automate Designer

### Method 1: Edit in Designer (Recommended)

1. **Open the flow** in Edit mode
2. **Find the action** with the error (look for ⚠️ warning icon)
3. **Click on the action** to expand it
4. **Find the Customer field** (it will show an error)
5. **Delete the old value**
6. **Click in the field** and select from Dynamic content:
   - For Email Engine: Select **THFinance Cash Collection Customer** from "Get_Customer" outputs
   - For SAP Import: Select **THFinance Cash Collection Customer** from "List_customer" outputs
7. **Save** the flow

### Method 2: Edit in Peek Code (Advanced)

1. **Open the flow** in Edit mode
2. **Click ⋯** (three dots) → **Peek code**
3. **Find the action** (search for "Create_Email_Log" or "Create_transaction")
4. **Replace the lookup field line**:

**From:**
```json
"item/_cr7bb_customer_value": "@outputs('Get_Customer')..."
```

**To:**
```json
"item/cr7bb_customer": "@outputs('Get_Customer')?['cr7bb_thfinancecashcollectioncustomerid']"
```

5. **Save** and close

---

## 📋 Complete Fixed Action - Email Log

Replace the entire "Create_Email_Log" action parameters with this:

```json
{
  "entityName": "cr7bb_thfinancecashcollectionemaillogs",
  "item/cr7bb_customer": "@outputs('Get_Customer')?['cr7bb_thfinancecashcollectioncustomerid']",
  "item/cr7bb_processdate": "@variables('varProcessDate')",
  "item/cr7bb_emailsubject": "@outputs('Compose_Email_Subject')",
  "item/cr7bb_emailtemplate": "@outputs('Compose_Template_Selection')",
  "item/cr7bb_maxdaycount": "@outputs('Compose_Max_DayCount')",
  "item/cr7bb_totalamount": "@outputs('Compose_Net_Amount')",
  "item/cr7bb_transactioncount": "@length(body('Filter_DN_List'))",
  "item/cr7bb_recipientemails": "@outputs('Compose_Recipient_Emails')",
  "item/cr7bb_ccemails": "@outputs('Compose_CC_Emails')",
  "item/cr7bb_sentdatetime": "@utcNow()",
  "item/cr7bb_sendstatus": "@{if(equals(outputs('Send_Email')?['statusCode'], 200), 'Success', 'Failed')}",
  "item/cr7bb_qrcodeincluded": "@not(empty(body('Get_QR_Code')))"
}
```

---

## 📋 Complete Fixed Action - Create Transaction

Replace the entire "Create_transaction" action parameters with this:

```json
{
  "entityName": "cr7bb_thfinancecashcollectiontransactions",
  "item/cr7bb_customer": "@{first(outputs('List_customer')?['value'])?['cr7bb_thfinancecashcollectioncustomerid']}",
  "item/cr7bb_recordtype": "Transaction",
  "item/cr7bb_documentnumber": "@{item()?['Document Number']}",
  "item/cr7bb_assignment": "@{item()?['Assignment']}",
  "item/cr7bb_documenttype": "@{item()?['Document Type']}",
  "item/cr7bb_documentdate": "@{item()?['Document Date']}",
  "item/cr7bb_netduedate": "@{item()?['Net Due Date']}",
  "item/cr7bb_arrearsdays": "@{int(coalesce(item()?['Arrears by Net Due Date'], 0))}",
  "item/cr7bb_amountlocalcurrency": "@{outputs('Compose_ParsedAmount')}",
  "item/cr7bb_textfield": "@{item()?['Text']}",
  "item/cr7bb_reference": "@{item()?['Reference']}",
  "item/cr7bb_transactiontype": "@{outputs('Compose_TransactionType')}",
  "item/cr7bb_isexcluded": "@{outputs('Compose_isExcluded')}",
  "item/cr7bb_excludereason": "@{if(outputs('Compose_isExcluded'), 'Keyword found in text field', null)}",
  "item/cr7bb_daycount": "@{int(coalesce(item()?['Arrears by Net Due Date'], 0))}",
  "item/cr7bb_processdate": "@{variables('varProcessDate')}",
  "item/cr7bb_processbatch": "@{variables('varBatchID')}",
  "item/cr7bb_rownumber": "@{variables('varRowCounter')}",
  "item/cr7bb_isprocessed": false,
  "item/cr7bb_emailsent": false
}
```

---

## 🔍 Other Actions to Check

Look for these actions that might have the same issue:

### Email Engine Flow:
- ✅ **Create_Email_Log** (fix above)

### SAP Import Flow:
- ✅ **Create_transaction** (fix above)
- ✅ **Create_Process_Log** (check if it has lookup fields - probably not)

---

## ✅ Testing After Fix

After fixing the lookup fields:

1. **Save** the flow
2. **Test** → **Manually** → **Test**
3. **Verify**:
   - No more schema errors ✅
   - Action runs successfully ✅
   - Record created in Dataverse with customer linked ✅

---

## 🎯 Quick Fix Summary

**Replace:**
```
item/_cr7bb_customer_value
```

**With:**
```
item/cr7bb_customer
```

**In these actions:**
1. Email Engine → Create_Email_Log
2. SAP Import → Create_transaction

That's it! The `_value` suffix is old syntax that's no longer supported in the current Dataverse connector.

---

## 💡 Why This Happened

The JSON I created used the older Dataverse connector syntax (`_fieldname_value`). The current connector uses simplified syntax (just `fieldname` for lookups).

Power Platform connectors are frequently updated, and syntax changes between versions. The designer handles this automatically, but when importing JSON, you need to fix it manually.

---

**Fix these two actions and your flows should work! 🚀**

Let me know if you encounter any other errors!
