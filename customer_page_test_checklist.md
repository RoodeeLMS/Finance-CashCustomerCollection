# Customer Page Test Checklist

## Data Import Validation

### Customer Master Data Import
- [x] **Customer data file location**: `client docs/Example Data/CustomerMasterData.csv`
- [x] **Data structure verified**: 16 columns including Customer code, Name, Region, and multiple email fields
- [x] **Field mapping confirmed**: CSV headers match Dataverse cr7bb_ field names

### Expected Data Sample (First 3 Records)
| Customer Code | Customer Name | Region | Customer Email |
|---------------|---------------|---------|----------------|
| 200120 | Nakhonsawan NNP Distributor (2000) | NO | nakornsa.nnp@gmail.com |
| 1991089 | Chuenchomtaveesup Ltd.Part | NO | Chuenchomtaveerat_sup@hotmail.com |
| 4956439 | Bio Kamphaengphet Co.,Ltd. | NO | avika2011@hotmail.com |

## Power Apps Customer Page Test Plan

### 1. Data Source Connection Test
- [ ] Open Power Apps Studio
- [ ] Import the Customer page YAML from `templates/powerapps/scnCustomer.yaml`
- [ ] Verify data source connection to `[THFinanceCashCollection]Customers`
- [ ] Check for any connection errors or authentication issues

### 2. Table View Functionality Test
- [ ] **Basic Data Display**
  - [ ] Customer table loads without errors
  - [ ] All imported customers are visible (should show 100+ records)
  - [ ] Columns display correctly: Customer Code, Customer Name, Region, Email

- [ ] **Search Functionality**
  - [ ] Test search with customer code "200120" - should find Nakhonsawan NNP
  - [ ] Test search with partial name "Bio" - should find Bio Kamphaengphet
  - [ ] Test search with region "NO" - should show multiple Northern region customers
  - [ ] Clear search should show all customers again

### 3. Form Functionality Test
- [ ] **Add New Customer**
  - [ ] Click "Add Customer" button
  - [ ] Form appears with all input fields
  - [ ] Fill sample data and save
  - [ ] Verify new customer appears in table

- [ ] **Edit Existing Customer**
  - [ ] Select customer "200120" from table
  - [ ] Click "Edit" button
  - [ ] Form pre-populates with existing data
  - [ ] Modify customer name and save
  - [ ] Verify changes appear in table

- [ ] **Delete Customer**
  - [ ] Select a test customer from table
  - [ ] Click "Remove" button
  - [ ] Confirmation popup appears
  - [ ] Confirm deletion
  - [ ] Verify customer is removed from table

### 4. Navigation and UI Test
- [ ] **Header and Menu**
  - [ ] Header displays "Customer" title correctly
  - [ ] Menu icon toggles navigation menu
  - [ ] Navigation menu highlights "Customer" as active

- [ ] **Responsive Design**
  - [ ] Test on different screen sizes
  - [ ] Menu behavior changes appropriately
  - [ ] Form layouts adapt to screen size

### 5. Data Validation Test
- [ ] **Required Fields**
  - [ ] Try to save customer without Customer Code - should show validation error
  - [ ] Try to save customer without Customer Name - should show validation error
  - [ ] Try to save customer without primary email - should show validation error

- [ ] **Email Format Validation**
  - [ ] Enter invalid email format - should show validation error
  - [ ] Enter valid email format - should save successfully

### 6. Error Handling Test
- [ ] **Network Issues**
  - [ ] Test with poor network connection
  - [ ] Verify appropriate error messages display
  - [ ] Check data doesn't get corrupted

- [ ] **Dataverse Connection Issues**
  - [ ] Test with temporary Dataverse unavailability
  - [ ] Verify graceful error handling

## Expected Issues and Solutions

### Common Import Issues
1. **Data Source Not Found**: Ensure Dataverse table name is exactly `cr7bb_thfinancecashcollectioncustomers`
2. **Permission Errors**: Verify Canvas app has read/write permissions to Customer table
3. **Field Mapping Errors**: Double-check field names match exactly (case-sensitive)

### Performance Expectations
- **Table Load Time**: Should load 100+ customers within 3-5 seconds
- **Search Response**: Search results should appear within 1-2 seconds
- **Save Operations**: Customer save should complete within 2-3 seconds

## Success Criteria
- [ ] All 100+ customers from CSV are visible and accessible
- [ ] Search functionality works for code, name, and region
- [ ] CRUD operations (Create, Read, Update, Delete) all function properly
- [ ] No data corruption or connection errors
- [ ] UI is responsive and user-friendly
- [ ] Performance meets expected benchmarks

## Next Steps After Testing
1. **Dashboard Integration**: Connect customer data to main Dashboard
2. **Transaction Integration**: Link customers to their AR transaction data
3. **Email Template Integration**: Connect to automated email system
4. **Role-Based Access**: Test with different user permissions

---
*Test checklist created for Customer page validation with imported data*