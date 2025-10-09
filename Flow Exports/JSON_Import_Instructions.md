# Power Automate Flow JSON Import Instructions

## Files Created

✅ **SAP_Import_Complete.json** - Complete SAP Data Import flow with all business logic
✅ **Email_Engine_Complete.json** - Complete Collections Email Engine flow with FIFO logic

---

## Important: How to Import JSON into Existing Flows

Power Automate doesn't support direct JSON import to replace existing flows. Instead, you have **two options**:

### **Option A: Manual Copy (Recommended for Testing)**
Copy the `definition` section from JSON into your existing flow's definition

### **Option B: Delete & Recreate (Clean Slate)**
Delete existing flows and create new ones from JSON

---

## Option A: Update Existing Flows (Manual Copy)

This approach keeps your existing connections and updates only the logic.

### For SAP Import Flow:

1. **Open Power Automate**:
   - Go to [https://make.powerapps.com](https://make.powerapps.com)
   - Navigate to **Flows**
   - Find: `[THFinanceCashCollection] Daily SAP Transaction Import`
   - Click **Edit**

2. **Switch to Code View**:
   - Click **⋯** (three dots) in top right
   - Select **Peek code**
   - This shows the current JSON

3. **Compare and Copy**:
   - Open `SAP_Import_Complete.json` in a text editor
   - Copy the entire `"actions"` section (lines 44-545)
   - Replace the `"actions"` section in your flow

4. **Save and Test**:
   - Click **Save**
   - Test with small dataset

**⚠️ Warning**: This is advanced and error-prone. One typo breaks the entire flow.

---

## Option B: Delete and Recreate (Cleaner Approach)

This creates brand new flows from the JSON files.

### Step 1: Export Your Current Flows (Backup)

Before deleting anything:

1. Go to **Solutions** → `[THFinanceCashCollection] Finance Cash Collection`
2. Select your existing flows
3. Click **Export** → Save as backup

### Step 2: Delete Existing Flows

1. In your solution, select both flows:
   - `[THFinanceCashCollection] Daily SAP Transaction Import`
   - `[THFinanceCashCollection] Daily Collections Email Engine`
2. Click **Remove** → **Remove from this solution**
3. Confirm deletion

### Step 3: Import New Flows from JSON

#### Using Power Automate CLI (Advanced):

```powershell
# Install Power Platform CLI
pac auth create --url https://[your-environment].crm5.dynamics.com

# Import flow
pac solution import --path SAP_Import_Complete.json
```

#### Using Power Automate Portal (Manual):

Unfortunately, Power Automate doesn't have a direct "Import JSON" button. You need to:

1. **Create new blank flow**
2. **Use Peek code to paste JSON**
3. **Save**

**Detailed Steps:**

1. Go to **Flows** → **+ New flow** → **Instant cloud flow**
2. Name: `[THFinanceCashCollection] Daily SAP Transaction Import`
3. Skip trigger, click **Create**
4. Click **⋯** → **Peek code**
5. **Replace entire content** with `SAP_Import_Complete.json`
6. Click **Save**
7. **Fix connection references** (Power Automate will prompt)

---

## Option C: Recommended Hybrid Approach ⭐

Since direct JSON import is complex, I recommend:

### **Use the Builder Guide Instead**

The JSON files I created are complete references, but **building step-by-step in the designer is safer**.

**Follow these instead**:
1. Open your existing skeleton flows
2. Use [README_Import_Instructions.md](README_Import_Instructions.md)
3. Add actions one-by-one following the guide
4. Copy-paste expressions from JSON when needed

**Why this is better**:
- Visual validation at each step
- Easier to debug
- Power Automate handles connection references
- Test incrementally

---

## Using JSON Files as Reference

The JSON files are valuable as **expression references**. When building in the designer:

### Example: Need the Exclusion Check Expression?

**From JSON (line 248)**:
```json
"inputs": "@or(contains(toLower(coalesce(item()?['Text'], '')), 'paid'), contains(toLower(coalesce(item()?['Text'], '')), 'partial payment'), ...)"
```

**Copy this into** your Compose action in the designer.

### Key Expression Locations in SAP_Import_Complete.json:

- **Line 44-75**: All variable initializations
- **Line 248**: Exclusion check logic
- **Line 256**: Amount parsing
- **Line 264**: Transaction type (CN/DN)
- **Line 273-295**: Create transaction with all fields
- **Line 525-535**: Summary email HTML

### Key Expression Locations in Email_Engine_Complete.json:

- **Line 147-162**: Filter non-excluded transactions
- **Line 175-186**: Separate CN and DN
- **Line 188-202**: Calculate totals and net amount
- **Line 217-225**: FIFO logic and day count
- **Line 227-232**: Template selection
- **Line 234-240**: Email subject composition
- **Line 242-256**: Transaction table HTML
- **Line 258-268**: Email body HTML with conditional templates
- **Line 307-315**: Send email with QR attachment

---

## Connection Reference Mapping

If you do import JSON, you'll need to map connections. The JSON uses these logical names:

### SAP Import Flow:
```json
"nc_sharedsharepointonline_80205" → Your SharePoint connection
"new_sharedcommondataserviceforapps_7e300" → Your Dataverse connection
"nc_sharedexcelonlinebusiness_67d04" → Your Excel connection
"new_sharedoffice365_50b72" → Your Outlook connection
```

### Email Engine Flow:
```json
"new_sharedcommondataserviceforapps_7e300" → Your Dataverse connection
"nc_sharedsharepointonline_80205" → Your SharePoint connection
"new_sharedoffice365users_0fee9" → Your Office 365 Users connection
"new_sharedoffice365_50b72" → Your Outlook connection
```

Power Automate will prompt you to map these when you import.

---

## Testing Checklist

After importing (either method):

### SAP Import Flow:
- [ ] All variables initialized
- [ ] Get files action configured
- [ ] Process log creation works
- [ ] Excel parsing successful
- [ ] Customer lookup works
- [ ] Transaction creation works
- [ ] Error handling captures issues
- [ ] Summary email sent

### Email Engine Flow:
- [ ] Variables initialized
- [ ] Import completion check works
- [ ] Transaction filtering correct
- [ ] Customer loop processes
- [ ] FIFO calculation correct
- [ ] Email template selection works
- [ ] QR code attachment works
- [ ] Email sending successful
- [ ] Email log created
- [ ] Transaction records updated

---

## Troubleshooting

### Issue: "Invalid JSON"
**Solution**: Ensure you copied the entire file content, including opening `{` and closing `}`

### Issue: "Connection reference not found"
**Solution**: Power Automate will prompt to map connections. Select your authenticated connections from the dropdown.

### Issue: "Action validation failed"
**Solution**: Some field names may need adjustment based on your actual Dataverse schema. Check field names match exactly.

### Issue: "Expression error"
**Solution**: Power Automate expression syntax is strict. Ensure no line breaks in expressions.

---

## My Recommendation

**Don't import the JSON directly.** Instead:

1. ✅ Keep your existing skeleton flows
2. ✅ Use [README_Import_Instructions.md](README_Import_Instructions.md) to build step-by-step
3. ✅ Use the JSON files as **expression reference** when needed
4. ✅ Test each component as you build

**Why?**
- Safer (errors caught early)
- Easier to debug
- Better learning experience
- Connection references handled automatically

**The JSON files are still valuable** - they show you exactly what the complete flow should look like and provide ready-to-copy expressions.

---

## Quick Start

**Start here**:
1. Open `[THFinanceCashCollection] Daily SAP Transaction Import` in designer
2. Follow [README_Import_Instructions.md](README_Import_Instructions.md) Step 1
3. Add first variable: `varProcessDate`
4. Test it works
5. Continue adding actions one by one
6. Use JSON as reference for complex expressions

**Need help?** The JSON shows exactly what each action should look like!

---

**Status**: Complete JSON files created ✅
**Next Step**: Choose your import approach and start building
**Estimated Time**:
- Option A (JSON import): 30 min + 2 hours troubleshooting
- Option C (Builder guide): 1-2 hours, fewer errors
