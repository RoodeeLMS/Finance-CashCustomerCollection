# Generate-WorkingDayCalendar.ps1
# Generates WorkingDayCalendar CSV for import into Dataverse
# Date: January 10, 2026

param(
    [string]$OutputPath = ".\WorkingDayCalendar_2025-2027.csv",
    [datetime]$StartDate = "2025-01-01",
    [datetime]$EndDate = "2027-12-31"
)

Write-Host "Generating Working Day Calendar from $($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))..."

# Thai Public Holidays (2025-2027)
# Format: Array of dates that are holidays
$holidays = @(
    # 2025 Holidays (from documentation)
    "2025-01-01",  # New Year's Day
    "2025-02-12",  # Makha Bucha Day
    "2025-04-06",  # Chakri Memorial Day (Sunday - still marked)
    "2025-04-13",  # Songkran
    "2025-04-14",  # Songkran
    "2025-04-15",  # Songkran
    "2025-05-01",  # Labour Day
    "2025-05-04",  # Coronation Day (Sunday - still marked)
    "2025-05-12",  # Visakha Bucha Day
    "2025-06-03",  # Queen Suthida's Birthday
    "2025-07-21",  # Asarnha Bucha Day
    "2025-07-22",  # Buddhist Lent Day
    "2025-07-28",  # King's Birthday
    "2025-08-12",  # Queen's Birthday / Mother's Day
    "2025-10-13",  # King Bhumibol Memorial Day
    "2025-10-23",  # Chulalongkorn Day
    "2025-12-05",  # Father's Day
    "2025-12-10",  # Constitution Day
    "2025-12-31",  # New Year's Eve

    # 2026 Holidays (from Holiday2026.csv)
    "2026-01-01",  # New Year's Day
    "2026-01-02",  # Special Additional Holiday
    "2026-03-03",  # Makha Bucha Day
    "2026-04-06",  # Chakri Memorial Day
    "2026-04-13",  # Songkran
    "2026-04-14",  # Songkran
    "2026-04-15",  # Songkran
    "2026-05-01",  # Labour Day
    "2026-05-04",  # Coronation Day
    "2026-06-01",  # Visakha Bucha Day (substitute)
    "2026-06-03",  # Queen Suthida's Birthday
    "2026-07-28",  # King's Birthday
    "2026-07-29",  # Asarnha Bucha Day
    "2026-08-12",  # Queen's Birthday / Mother's Day
    "2026-10-13",  # King Bhumibol Memorial Day
    "2026-10-23",  # Chulalongkorn Day
    "2026-12-07",  # Father's Day (substitute for Dec 5)
    "2026-12-10",  # Constitution Day
    "2026-12-31",  # New Year's Eve

    # 2027 Holidays (estimated - update when official dates released)
    "2027-01-01",  # New Year's Day
    "2027-02-22",  # Makha Bucha Day (estimated)
    "2027-04-06",  # Chakri Memorial Day
    "2027-04-13",  # Songkran
    "2027-04-14",  # Songkran
    "2027-04-15",  # Songkran
    "2027-05-03",  # Labour Day (substitute - May 1 is Saturday)
    "2027-05-04",  # Coronation Day
    "2027-05-20",  # Visakha Bucha Day (estimated)
    "2027-06-03",  # Queen Suthida's Birthday
    "2027-07-19",  # Asarnha Bucha Day (estimated)
    "2027-07-28",  # King's Birthday
    "2027-08-12",  # Queen's Birthday / Mother's Day
    "2027-10-13",  # King Bhumibol Memorial Day
    "2027-10-25",  # Chulalongkorn Day (substitute - Oct 23 is Saturday)
    "2027-12-06",  # Father's Day (substitute - Dec 5 is Sunday)
    "2027-12-10",  # Constitution Day
    "2027-12-31"   # New Year's Eve
)

# Convert to hashtable for O(1) lookup
$holidaySet = @{}
foreach ($h in $holidays) {
    $holidaySet[$h] = $true
}

# Generate calendar data
$results = @()
$workingDayNumber = 0  # Will be incremented for first working day
$currentDate = $StartDate

while ($currentDate -le $EndDate) {
    $dateStr = $currentDate.ToString("yyyy-MM-dd")
    $dayOfWeek = $currentDate.DayOfWeek
    $year = $currentDate.Year

    # Check if working day
    $isWeekend = ($dayOfWeek -eq "Saturday") -or ($dayOfWeek -eq "Sunday")
    $isHoliday = $holidaySet.ContainsKey($dateStr)
    $isWorkingDay = (-not $isWeekend) -and (-not $isHoliday)

    # Assign working day number
    if ($isWorkingDay) {
        $workingDayNumber++
        $wdnValue = $workingDayNumber
    } else {
        $wdnValue = ""  # NULL for non-working days
    }

    # Create record
    $record = [PSCustomObject]@{
        cr7bb_name = $dateStr  # Primary column (Text) - uses date string
        cr7bb_calendardate = $dateStr
        cr7bb_isworkingday = if ($isWorkingDay) { "Yes" } else { "No" }
        cr7bb_workingdaynumber = $wdnValue
        cr7bb_year = $year
    }

    $results += $record
    $currentDate = $currentDate.AddDays(1)
}

# Export to CSV
$results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

# Summary
$totalDays = $results.Count
$workingDays = ($results | Where-Object { $_.cr7bb_isworkingday -eq "Yes" }).Count
$nonWorkingDays = $totalDays - $workingDays

Write-Host ""
Write-Host "=========================================="
Write-Host "Working Day Calendar Generated Successfully"
Write-Host "=========================================="
Write-Host "Output File: $OutputPath"
Write-Host "Date Range: $($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
Write-Host "Total Days: $totalDays"
Write-Host "Working Days: $workingDays"
Write-Host "Non-Working Days: $nonWorkingDays (weekends + holidays)"
Write-Host "Last Working Day Number: $workingDayNumber"
Write-Host ""
Write-Host "Year Breakdown:"

foreach ($y in 2025..2027) {
    $yearData = $results | Where-Object { $_.cr7bb_year -eq $y }
    $yearWorking = ($yearData | Where-Object { $_.cr7bb_isworkingday -eq "Yes" }).Count
    $firstWDN = ($yearData | Where-Object { $_.cr7bb_workingdaynumber -ne "" } | Select-Object -First 1).cr7bb_workingdaynumber
    $lastWDN = ($yearData | Where-Object { $_.cr7bb_workingdaynumber -ne "" } | Select-Object -Last 1).cr7bb_workingdaynumber
    Write-Host "  $y : $yearWorking working days (WDN $firstWDN - $lastWDN)"
}

Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Open the CSV in Excel to verify"
Write-Host "2. Import into Dataverse table: [THFinanceCashCollection]WorkingDayCalendar"
Write-Host "3. Use Power Apps Dataverse import or Power Automate flow"
