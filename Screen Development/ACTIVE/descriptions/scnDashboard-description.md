# Dashboard Screen Description

## Screen Name
`scnDashboard`

## Purpose
Main dashboard providing AR team with real-time overview of daily collections process status, key metrics, and recent activity.

## Data Source
**Microsoft Dataverse**

## Tables Used
1. `[THFinanceCashCollection]Process Logs` - Daily process execution logs
2. `[THFinanceCashCollection]Transactions` - Transaction records
3. `[THFinanceCashCollection]Emaillogs` - Email send logs
4. `[THFinanceCashCollection]Customers` - Customer master data

## Screen Layout

```
┌────────────────────────────────────────────────────────────────┐
│ ☰  Dashboard                                          [Role]   │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  TODAY'S PROCESS STATUS                                  │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │ │
│  │  │ SAP Import  │  │  FIFO Calc  │  │ Email Send  │      │ │
│  │  │  ✓ Complete │  │ ✓ Complete  │  │ ✓ Complete  │      │ │
│  │  │  08:30 AM   │  │  09:15 AM   │  │  10:00 AM   │      │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  KEY METRICS (Today)                                     │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐     │ │
│  │  │ Transactions │ │ Emails Sent  │ │ Failed Emails│     │ │
│  │  │     150      │ │      95      │ │      2       │     │ │
│  │  └──────────────┘ └──────────────┘ └──────────────┘     │ │
│  │                                                           │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐     │ │
│  │  │Total Amount  │ │  Excluded    │ │   Customers  │     │ │
│  │  │ ฿2,450,000   │ │      12      │ │      98      │     │ │
│  │  └──────────────┘ └──────────────┘ └──────────────┘     │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  RECENT PROCESS HISTORY (Last 7 Days)                   │ │
│  │  ┌────────┬──────────┬─────────┬────────┬─────────┐     │ │
│  │  │  Date  │ Trans.   │ Emails  │ Failed │ Amount  │     │ │
│  │  ├────────┼──────────┼─────────┼────────┼─────────┤     │ │
│  │  │2025-10-13│  150   │   95    │   2    │ ฿2.45M  │     │ │
│  │  │2025-10-12│  145   │   92    │   0    │ ฿2.38M  │     │ │
│  │  │2025-10-11│  148   │   94    │   1    │ ฿2.42M  │     │ │
│  │  └────────┴──────────┴─────────┴────────┴─────────┘     │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  QUICK ACTIONS                                           │ │
│  │  [ View Transactions ] [ View Emails ] [ Run Manual ]   │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Functional Requirements

### 1. Today's Process Status Section
**Data Source**: `[THFinanceCashCollection]Process Logs` filtered by today's date

**Display**:
- Three status cards showing:
  - **SAP Import**: Status (✓ Complete / ⏳ Running / ⚠️ Failed), completion time
  - **FIFO Calculation**: Status and time (inferred from SAP completion)
  - **Email Sending**: Status and time

**Status Logic**:
- **Complete**: `cr7bb_endtime` is not null
- **Running**: `cr7bb_starttime` is not null AND `cr7bb_endtime` is null
- **Failed**: No record exists for today OR email failures > 0

**Field Mapping**:
- Process Date: `cr7bb_processdate` (TEXT field, format "yyyy-mm-dd")
- Start Time: `cr7bb_starttime` (DateTime)
- End Time: `cr7bb_endtime` (DateTime)

### 2. Key Metrics Section
**Data Source**: Multiple queries for today's date

**Metrics**:
1. **Transactions**: Count from `[THFinanceCashCollection]Transactions` where `cr7bb_processdate = Text(Today(), "yyyy-mm-dd")`
2. **Emails Sent**: Count from `[THFinanceCashCollection]Emaillogs` where `DateValue(cr7bb_sentdatetime) = Today()`
3. **Failed Emails**: From Process Log `cr7bb_emailsfailed`
4. **Total Amount**: Sum of `cr7bb_amountlocalcurrency` from today's transactions (format: ฿#,##0)
5. **Excluded**: Count from Process Log `cr7bb_transactionsexcluded`
6. **Customers**: Count distinct `_cr7bb_customer_value` from today's email logs

**Formatting**:
- Currency: Thai Baht with "฿" symbol
- Large numbers: Use "K" for thousands, "M" for millions (e.g., ฿2.45M)

### 3. Recent Process History Table
**Data Source**: `[THFinanceCashCollection]Process Logs` for last 7 days

**Columns**:
1. **Date**: `cr7bb_processdate` (format: yyyy-mm-dd)
2. **Trans.**: `cr7bb_transactionsprocessed`
3. **Emails**: Count from email logs for that date
4. **Failed**: `cr7bb_emailsfailed`
5. **Amount**: Sum from transactions (abbreviated, e.g., ฿2.45M)

**Sort**: Descending by date (most recent first)

### 4. Quick Actions
**Buttons**:
1. **View Transactions**: Navigate to `scnTransactions`
2. **View Emails**: Navigate to `scnEmailMonitor`
3. **Run Manual**: Show options (Manual SAP Upload, Manual Email Resend)

## User Interactions

### On Screen Load (OnVisible)
```yaml
1. Set currentScreen = "Dashboard"
2. Load today's process log
3. Calculate today's metrics
4. Load last 7 days process history
5. Set refresh timer (auto-refresh every 60 seconds)
```

### Auto-Refresh Behavior
- Timer refreshes data every 60 seconds
- Show last refresh time in footer
- Animate metrics when values change

### Status Card Click Actions
- **SAP Import Card**: Show detailed import log
- **Email Sending Card**: Navigate to Email Monitor

## Navigation Menu Integration
- Include NavigationMenu component
- Set `navSelected: ="Dashboard"`

## Styling (Nestlé Brand)

### Colors
- **Status Cards**:
  - Complete: Green background `RGBA(0, 128, 0, 0.1)` with green icon
  - Running: Orange background `RGBA(255, 165, 0, 0.1)` with orange icon
  - Failed: Red background `RGBA(212, 41, 57, 0.1)` with red icon
- **Metric Cards**: White with Nestlé Blue border `RGBA(0, 101, 161, 1)`
- **Header**: Nestlé Blue `RGBA(0, 101, 161, 1)`

### Typography
- **Headers**: Size 20-24, Weight.Bold, Font.Lato
- **Metrics Numbers**: Size 32, Weight.Bold, Nestlé Blue
- **Labels**: Size 14, Weight.Semibold

## Data Refresh Strategy
1. **Initial Load**: OnVisible loads all data
2. **Auto Refresh**: Timer every 60 seconds
3. **Manual Refresh**: Pull-to-refresh gesture or refresh button

## Error Handling
- If no process log for today: Show "No process run today" message
- If metrics fail to load: Show "---" placeholder
- Network errors: Show error notification with retry button

## Performance Considerations
1. Use collections for metrics to avoid repeated queries
2. Cache process history (only refresh on timer)
3. Limit history table to 7 days max
4. Use `$select` to get only needed fields from Dataverse

## Special Notes

### Process Date is TEXT
**CRITICAL**: Process Log `cr7bb_processdate` is TEXT type, not Date.
- Filter: `cr7bb_processdate = Text(Today(), "yyyy-mm-dd")`
- NOT: `cr7bb_processdate = Today()` ❌

### Currency Display
Use `AmountFormatted` calculated column pattern:
```yaml
ClearCollect(
    colTodayTransactions,
    AddColumns(
        Filter('[THFinanceCashCollection]Transactions',
               cr7bb_processdate = Text(Today(), "yyyy-mm-dd")),
        AmountFormatted,
        "฿" & Text(cr7bb_amountlocalcurrency, "#,##0.00")
    )
)
```

## Validation Rules
- All date comparisons with Process Log must convert to TEXT format
- Currency amounts must use original field for Sum(), formatted column for display
- Email count must use `DateValue(cr7bb_sentdatetime)` for date comparison

## Dependencies
- NavigationMenu component (existing)
- Process Log data updated by SAP Import flow
- Email Log data updated by Email Sending flow
- Transaction data updated by SAP Import flow
