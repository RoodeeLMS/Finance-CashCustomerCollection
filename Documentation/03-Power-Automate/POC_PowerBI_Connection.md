# POC: Power BI to Power Automate Connection

**Date**: January 9, 2026
**Purpose**: Proof of concept to verify Power BI data retrieval in Power Automate

---

## Prerequisites

1. **Power BI Pro or Premium** license (for the service account)
2. **Access to workspace**: `[ICR] IT Finance & Legal`
3. **Dataset name**: `Finance Customer Line Item For ...` (Semantic Model)
4. **Power Automate Premium** (for Power BI connector)

---

## Step-by-Step: Create POC Flow

### Step 1: Create New Flow

1. Go to [make.powerautomate.com](https://make.powerautomate.com)
2. Click **+ Create** → **Instant cloud flow**
3. Name: `POC - Power BI Data Test`
4. Trigger: **Manually trigger a flow**
5. Click **Create**

---

### Step 2: Add Power BI Action

1. Click **+ New step**
2. Search for: `Power BI`
3. Select: **Run a query against a dataset**

---

### Step 3: Configure the Action

**Fill in these fields:**

| Field | Value |
|-------|-------|
| **Workspace** | `[ICR] IT Finance & Legal` |
| **Dataset** | `Finance Customer Line Item For ...` (select from dropdown) |
| **Query Text** | See DAX query below |

---

### Step 4: DAX Query - Simple Test

Start with a simple query to test connectivity:

```dax
EVALUATE
TOPN(
    10,
    'CCC: Customer Line Item'
)
```

**Note**: The table name might be different. Common names:
- `'CCC: Customer Line Item'`
- `'Customer Line Item'`
- `'FactTransactions'`

If the above doesn't work, try this to list all tables:

```dax
EVALUATE
INFO.TABLES()
```

---

### Step 5: Add Compose Action (View Results)

1. Click **+ New step**
2. Search: `Compose`
3. Select: **Compose** (Data Operations)
4. **Inputs**: Select `First table rows` from Dynamic content (from Power BI action)

---

### Step 6: Save and Test

1. Click **Save**
2. Click **Test** → **Manually** → **Test**
3. Click **Run flow**
4. Check the output of the Compose action

---

## Expected Output

If successful, you should see JSON data like:

```json
[
  {
    "KUNNR": "1002541",
    "BELNR": "0800015370",
    "BLART": "MI",
    "BLDAT": 20250906,
    "NETDT": "2025-10-06T00:00:00",
    "VERZN": 94,
    "S_DMBTR": 40018,
    "SGTXT": "",
    "XBLNR": "12000096"
  },
  ...
]
```

---

## Troubleshooting

### Error: "Dataset not found"
- Verify you have access to the workspace
- Check the dataset name spelling
- Try selecting from dropdown instead of typing

### Error: "Query failed"
- Table name might be different
- Try `INFO.TABLES()` query first to see available tables
- Check column names match

### Error: "Unauthorized"
- Need Power BI Pro license
- Need workspace access (Viewer or higher)
- Connection might need re-authentication

### Error: "Premium capacity required"
- Some DAX functions require Premium
- Try simpler query first

---

## Alternative: Export Report to File

If DAX query doesn't work, try exporting the paginated report:

### Step 1: Use "Export to File for Paginated Reports"

1. **+ New step** → Search: `Power BI`
2. Select: **Export to File for Paginated Reports**
3. Configure:
   - **Workspace**: `[ICR] IT Finance & Legal`
   - **Report**: `Cash Collection Report`
   - **Export Format**: `CSV`

### Step 2: Get File Content

1. **+ New step** → **Get file content** (from the export)

### Step 3: Parse CSV

1. Use expressions or child flow to parse CSV

---

## Next Steps After POC Success

Once connection is verified:

1. **Expand DAX query** to filter by date/customer
2. **Add Holiday lookup** from SharePoint
3. **Calculate arrear days** using expressions
4. **Group by customer** and calculate totals
5. **Send test email** with data

---

## Full DAX Query (After POC Works)

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS(
        'CCC: Customer Line Item',
        "CustomerCode", [KUNNR],
        "DocumentNumber", [BELNR],
        "DocumentType", [BLART],
        "DocumentDate", [BLDAT],
        "NetDueDate", [NETDT],
        "Amount", [S_DMBTR],
        "ItemText", [SGTXT],
        "Reference", [XBLNR]
    ),
    NOT(ISBLANK([CustomerCode]))
)
```

---

## POC Flow Summary

```
[Manual Trigger]
       ↓
[Run DAX Query against Power BI Dataset]
       ↓
[Compose - View Results]
       ↓
[Success = Ready for full implementation]
```

---

**Status**: Ready to test
