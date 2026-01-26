# Arrear Days Calculation Logic

**Objective:** Calculate the number of "Work Days Past Due".
**Formula:** `Count(Days)` from `DueDate` to `CurrentDate` (exclusive of start, inclusive of end?)
**Exclusions:** Weekends (Sat, Sun) and Public Holidays.

## Algorithm

1.  **Inputs:**
    - `DueDate` (Date)
    - `ReferenceDate` (Date, usually Today)
    - `HolidayList` (Array of Dates)

2.  **Guards:**
    - If `ReferenceDate` <= `DueDate`: Return 0 (not Overdue).

3.  **Process:**
    - Initialize `ArrearDays = 0`
    - Initialize `CheckDate = DueDate + 1 day`
    - **Loop** while `CheckDate <= ReferenceDate`:
        - **Step A: Check Weekend**
            - If `DayOfWeek(CheckDate)` is Saturday or Sunday:
                - Skip (Do not increment ArrearDays)
        - **Step B: Check Holiday**
            - If `CheckDate` exists in `HolidayList`:
                - Skip (Do not increment ArrearDays)
        - **Step C: Increment**
            - If neither A nor B: `ArrearDays = ArrearDays + 1`
        - **Step D: Advance**
            - `CheckDate = CheckDate + 1 day`

4.  **Output:**
    - `ArrearDays` (Integer)

## Implementation in Power Automate

Since Power Automate loops can be slow for large date ranges, optimize by:
1.  **Pre-filtering Holidays:** Filter the holiday array to only include dates between DueDate and ReferenceDate. `Length(FilteredHolidays)`.
2.  **Calculate Weekdays:** Use a mathematical formula to calculate total weekdays between two dates.
    - `TotalDays = DateDiff(DueDate, ReferenceDate)`
    - `Weekends = (TotalDays / 7) * 2` + adjustment for start/end day of week.
    - `WorkingDays = TotalDays - Weekends`
3.  **Subtract Holidays:**
    - `FinalArrearDays = WorkingDays - Length(FilteredHolidays)`
    - *Note:* Ensure holidays falling on weekends aren't double-counted.

### Optimized Formula (No Loop)
`NetworkDays(DueDate, ReferenceDate)` [Excel-like logic]

**Power Automate Expression:**
(Variable `TotalBusinessDays`) - (Count of Holidays that are NOT Sat/Sun)

*Warning:* Power Automate does not have a native `NetworkDays` function.
**Recommendation:** Create a Child Flow that accepts `StartDate` and `EndDate` and returns the count, OR use an Azure Function / Custom Connector if performance is critical for thousands of rows. For small batches (<100), a simple loop or the optimization above is acceptable.
